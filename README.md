# SwiftyCouchDB

SwiftyCouchDB is a wrapper for the current [Kitura CouchDB client](https://github.com/IBM-Swift/Kitura-CouchDB).

## How to use?

The idea was to keep things as simple as possible, so firstly you want to set up your connection properties.

```swift
Utils.connectionProperties = ConnectionProperties(
    host: host, // 127.0.0.1
    port: post, // 5984
    secured: secured, // false
    username: username, // nil
    password: password // nil
)
```

> NOTE: If working with a local database and no username and password, `ConnectionProperties.default` will suffice

To create a database this is quick and simple.

```swift
try! Database("products").create { (database, error) -> Void in
    if let error = error {
        /* handle error */
    } else {
        /* work with the database */
    }
}
```
