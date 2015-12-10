//
//  session.swift
//  unchained
//
//  Created by Johannes Schriewer on 10/12/15.
//  Copyright © 2015 Johannes Schriewer. All rights reserved.
//

import twohundred

/// Session Class
public class Session {
    static var store: SessionStore = InMemorySessionStore.sharedInstance
    
    var sessionID: UUID4
    var data:[String:String]
    
    public class func restore(sessionID: String) -> Session? {
        if let id = UUID4(string: sessionID) {
            return Session.store.restoreSession(id)
        }
        return nil
    }
    
    public init() {
        self.sessionID = UUID4()
        self.data = [String:String]()
        // TODO: save creation date
        Session.store.storeSession(self)
    }
}

/// Session extension for HTTPRequest
extension HTTPRequest {
    public var session:Session? {
        
        get {
            if case let session as Session = self.middlewareData["session"] {
                return session
            }
            return nil
        }
        
        set(newValue) {
            self.middlewareData["session"] = newValue
        }
    }
}
