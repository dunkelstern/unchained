//
//  responseHandler.swift
//  unchained
//
//  Created by Johannes Schriewer on 09/12/15.
//  Copyright © 2015 Johannes Schriewer. All rights reserved.
//

import twohundred

/// Response handler class protocoll
public protocol UnchainedResponseHandler {

    /// we need a publicly accessible init
    init(request: HTTPRequest)
    
    /// the request
    var request:HTTPRequest { get }
    
    /// CSRF required for this request
    var csrfRequired:Bool { get }
    
    /// the dispatch function is called by the router to dispatch a call
    ///
    /// - parameter parameters: unnamed capture groups from the route
    /// - parameter namedParameters: named capture groups from the route
    /// - returns: HTTPResponse
    func dispatch(parameters: [String], namedParameters: [String:String]) -> HTTPResponse

    /// the head function is called for any HEAD-request
    ///
    /// the default implementation returns a code 400 BAD REQUEST
    ///
    /// - parameter parameters: unnamed capture groups from the route
    /// - parameter namedParameters: named capture groups from the route
    /// - returns: HTTPResponse
    func head(parameters: [String], namedParameters: [String:String]) -> HTTPResponse

    /// the get function is called for any GET-request
    ///
    /// the default implementation returns a code 400 BAD REQUEST
    ///
    /// - parameter parameters: unnamed capture groups from the route
    /// - parameter namedParameters: named capture groups from the route
    /// - returns: HTTPResponse
    func get(parameters: [String], namedParameters: [String:String]) -> HTTPResponse

    /// the post function is called for any POST-request
    ///
    /// the default implementation returns a code 400 BAD REQUEST
    ///
    /// - parameter parameters: unnamed capture groups from the route
    /// - parameter namedParameters: named capture groups from the route
    /// - returns: HTTPResponse
    func post(parameters: [String], namedParameters: [String:String]) -> HTTPResponse

    /// the put function is called for any PUT-request
    ///
    /// the default implementation returns a code 400 BAD REQUEST
    ///
    /// - parameter parameters: unnamed capture groups from the route
    /// - parameter namedParameters: named capture groups from the route
    /// - returns: HTTPResponse
    func put(parameters: [String], namedParameters: [String:String]) -> HTTPResponse

    /// the patch function is called for any PATCH-request
    ///
    /// the default implementation returns a code 400 BAD REQUEST
    ///
    /// - parameter parameters: unnamed capture groups from the route
    /// - parameter namedParameters: named capture groups from the route
    /// - returns: HTTPResponse
    func patch(parameters: [String], namedParameters: [String:String]) -> HTTPResponse

    /// the delete function is called for any DELETE-request
    ///
    /// the default implementation returns a code 400 BAD REQUEST
    ///
    /// - parameter parameters: unnamed capture groups from the route
    /// - parameter namedParameters: named capture groups from the route
    /// - returns: HTTPResponse
    func delete(parameters: [String], namedParameters: [String:String]) -> HTTPResponse

    /// the options function is called for any OPTIONS-request
    ///
    /// the default implementation returns a code 400 BAD REQUEST
    ///
    /// - parameter parameters: unnamed capture groups from the route
    /// - parameter namedParameters: named capture groups from the route
    /// - returns: HTTPResponse
    func options(parameters: [String], namedParameters: [String:String]) -> HTTPResponse
}

/// Default implementation for the `UnchainedResponseHandler` protocol
public extension UnchainedResponseHandler {
    
    /// By default all modifying requests need CSRF checks
    public var csrfRequired: Bool {
        return true
    }
    
    /// Default implementation of the dispatcher, very simple
    ///
    /// - parameter request: the HTTPRequest to handle
    /// - parameter parameters: unnamed capture groups from the route
    /// - parameter namedParameters: named capture groups from the route
    /// - returns: HTTPResponse
    public func dispatch(parameters: [String], namedParameters: [String:String]) -> HTTPResponse {
        switch self.request.header.method {
        case .HEAD:
            return self.head(parameters, namedParameters: namedParameters)
        case .GET:
            return self.get(parameters, namedParameters: namedParameters)
        case .POST:
            if !self.csrfRequired || (self.request.csrfTestPassed != nil && self.request.csrfTestPassed!) {
                return self.post(parameters, namedParameters: namedParameters)
            }
        case .PUT:
            if !self.csrfRequired || (self.request.csrfTestPassed != nil && self.request.csrfTestPassed!) {
                return self.put(parameters, namedParameters: namedParameters)
            }
        case .PATCH:
            if !self.csrfRequired || (self.request.csrfTestPassed != nil && self.request.csrfTestPassed!) {
                return self.patch(parameters, namedParameters: namedParameters)
            }
        case .DELETE:
            if !self.csrfRequired || (self.request.csrfTestPassed != nil && self.request.csrfTestPassed!) {
                return self.delete(parameters, namedParameters: namedParameters)
            }
        case .OPTIONS:
            return self.options(parameters, namedParameters: namedParameters)
        default:
            return HTTPResponse(.BadRequest)
        }
        
        if self.request.csrfTestPassed != nil && !self.request.csrfTestPassed! {
            return HTTPResponse(.BadRequest, body: [.StringData("Invalid CSRF token")])
        }
        
        return HTTPResponse(.InternalServerError)
    }
    
    // here follow the default implementations of the dispatcher which just return status 400 BAD REQUEST
    
    public func head(parameters: [String], namedParameters: [String:String]) -> HTTPResponse {
        return HTTPResponse(.BadRequest)
    }
    
    public func get(parameters: [String], namedParameters: [String:String]) -> HTTPResponse {
        return HTTPResponse(.BadRequest)
    }
    
    public func post(parameters: [String], namedParameters: [String:String]) -> HTTPResponse {
        return HTTPResponse(.BadRequest)
    }
    
    public func put(parameters: [String], namedParameters: [String:String]) -> HTTPResponse {
        return HTTPResponse(.BadRequest)
    }
    
    public func patch(parameters: [String], namedParameters: [String:String]) -> HTTPResponse {
        return HTTPResponse(.BadRequest)
    }
    
    public func delete(parameters: [String], namedParameters: [String:String]) -> HTTPResponse  {
        return HTTPResponse(.BadRequest)
    }
    
    public func options(parameters: [String], namedParameters: [String:String]) -> HTTPResponse {
        return HTTPResponse(.BadRequest)
    }
    
    /// Call this in your router config to get a request handler block that just calls dispatch
    ///
    /// Example:
    ///
    ///     Route("^/$", handler: IndexHandler.forRoute(), name: "index")
    ///
    public static func forRoute() -> Route.RequestHandler {
        return { (request: HTTPRequest, parameters: [String], namedParameters: [String:String]) -> HTTPResponse in
            return self.init(request: request).dispatch(parameters, namedParameters: namedParameters)
        }
    }
}