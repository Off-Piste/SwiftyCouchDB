#!/bin/bash

# Installs the SwiftLint package.
# Tries to get the precompiled .pkg file from Github, but if that
# fails just recompiles from source.

set -o pipefail
set -e

source_root="$(dirname "$0")"
source="$0"

# Tests for macOS
# Before Install
# 1. Download CouchDB
# 2. Run CouchDB In the background
# 3. Install xcpretty & xcpretty-travis-formatter
# Before script
# 1. swift build && swift package generate-xcodeproj
# 2. Create Databases for CouchDB
# After script
# 1. Delete the remaining CouchDB's

#######################################
#               Helpers               #
#######################################

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
#               Scripts               #
#######################################

function run_mac_os_tests {
  XCODE_TESTS_PARAMS="-project $source_root/SwiftyCouchDB.xcodeproj -scheme SwiftyCouchDBTests"

  echo "Running Tests"
  xcode "xcodebuild clean build test $XCODE_TESTS_PARAMS | xcpretty -f `xcpretty-travis-formatter`"
}

function create_docs {
  jazzy -x -project,SwiftyCouchDB.xcodeproj,-scheme,SwiftyCouchDB --hide-documentation-coverage

  if [-d ./build]; then
    rm -R ./build
  fi
}


#######################################
#           Before Install            #
#######################################

function install_xcode_helpers {
  gem install xcpretty --no-rdoc --no-ri --no-document --quiet
  gem install xcpretty-travis-formatter --no-rdoc --no-ri --no-document --quiet
}

#######################################
#            Before Script            #
#######################################

function create_couch_db_databases {
  echo "curl -X PUT 127.0.0.1:5984/test_exists"
  eval "curl -X PUT 127.0.0.1:5984/test_exists"

  echo "curl -X PUT 127.0.0.1:5984/test_deletion"
  eval "curl -X PUT 127.0.0.1:5984/test_deletion"

  echo "curl -X PUT 127.0.0.1:5984/test_adding"
  eval "curl -X PUT 127.0.0.1:5984/test_adding"

  echo "curl -X PUT 127.0.0.1:5984/test_retrieve"
  eval "curl -X PUT 127.0.0.1:5984/test_retrieve"

  echo "curl -X PUT 127.0.0.1:5984/test_add_change"
  eval "curl -X PUT 127.0.0.1:5984/test_add_change"

  echo "curl -X POST -H 'Content-Type: application/json' -d '{\"_id\":\"qwertyuiop\",\"list\":[{\"_id\":\"abc\",\"username\":\"qwerty\",\"email\":\"qwerty@email.com\"}]} 127.0.0.1:5985/test_add_change'"
  eval "curl -X POST -H 'Content-Type: application/json' -d '{\"_id\":\"qwertyuiop\",\"list\":[{\"_id\":\"abc\",\"username\":\"qwerty\",\"email\":\"qwerty@email.com\"}]}' 127.0.0.1:5985/test_add_change"

  echo "curl -X POST -H 'Content-Type: application/json' -d '{\"_id\":\"qwertyuiop\", \"username\":\"swiftylover99\"}' 127.0.0.1:5984/test_retrieve"
  eval "curl -X POST -H 'Content-Type: application/json' -d '{\"_id\":\"qwertyuiop\", \"username\":\"swiftylover99\"}' 127.0.0.1:5984/test_retrieve"

  echo "curl -X GET 127.0.0.1:5984/_all_dbs"
  eval "curl -X GET 127.0.0.1:5984/_all_dbs"
}

function build_swift {
  swift build

  swift package generate-xcodeproj
}

#######################################
#            After Script             #
#######################################

function delete_couch_db_databases {
  eval "curl -X DELETE 127.0.0.1:5984/test_exists"
  eval "curl -X DELETE 127.0.0.1:5984/test_adding"
  eval "curl -X DELETE 127.0.0.1:5984/test_retrieve"

  eval "curl -X GET 127.0.0.1:5984/_all_dbs"
}

#######################################
#           Parse Argument            #
#######################################

case $1 in
  tests-before-install) install_xcode_helpers ;;
  tests-before-script) create_couch_db_databases ;;
  tests-after-script) delete_couch_db_databases ;;
  build-swift-package) build_swift ;;
  run-tests) run_mac_os_tests ;;
  jazzy) create_docs ;;
  *) usage ;;
esac
