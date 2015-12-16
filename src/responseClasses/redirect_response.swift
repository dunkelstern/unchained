//
//  redirect_response.swift
//  unchained
//
//  Created by Johannes Schriewer on 17/12/15.
//  Copyright © 2015 Johannes Schriewer. All rights reserved.
//

import twohundred

/// Redirect response, redirects the user to another URL
public class RedirectResponse: HTTPResponseBase {
    
    /// Init with URL
    ///
    /// - parameter url: URL to redirect to
    /// - parameter permanent: (optional) set to true to send a permanent redirect (defaults to false)
    /// - parameter headers: (optional) additional headers to send
    public init(_ url: String, permanent: Bool = false, headers: [HTTPHeader]? = nil) {
        super.init()
        

        if permanent {
            self.statusCode = .MovedPermanently
        } else {
            self.statusCode = .SeeOther
        }
        
        if let headers = headers {
            self.headers.appendContentsOf(headers)
        }
        self.headers.append(HTTPHeader("Location", url))
    }
}