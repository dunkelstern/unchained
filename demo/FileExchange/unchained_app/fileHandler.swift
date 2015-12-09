//
//  uploadHandler.swift
//  FileExchange
//
//  Created by Johannes Schriewer on 09/12/15.
//  Copyright © 2015 Johannes Schriewer. All rights reserved.
//

import twohundred
import unchained

public class FileHandler: UnchainedResponseHandler {
    public let request: HTTPRequest
    
    public required init(request: HTTPRequest) {
        self.request = request
    }
    
    public func get(parameters: [String], namedParameters: [String : String]) -> HTTPResponse {
        return HTTPResponse(.Ok, body: [.StringData("Hello world (\(namedParameters["id"]!))!")])
    }

    public func post(parameters: [String], namedParameters: [String : String]) -> HTTPResponse {
        return HTTPResponse(.Ok, body: [.StringData("Hello world!")])
    }
}