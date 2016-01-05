//
//  loginHandler.swift
//  FileExchange
//
//  Created by Johannes Schriewer on 09/12/15.
//  Copyright © 2015 Johannes Schriewer. All rights reserved.
//

import TwoHundred
import Unchained

public class LoginHandler: UnchainedResponseHandler {
    public let request: HTTPRequest

    public required init(request: HTTPRequest) {
        self.request = request
    }

    public func get(parameters: [String], namedParameters: [String : String]) -> HTTPResponseBase {
        return HTTPResponse(.Ok, body: [.StringData("<html><body><form method='POST' action='/login' enctype='multipart/form-data'><input type='text' name='username'><br><input type='password' name='password'><br><input type='file' name='upload'><br><input type='submit'><input type='hidden' name='CSRFToken' value='\(self.request.csrfToken)'></form></body></html>")])
    }

    public func post(parameters: [String], namedParameters: [String : String]) -> HTTPResponseBase {
        if let postData = request.postData {
            var responseString = ""
            for (name, value) in postData {
                responseString.appendContentsOf("\(name) = \(value)<br>")
            }
            return HTTPResponse(.Ok, body: [.StringData(responseString)], contentType: "text/html")
        }
        return HTTPResponse(.BadRequest)
    }
}