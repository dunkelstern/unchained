//
//  config.swift
//  unchained
//
//  Created by Johannes Schriewer on 30/11/15.
//  Copyright © 2015 Johannes Schriewer. All rights reserved.
//

#if os(Linux)
    import UnchainedGlibc
#else
    import Darwin
#endif

import TwoHundred
import UnchainedIPAddress

/// Required settings
public protocol UnchainedConfig {

    /// IP address to listen on, defaults to .Wildcard
    var listenAddress:IPAddress { get }

    /// Port to listen on, defaults to 8000
    var listenPort:UInt16 { get }

    /// Server name, has no default, has to be overridden
    var serverName: String { get }

    /// External visible server base URL, has no default, has to be overridden
    var externalServerURL: String { get }

    /// Path to the logfile, set to nil to log to stdout
    var logfilePath: String? { get }

    /// Enabled middleware, empty by default
    var middleware: [Middleware] { get }

    /// URL routes, if no route matches the server returns a 404. First route that matches is executed, use `lazy` to get access to `self`
    var routes: [Route] { get }

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

    public var logfilePath:String? {
        return nil
    }

    public var middleware: [Middleware] {
        return [Middleware]()
    }

    public var routes: [Route] {
        return [Route]()
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
            if let path = String.fromCString(&buffer) {
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
