//
//  router.swift
//  unchained
//
//  Created by Johannes Schriewer on 30/11/15.
//  Copyright © 2015 Johannes Schriewer. All rights reserved.
//

import Darwin
import twohundred
import SwiftyRegex

/// Unchained route entry
public struct Route {
    
    /// A route request handler, takes `request`, numbered `parameters` and `namedParameters`, returns `HTTPResponse`
    public typealias RequestHandler = ((request: HTTPRequest, parameters: [String], namedParameters: [String:String]) -> HTTPResponse)
    
    private var re: RegEx?
    private var name: String?
    private var handler:RequestHandler
    
    /// Initialize a route
    ///
    /// - parameter regex: Regex to match
    /// - parameter handler: handler callback to run if route matches
    /// - parameter name: (optional) name of this route to `reverse`
    public init(_ regex: String, handler:RequestHandler, name: String? = nil) {
        do {
            self.re = try RegEx(pattern: regex)
        } catch RegEx.Error.InvalidPattern(let offset, let message) {
            // TODO: Implement centralized logging
            print("Route: Pattern parse error for pattern \(regex) at character \(offset): \(message)")
        } catch {
            // unused
        }
        self.name = name
        self.handler = handler
    }
    
    /// execute a route on a request
    ///
    /// - parameter request: the request on which to execute this route
    /// - returns: response to the request or nil if the route does not match
    public func execute(request: HTTPRequest) -> HTTPResponse? {
        guard let re = self.re else {
            return nil
        }
        let matches = re.match(request.header.url)
        if matches.numberedParams.count > 0 {
            return self.handler(request: request, parameters: matches.numberedParams, namedParameters: matches.namedParams)
        }
        return nil
    }
}