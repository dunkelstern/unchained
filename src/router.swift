//
//  router.swift
//  unchained
//
//  Created by Johannes Schriewer (privat) on 30/11/15.
//  Copyright © 2015 Johannes Schriewer. All rights reserved.
//

import Darwin
import twohundred
import SwiftyRegex

public struct UnchainedRoute {
    public typealias RequestHandler = ((request: HTTPRequest, parameters: [String], namedParameters: [String:String]) -> HTTPResponse)
    
    private var re: RegEx
    private var name: String?
    private var handler:RequestHandler
    
    /// Initialize a route
    ///
    /// - parameter regex: Regex to match
    /// - parameter handler: handler callback to run if route matches
    /// - parameter name: (optional) name of this route to `reverse`
    public init(_ regex: String, handler:RequestHandler, name: String? = nil) throws {
        self.re = try RegEx(pattern: regex)
        self.name = name
        self.handler = handler
    }
    
    /// execute a route on a request
    ///
    /// - parameter request: the request on which to execute this route
    /// - returns: response to the request or nil if the route does not match
    public func execute(request: HTTPRequest) -> HTTPResponse? {
        let matches = self.re.match(request.header.url)
        if matches.numberedParams.count > 0 {
            return self.handler(request: request, parameters: matches.numberedParams, namedParameters: matches.namedParams)
        }
        return nil
    }
}