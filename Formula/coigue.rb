class Coigue < Formula
  desc "Small modal terminal editor with Scheme extensions"
  homepage "https://github.com/fclaude/coigue"
  if Hardware::CPU.arm?
    url "https://github.com/fclaude/coigue/releases/download/v0.5.2/coigue_0.5.2_darwin_arm64.tar.gz"
    sha256 "96b0787636446bebbcc8e3754df3ca627366df4de9c0566925b1d051868a01ad"
  else
    url "https://github.com/fclaude/coigue/releases/download/v0.5.2/coigue_0.5.2_darwin_amd64.tar.gz"
    sha256 "2035a4a4849dea34005e32af0478ec357ef70e1f5b45f45a6f3215af7e88aa80"
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
