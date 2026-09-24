class PiCodingAgent < Formula
  desc "AI agent toolkit with nredd transcript disclosures"
  homepage "https://github.com/nredd/pi"
  url "https://github.com/nredd/pi/releases/download/v0.87.1-nredd.2/earendil-works-pi-coding-agent-0.87.1.tgz"
  version "0.87.1-nredd.2"
  sha256 "52e47453296d17e94d32d819dac16c0b7dd31b80db1b025d2eb653677d1d669d"
  license "MIT"

  depends_on "node"

  resource "pi-tui" do
    url "https://github.com/nredd/pi/releases/download/v0.87.1-nredd.2/earendil-works-pi-tui-0.87.1.tgz"
    sha256 "feeba0107b09cfed4ea77dab0711bcb53e28b1d80b3ae100cd15134ec2a834a7"
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
    assert_equal "0.87.1", shell_output("#{bin}/pi --version 2>&1").strip
    assert_match "Usage:", shell_output("#{bin}/pi --help 2>&1")
  end
end
