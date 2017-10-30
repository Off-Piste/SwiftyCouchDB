# SwiftyCouchDB

SwiftyCouchDB is a wrapper for CouchDB

## Getting started

SwiftyCouchDB enables you to access your CouchDB cleanly and as swiftly as possible using Swift 4's Codable and for backwards compatabily Mirror.

```swift
// Define your models like regular Swift classes
class User: DBObject {
    var username: String = ""
    var email: String = ""
}

// Use them like regular objects
let user = User()
user._id = "qwertyuiop" // The _id property is added by DBObject automatically and is UUID().uuidString for default
user.username = "swiftylover99"
user.email = "swiftylover99@gmail.com"

// Create your database instance
let usersDatabase = try! Database("_users")

// Add your database easily
usersDatabase.add(user) { (info, error) in
    if let error = error {
        ...
    } else {
        ...
    }
}
```
