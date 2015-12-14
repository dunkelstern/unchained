//
//  config.swift
//  unchained
//
//  Created by Johannes Schriewer on 30/11/15.
//  Copyright © 2015 Johannes Schriewer. All rights reserved.
//

import Darwin
import twohundred

/// Required settings
public protocol UnchainedConfig {
    
    /// IP address to listen on, defaults to .Wildcard
    var listenAddress:IPAddress { get }
    
    /// Port to listen on, defaults to 8000
    var listenPort:UInt16 { get }
    
    /// Server name, has no default, has to be overridden
    var serverName: String { get }
    
    /// Enabled middleware, empty by default
    var middleware: [UnchainedMiddleware] { get }
    
    /// URL routes, if no route matches the server returns a 404. First route that matches is executed
    var routes: [UnchainedRoute] { get }
    
    /// Template storage location (stencil templates)
    var templateDirectory: String { get }
    
    /// Static file storage location (css and javascript files, images)
    var staticFilesDirectory: String { get }

    /// Media file storage location (generated files, uploaded content)
    var mediaFilesDirectory: String { get }

    /// Temporary file storage location
    var temporaryDirectory: String { get }
}

/// Default settings
extension UnchainedConfig {
    public var listenAddress:IPAddress {
        return .Wildcard
    }
    
    public var listenPort:UInt16 {
        return 8000
    }
    
    public var middleware: [UnchainedMiddleware] {
        return [UnchainedMiddleware]()
    }
    
    public var routes: [UnchainedRoute] {
        return [UnchainedRoute]()
    }
    
    public var templateDirectory: String {
        return self.workDir + "/templates"
    }
    
    public var staticFilesDirectory: String {
        return self.workDir + "/static"
    }

    public var mediaFilesDirectory: String {
        return self.workDir + "/media"
    }
    
    public var temporaryDirectory: String {
        return "/tmp"
    }

    private var workDir: String {
        var buffer = [CChar](count: Int(FILENAME_MAX + 1), repeatedValue: 0)
        if getcwd(&buffer, Int(FILENAME_MAX)) != nil {
            if let path = String(CString: &buffer, encoding: NSUTF8StringEncoding) {
                return path
            }
        }
        return "."
    }
}

/// Add config to request
extension HTTPRequest {
    
    /// Unchained config
    public var config:UnchainedConfig {
        
        get {
            return self.middlewareData["config"]! as! UnchainedConfig
        }
        
        set(newValue) {
            self.middlewareData["config"] = newValue
        }
    }
}