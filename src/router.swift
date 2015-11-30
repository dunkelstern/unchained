//
//  router.swift
//  unchained
//
//  Created by Johannes Schriewer (privat) on 30/11/15.
//  Copyright © 2015 Johannes Schriewer. All rights reserved.
//

import Darwin
import twohundred

public struct UnchainedRoute {
    public typealias RequestHandler = ((request: HTTPRequest, parameters: [String:String]) -> HTTPResponse)
    
    private var regexString: String
    private var name: String?
    private var handler:RequestHandler
    
    /// Initialize a route
    ///
    /// - parameter regex: Regex to match
    /// - parameter handler: handler callback to run if route matches
    /// - parameter name: (optional) name of this route to `reverse`
    public init(_ regex: String, handler:RequestHandler, name: String? = nil) {
        self.regexString = regex
        self.name = name
        self.handler = handler
    }
    
    /// execute a route on a request
    ///
    /// - parameter request: the request on which to execute this route
    /// - returns: response to the request or nil if the route does not match
    public func execute(request: HTTPRequest) -> HTTPResponse? {
        if self.doesMatch(request.header.url) {
            // TODO: Split parameters by regex
            return self.handler(request: request, parameters: [String:String]())
        }
        return nil
    }
    
    // MARK: - Private
    private func doesMatch(url: String) -> Bool {
        // TODO: Regex match the url to determine match
        return false
    }
}