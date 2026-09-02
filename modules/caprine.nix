# Caprine's renderer process dies with SIGSEGV inside
# node::wasm_web_api::StartStreamingCompilation() a few seconds after launch,
# which shows up as Caprine crashing on startup.
#
# Caprine's main window sets contextIsolation = true together with
# nodeIntegration = true. nodeIntegration keeps the renderer unsandboxed so
# Caprine's preload can use Node, and that makes Node install V8's isolate-wide
# WebAssembly streaming callback. contextIsolation puts the Messenger page in a
# separate main-world context which has no Node environment, so as soon as
# Messenger calls WebAssembly.instantiateStreaming() that callback looks up the
# missing environment and dereferences NULL.
#
# Every webPreferences combination that keeps Caprine's preload working also
# keeps the crash (sandboxing the renderer fixes the crash but strips Node from
# the preload). So instead we replace WebAssembly.{instantiate,compile}Streaming
# in the main world with buffered equivalents, and the crashing callback is
# never reached. See ./caprine-wasm-fix.py for the injection details.
#
# This can be dropped once Electron/Node null-check the environment there.

{ ... }:

{
  nixpkgs.overlays = [
    (final: prev: {
      caprine = final.runCommand "caprine-${prev.caprine.version}"
        {
          nativeBuildInputs = [ final.python3 ];
          inherit (prev.caprine) meta;
        }
        ''
          # Preserve modes (bin/caprine must stay executable), just add +w.
          cp -r ${prev.caprine} $out
          chmod -R u+w $out

          python3 ${./caprine-wasm-fix.py} \
            ${prev.caprine}/share/caprine/resources/app.asar \
            $out/share/caprine/resources/app.asar

          # bin/caprine points Electron at the unpatched app.asar.
          substituteInPlace $out/bin/caprine \
            --replace-fail ${prev.caprine} $out
        '';
    })
  ];
}
