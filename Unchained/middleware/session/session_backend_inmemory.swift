//
//  session_backend_inmemory.swift
//  unchained
//
//  Created by Johannes Schriewer on 10/12/15.
//  Copyright © 2015 Johannes Schriewer. All rights reserved.
//

import UnchainedUUID

/// In memory session store, only use for debugging purposes
public class InMemorySessionStore: SessionStore {
    private var sessions = [UUID4:Session]()
    
    public init() {
        
    }
    
    public func storeSession(session: Session) {
        sessions[session.sessionID] = session
    }
    
    public func restoreSession(sessionID: UUID4) -> Session? {
        return sessions[sessionID]
    }
}
