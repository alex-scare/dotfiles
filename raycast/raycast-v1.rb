cask "raycast-v1" do
  arch arm: "arm", intel: "x86_64"

  version "1.104.25"
  sha256 arm:   "972f6de210ffcacfa1feee095b8a30c7eeb972e914c876f65d37d218354a7067",
         intel: "754c3e367b88b52d7ccb17ae7a56653419616e008f1e002d0761a39c68adc19d"

  url "https://releases.raycast.com/releases/#{version}/download?build=#{arch}"
  name "Raycast"
  desc "Control your tools with a few keystrokes"
  homepage "https://raycast.com/"

  auto_updates true
  depends_on macos: :ventura

  app "Raycast.app"

  uninstall quit:       "com.raycast.macos",
            login_item: "Raycast"
  zap trash: [
    "~/.config/raycast",
    "~/Library/Application Scripts/com.raycast.macos.BrowserExtension",
    "~/Library/Application Support/com.raycast.macos",
    "~/Library/Caches/com.raycast.macos",
    "~/Library/Caches/SentryCrash/Raycast",
    "~/Library/Containers/com.raycast.macos.BrowserExtension",
    "~/Library/Cookies/com.raycast.macos.binarycookies",
    "~/Library/HTTPStorages/com.raycast.macos",
    "~/Library/Preferences/com.raycast.macos.plist",
    "~/Library/WebKit/com.raycast.macos",
  ]
end
