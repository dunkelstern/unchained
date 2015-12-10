//
//  config.swift
//  FileExchange
//
//  Created by Johannes Schriewer on 09/12/15.
//  Copyright © 2015 Johannes Schriewer. All rights reserved.
//

import unchained
import SwiftyRegex

public class FileExchangeConfig: UnchainedConfig {

    public var serverName: String { return "localhost" }
    
    public var middleware: [UnchainedMiddleware] {
        return [ SessionMiddleware() ]
    }
    
    public var routes: [UnchainedRoute] {
        return [
            UnchainedRoute("^/$",                 handler: IndexHandler.forRoute()),
            UnchainedRoute("^/login$",            handler: LoginHandler.forRoute()),
            UnchainedRoute("^/files/(?P<id>.+)$", handler: FileHandler.forRoute())
        ]
    }
}