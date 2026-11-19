class PiCodingAgent < Formula
  desc "AI agent toolkit with nredd transcript disclosures"
  homepage "https://github.com/nredd/pi"
  url "https://github.com/nredd/pi/releases/download/v1.3.0-nredd.13/earendil-works-pi-coding-agent-1.3.0.tgz"
  version "1.3.0-nredd.13"
  sha256 "17374c272841b6d688020d1b7b6fa8412afd59d45d4e9529075ea716cf5107e4"
  license "MIT"

  depends_on "node"

  resource "pi-agent-core" do
    url "https://github.com/nredd/pi/releases/download/v1.3.0-nredd.13/earendil-works-pi-agent-core-1.3.0.tgz"
    sha256 "c28b52160d62b902ff25322d10b279f97b7378f065d79ae8c1260f4e14246655"
  end

  resource "pi-ai" do
    url "https://github.com/nredd/pi/releases/download/v1.3.0-nredd.13/earendil-works-pi-ai-1.3.0.tgz"
    sha256 "b2a16082dcbb9e7895b186492c0a8220b2dae61cf0f715ec0f93f740dd563cf9"
  end

  resource "pi-tui" do
    url "https://github.com/nredd/pi/releases/download/v1.3.0-nredd.13/earendil-works-pi-tui-1.3.0.tgz"
    sha256 "882a979b8c26be39f5f63cf5f905b1ebe423ab48417b35e2812840e5654a2f57"
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
