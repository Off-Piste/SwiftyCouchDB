//
//  BaseTestCase.swift
//  SwiftyCouchDBTests
//
//  Created by Harry Wright on 24.10.17.
//

import XCTest
import SwiftyCouchDB
import HeliumLogger

enum Change {
    case addition
    case deletion
    case change(from: Any, to: Any)
}

extension Array where Element == (String, Change) {
    subscript (_ string: String) -> Element? {
        for touple in self {
            if touple.0 == string { return touple }
        }
        return nil
    }
}

func XCTAssertChanges(changes: [DBPropertyChange], equalTo checks: (String, Change)...) {
    let checkingChanges = changes.filter { change in
        checks.contains { touple -> Bool in touple.0 == change.name }
    }

    for change in checkingChanges {
        guard let touple = checks[change.name] else { continue }

        switch touple.1 {
        case .addition: XCTAssertNil(change.oldValue)
        case .deletion: XCTAssertNil(change.newValue)
        case .change(let old, let new):
            XCTAssertNotEqual(old as? AnyHashable, new as? AnyHashable)
        }
    }

}

typealias TestNotificationHandler = (Notification, XCTestExpectation) -> Void

var _has_set_up_db: Bool = false

class BaseTestCase: XCTestCase {

    var timeout: TimeInterval = 40

    var _observer: NSObjectProtocol?

    var _dbName: String?

    override func setUp() {
        super.setUp()

        HeliumLogger.use()
    }

    func async(for description: String = #function, callback: (XCTestExpectation) throws -> Void) {
        let exp = self.expectation(description: description)

        do { try callback(exp) } catch { XCTFail() }
        self.waitForExpectations(timeout: timeout, handler: nil)

        self._dbName = description
    }

    func observe(
        _ notification: Notification.Name,
        handler body: @escaping TestNotificationHandler
        )
    {
        let exp = self.expectation(description: description)
        _observer = NotificationCenter
            .default
            .addObserver(
                forName: notification,
                object: nil,
                queue: nil,
                using: { (note) in
                    body(note, exp)
            }
        )

        self.waitForExpectations(timeout: timeout, handler: nil)
    }

    override func tearDown() {
        super.tearDown()
        if let obserser = _observer {
            NotificationCenter.default.removeObserver(obserser)
        }
    }

}
