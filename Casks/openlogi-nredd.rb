cask "openlogi-nredd" do
  version "0.8.11-nredd.2"
  sha256 "377823cdb6f548ab3e83e0ea78929d87b84771427a0c6bae5ceba693be357d33"

  url "https://github.com/nredd/OpenLogi/releases/download/v#{version}/OpenLogi-v#{version}-macos-arm64.zip"
  name "OpenLogi (nredd fork)"
  desc "Local-first alternative to Logitech Options+, with phased horizontal thumb-wheel scroll"
  homepage "https://github.com/nredd/OpenLogi"

  # Ad-hoc signed, so there is no update feed to follow. Switch back to the stock cask once
  # AprilNEA/OpenLogi ships the phased horizontal scroll fix.
  conflicts_with cask: "openlogi"
  depends_on macos: ">= :ventura"
  depends_on arch: :arm64

  app "OpenLogi.app"
  binary "#{appdir}/OpenLogi.app/Contents/MacOS/openlogi", target: "openlogi"

  uninstall launchctl: "org.openlogi.agent.service",
            quit:      [
              "org.openlogi.agent",
              "org.openlogi.openlogi",
              "org.openlogi.overlay",
            ]

  zap trash: [
    "~/.config/openlogi",
    "~/.local/share/openlogi",
    "~/Library/Caches/org.openlogi.openlogi",
    "~/Library/Preferences/org.openlogi.openlogi.plist",
    "~/Library/Preferences/org.openlogi.overlay.plist",
    "~/Library/Saved Application State/org.openlogi.openlogi.savedState",
  ]

  caveats <<~EOS
    This build is ad-hoc signed. macOS treats it as a different app than the upstream
    Developer ID build, so grant Accessibility and Input Monitoring again after installing,
    and again after each new release.

    Gatekeeper blocks the first launch (the build is not notarized). In the dialog click
    "Done", not "Move to Trash", then System Settings > Privacy & Security > "Open Anyway".
    Afterwards enable OpenLogi and OpenLogi Agent in Login Items & Extensions.
  EOS
end
