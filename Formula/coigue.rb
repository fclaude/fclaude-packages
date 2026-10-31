class Coigue < Formula
  desc "Small modal terminal editor with Scheme extensions"
  homepage "https://github.com/fclaude/coigue"
  if Hardware::CPU.arm?
    url "https://github.com/fclaude/coigue/releases/download/v0.6.1/coigue_0.6.1_darwin_arm64.tar.gz"
    sha256 "d83881ec88df9059cc3b5902ad4551caabeb43bf8dbebec579d12e3ee965360f"
  else
    url "https://github.com/fclaude/coigue/releases/download/v0.6.1/coigue_0.6.1_darwin_amd64.tar.gz"
    sha256 "9de6f3df603aa2e2e8700e3eb722abece74e92663ef97ef601c4d6147f9a7dba"
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
