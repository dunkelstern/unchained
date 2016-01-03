//
//  session_backend.swift
//  unchained
//
//  Created by Johannes Schriewer on 10/12/15.
//  Copyright © 2015 Johannes Schriewer. All rights reserved.
//

import UnchainedUUID

/// Session store protocol
public protocol SessionStore {
    func storeSession(session: Session)
    func restoreSession(sessionID: UUID4) -> Session?
}
