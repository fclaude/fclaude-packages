class Coigue < Formula
  desc "Small modal terminal editor with Scheme extensions"
  homepage "https://github.com/fclaude/coigue"
  if Hardware::CPU.arm?
    url "https://github.com/fclaude/coigue/releases/download/v0.4.0/coigue_0.4.0_darwin_arm64.tar.gz"
    sha256 "8b4dc33c701caf9c8c009cff33f8699d819eb9e5926afa7d8aa6cdc179525e4a"
  else
    url "https://github.com/fclaude/coigue/releases/download/v0.4.0/coigue_0.4.0_darwin_amd64.tar.gz"
    sha256 "ed8d2fb3fbc946f653e2711d9fcde14c13691cadd56feb334142e4dc91744352"
  end
  license "MIT"

  livecheck do
    url :stable
    strategy :github_latest
  end

  depends_on :macos

  def install
    bin.install "coigue"
    doc.install "LICENSE", "THIRD_PARTY_NOTICES.md"
  end

  def caveats
    <<~EOS
      Language servers are optional. For Scheme language support:
        brew install fclaude/fclaude-packages/brote
      Brote's interpreter is embedded in Coigüe; a separate interpreter
      installation is only needed for standalone use or brote-lsp.
    EOS
  end

  test do
    assert_match "coigue #{version}", shell_output("#{bin}/coigue --version")
    assert_match "Usage: coigue [FILE]", shell_output("#{bin}/coigue --help")
    assert_path_exists doc/"THIRD_PARTY_NOTICES.md"
  end
end
