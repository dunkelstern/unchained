//
//  json_middleware.swift
//  unchained
//
//  Created by Johannes Schriewer on 13/12/15.
//  Copyright © 2015 Johannes Schriewer. All rights reserved.
//

import twohundred
import DEjson

/// JSON Decoding data middleware
public class JSONMiddleware: Middleware {
    public init() {}
    
    public func request(request: HTTPRequest, config: UnchainedConfig) -> (request: HTTPRequest?, response: HTTPResponseBase?)? {
        guard (request.header["content-type"] == "application/json" || request.header["content-type"] == "text/json") &&
              request.data != nil &&
              request.data!.count > 0 else {
                return nil // not our case
        }
        var modifiedRequest = request
        
        // zero terminate data
        modifiedRequest.data!.append(0)
        
        // make string from request body
        if let body = String(CString: UnsafePointer<Int8>(modifiedRequest.data!), encoding: NSUTF8StringEncoding) {
            
            let json = JSONDecoder(body).jsonObject
            
            // save to postData
            modifiedRequest.json = json
            
            // return modified request
            return (request: modifiedRequest, response: nil)
        }
        return nil
    }
}

/// JSON extension for HTTPRequest
public extension HTTPRequest {
    public var json:JSONObject? {
        
        get {
            if case let json as JSONObject = self.middlewareData["json"] {
                return json
            }
            return nil
        }
        
        set(newValue) {
            self.middlewareData["json"] = newValue
        }
    }
}
