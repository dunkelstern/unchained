//
//  session_middleware.swift
//  unchained
//
//  Created by Johannes Schriewer on 10/12/15.
//  Copyright © 2015 Johannes Schriewer. All rights reserved.
//

import TwoHundred
import UnchainedUUID

public class SessionMiddleware: Middleware {
    let store: SessionStore
    
    public init(store: SessionStore) {
        self.store = store
    }
    
    public func request(request: HTTPRequest, config: UnchainedConfig) -> (request: HTTPRequest?, response: HTTPResponseBase?)? {
        var modifiedRequest = request
        
        // try to restore a session
        var sessionID: String? = nil
        for cookie in request.header.cookies {
            if cookie.name == "sessionID" {
                sessionID = cookie.value
            }
        }
        if let sessionID = sessionID {
            if let id = UUID4(string: sessionID) {
                modifiedRequest.session = self.store.restoreSession(id)
            }
        }
        
        // restart a new session if session ID restore failed
        if modifiedRequest.session == nil {
            let newSession = Session()
            self.store.storeSession(newSession)
            modifiedRequest.session = newSession
        }
        return (request: modifiedRequest, response: nil)
    }
    
    public func response(request: HTTPRequest, response: HTTPResponseBase, config: UnchainedConfig) -> HTTPResponseBase? {
        // send set cookie header
        if let session = request.session {
            let sessionCookie = Cookie(name: "sessionID", value: session.sessionID.description, domain: config.serverName, secure: false, httpOnly: false)
            response.setCookie(sessionCookie)
        }
        return response
    }
}
