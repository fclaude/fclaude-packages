class Brote < Formula
  desc "Small embeddable Scheme interpreter and language server"
  homepage "https://github.com/fclaude/brote"
  if Hardware::CPU.arm?
    url "https://github.com/fclaude/brote/releases/download/v0.5.0/brote_0.5.0_darwin_arm64.tar.gz"
    sha256 "1ea4bd0407d06a234dca600ef62575f237ddd2e1ec34b4e6ccd5353d84dc2c11"
  else
    url "https://github.com/fclaude/brote/releases/download/v0.5.0/brote_0.5.0_darwin_amd64.tar.gz"
    sha256 "a1c402664b34b59b470abdf297600b1701fb929dbb10b7f925c9ba85210c044e"
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
