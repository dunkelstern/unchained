//
//  session.swift
//  unchained
//
//  Created by Johannes Schriewer on 10/12/15.
//  Copyright © 2015 Johannes Schriewer. All rights reserved.
//

import twohundred

public class SessionMiddleware: UnchainedMiddleware {
    public init() {
        
    }
    
    public func request(request: HTTPRequest, config: UnchainedConfig) -> (request: HTTPRequest?, response: HTTPResponse?)? {
        var modifiedRequest = request
        
        // try to restore a session
        var sessionID: String? = nil
        for cookie in request.header.cookies {
            if cookie.name == "sessionID" {
                sessionID = cookie.value
            }
        }
        if let sessionID = sessionID {
            modifiedRequest.session = Session.restore(sessionID)
        }
        
        // restart a new session if session ID restore failed
        if modifiedRequest.session == nil {
            modifiedRequest.session = Session()
        }
        return (request: modifiedRequest, response: nil)
    }
    
    public func response(request: HTTPRequest, response: HTTPResponse, config: UnchainedConfig) -> HTTPResponse? {
        // send set cookie header
        if let session = request.session {
            let sessionCookie = Cookie(name: "sessionID", value: session.sessionID.description, domain: config.serverName, secure: false, httpOnly: false)
            response.setCookie(sessionCookie)
        }
        return response
    }
}
