class Brote < Formula
  desc "Small embeddable Scheme interpreter and language server"
  homepage "https://github.com/fclaude/brote"
  if Hardware::CPU.arm?
    url "https://github.com/fclaude/brote/releases/download/v0.9.0/brote_0.9.0_darwin_arm64.tar.gz"
    sha256 "974eed6146f6a04591dba8a72e61282980aa4ce5a2c7f6b041900330d1984c41"
  else
    url "https://github.com/fclaude/brote/releases/download/v0.9.0/brote_0.9.0_darwin_amd64.tar.gz"
    sha256 "ffe276109c075bb22814ae8de1dacb44609537a3375c29be9227203f0df9ab03"
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
