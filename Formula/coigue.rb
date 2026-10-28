class Coigue < Formula
  desc "Small modal terminal editor with Scheme extensions"
  homepage "https://github.com/fclaude/coigue"
  if Hardware::CPU.arm?
    url "https://github.com/fclaude/coigue/releases/download/v0.2.3/coigue_0.2.3_darwin_arm64.tar.gz"
    sha256 "b916fe12324a8559dce915f7b75d9e656fcb3c73d6756f7640b1d5210faa9a64"
  else
    url "https://github.com/fclaude/coigue/releases/download/v0.2.3/coigue_0.2.3_darwin_amd64.tar.gz"
    sha256 "64a2e42905c35c4205dc05b3a0f806bcdc2215583f5537345ff8e1456484ee60"
  end
  license "MIT"
  revision 1

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
