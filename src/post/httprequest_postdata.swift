//
//  httprequest_postdata.swift
//  unchained
//
//  Created by Johannes Schriewer on 11/12/15.
//  Copyright © 2015 Johannes Schriewer. All rights reserved.
//

import twohundred

/// PostData extension for HTTPRequest
extension HTTPRequest {
    
    /// Decoded POST data
    public var postData:[String:String]? {
        
        get {
            if case let postData as [String:String] = self.middlewareData["postData"] {
                return postData
            }
            return nil
        }
        
        set(newValue) {
            self.middlewareData["postData"] = newValue
        }
    }

    /// File upload data
    public var files:[String:[UInt8]]? {
        
        get {
            if case let files as [String:[UInt8]] = self.middlewareData["fileData"] {
                return files
            }
            return nil
        }
        
        set(newValue) {
            self.middlewareData["fileData"] = newValue
        }
    }

}
