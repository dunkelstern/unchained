//
//  mediafile_response.swift
//  unchained
//
//  Created by Johannes Schriewer on 14/12/15.
//  Copyright © 2015 Johannes Schriewer. All rights reserved.
//

import Foundation

import twohundred

/// Template response, fills a Stencil template with content
public class MediaFileResponse: HTTPResponseBase {
    
    /// Init with template and context
    ///
    /// - parameter path: relative path to media file from configured media file base dir
    /// - parameter request: HTTPRequest for which to render the response
    /// - parameter statusCode: (optional) HTTP Status code to send (defaults to `200 Ok`)
    /// - parameter headers: (optional) additional headers to send
    /// - parameter contentType: (optional) content type to send (defaults to calling `file --mime` on the file)
    public init(_ path: String, request: HTTPRequest, statusCode: HTTPStatusCode = .Ok, headers: [HTTPHeader]? = nil, contentType: String? = nil) {
        super.init()
        
        let filename = request.config.mediaFilesDirectory + "/\(path)"
        
        self.statusCode = statusCode
        
        if let headers = headers {
            self.headers.appendContentsOf(headers)
        }
        if let contentType = contentType {
            self.headers.append(HTTPHeader("Content-Type", contentType))
        } else {
            // determine content type from file
            var buffer = [CChar](count: 256, repeatedValue: 0)
            let fp = popen("file --mime -b '\(filename)'", "r")
            fread(&buffer, 1, 255, fp)
            fclose(fp)
            if let ct = String(CString: buffer, encoding: NSUTF8StringEncoding) {
                self.headers.append(HTTPHeader("Content-Type", ct))
            } else {
                self.headers.append(HTTPHeader("Content-Type", "application/octet-stream"))
            }
        }
        
        self.body = [.File(filename)]
    }
}