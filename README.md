# asdf-entire

[![Build](https://github.com/wasabeef/asdf-entire/actions/workflows/build.yml/badge.svg)](https://github.com/wasabeef/asdf-entire/actions/workflows/build.yml)
[![Lint](https://github.com/wasabeef/asdf-entire/actions/workflows/lint.yml/badge.svg)](https://github.com/wasabeef/asdf-entire/actions/workflows/lint.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://github.com/wasabeef/asdf-entire/blob/main/LICENSE)

[Entire CLI](https://github.com/entireio/cli) plugin for the [asdf version manager](https://asdf-vm.com). Also compatible with [mise](https://mise.jdx.dev).

## Install

### asdf

```shell
asdf plugin add entire https://github.com/wasabeef/asdf-entire.git
```

### mise

```shell
mise plugin install entire https://github.com/wasabeef/asdf-entire.git
```

## Usage

### List available versions

```shell
# asdf
asdf list all entire

# mise
mise ls-remote entire
```

### Install a specific version

```shell
# asdf
asdf install entire 0.5.2
asdf set entire 0.5.2

# mise
mise install entire@0.5.2
mise use entire@0.5.2
```

### Install the latest version

```shell
# asdf
asdf install entire latest
asdf set entire latest

# mise
mise install entire@latest
mise use entire@latest
```

### Verify

```shell
entire --version
```

## License

MIT
