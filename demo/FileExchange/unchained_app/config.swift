//
//  config.swift
//  FileExchange
//
//  Created by Johannes Schriewer on 09/12/15.
//  Copyright © 2015 Johannes Schriewer. All rights reserved.
//

import unchained

public class FileExchangeConfig: UnchainedConfig {

    public var serverName: String = "voltaire.local"
    public var externalServerURL: String = "http://voltaire.local"

    public lazy var middleware: [Middleware] = [
        SessionMiddleware(store: InMemorySessionStore()),
        URLEncodedPostMiddleware(),
        MultipartPostMiddleware()
    ]
    
    public lazy var routes: [Route] = [
        Route("^/$",                 handler: IndexHandler.forRoute(), name: "index"),
        Route("^/login$",            handler: LoginHandler.forRoute(), name: "login"),
        Route("^/files/(?<filename>.+)$",       handler: StaticFileHandler.forRoute(self.mediaFilesDirectory), name: "files")
    ]
}