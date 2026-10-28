class Brote < Formula
  desc "Small embeddable Scheme interpreter and language server"
  homepage "https://github.com/fclaude/brote"
  url "https://github.com/fclaude/brote/archive/ad0da5b6e99c942221ff8c7b1bdc239921a95dcb.tar.gz"
  version "0.3.0"
  sha256 "a4e75532315cff6cc82dbfefd0c50f808d76c36ba33a5cb8af43f8c7184a74c8"
  license "MIT"

  livecheck do
    url "https://github.com/fclaude/brote/releases/latest"
    strategy :github_latest
  end

  depends_on "go" => :build
  depends_on :macos

  def install
    ldflags = "-s -w -X github.com/fclaude/brote/version.SourceCommit=ad0da5b6e99c942221ff8c7b1bdc239921a95dcb"
    system "go", "build", *std_go_args(ldflags:), "./cmd/brote"
    system "go", "build", *std_go_args(output: bin/"brote-lsp", ldflags:), "./cmd/brote-lsp"
    doc.install "README.md", "LICENSE"
  end

  test do
    assert_equal "42", shell_output("#{bin}/brote -e '(+ 20 22)'").strip
    assert_match version.to_s, shell_output("#{bin}/brote-lsp --version")

    require "json"
    messages = [
      { jsonrpc: "2.0", id: 1, method: "initialize", params: {} },
      { jsonrpc: "2.0", id: 2, method: "shutdown" },
      { jsonrpc: "2.0", method: "exit" },
    ]
    input = messages.map do |message|
      body = JSON.generate(message)
      "Content-Length: #{body.bytesize}\r\n\r\n#{body}"
    end.join
    assert_match '"name":"brote-lsp"', pipe_output("#{bin}/brote-lsp", input, 0)
  end
end
