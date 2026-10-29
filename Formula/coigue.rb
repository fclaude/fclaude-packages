class Coigue < Formula
  desc "Small modal terminal editor with Scheme extensions"
  homepage "https://github.com/fclaude/coigue"
  if Hardware::CPU.arm?
    url "https://github.com/fclaude/coigue/releases/download/v0.5.0/coigue_0.5.0_darwin_arm64.tar.gz"
    sha256 "44b8cb7544e093f52cfe022a2d73edcc589cb42e320ba6ebb00882e4fa9e0f5f"
  else
    url "https://github.com/fclaude/coigue/releases/download/v0.5.0/coigue_0.5.0_darwin_amd64.tar.gz"
    sha256 "efa34fffedf83553fe3e243c810e9ef68edf32ee90ea400dce8445c6256ad511"
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
