class Brote < Formula
  desc "Small embeddable Scheme interpreter and language server"
  homepage "https://github.com/fclaude/brote"
  if Hardware::CPU.arm?
    url "https://github.com/fclaude/brote/releases/download/v0.3.0/brote_0.3.0_darwin_arm64.tar.gz"
    sha256 "065b70376ceab4060834c8e576c68a7227a91bdd4a04991b58ad7c6c8f5a22b2"
  else
    url "https://github.com/fclaude/brote/releases/download/v0.3.0/brote_0.3.0_darwin_amd64.tar.gz"
    sha256 "719bba8461ef62d199b385f3e9c00d4ae928d05574f603e90bf1231cc87d3da7"
  end
  license "MIT"
  revision 1

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
