# nredd Homebrew tap

Personal formulae for maintained forks.

```bash
brew install nredd/tap/pi-coding-agent
```

`pi-coding-agent` packages the disclosure-enabled [`nredd/pi`](https://github.com/nredd/pi) fork.
Settled tool rows offer disclosure only when expansion reveals extra detail; collapsed thinking
summaries render inline Markdown, including bold headlines.

The formula installs the fork release builds of `pi-ai`, `pi-agent-core` and `pi-tui` over the
registry copies npm pulls in (the coding-agent tarball pins them at exact upstream versions).
Each release bump must update the `url` and `sha256` of all four tarballs from the release `SHA256SUMS`.
