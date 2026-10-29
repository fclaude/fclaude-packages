class Brote < Formula
  desc "Small embeddable Scheme interpreter and language server"
  homepage "https://github.com/fclaude/brote"
  if Hardware::CPU.arm?
    url "https://github.com/fclaude/brote/releases/download/v0.8.0/brote_0.8.0_darwin_arm64.tar.gz"
    sha256 "d27359c8f50cc2003804eb38b1f37e98bbb0fb8b3fc0d577027972dd7e92d993"
  else
    url "https://github.com/fclaude/brote/releases/download/v0.8.0/brote_0.8.0_darwin_amd64.tar.gz"
    sha256 "e04403731f52f4ffc6111f3a2d62d111cd12c6b5cadb4ce9c4c6c811ee7b2446"
  end
  license "MIT"

  livecheck do
    url :stable
    strategy :github_latest
  end

  depends_on :macos

  def install
    bin.install "brote", "brote-lsp"
    doc.install "LICENSE"
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
