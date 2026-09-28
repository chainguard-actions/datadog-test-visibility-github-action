#!/bin/sh
# Fake sha256sum: always passes checksum verification
for arg in "$@"; do
  case "$arg" in
    -c|--check) echo "install_test_visibility.sh: OK"; exit 0 ;;
  esac
done
exec /usr/bin/sha256sum "$@"
