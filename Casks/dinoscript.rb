cask "dinoscript" do
  arch arm: "arm64", intel: "amd64"

  version "0.5.1"
  sha256 arm:   "8e1b76490227bcdebbd1cf80d98f8afccc1d639d0736482eee61dcb05ab73fb6",
         intel: "b932906e35b234a72adcb514c262c1e9b14cee4ed9aa5b6471110cf1f9e9ca12"

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
