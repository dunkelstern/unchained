//
//  unchained.swift
//  unchained
//
//  Created by Johannes Schriewer on 30/11/15.
//  Copyright © 2015 Johannes Schriewer. All rights reserved.
//

import Darwin
import twohundred

/// Unchained Server main class
public class UnchainedServer: TwoHundredServer {

    /// Configuration
    public let config:UnchainedConfig
    
    
    /// Initialize with configuration
    ///
    /// - parameter config: configuration to run on
    public init(config: UnchainedConfig) {
        self.config = config
        super.init(listenAddress: config.listenAddress, port: config.listenPort)
    }
    
    /// Handle a request (execute request middleware, route request, execute response middleware)
    ///
    /// - parameter request: request to handle
    /// - returns: response to send
    override public func handleRequest(request: HTTPRequest) -> HTTPResponse {
        // execute request middleware
        let result = self.executeRequestMiddleware(request)
        let modifiedRequest = result.request
        
        // if the middleware did not yield a response execute the request
        var response: HTTPResponse?
        if result.response == nil {
            response = self.executeRequest(request)
        } else {
            response = result.response!
        }
    
        // execute the response middleware
        if let response = response {
            return self.executeResponseMiddleware(modifiedRequest, response: response)
        }
        
        // nothing returned a response, default to 404
        return HTTPResponse(.NotFound)
    }
    
    // MARK: - Private
    private func executeRequestMiddleware(request: HTTPRequest) -> (request: HTTPRequest, response: HTTPResponse?) {
        var modifiedRequest = request
        
        // Walk all middleware and combine request changes, if a middleware returns a response cancel processing
        for middleware in self.config.middleware {
            if let result = middleware.request(request, config: self.config) {
                if let newRequest = result.request {
                    modifiedRequest = newRequest
                }
                if let response = result.response {
                    return (request: modifiedRequest, response: response)
                }
            }
        }
        
        return (request: modifiedRequest, response: nil)
    }
    
    private func executeRequest(request: HTTPRequest) -> HTTPResponse? {
        // Walk all routes, return response of first match
        for route in self.config.routes {
            if let response = route.execute(request) {
                return response
            }
        }
        return nil
    }
    
    private func executeResponseMiddleware(request: HTTPRequest, response: HTTPResponse) -> HTTPResponse {
        var modifiedResponse = response
        
        // Walk all middleware and combine responses
        for middleware in self.config.middleware {
            if let response = middleware.response(request, response: modifiedResponse, config: self.config) {
                modifiedResponse = response
            }
        }
        
        // return the combined responses
        return modifiedResponse
    }
}

/// Route reversion
public extension UnchainedServer {
    
    /// reverse a route
    ///
    /// - parameter name: the name of the route URL to produce
    /// - parameter parameters: the parameters to substitute
    /// - returns: URL of route with parameters
    ///
    /// - throws: Throws errors if route could not be reversed
    public class func reverseRoute(name: String, parameters:[String:String]?) throws -> String {
        // TODO: Implement route reversion
        return ""
    }
}
