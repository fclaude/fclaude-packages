class Hoot < Formula
  desc "Terminal UI for reviewing Git changes alongside a coding agent"
  homepage "https://github.com/fclaude/hoot"
  url "https://github.com/fclaude/hoot/archive/7eee895dfc12cd84e23166b0363770f5590239ef.tar.gz"
  version "0.1.2"
  sha256 "c2cc8afab285eeba55e0da5e0ea86a23cee9942d99ce95a4f0312b09ce46ac69"
  license "MIT"

  livecheck do
    url "https://github.com/fclaude/hoot/releases/latest"
    strategy :github_latest
  end

  depends_on "rust" => :build
  depends_on "git"
  depends_on :macos

  def install
    system "cargo", "install", *std_cargo_args
    doc.install "README.md", "KEYBINDINGS.md", "LICENSE"
  end

  def caveats
    <<~EOS
      Run hoot in a Git repository, or use hoot --demo to explore it.
      Agent features require opencode or pi to be installed separately.
    EOS
  end

  test do
    assert_match "hoot #{version}", shell_output("#{bin}/hoot --version")
    assert_match "Quit", shell_output("#{bin}/hoot --print-keymap")
    assert_match "isn't a git repository", shell_output("#{bin}/hoot #{testpath} 2>&1", 1)
  end
end
