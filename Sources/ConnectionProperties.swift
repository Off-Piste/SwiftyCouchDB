//
//  ConnectionProperties.swift
//  SwiftyCouchDB
//
//  Created by Harry Wright on 08.08.17.
//
//

import Foundation
import LoggerAPI

/** */
public struct Utils {

    /** */
    public static var connectionProperties: ConnectionProperties? = .default

}

/** */
public struct ConnectionProperties {

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

    /// <#Description#>
    ///
    /// - Parameters:
    ///   - host: <#host description#>
    ///   - port: <#port description#>
    ///   - secured: <#secured description#>
    ///   - username: <#username description#>
    ///   - password: <#password description#>
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
            Log.warning("Initializing a CouchDB connection without a username or password.")
        }
    }

}

extension ConnectionProperties {

    /// <#Description#>
    public static var `default`: ConnectionProperties {
        return ConnectionProperties(host: "127.0.0.1", port: 5984, secured: false)
    }

}

extension ConnectionProperties {

    /// Use https or http
    var HTTPProtocol: String {
        return secured ? "https" : "http"
    }

    /// CouchDB URL
    var URL: String {
        if let username = username, let password = password {
            return "\(HTTPProtocol)://\(username):\(password)@\(host):\(port)"
        } else {
            return "\(HTTPProtocol)://\(host):\(port)"
        }
    }

}
