cask "bento" do
  version "0.1.0"
  sha256 "9e36c9f2b2d666ec00913524d65f033ef3122d89d0f0bc53175b378c5875a6b5"

  url "https://github.com/ThreeDotsLabs/homebrew-tap/releases/download/v#{version}/Bento-#{version}-arm64.zip"
  name "Bento"
  desc "Run coding agents side by side"
  homepage "https://github.com/ThreeDotsLabs/homebrew-tap"

  depends_on arch: :arm64
  depends_on macos: :monterey

  app "Bento.app"
  binary "#{appdir}/Bento.app/Contents/MacOS/bento"

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
