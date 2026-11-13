class PiCodingAgent < Formula
  desc "AI agent toolkit with nredd transcript disclosures"
  homepage "https://github.com/nredd/pi"
  url "https://github.com/nredd/pi/releases/download/v1.3.0-nredd.10/earendil-works-pi-coding-agent-1.3.0.tgz"
  version "1.3.0-nredd.10"
  sha256 "ac42b4317b85182065606cc8a526ec157f4c950a7b74f3410eed110a22bf8903"
  license "MIT"

  depends_on "node"

  resource "pi-agent-core" do
    url "https://github.com/nredd/pi/releases/download/v1.3.0-nredd.10/earendil-works-pi-agent-core-1.3.0.tgz"
    sha256 "1e714468b1cd0a05ff7aed322c7173bedc6edbf016ed061478c62b545bce3022"
  end

  resource "pi-ai" do
    url "https://github.com/nredd/pi/releases/download/v1.3.0-nredd.10/earendil-works-pi-ai-1.3.0.tgz"
    sha256 "c83fa27ce06da978f532f409832c7fc111707c7ffbf19086795ddfaa88f97410"
  end

  resource "pi-tui" do
    url "https://github.com/nredd/pi/releases/download/v1.3.0-nredd.10/earendil-works-pi-tui-1.3.0.tgz"
    sha256 "4f1e74a43649fd2024ad7f5ba1f6ed5efa651df024caad1a60f0d4875be58201"
  end

  def install
    system "npm", "install", *std_npm_args, "--min-release-age=0"
    (bin/"pi").write_env_script libexec/"bin/pi", PI_SKIP_VERSION_CHECK: "1"

    node_modules = libexec/"lib/node_modules/@earendil-works/pi-coding-agent/node_modules/"
    # The coding-agent tarball pins these at exact upstream versions, so npm installs the
    # registry builds. Replace them with the fork release assets.
    %w[pi-agent-core pi-ai pi-tui].each do |name|
      resource(name).stage do
        destination = node_modules/"@earendil-works"/name
        rm_r destination
        mkdir_p destination
        cp_r Pathname(".").children, destination
      end
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

    # Each fork release asset must have replaced its registry build. Compare a dist file that
    # carries real fork changes (not the manifest, which differs only incidentally), so a
    # dropped or misplaced stage fails byte comparison.
    node_modules = libexec/"lib/node_modules/@earendil-works/pi-coding-agent/node_modules/@earendil-works"
    fork_files = {
      "pi-agent-core" => "dist/agent-loop.js",
      "pi-ai"         => "dist/api/openai-responses-shared.js",
      "pi-tui"        => "dist/tui.js",
    }
    fork_files.each do |name, file|
      resource(name).stage do
        assert_equal Pathname(file).read, (node_modules/name/file).read,
                     "#{name} #{file} was not replaced by the fork release asset"
      end
    end
  end
end
