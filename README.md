# SwiftyCouchDB

SwiftyCouchDB is a warpper for the current [Kitura CouchDB client](https://github.com/IBM-Swift/Kitura-CouchDB), allowing you to work with your JSON database easier.

let says you need to change the img links for a specific product the old way would be as such
```swift
let docID: String = ...
let newLinks: Dictionary<String, Any> = ...
database.retrieve(docID, callback: { (json, error) in
    if let document = json, error == nil {
        document["data"]["metadata"]["links"].dictionaryObject = newLinks

        guard let rev = document["_rev"].string else {
            return
        }

        self.database.update(id, rev: rev, document: document, callback: {(_, _, err) in
            if let error = err {
                /* handle error */
            } else {
                /* fulfilled request */
            }
        })
    } else {
        /* handle error */
    }
})
```

Now let see the new way

```swift
let docID: String = ...
let newLinks: Dictionary<String, Any> = ...
let ref = DatabaseManager(...).referenceForFile(docID)
ref.child("data").child("metadata").child("links")
ref.update(newLinks)
```

> NOTE: The inspiration comes from the way firebase database systems works, it is currently the cleanest way to work with JSON database
