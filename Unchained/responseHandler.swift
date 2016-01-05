//
//  responseHandler.swift
//  unchained
//
//  Created by Johannes Schriewer on 09/12/15.
//  Copyright © 2015 Johannes Schriewer. All rights reserved.
//

import TwoHundred

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
    /// - returns: HTTPResponseBase
    func dispatch(parameters: [String], namedParameters: [String:String]) -> HTTPResponseBase

    /// the head function is called for any HEAD-request
    ///
    /// the default implementation returns a code 400 BAD REQUEST
    ///
    /// - parameter parameters: unnamed capture groups from the route
    /// - parameter namedParameters: named capture groups from the route
    /// - returns: HTTPResponseBase
    func head(parameters: [String], namedParameters: [String:String]) -> HTTPResponseBase

    /// the get function is called for any GET-request
    ///
    /// the default implementation returns a code 400 BAD REQUEST
    ///
    /// - parameter parameters: unnamed capture groups from the route
    /// - parameter namedParameters: named capture groups from the route
    /// - returns: HTTPResponseBase
    func get(parameters: [String], namedParameters: [String:String]) -> HTTPResponseBase

    /// the post function is called for any POST-request
    ///
    /// the default implementation returns a code 400 BAD REQUEST
    ///
    /// - parameter parameters: unnamed capture groups from the route
    /// - parameter namedParameters: named capture groups from the route
    /// - returns: HTTPResponseBase
    func post(parameters: [String], namedParameters: [String:String]) -> HTTPResponseBase

    /// the put function is called for any PUT-request
    ///
    /// the default implementation returns a code 400 BAD REQUEST
    ///
    /// - parameter parameters: unnamed capture groups from the route
    /// - parameter namedParameters: named capture groups from the route
    /// - returns: HTTPResponseBase
    func put(parameters: [String], namedParameters: [String:String]) -> HTTPResponseBase

    /// the patch function is called for any PATCH-request
    ///
    /// the default implementation returns a code 400 BAD REQUEST
    ///
    /// - parameter parameters: unnamed capture groups from the route
    /// - parameter namedParameters: named capture groups from the route
    /// - returns: HTTPResponseBase
    func patch(parameters: [String], namedParameters: [String:String]) -> HTTPResponseBase

    /// the delete function is called for any DELETE-request
    ///
    /// the default implementation returns a code 400 BAD REQUEST
    ///
    /// - parameter parameters: unnamed capture groups from the route
    /// - parameter namedParameters: named capture groups from the route
    /// - returns: HTTPResponseBase
    func delete(parameters: [String], namedParameters: [String:String]) -> HTTPResponseBase

    /// the options function is called for any OPTIONS-request
    ///
    /// the default implementation returns a code 400 BAD REQUEST
    ///
    /// - parameter parameters: unnamed capture groups from the route
    /// - parameter namedParameters: named capture groups from the route
    /// - returns: HTTPResponseBase
    func options(parameters: [String], namedParameters: [String:String]) -> HTTPResponseBase
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
    /// - returns: HTTPResponseBase
    public func dispatch(parameters: [String], namedParameters: [String:String]) -> HTTPResponseBase {
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
    
    public func head(parameters: [String], namedParameters: [String:String]) -> HTTPResponseBase {
        return HTTPResponse(.BadRequest)
    }
    
    public func get(parameters: [String], namedParameters: [String:String]) -> HTTPResponseBase {
        return HTTPResponse(.BadRequest)
    }
    
    public func post(parameters: [String], namedParameters: [String:String]) -> HTTPResponseBase {
        return HTTPResponse(.BadRequest)
    }
    
    public func put(parameters: [String], namedParameters: [String:String]) -> HTTPResponseBase {
        return HTTPResponse(.BadRequest)
    }
    
    public func patch(parameters: [String], namedParameters: [String:String]) -> HTTPResponseBase {
        return HTTPResponse(.BadRequest)
    }
    
    public func delete(parameters: [String], namedParameters: [String:String]) -> HTTPResponseBase  {
        return HTTPResponse(.BadRequest)
    }
    
    public func options(parameters: [String], namedParameters: [String:String]) -> HTTPResponseBase {
        return HTTPResponse(.BadRequest)
    }
    
    /// Call this in your router config to get a request handler block that just calls dispatch
    ///
    /// Example:
    ///
    ///     Route("^/$", handler: IndexHandler.forRoute(), name: "index")
    ///
    public static func forRoute() -> Route.RequestHandler {
        return { (request: HTTPRequest, parameters: [String], namedParameters: [String:String]) -> HTTPResponseBase in
            return self.init(request: request).dispatch(parameters, namedParameters: namedParameters)
        }
    }
}