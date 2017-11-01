/**
 Copyright IBM Corporation 2016
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 http://www.apache.org/licenses/LICENSE-2.0
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

import Foundation

// Abstract to a protocol for collection extensions
public protocol ResultProtocol {
    associatedtype FulfilledValue
    // SOMEDAY: make then return a ResultProtocol
    func then<NewFulfilledValue>( execute body: (FulfilledValue) throws -> NewFulfilledValue )  -> Result<NewFulfilledValue>
    func getOrThrow() throws -> FulfilledValue
    func recover(execute body: (Error) throws -> FulfilledValue) -> Self
    func `catch`( execute body: (Error) throws -> Void) rethrows -> Self
    
    func tap( execute body: (Self) -> Void ) -> Self
    func always( execute body: () -> Void ) -> Self
    var errorOrNil: Error? {get}
}

/// <#Description#>
public enum Result<FulfilledValueParameter> {

    /// <#Description#>
    public typealias FulfilledValue = FulfilledValueParameter

    ///
    case fulfilled(FulfilledValue)

    ///
    case rejected(Error)
}

public extension Result {

    // MARK: Inits

    /// <#Description#>
    ///
    /// - Parameter body: <#body description#>
    public init(of body: () throws -> FulfilledValue) {
        do { self = try .fulfilled(body()) }
        catch { self = .rejected (error) }
    }

}

public extension Result {

    // MARK: Properties

    /// <#Description#>
    public var errorOrNil: Error? {
        switch self {
        case .rejected(let e): return e
        case .fulfilled: return nil
        }
    }
}

public extension Result {

    // MARK: Then

    /// <#Description#>
    ///
    /// - Parameter body: <#body description#>
    /// - Returns: <#return value description#>
    @discardableResult
    public func then<NewFulfilledValue>(
        execute body: (FulfilledValue) throws -> NewFulfilledValue
        ) -> Result<NewFulfilledValue>
    {
        switch self {
        case .rejected(let error): return .rejected(error)
        case .fulfilled(let value):
            do { return try .fulfilled(body(value)) }
            catch { return .rejected(error) }
        }
    }


    /// <#Description#>
    ///
    /// - Returns: <#return value description#>
    /// - Throws: <#throws value description#>
    public func getOrThrow() throws -> FulfilledValue {
        switch self {
        case .rejected(let error): throw error
        case .fulfilled(let value): return value
        }
    }
}

public extension Result {

    // MARK: Error Handling

    /// <#Description#>
    ///
    /// - Parameter body: <#body description#>
    /// - Returns: <#return value description#>
    @discardableResult
    public func recover(execute body: (Error) throws -> FulfilledValue) -> Result {
        switch self {
        case .fulfilled: return self
        case .rejected(let error):
            do { return try .fulfilled(body(error)) }
            catch { return .rejected(error) }
        }
    }

    /// <#Description#>
    ///
    /// - Parameter body: <#body description#>
    /// - Returns: <#return value description#>
    /// - Throws: <#throws value description#>
    @discardableResult
    public func `catch`( execute body: (Error) throws -> Void) rethrows -> Result {
        switch self {
        case .fulfilled: break
        case .rejected(let error): try body(error)
        }
        return self
    }
}


public extension Result {

    // MARK: Always

    // Could add in all of the Promise protocol
    // The following is not needed for the book.
    // Why do the bodies not get to transform the result??
    
    /// <#Description#>
    ///
    /// - Parameter body: <#body description#>
    /// - Returns: <#return value description#>
    public func tap(execute body: (Result) -> Void) -> Result {
        body(self)
        return self
    }
    
    /// <#Description#>
    ///
    /// - Parameter body: <#body description#>
    /// - Returns: <#return value description#>
    public func always(execute body: () -> Void) -> Result {
        body()
        return self
    }
}

extension Result: ResultProtocol { }
