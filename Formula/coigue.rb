class Coigue < Formula
  desc "Small modal terminal editor with Scheme extensions"
  homepage "https://github.com/fclaude/coigue"
  url "https://github.com/fclaude/coigue/archive/d01df859582b26493c84c7419985e6ce2ff7898b.tar.gz"
  version "0.2.3"
  sha256 "8538ff6e4a550548e4a8207a2277744d3936c656b4f489752a8165719e58819c"
  license "MIT"

  livecheck do
    url "https://github.com/fclaude/coigue/releases/latest"
    strategy :github_latest
  end

  depends_on "go" => :build
  depends_on :macos

  def install
    ldflags = %w[
      -s -w
      -X github.com/fclaude/coigue/internal/version.SourceCommit=d01df859582b26493c84c7419985e6ce2ff7898b
    ]
    system "go", "build", *std_go_args(ldflags:), "./cmd/coigue"
    doc.install "README.md", "LICENSE", "THIRD_PARTY_NOTICES.md"
  end

  def caveats
    <<~EOS
      Language servers are optional. For Scheme language support:
        brew install fclaude/tap/brote
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
