class Brote < Formula
  desc "Small embeddable Scheme interpreter and language server"
  homepage "https://github.com/fclaude/brote"
  if Hardware::CPU.arm?
    url "https://github.com/fclaude/brote/releases/download/v0.9.1/brote_0.9.1_darwin_arm64.tar.gz"
    sha256 "70dd26cfd351cf8b39803d7619f9e8c81f80981989791c978f8d19a159b08ffd"
  else
    url "https://github.com/fclaude/brote/releases/download/v0.9.1/brote_0.9.1_darwin_amd64.tar.gz"
    sha256 "e58d16fb77a28d1d0eead93ebfda8070633c27b6f06c945d6be87bc846bed6b0"
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
