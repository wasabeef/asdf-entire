#!/usr/bin/env bash

set -euo pipefail

GH_REPO="https://github.com/entireio/cli"
TOOL_NAME="entire"
TOOL_TEST="entire --version"

fail() {
	echo -e "\033[31masdf-$TOOL_NAME: $*\033[39m" >&2
	exit 1
}

msg() {
	echo -e "\033[32m$1\033[39m" >&2
}

curl_opts=(-fsSL)

# Support both GITHUB_API_TOKEN and GITHUB_TOKEN (GitHub Actions standard)
github_token="${GITHUB_API_TOKEN:-${GITHUB_TOKEN:-}}"
if [ -n "$github_token" ]; then
	curl_opts=("${curl_opts[@]}" -H "Authorization: token $github_token")
fi

sort_versions() {
	sed 'h; s/[+-]/./g; s/.p\([[:digit:]]\)/.z\1/; s/$/.z/; G; s/\n/ /' |
		LC_ALL=C sort -t. -k 1,1 -k 2,2n -k 3,3n -k 4,4n -k 5,5n | awk '{print $2}'
}

list_github_tags() {
	git ls-remote --tags --refs "$GH_REPO" |
		grep -o 'refs/tags/.*' | cut -d/ -f3- |
		sed 's/^v//'
}

list_all_versions() {
	list_github_tags
}

get_platform() {
	local platform
	platform="$(uname | tr '[:upper:]' '[:lower:]')"

	case "$platform" in
	linux | darwin) ;;
	*)
		fail "Platform '$platform' not supported!"
		;;
	esac

	printf "%s" "$platform"
}

get_arch() {
	local arch
	local arch_check="${ASDF_ENTIRE_OVERWRITE_ARCH:-$(uname -m)}"

	case "$arch_check" in
	x86_64 | amd64) arch="amd64" ;;
	aarch64 | arm64) arch="arm64" ;;
	*)
		fail "Architecture '$arch_check' not supported!"
		;;
	esac

	printf "%s" "$arch"
}

get_download_url() {
	local version="$1"
	local platform
	local arch
	platform="$(get_platform)"
	arch="$(get_arch)"

	echo "$GH_REPO/releases/download/v${version}/entire_${platform}_${arch}.tar.gz"
}

get_checksum_url() {
	local version="$1"
	echo "$GH_REPO/releases/download/v${version}/checksums.txt"
}

download_release() {
	local version="$1"
	local filename="$2"
	local url

	url="$(get_download_url "$version")"

	msg "Downloading $TOOL_NAME release $version..."
	curl "${curl_opts[@]}" -o "$filename" "$url" || fail "Could not download $url"
}

verify_checksum() {
	local archive_path="$1"
	local version="$2"
	local checksum_url
	local checksum_file
	local expected_checksum
	local archive_filename

	checksum_url="$(get_checksum_url "$version")"
	checksum_file="$(dirname "$archive_path")/checksums.txt"
	archive_filename="$(basename "$archive_path")"

	msg "Downloading checksums..."
	curl "${curl_opts[@]}" -o "$checksum_file" "$checksum_url" || fail "Could not download checksums"

	expected_checksum="$(grep "  ${archive_filename}$" "$checksum_file" | awk '{print $1}')"
	if [ -z "$expected_checksum" ]; then
		fail "Could not find checksum for $archive_filename"
	fi

	msg "Verifying checksum..."
	if command -v sha256sum >/dev/null 2>&1; then
		sha256sum -c <(echo "$expected_checksum  $archive_path") >/dev/null 2>&1 ||
			fail "Checksum verification failed!"
	elif command -v shasum >/dev/null 2>&1; then
		shasum -a 256 -c <(echo "$expected_checksum  $archive_path") >/dev/null 2>&1 ||
			fail "Checksum verification failed!"
	else
		fail "sha256sum or shasum is not available"
	fi

	msg "Checksum verified!"
	rm -f "$checksum_file"
}

install_version() {
	local install_type="$1"
	local version="$2"
	local install_path="${3%/bin}/bin"

	if [ "$install_type" != "version" ]; then
		fail "asdf-$TOOL_NAME supports release installs only"
	fi

	mkdir -p "$install_path"

	trap 'rm -rf "$install_path"' ERR

	cp "$ASDF_DOWNLOAD_PATH/$TOOL_NAME" "$install_path/$TOOL_NAME"
	chmod +x "$install_path/$TOOL_NAME"

	local tool_cmd
	tool_cmd="$(echo "$TOOL_TEST" | cut -d' ' -f1)"
	test -x "$install_path/$tool_cmd" || fail "Expected $install_path/$tool_cmd to be executable."

	trap - ERR
	msg "$TOOL_NAME $version installation was successful!"
}
