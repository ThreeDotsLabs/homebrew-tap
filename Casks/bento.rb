cask "bento" do
  version "0.1.3"
  sha256 "1abc0a32b33eeac0e38ea8c0f45702e81d38c9da23f927e8f5c5a2f924833182"

  url "https://github.com/ThreeDotsLabs/homebrew-tap/releases/download/v#{version}/Bento-#{version}-arm64.zip"
  name "Bento"
  desc "Run coding agents side by side"
  homepage "https://github.com/ThreeDotsLabs/homebrew-tap"

  depends_on arch: :arm64
  depends_on macos: :monterey

  app "Bento.app"
  binary "#{appdir}/Bento.app/Contents/MacOS/bento"

  # No auto_updates: bento's Update button runs brew upgrade, which
  # skips casks that say they update themselves.
  # TODO: sign with a Developer ID and notarize, then drop this step.
  # The app is not notarized, so Gatekeeper would refuse the download.
  postflight_steps do
    run "/usr/bin/xattr", args: ["-rd", "com.apple.quarantine", "{{appdir}}/Bento.app"]
  end

  zap trash: "~/Library/Logs/bento"

  caveats <<~EOS
    The Private VM sandbox needs Lima: brew install lima
  EOS
end
