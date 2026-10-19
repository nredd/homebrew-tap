class PiCodingAgent < Formula
  desc "AI agent toolkit with nredd transcript disclosures"
  homepage "https://github.com/nredd/pi"
  url "https://github.com/nredd/pi/releases/download/v1.3.0-nredd.6/earendil-works-pi-coding-agent-1.3.0.tgz"
  version "1.3.0-nredd.6"
  sha256 "0c1b9549cfed58c19f03b642cb259bf52f83beb1a339f154e5616c9b28c939b8"
  license "MIT"

  depends_on "node"

  resource "pi-tui" do
    url "https://github.com/nredd/pi/releases/download/v1.3.0-nredd.6/earendil-works-pi-tui-1.3.0.tgz"
    sha256 "dd8ac6c221bfd8e76fcc5b93418ba8feffd63dd705bde814aea6d4b1b46938e0"
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
    assert_equal "1.3.0", shell_output("#{bin}/pi --version 2>&1").strip
    assert_match "Usage:", shell_output("#{bin}/pi --help 2>&1")
  end
end
