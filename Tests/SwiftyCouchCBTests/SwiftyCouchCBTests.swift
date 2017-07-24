import XCTest
@testable import SwiftyCouchCB

struct Credentials {
    
    static let defaultCouchHost = "127.0.0.1"
    
    static let defaultCouchPort = UInt16(5984)
    
    var host: String = Credentials.defaultCouchHost
    
    var port: UInt16 = Credentials.defaultCouchPort
    
    var username: String? = nil
    
    var password: String? = nil
    
}

extension String {
    var dbName: String {
        return (self as NSString)
            .lastPathComponent
            .replacingOccurrences(of: ".swift", with: "")
            .lowercased()
    }
}

extension ConnectionProperties {

    init(credentials: Credentials) {
        self.init(
            host: credentials.host,
            port: Int16(credentials.port),
            secured: false,
            username: credentials.username,
            password: credentials.password
        )
    }

}

class SwiftyCouchCBTests: XCTestCase {
    
    var dbManager: DatabaseManager!
    
    override func setUp() {
        let file: String = #file.dbName
        let credentials = Credentials()
        let cp = ConnectionProperties(credentials: credentials)
        
        self.dbManager = DatabaseManager(
            connectionProperties: cp,
            databaseName: file,
            design: "_\(file)"
        )
    }

    func testDatabaseCreation() {
        dbManager.reference.createDatabase { (error) in
            if let error = error {
                XCTFail("DB creation error: \(error.code) \(error.localizedDescription)")
            }

            print(">> Database successfully created")

            self.dbManager.reference.deleteDatabase(callback: { (error) in
                if let error = error {
                    XCTFail("DB deletion error: \(error.code) \(error.localizedDescription)")
                }
                print(">> Database successfully deleted")
            })
        }
    }



    static var allTests = [
        ("testDatabaseCreation", testDatabaseCreation),
    ]
}
