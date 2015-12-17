//
//  config.swift
//  FileExchange
//
//  Created by Johannes Schriewer on 09/12/15.
//  Copyright © 2015 Johannes Schriewer. All rights reserved.
//

import unchained

public class FileExchangeConfig: UnchainedConfig {

    public var serverName: String { return "localhost" }
    
    public var middleware: [Middleware] {
        return [
            SessionMiddleware(store: InMemorySessionStore()),
            URLEncodedPostMiddleware(),
            MultipartPostMiddleware()
        ]
    }
    
    public var routes: [Route] {
        return [
            Route("^/$",                 handler: IndexHandler.forRoute(), name: "index"),
            Route("^/login$",            handler: LoginHandler.forRoute(), name: "login"),
            Route("^/files/(.+)$",       handler: StaticFileHandler.forRoute(self.mediaFilesDirectory), name: "files")
        ]
    }
}