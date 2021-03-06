//
//  post_urlencoded_middleware.swift
//  unchained
//
//  Created by Johannes Schriewer on 10/12/15.
//  Copyright © 2015 Johannes Schriewer. All rights reserved.
//

import TwoHundred
import UnchainedString

/// URL Decoding POST data middleware
public class URLEncodedPostMiddleware: Middleware {
    public init() {}
    
    public func request(request: HTTPRequest, config: UnchainedConfig) -> (request: HTTPRequest?, response: HTTPResponseBase?)? {
        guard request.header["content-type"] == "application/x-www-form-urlencoded" &&
              request.data != nil &&
              request.data!.count > 0 else {
            return nil // not our case
        }
        var modifiedRequest = request
        
        // zero terminate data
        modifiedRequest.data!.append(0)
        
        // make string from request body
        if let body = String.fromCString(UnsafePointer<Int8>(modifiedRequest.data!)) {
            
            // split tuples
            let tuples = body.split("&")
        
            // create postData dict
            var postData = [String:String]()
            for item in tuples {
                let parts = item.split("=")
                if parts.count == 2 {
                    postData[parts[0].urlDecodedString()] = parts[1].urlDecodedString()
                }
            }
            
            // save to postData
            modifiedRequest.postData = postData
            
            // return modified request
            return (request: modifiedRequest, response: nil)
        }
        return nil
    }
}

