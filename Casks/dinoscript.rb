cask "dinoscript" do
  arch arm: "arm64", intel: "amd64"

  version "0.2.2"
  sha256 arm:   "402c563515958a4039fec82ab6a906316b09b17d058b49afd2f299093d867903",
         intel: "a8cf96e7db629507dc3792063fd26b937b1008a9ff96e52712e0f70f401cbea0"

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
