//
//  mediafile_response.swift
//  unchained
//
//  Created by Johannes Schriewer on 14/12/15.
//  Copyright © 2015 Johannes Schriewer. All rights reserved.
//

import Darwin

import TwoHundred

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
        
        if let headers = headers {
            self.headers.appendContentsOf(headers)
        }
        
        if let ct = MimeType.fromFile(filename) {
            self.statusCode = statusCode
            self.body = [.File(filename)]
            if let contentType = contentType {
                self.headers.append(HTTPHeader("Content-Type", contentType))
            } else {
                self.headers.append(HTTPHeader("Content-Type", ct))
            }
        } else {
            self.statusCode = .NotFound
        }
    }
}