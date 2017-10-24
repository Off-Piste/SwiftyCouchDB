//
//  DatabaseConfiguration.swift
//  CouchDB
//
//  Created by Harry Wright on 23.10.17.
//  Copyright © 2017 Trolley. All rights reserved.
//

import Foundation
import LoggerAPI

private var kDefault: DBConfiguration = DBConfiguration(host: "127.0.0.1", port: 5984, secured: false)

/// DBConfiguration is the Network Configuration for your CouchDB so we know to
/// make requests to the right place.
public final class DBConfiguration {

    /// This is set to local, calling DBConfiguration.setDefault() will change this
    public static var `default`: DBConfiguration { return kDefault }

    /// Hostname or IP address to the CouchDB server
    public let host: String

    /// Port number where CouchDB server is listening for incoming connections
    public let port: Int16

    /// Whether or not to use a secured connection
    public let secured: Bool

    /// CouchDB admin username
    internal let username: String?

    /// CouchDB admin password
    internal let password: String?

    /// Method used to create a new DBConfiguration
    ///
    /// - Parameters:
    ///   - host: The URL host
    ///   - port: The URL port
    ///   - secured: Bool to say if the URL is secured
    ///   - username: The URI username
    ///   - password: The URI password
    public init(
        host: String,
        port: Int16,
        secured: Bool,
        username: String? = nil,
        password: String? = nil
        )
    {
        self.host = host
        self.port = port
        self.secured = secured
        self.username = username
        self.password = password

        if self.username == nil || self.password == nil {
            Log.warning("Initializing a CouchDB configuration without a username or password.")
        }
    }

    /// Method to set the default configuration
    ///
    /// - Parameter config: A new DBConfiguration.
    public static func setDefault(_ config: DBConfiguration) {
        kDefault = config
    }

    /// Use https or http
    internal var HTTPProtocol: String {
        return secured ? "https" : "http"
    }

    /// CouchDB URL
    internal var URL: String {
        var base: String
        if let username = username, let password = password {
            base = "\(HTTPProtocol)://\(username):\(password)@\(host)"
        } else {
            base = "\(HTTPProtocol)://\(host)"
        }

        if port == 0000 {
            return base
        } else {
            return "\(base):\(port)"
        }
    }
}
