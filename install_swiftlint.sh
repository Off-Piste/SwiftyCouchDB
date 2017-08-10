#!/bin/bash

# Installs the SwiftLint package.
# Tries to get the precompiled .pkg file from Github, but if that
# fails just recompiles from source.

set -e

if which swiftlint >/dev/null; then
    brew upgrade swiftlint
    swiftlint
else
    echo "SwiftLint not installed, downloading from https://github.com/realm/SwiftLint"
    brew install swiftlint
    swiftlint
fi
