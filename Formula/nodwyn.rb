class Nodwyn < Formula
  desc "Personal coding agent with a browser interface"
  homepage "https://github.com/fclaude/nodwyn"
  if Hardware::CPU.arm?
    url "https://github.com/fclaude/nodwyn/releases/download/v0.1.2/nodwyn-darwin-arm64.tar.gz"
    sha256 "2c53318a054847f0746f70b963cc02e7388695fb9731bc350e90cde286e35a0a"
  else
    url "https://github.com/fclaude/nodwyn/releases/download/v0.1.2/nodwyn-darwin-amd64.tar.gz"
    sha256 "72e639b43df4931208c0d1f66ba3b923bf3d1fb1bd425cac90ccabd1c1ea2cbd"
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
    assert_equal "nodwyn fa17298dc7f568d688dc5b9f85fa01a1c12aa010", shell_output("#{bin}/nodwyn version").strip
    assert_equal "\x7FELF".b, (bin/"nodwyn-egress").binread(4)
    assert_path_exists doc/"LICENSE"
    assert_path_exists doc/"NOTICE"
    assert_path_exists prefix/"Nodwyn.app/Contents/MacOS/nodwyn-app"
  end
end
