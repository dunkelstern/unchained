//
//  middleware.swift
//  unchained
//
//  Created by Johannes Schriewer on 30/11/15.
//  Copyright © 2015 Johannes Schriewer. All rights reserved.
//

import Darwin
import twohundred

/// Unchained middleware, modifies requests before routing and responses afterwards
public protocol UnchainedMiddleware {
    /// Process a request before anything other is done with it
    ///
    /// Unchained will not further call other (request-) middleware or even a router function if the
    /// return tuple contains a non-nil request. Middleware may even change the HTTP request if it wants to.
    /// If the middleware decides it has nothing to modify it should just return nil
    ///
    /// - parameter request: Request that is about to be processed
    /// - returns: Tuple of new HTTPRequest and HTTPResponse
    func request(request: HTTPRequest, config: UnchainedConfig) -> (request: HTTPRequest?, response: HTTPResponse?)?
    
    /// Process a response before it will be delivered
    ///
    /// - parameter request: the request that triggered the response
    /// - parameter response: the response that is about to be delivered
    /// - returns: nil if nothing has to be changed in the response or a changed response object
    func response(request: HTTPRequest, response: HTTPResponse, config: UnchainedConfig) -> HTTPResponse?
}

/// Default implementation does nothing
extension UnchainedMiddleware {
    public func request(request: HTTPRequest, config: UnchainedConfig) -> (request: HTTPRequest?, response: HTTPResponse?)? {
        return nil // do nothing to neither request nor response
    }
    
    public func response(request: HTTPRequest, response: HTTPResponse, config: UnchainedConfig) -> HTTPResponse? {
        return nil // do nothing to response
    }
}