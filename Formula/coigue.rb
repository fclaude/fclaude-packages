class Coigue < Formula
  desc "Small modal terminal editor with Scheme extensions"
  homepage "https://github.com/fclaude/coigue"
  if Hardware::CPU.arm?
    url "https://github.com/fclaude/coigue/releases/download/v0.7.0/coigue_0.7.0_darwin_arm64.tar.gz"
    sha256 "449d1f924df7ab06ff7cd9b2e414047428e8f8945ce07e9aa582d01b2ca655f6"
  else
    url "https://github.com/fclaude/coigue/releases/download/v0.7.0/coigue_0.7.0_darwin_amd64.tar.gz"
    sha256 "51d72e52eff937c3fa97a284db2b04502ff0222bf4f8fb04d8c599a2649ebff6"
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
