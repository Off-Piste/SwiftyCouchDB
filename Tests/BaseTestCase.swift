//
//  BaseTestCase.swift
//  SwiftyCouchDBTests
//
//  Created by Harry Wright on 24.10.17.
//

import XCTest
import SwiftyCouchDB
import HeliumLogger

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
