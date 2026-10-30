cask "nodwyn" do
  version "0.1.5"
  sha256 "45c50de3d4dbf4d946b73a18839fa94179432b2d4394f6b9af2e27abdf67d8bb"

  url "https://github.com/fclaude/nodwyn/releases/download/v#{version}/Nodwyn-macos-universal.zip"
  name "Nodwyn"
  desc "Personal coding agent with its own window"
  homepage "https://github.com/fclaude/nodwyn"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on macos: :ventura

  app "Nodwyn.app"
  # nodwyn finds its egress helper beside the executable it was started as,
  # so the command runs the app's own copy by its path rather than a symlink.
  binary "#{staged_path}/nodwyn.wrapper.sh", target: "nodwyn"

  preflight_steps do
    write_file "nodwyn.wrapper.sh", <<~EOS
      #!/bin/sh
      exec '{{appdir}}/Nodwyn.app/Contents/MacOS/nodwyn' "$@"
    EOS
  end

  caveats do
    <<~EOS
      This upstream release is ad-hoc signed and is not notarized by Apple.
      macOS Gatekeeper refuses its first launch, and until it is allowed the
      nodwyn command is killed (exit 137). Open Nodwyn once, choose Done, then
      click Open Anyway beside it in System Settings > Privacy & Security.
      Right-click and Open no longer does this since macOS 15, and a new
      version may ask again. nodwyn-egress-linux-* inside the app are Linux
      executables for MCP containers.
    EOS
  end
end
