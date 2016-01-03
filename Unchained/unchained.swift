//
//  unchained.swift
//  unchained
//
//  Created by Johannes Schriewer on 30/11/15.
//  Copyright © 2015 Johannes Schriewer. All rights reserved.
//

import Darwin
import TwoHundred
import UnchainedLogger

/// Unchained Server main class
public class UnchainedServer: TwoHundredServer {

    /// Configuration
    public let config:UnchainedConfig
    
    
    /// Initialize with configuration
    ///
    /// - parameter config: configuration to run on
    public init(config: UnchainedConfig) {
        self.config = config
        if let logfilePath = config.logfilePath {
            Log.logFileName = logfilePath
        }
        Log.info("Starting server, listening on \(config.listenAddress):\(config.listenPort)")
        super.init(listenAddress: config.listenAddress, port: config.listenPort)
    }
    
    /// Handle a request (execute request middleware, route request, execute response middleware)
    ///
    /// - parameter request: request to handle
    /// - returns: response to send
    override public func handleRequest(request: HTTPRequest) -> HTTPResponseBase {
        // execute request middleware
        let result = self.executeRequestMiddleware(request)
        var modifiedRequest = result.request
        modifiedRequest.config = self.config
        
        // if the middleware did not yield a response execute the request
        var response: HTTPResponseBase?
        if result.response == nil {
            response = self.executeRequest(modifiedRequest)
        } else {
            response = result.response!
            Log.info("\(request.header.method) \(request.header.url), \(response!.statusCode.rawValue.uppercaseString), from middleware")
        }
    
        // execute the response middleware
        if let response = response {
            return self.executeResponseMiddleware(modifiedRequest, response: response)
        }
        
        // nothing returned a response, default to 404
        Log.info("\(request.header.method) \(request.header.url), 404 NOT FOUND, No route found")
        return HTTPResponse(.NotFound)
    }
    
    // MARK: - Private
    private func executeRequestMiddleware(request: HTTPRequest) -> (request: HTTPRequest, response: HTTPResponseBase?) {
        var modifiedRequest = request
        
        // Walk all middleware and combine request changes, if a middleware returns a response cancel processing
        for middleware in self.config.middleware {
            if let result = middleware.request(modifiedRequest, config: self.config) {
                if let newRequest = result.request {
                    Log.debug("\(request.header.method) \(request.header.url), \(middleware.name) modified request")
                    modifiedRequest = newRequest
                }
                if let response = result.response {
                    return (request: modifiedRequest, response: response)
                }
            }
        }
        
        return (request: modifiedRequest, response: nil)
    }
    
    private func executeRequest(request: HTTPRequest) -> HTTPResponseBase? {
        // Walk all routes, return response of first match
        for route in self.config.routes {
            if let response = route.execute(request) {
                Log.info("\(request.header.method) \(request.header.url), \(response.statusCode.rawValue.uppercaseString), \(route.name)")
                return response
            }
        }
        return nil
    }
    
    private func executeResponseMiddleware(request: HTTPRequest, response: HTTPResponseBase) -> HTTPResponseBase {
        var modifiedResponse = response
        
        // Walk all middleware and combine responses
        for middleware in self.config.middleware {
            if let response = middleware.response(request, response: modifiedResponse, config: self.config) {
                Log.debug("\(request.header.method) \(request.header.url), \(middleware.name) modified response")
                modifiedResponse = response
            }
        }
        
        // return the combined responses
        return modifiedResponse
    }
}
