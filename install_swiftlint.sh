#!/bin/bash

# Installs the SwiftLint package.
# Tries to get the precompiled .pkg file from Github, but if that
# fails just recompiles from source.

set -o pipefail
set -e

source_root="$(dirname "$0")"

# XCPRETTY_PARAMS="-f `xcpretty-travis-formatter`"
# XCODE_TESTS_PARAMS="-project $source_root/SwiftyCouchDB.xcodeproj -scheme SwiftyCouchDBTests"

function downloadSwiftlint {
    if which swiftlint >/dev/null; then
        echo "SwiftLint is installed"
        brew outdated swiftlint || brew upgrade swiftlint
    else
        echo "SwiftLint not installed, downloading via homebrew"
        brew install swiftlint
    fi
}

function runSwiftlint {
    echo "Running SwiftLint"
    swiftlint
}

function runTests {
    echo "Running Tests"
    xcodebuild clean build test -project $source_root/SwiftyCouchDB.xcodeproj -scheme SwiftyCouchDBTests | xcpretty -f `xcpretty-travis-formatter`
}

function downloadHelperCode {
  gem install xcpretty --no-rdoc --no-ri --no-document --quiet;  gem install xcpretty-travis-formatter --no-rdoc --no-ri --no-document --quiet
}

function createXcode {
    echo "Building Swift"
    swift build

    echo "Generating Package"
    swift package generate-xcodeproj
}

case $1 in
    swiftlint)
        downloadSwiftlint
        runSwiftlint
        ;;
    test-server)
        runTests
        ;;
    pre-build)
      downloadHelperCode
      createXcode
      ;;
esac
