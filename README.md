# SwiftyCouchDB

[![Build Status](https://travis-ci.org/Off-Piste/SwiftyCouchDB.svg?branch=master)](https://travis-ci.org/Off-Piste/SwiftyCouchDB)

SwiftyCouchDB is a wrapper for CouchDB

- [Requirements](#Features)
- [Installation](#Installation)
- [Usage](#Usage)
  - [Basic Database Methods](#Basic-Database-Methods)
  - [Custom Database Configuration](#Custom-Database-Configuration)

## Requirements

- macOS (linux soon come, when Alamofire is compatible, more info [here](https://github.com/Alamofire/Alamofire/issues/1935))
- Xcode 9.0+
- Swift 4.0

## Installation

> NOTE:
> Currently we only support Swift Package Manager, as we are more of a server side framework, but if you wish us to move to Cocoapods please let us know

### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler. It is in early development, but Alamofire does support its use on supported platforms.

Once you have your Swift package set up, adding Alamofire as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift`.

```swift
dependencies: [
    .package(url: "https://github.com/Off-Piste/SwiftyCouchDB.git", from: "1.0.0")
]
```

## Usage

> NOTE:
> Due to the all objects subclassing `DBObject` you will need to override `init(from decoder: Decoder) throws` and `func encode(to encoder: Encoder) throws`, for more info see [article](http://benscheirman.com/2017/06/ultimate-guide-to-json-parsing-with-swift-4) on how to use Codable

### Basic Database Methods

> NOTE:
> If the error has a `._code` of 500, this usually means that CouchDB is not running

```swift
import SwiftyCouchDB

// This will only throw an error if the database name is invalid
let database = try! Database("users")

// Sends a GET request to the server to get its basic infomation
database.info { (info, error) in
    // ...
}

// Sends a HEAD request to server to check if the database exists
database.exists { (exists, error) in
    // ...
}

// Sends a PUT request to create the database
database.create { (database, error) in
    // ...
}

// Sends a DELETE request to delete the database
database.delete { (success, error) in
    // ...
}
```

### Custom Database Configuration

Calling `Database(_:)` currently passes `DBConfiguration.default` when being called, this is set to `127.0.0.1:5984` which is the default CouchDB connection.

Changing `.default` is easy:
```swift
DBConfiguration.setDefault(DBConfiguration(host: "sever_url.com", port: nil, secure: false))
```

Of if one database is at a custom location, you can set each Database with a separate configuration:

```swift
let config = DBConfiguration(host: "sever_url.com", port: nil, secure: false)
let database = try! Database("database", configuration: config)
```

Or last of all, if you pass a URLConvertible through we can infer the details

```swift
let database = try! Database("http://server_url.com/database")

print(database.config, database.name) // DBConfiguration{host: "sever_url.com", secure: false}, database
```

## FINISH


## License

SwiftyCouchDB is released under the MIT license.
