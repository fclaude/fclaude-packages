cask "dinoscript" do
  arch arm: "arm64", intel: "amd64"

  version "0.7.0"
  sha256 arm:   "1fb41bc51bc10b207962cddfe69e7a971b98c18e512cb86ba5009baf8bb877c3",
         intel: "bc53ed3a98c31665bcf77a649fdf50cac2de2ed087e107abc4313737c728dfec"

  url "https://github.com/fclaude/dinoscript/releases/download/v#{version}/Dinoscript-#{arch}.dmg"
  name "Dinoscript"
  desc "Offline programming editor and illustrated coding lessons for kids"
  homepage "https://github.com/fclaude/dinoscript"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on macos: :ventura

  app "Dinoscript.app"

  caveats do
    <<~EOS
      This upstream release uses ad-hoc signing. macOS Gatekeeper may block
      its first launch.
    EOS
  end
end
