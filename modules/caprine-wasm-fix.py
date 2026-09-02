#!/usr/bin/env python3
"""Patch Caprine's app.asar to work around an Electron renderer crash (SIGSEGV).

Caprine's main window uses contextIsolation: true together with
nodeIntegration: true. The renderer therefore has a Node environment (needed by
Caprine's preload), which installs V8's isolate-wide WebAssembly streaming
callback, while the page itself lives in a separate main-world context that has
no Node environment. When Messenger calls WebAssembly.instantiateStreaming(),
node::wasm_web_api::StartStreamingCompilation() looks up that missing
environment and dereferences NULL, killing the renderer.

The fix replaces WebAssembly.{instantiate,compile}Streaming in the *main world*
with buffered equivalents, so the crashing callback is never reached. It is
injected into the preload (dist-js/browser.js) via webFrame.executeJavaScript,
which is what runs code in the main world when contextIsolation is on.

Rewriting the asar only touches the header and appends the new preload; every
existing file offset is relative to the data region and stays valid.
"""
import json
import struct
import sys

SHIM = r"""
// --- NixOS: WebAssembly streaming crash workaround (see caprine-wasm-fix.py) ---
try {
    require("electron").webFrame.executeJavaScript(`
(() => {
    if (typeof WebAssembly !== "object") return;
    const toBuffer = (source) => Promise.resolve(source).then((response) => response.arrayBuffer());
    WebAssembly.instantiateStreaming = (source, importObject) =>
        toBuffer(source).then((bytes) => WebAssembly.instantiate(bytes, importObject));
    WebAssembly.compileStreaming = (source) =>
        toBuffer(source).then((bytes) => WebAssembly.compile(bytes));
})();
`);
} catch (error) {
    console.error("[caprine-wasm-fix] could not install WebAssembly shim:", error);
}
// --- end workaround ---
"""

TARGET = ("dist-js", "browser.js")
ANCHOR = b'"use strict";\n'


def main(src_path, dst_path):
    with open(src_path, "rb") as handle:
        blob = handle.read()

    _, _, _, json_len = struct.unpack("<4I", blob[:16])
    header = json.loads(blob[16:16 + json_len].decode("utf8"))
    data_start = 16 + json_len
    data_start += (-data_start) % 4
    data = blob[data_start:]

    node = header["files"]
    for part in TARGET[:-1]:
        node = node[part]["files"]
    entry = node[TARGET[-1]]

    offset, size = int(entry["offset"]), int(entry["size"])
    original = data[offset:offset + size]
    if b"caprine-wasm-fix" in original:
        sys.exit("error: app.asar is already patched")
    if not original.startswith(ANCHOR):
        sys.exit("error: %s does not start with %r" % ("/".join(TARGET), ANCHOR))

    patched = ANCHOR + SHIM.encode("utf8") + original[len(ANCHOR):]

    # Append the new preload; offsets are relative to the data region, so moving
    # the header (which changes data_start) leaves every other entry valid.
    entry["offset"] = str(len(data))
    entry["size"] = len(patched)
    data += patched

    new_json = json.dumps(header, separators=(",", ":")).encode("utf8")
    pad = (-len(new_json)) % 4
    out = struct.pack(
        "<4I", 4, 8 + len(new_json) + pad, 4 + len(new_json) + pad, len(new_json)
    ) + new_json + b"\0" * pad + data

    with open(dst_path, "wb") as handle:
        handle.write(out)
    print("patched %s -> %s (preload %d -> %d bytes)" % (src_path, dst_path, size, len(patched)))


if __name__ == "__main__":
    if len(sys.argv) != 3:
        sys.exit("usage: caprine-wasm-fix.py <in.asar> <out.asar>")
    main(sys.argv[1], sys.argv[2])
