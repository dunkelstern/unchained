//
//  session_backend_inmemory.swift
//  unchained
//
//  Created by Johannes Schriewer on 10/12/15.
//  Copyright © 2015 Johannes Schriewer. All rights reserved.
//

import twohundred

/// In memory session store, only use for debugging purposes
public class InMemorySessionStore: SessionStore {
    public static let sharedInstance: SessionStore = InMemorySessionStore()
    
    private var sessions = [UUID4:Session]()
    
    public func storeSession(session: Session) {
        sessions[session.sessionID] = session
    }
    
    public func restoreSession(sessionID: UUID4) -> Session? {
        return sessions[sessionID]
    }
}
