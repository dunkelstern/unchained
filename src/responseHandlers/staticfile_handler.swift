//
//  static_file_handler.swift
//  unchained
//
//  Created by Johannes Schriewer on 14/12/15.
//  Copyright © 2015 Johannes Schriewer. All rights reserved.
//

import twohundred

public class StaticFileHandler: UnchainedResponseHandler {
    public let request: HTTPRequest
    private var root: String
    
    public required init(request: HTTPRequest) {
        self.request = request
        self.root = request.config.staticFilesDirectory
    }
    
    public convenience init(request: HTTPRequest, root: String) {
        self.init(request: request)
        self.root = root
    }
    
    public func get(parameters: [String], namedParameters: [String : String]) -> HTTPResponse {
        let filename = self.root + "/\(parameters[1])"
        if let contentType = MimeType.fromFile(filename) {
            return HTTPResponse(.Ok, body: [.File(filename)], contentType: contentType)
        }
        return HTTPResponse(.NotFound)
    }
    
    public func head(parameters: [String], namedParameters: [String : String]) -> HTTPResponse {
        let filename = self.root + "/\(parameters[1])"
        if let contentType = MimeType.fromFile(filename) {
            return HTTPResponse(.Ok, body: [.File(filename)], contentType: contentType)
        }
        return HTTPResponse(.NotFound)
    }
    
    public static func forRoute(root: String) -> UnchainedRoute.RequestHandler {
        return { (request: HTTPRequest, parameters: [String], namedParameters: [String:String]) -> HTTPResponse in
            return StaticFileHandler(request: request, root:root).dispatch(parameters, namedParameters: namedParameters)
        }
    }

}