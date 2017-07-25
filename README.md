# SwiftyCouchDB

SwiftyCouchDB is a wrapper for the current [Kitura CouchDB client](https://github.com/IBM-Swift/Kitura-CouchDB).

## How to use?

The idea was to keep things as simple as possible, so firstly you want to set up your connection properties.

```swift
ConnectionPropertiesManager.connectionProperties = ConnectionProperties(
    host: host, // 127.0.0.1
    port: post, // 5984
    secured: secured, // false
    username: username, // nil
    password: password // nil
)
```

This is the global `ConnectionProperties` for your CouchDB.

To create your new database.

```swift
let db = try! CouchDatabase(name: "prodcts")
db.create { error in
    if let error = error {
        /* Handle error */
    } else {
        /* Work with database */
    }
}
```

Oh no, we have spelt out database name wrong, how would we delete our database?

```swift
db.delete { error in
    if let error = error {
        /* Handle error */
    } else {
        /* Create new Database */
    }
}
```
