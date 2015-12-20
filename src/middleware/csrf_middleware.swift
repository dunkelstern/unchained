//
//  csrf_middleware.swift
//  unchained
//
//  Created by Johannes Schriewer on 10/12/15.
//  Copyright © 2015 Johannes Schriewer. All rights reserved.
//

import twohundred

public class CSRFMiddleware: Middleware {
   
    public init() {
    }
    
    public func request(request: HTTPRequest, config: UnchainedConfig) -> (request: HTTPRequest?, response: HTTPResponseBase?)? {
        // make sure we have a session
        guard let session = request.session else {
            Log.fatal("CSRF Middleware needs session middleware to be registered")
            return (request: request, response: HTTPResponse(.InternalServerError, body: [.StringData("Session invalid")]))
        }
        
        // create CSRF token if not already set
        if session.data["CSRFToken"] == nil {
            session.data["CSRFToken"] = UUID4().description
        }
        
        // exit further processing if this is not a CSRF enabled request
        if request.header.method == .GET || request.header.method == .HEAD {
            return nil
        }

        var tokenValid = false
        if let token = session.data["CSRFToken"] {

            if let header = request.header["X-CSRFToken"] {
                if header == token {
                    tokenValid = true
                }
            }
            if let postData = request.postData {
                if let post = postData["CSRFToken"] {
                    if post == token {
                        tokenValid = true
                    }
                }
            }
            if let get = request.header.getParameters["CSRFToken"] {
                if get == token {
                    tokenValid = true
                }
            }
            
        }

        var modifiedRequest = request
        modifiedRequest.csrfTestPassed = tokenValid
        return (request: modifiedRequest, response: nil)
    }
}


/// CSRF extension for HTTPRequest
public extension HTTPRequest {
    public var csrfTestPassed:Bool? {
        
        get {
            if case let pass as Bool = self.middlewareData["CSRFTestPassed"] {
                return pass
            }
            return nil
        }
        
        set(newValue) {
            self.middlewareData["CSRFTestPassed"] = newValue
        }
    }
    
    public var csrfToken:String {
        guard let session = self.session,
              let token = session.data["CSRFToken"] else {
            return ""
        }
        return token
    }
}
