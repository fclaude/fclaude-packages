cask "sqlite-explorer" do
  version "0.2.1"
  sha256 "8d471ef37d8e4d3c22cdaa91221156f1116655b48dcb157fb2d0ae4d0bd7fa21"

  url "https://github.com/fclaude/sqlite-explorer/releases/download/v#{version}/SQLite-Explorer-#{version}-universal-unsigned.dmg"
  name "SQLite Explorer"
  desc "Local desktop browser and editor for SQLite databases"
  homepage "https://github.com/fclaude/sqlite-explorer"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on macos: ">= :monterey"

  app "sqlite-explorer.app"

  caveats do
    <<~EOS
      This upstream release is ad-hoc signed and is not notarized by Apple.
      macOS Gatekeeper may block its first launch.
    EOS
  end
end
