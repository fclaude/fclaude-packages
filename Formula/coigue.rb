class Coigue < Formula
  desc "Small modal terminal editor with Scheme extensions"
  homepage "https://github.com/fclaude/coigue"
  if Hardware::CPU.arm?
    url "https://github.com/fclaude/coigue/releases/download/v0.3.0/coigue_0.3.0_darwin_arm64.tar.gz"
    sha256 "59f7e4fd0b8f0e9b89048740558369f01b8bad1ad9309d743816bc5a0ed30025"
  else
    url "https://github.com/fclaude/coigue/releases/download/v0.3.0/coigue_0.3.0_darwin_amd64.tar.gz"
    sha256 "49a295a14f402ac9538abfde50caad61048811a87a8f8c828e9b2093b0ee6eef"
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
