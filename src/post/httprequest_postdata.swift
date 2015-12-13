//
//  httprequest_postdata.swift
//  unchained
//
//  Created by Johannes Schriewer on 11/12/15.
//  Copyright © 2015 Johannes Schriewer. All rights reserved.
//

import twohundred

public class UploadedFile {
    public let data:[UInt8]
    public var filename:String
    public var mimeType:String
    
    // TODO: Write data to temp file and mmap back in on request
    
    public init(data: [UInt8], filename: String, mimeType: String = "application/octet-stream") {
        self.data = data
        self.filename = filename
        self.mimeType = mimeType
    }
}

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
    public var files:[String:UploadedFile]? {
        
        get {
            if case let files as [String:UploadedFile] = self.middlewareData["fileData"] {
                return files
            }
            return nil
        }
        
        set(newValue) {
            self.middlewareData["fileData"] = newValue
        }
    }

}
