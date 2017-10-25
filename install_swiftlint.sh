#!/bin/bash

# Installs the SwiftLint package.
# Tries to get the precompiled .pkg file from Github, but if that
# fails just recompiles from source.

set -o pipefail
set -e

source_root="$(dirname "$0")"
source="$0"


function pre_handle_CouchDB {
  eval "curl -X PUT 127.0.0.1:5984/test_exists"
  eval "curl -X PUT 127.0.0.1:5984/test_deletion"
}


function usage {
  echo "$source [tests-macos, swiftlint, jazzy, before-swiftlint, before-tests-macos]"
  exit 0
}

function xcode {
  CMD="$@"
  echo "Building with command:" $CMD
  eval "$CMD"
}

#######################################
#             Helper Code             #
#######################################

# Placed outside pre_xcode as this won't run on my system but is fine on travis
function pre_xcode_gem {
  gem install xcpretty --no-rdoc --no-ri --no-document --quiet
  gem install xcpretty-travis-formatter --no-rdoc --no-ri --no-document --quiet

  brew outdated couchdb || brew upgrade couchdb
  couchdb -b
  couchdb -s

  eval "curl -X GET 127.0.0.1:5984"
}

function pre_xcode {
  echo "Building Swift"
  swift build

  echo "Generating Package"
  swift package generate-xcodeproj
}

function build_for_swiftlint {
  if which swiftlint >/dev/null; then
      echo "SwiftLint is installed"
      brew outdated swiftlint || brew upgrade swiftlint
  else
      echo "SwiftLint not installed, downloading via homebrew"
      brew install swiftlint
  fi
}

#######################################
#             Running Code            #
#######################################

function _swiftlint {
  echo "Running SwiftLint"
  swiftlint
}

function run_tests {
  XCODE_TESTS_PARAMS="-project $source_root/SwiftyCouchDB.xcodeproj -scheme SwiftyCouchDBTests"

  echo "Running Tests"
  xcode "xcodebuild clean build test $XCODE_TESTS_PARAMS | xcpretty -f `xcpretty-travis-formatter`"
}

function _jazzy {
  jazzy -x -project,SwiftyCouchDB.xcodeproj,-scheme,SwiftyCouchDB --hide-documentation-coverage

  if [-d ./build]; then
    rm -R ./build
  fi
}

#######################################
#           Parse Argument            #
#######################################

case $1 in
    swiftlint) _swiftlint ;;
    tests-macos) run_tests ;;
    jazzy) _jazzy ;;
    before-tests-couch-db) pre_handle_CouchDB ;;
    before-tests-script) pre_xcode_gem ;;
    before-tests-macos) pre_xcode ;;
    before-swiftlint) build_for_swiftlint ;;
    *) usage ;;
esac
