//
//  session.swift
//  unchained
//
//  Created by Johannes Schriewer on 10/12/15.
//  Copyright © 2015 Johannes Schriewer. All rights reserved.
//

import TwoHundred
import UnchainedUUID

/// Session Class
public class Session {
    public let sessionID: UUID4
    public var data:[String:String]
    
    public init() {
        self.sessionID = UUID4()
        self.data = [String:String]()
        // TODO: save creation date
    }
    
    public init(sessionID: UUID4, data: [String:String]) {
        self.sessionID = sessionID
        self.data = data
    }
    
}

/// Session extension for HTTPRequest
public extension HTTPRequest {
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
