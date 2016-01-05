//
//  indexHandler.swift
//  FileExchange
//
//  Created by Johannes Schriewer on 09/12/15.
//  Copyright © 2015 Johannes Schriewer. All rights reserved.
//

import TwoHundred
import Unchained

public class IndexHandler: UnchainedResponseHandler {
    public let request: HTTPRequest

    public required init(request: HTTPRequest) {
        self.request = request
    }

    public func get(parameters: [String], namedParameters: [String : String]) -> HTTPResponseBase {
        return HTTPResponse(.Ok, body: [.StringData("Hello world!")])
    }
}