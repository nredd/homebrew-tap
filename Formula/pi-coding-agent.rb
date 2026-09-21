class PiCodingAgent < Formula
  desc "AI agent toolkit with nredd transcript disclosures"
  homepage "https://github.com/nredd/pi"
  url "https://github.com/nredd/pi/releases/download/v0.85.1-nredd.5/earendil-works-pi-coding-agent-0.85.1.tgz"
  version "0.85.1-nredd.5"
  sha256 "f5d6529497bc3bbf05eff9ce6471c9200ddd8d369211212d3b080487b85d989e"
  license "MIT"

  depends_on "node"

  on_macos do
    depends_on "rust" => :build

    resource "clipboard" do
      url "https://registry.npmjs.org/@mariozechner/clipboard/-/clipboard-0.3.9.tgz"
      sha256 "25986ebeecaffadf3d1dd5f9199869057e4b64c37d7069c7f31c231dd86b5639"
    end
  end

  resource "pi-tui" do
    url "https://github.com/nredd/pi/releases/download/v0.85.1-nredd.5/earendil-works-pi-tui-0.85.1.tgz"
    sha256 "7c46f8fb0290d261095289e3adbe5a9cfc6da5ba0183df56aee62173671a235d"
  end

  def install
    system "npm", "install", *std_npm_args
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

    return unless OS.mac?

    # Rebuild as the npm prebuilt lacks Mach-O header space to relocate install names for bottling.
    resource("clipboard").stage do
      system "cargo", "build", "--lib", "--release"
      cp "target/release/libcrosscopy_clipboard.dylib",
         node_modules/"@mariozechner/clipboard-darwin-universal/clipboard.darwin-universal.node"
    end
  end

  test do
    assert_equal "0.85.1", shell_output("#{bin}/pi --version 2>&1").strip
    assert_match "Usage:", shell_output("#{bin}/pi --help 2>&1")
  end
end
