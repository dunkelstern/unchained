//
//  json_response.swift
//  unchained
//
//  Created by Johannes Schriewer on 13/12/15.
//  Copyright © 2015 Johannes Schriewer. All rights reserved.
//

import TwoHundred
import DEjson

/// JSON response, automatically sets correct headers and serializes JSON
public class JSONResponse: HTTPResponseBase {
    
    /// Init with JSONObject
    ///
    /// - parameter statusCode: HTTP Status code to send
    /// - parameter body: JSONObject to send
    /// - parameter headers: (optional) additional headers to send
    /// - parameter contentType: (optional) content type to send (defaults to `application/json`)
    public init(_ statusCode: HTTPStatusCode, body: JSONObject, headers: [HTTPHeader]? = nil, contentType: String = "application/json") {
        super.init()

        guard let jsonData = JSONEncoder(body).jsonString else {
            return
        }

        self.statusCode = statusCode

        if let headers = headers {
            self.headers.appendContentsOf(headers)
        }
        self.headers.append(HTTPHeader("Content-Type", contentType))
        self.headers.append(HTTPHeader("Accept", "application/json"))
        
        self.body.append(.StringData(jsonData))
    }
}