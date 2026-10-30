class Nodwyn < Formula
  desc "Personal coding agent with a browser interface"
  homepage "https://github.com/fclaude/nodwyn"
  if Hardware::CPU.arm?
    url "https://github.com/fclaude/nodwyn/releases/download/v0.1.3/nodwyn-darwin-arm64.tar.gz"
    sha256 "0830e1d024af0ab07c3bf5fc0c8a4742febcca7bf1879529c24704f9bce11c2c"
  else
    url "https://github.com/fclaude/nodwyn/releases/download/v0.1.3/nodwyn-darwin-amd64.tar.gz"
    sha256 "695ee73726ebf7e616be95a718921db70ecef97dfba3c2fc56a7ea0672e05fbc"
  end
  license "Apache-2.0"

  livecheck do
    url :stable
    strategy :github_latest
  end

  depends_on :macos
  uses_from_macos "git"

  def install
    bin.install "nodwyn", "nodwyn-egress"
    doc.install "LICENSE", "NOTICE"
    (prefix/"Nodwyn.app/Contents/MacOS").mkpath
    (prefix/"Nodwyn.app/Contents/MacOS/nodwyn-app").write <<~SH
      #!/bin/sh
      exec "#{opt_bin}/nodwyn" app "$@"
    SH
    chmod 0755, prefix/"Nodwyn.app/Contents/MacOS/nodwyn-app"
    (prefix/"Nodwyn.app/Contents/Info.plist").write <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0"><dict>
        <key>CFBundleIdentifier</key><string>com.nodwyn.app</string>
        <key>CFBundleName</key><string>Nodwyn</string>
        <key>CFBundleExecutable</key><string>nodwyn-app</string>
        <key>CFBundlePackageType</key><string>APPL</string>
        <key>CFBundleShortVersionString</key><string>#{version}</string>
      </dict></plist>
    XML
  end

  def caveats
    <<~EOS
      Run nodwyn app to open the browser interface. This portable release
      has no native webview and does not start a background service on install.
      For a Dock launcher, link #{opt_prefix}/Nodwyn.app into ~/Applications.
      nodwyn-egress is a Linux executable for MCP containers, including on Mac.
    EOS
  end

  test do
    assert_equal "nodwyn f30399cc9762a38ac9fd47801e4e74ff762cf50a", shell_output("#{bin}/nodwyn version").strip
    assert_equal "\x7FELF".b, (bin/"nodwyn-egress").binread(4)
    assert_path_exists doc/"LICENSE"
    assert_path_exists doc/"NOTICE"
    assert_path_exists prefix/"Nodwyn.app/Contents/MacOS/nodwyn-app"
  end
end
