//
//  template_response.swift
//  unchained
//
//  Created by Johannes Schriewer on 13/12/15.
//  Copyright © 2015 Johannes Schriewer. All rights reserved.
//

import twohundred
import Stencil
import PathKit

/// Template response, fills a Stencil template with content
public class TemplateResponse: HTTPResponseBase {
    
    /// Init with template and context
    ///
    /// - parameter template: relative path to template from configured template base dir
    /// - parameter context: template context to render
    /// - parameter request: HTTPRequest for which to render the response
    /// - parameter statusCode: (optional) HTTP Status code to send (defaults to `200 Ok`)
    /// - parameter headers: (optional) additional headers to send
    /// - parameter contentType: (optional) content type to send (defaults to `text/html`)
    public init(_ template: String, context: [String:Any], request: HTTPRequest, statusCode: HTTPStatusCode = .Ok, headers: [HTTPHeader]? = nil, contentType: String = "text/html") {
        super.init()
        
        self.statusCode = statusCode
        
        if let headers = headers {
            self.headers.appendContentsOf(headers)
        }
        self.headers.append(HTTPHeader("Content-Type", contentType))

        let templatePath = request.config.templateDirectory + "/\(template)"
        do {
            let t = try Template(path: Path(templatePath))
            do {
                let body = try t.render(Context(dictionary: context), namespace: nil)
                self.body.append(.StringData(body))
            } catch let error as TemplateSyntaxError {
                self.statusCode = .InternalServerError
                self.body = [.StringData(error.description)]
            }
        } catch {
            self.statusCode = .InternalServerError
            self.body = [.StringData("Template not found")]
        }
    }
}