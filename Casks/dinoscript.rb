cask "dinoscript" do
  arch arm: "arm64", intel: "amd64"

  version "0.1.0"
  sha256 arm:   "222dbefce8fc74924fcb869ffe71c0088603058c6802bf4adfb9ac5a101fded0",
         intel: "8385eb6e0e0f150d252797a2948b7917b690e9ef64de5056f1ce0dfc73a48efd"

  url "https://github.com/fclaude/dinoscript/releases/download/v#{version}/Dinoscript-#{arch}.dmg"
  name "Dinoscript"
  desc "Offline programming editor and illustrated coding lessons for kids"
  homepage "https://github.com/fclaude/dinoscript"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on :macos

  app "Dinoscript.app"

  caveats do
    <<~EOS
      This upstream release uses ad-hoc signing. macOS Gatekeeper may block
      its first launch.
    EOS
  end
end
