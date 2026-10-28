class Hoot < Formula
  desc "Terminal UI for reviewing Git changes alongside a coding agent"
  homepage "https://github.com/fclaude/hoot"
  if Hardware::CPU.arm?
    url "https://github.com/fclaude/hoot/releases/download/v0.1.2/hoot-v0.1.2-aarch64-apple-darwin.tar.gz"
    sha256 "ee39e89a5af72d60f1becf2e7882ef82cc82e5d9ded7e9a1626eb27e2d482c87"
  else
    url "https://github.com/fclaude/hoot/releases/download/v0.1.2/hoot-v0.1.2-x86_64-apple-darwin.tar.gz"
    sha256 "72f98ffc9496171a979fcad57654711cb51a1d4b282ef9e2cd95c13afb6a9150"
  end
  license "MIT"
  revision 1

  livecheck do
    url :stable
    strategy :github_latest
  end

  depends_on :macos

  uses_from_macos "git"

  def install
    bin.install "hoot"
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
