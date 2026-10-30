cask "nodwyn" do
  version "0.1.4"
  sha256 "fd1d917e082bb35dedbb827382a28935c14d2f07674da8a63b8ac90945220bd9"

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
      macOS Gatekeeper may block its first launch; open it once with
      right-click and Open. nodwyn-egress-linux-* inside the app are Linux
      executables for MCP containers.
    EOS
  end
end
