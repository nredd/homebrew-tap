class PiCodingAgent < Formula
  desc "AI agent toolkit with nredd transcript disclosures"
  homepage "https://github.com/nredd/pi"
  url "https://github.com/nredd/pi/releases/download/v0.87.2/earendil-works-pi-coding-agent-0.87.2.tgz"
  sha256 "26d5c17b5be93a9a303ba6082a4039da272e27dad265ddb8f29eeebebeafcee2"
  license "MIT"

  depends_on "node"

  resource "pi-tui" do
    url "https://github.com/nredd/pi/releases/download/v0.87.2/earendil-works-pi-tui-0.87.2.tgz"
    sha256 "90d5cfefbcd7394747b8343169ed5eb4e541565a202a1f3a94c223d7b30b2779"
  end

  def install
    system "npm", "install", *std_npm_args, "--min-release-age=0"
    (bin/"pi").write_env_script libexec/"bin/pi", PI_SKIP_VERSION_CHECK: "1"

    node_modules = libexec/"lib/node_modules/@earendil-works/pi-coding-agent/node_modules/"
    resource("pi-tui").stage do
      tui_destination = node_modules/"@earendil-works/pi-tui"
      rm_r tui_destination
      mkdir_p tui_destination
      cp_r Pathname(".").children, tui_destination
    end

    arch = Hardware::CPU.arm? ? "arm64" : "x64"
    os = OS.linux? ? "linux" : "darwin"
    node_modules.glob("koffi/build/koffi/*").each do |dir|
      basename = dir.basename.to_s
      rm_r(dir) if basename != "#{os}_#{arch}"
    end

    node_modules.glob("@earendil-works/pi-tui/native/**/prebuilds/*").each do |dir|
      basename = dir.basename.to_s
      rm_r(dir) if basename != "#{os}-#{arch}"
    end
  end

  test do
    assert_equal "0.87.2", shell_output("#{bin}/pi --version 2>&1").strip
    assert_match "Usage:", shell_output("#{bin}/pi --help 2>&1")
  end
end
