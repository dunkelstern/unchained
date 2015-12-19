//
//  router.swift
//  unchained
//
//  Created by Johannes Schriewer on 30/11/15.
//  Copyright © 2015 Johannes Schriewer. All rights reserved.
//

import Darwin
import twohundred
import SwiftyRegex

/// Unchained route entry
public struct Route {
    
    /// Router errors
    public enum Error: ErrorType {
        /// No route with that name exists
        case NoRouteWithThatName(name: String)
        
        /// Route contains mix of numbered and named parameters
        case MixedNumberedAndNamedParameters
        
        /// Missing parameter of `name` to call that route
        case MissingParameterForRoute(name: String)
        
        /// Wrong parameter count for a route with unnamed parameters
        case WrongParameterCountForRoute
    }
    
    /// A route request handler, takes `request`, numbered `parameters` and `namedParameters`, returns `HTTPResponse`
    public typealias RequestHandler = ((request: HTTPRequest, parameters: [String], namedParameters: [String:String]) -> HTTPResponse)
    
    /// Name of the route (used for route reversing)
    public var name: String

    private var re: RegEx?
    private var handler:RequestHandler
    
    /// Initialize a route
    ///
    /// - parameter regex: Regex to match
    /// - parameter handler: handler callback to run if route matches
    /// - parameter name: (optional) name of this route to `reverse`
    public init(_ regex: String, handler:RequestHandler, name: String? = nil) {
        do {
            self.re = try RegEx(pattern: regex)
        } catch RegEx.Error.InvalidPattern(let offset, let message) {
            Log.error("Route: Pattern parse error for pattern \(regex) at character \(offset): \(message)")
        } catch {
            // unused
        }

        self.handler = handler
        
        if let name = name {
            self.name = name
        } else {
            self.name = "r'\(regex)'"
        }
    }
    
    /// execute a route on a request
    ///
    /// - parameter request: the request on which to execute this route
    /// - returns: response to the request or nil if the route does not match
    public func execute(request: HTTPRequest) -> HTTPResponse? {
        guard let re = self.re else {
            return nil
        }
        let matches = re.match(request.header.url)
        if matches.numberedParams.count > 0 {
            return self.handler(request: request, parameters: matches.numberedParams, namedParameters: matches.namedParams)
        }
        return nil
    }
    
    // MARK: - Internal
    
    enum RouteComponentType {
        case Text(String)
        case NamedPattern(String)
        case NumberedPattern(Int)
    }
    
    /// split a route regex into components for route reversal
    ///
    /// - returns: Array of route components
    func splitIntoComponents() -> [RouteComponentType]? {
        guard let pattern = self.re?.pattern else {
            return nil
        }

        var patternNum = 0
        var openBrackets = 0
        var components = [RouteComponentType]()
        var currentComponent = ""
        currentComponent.reserveCapacity(pattern.characters.count)
        var gen = pattern.characters.generate()
        
        while let c = gen.next() {
            switch c {
            case "(":
                if openBrackets == 0 {
                    // split point
                    if currentComponent.characters.count > 0 {
                        patternNum++
                        components.append(.Text(currentComponent))
                        currentComponent.removeAll()
                    }
                }
                break
            case ")":
                if openBrackets == 0 {
                    // split point
                    if currentComponent.characters.count > 0 {
                        var found = false
                        for (name, idx) in self.re!.namedCaptureGroups {
                            if idx == patternNum {
                                components.append(.NamedPattern(name))
                                currentComponent.removeAll()
                                found = true
                                break
                            }
                        }
                        if !found {
                            components.append(.NumberedPattern(patternNum))
                        }
                    }
                }
            case "[":
                openBrackets++
            case "]":
                openBrackets--
            case "\\":
                // skip next char
                gen.next()
            default:
                currentComponent.append(c)
            }
        }
        if currentComponent.characters.count > 0 {
            components.append(.Text(currentComponent))
        }
        
        // strip ^ on start
        if case .Text(let text) = components.first! {
            if text.characters.first! == "^" {
                components[0] = .Text(text.substringFromIndex(text.startIndex.advancedBy(1)))
            }
        }
        
        // strip $ on end
        if case .Text(let text) = components.last! {
            if text.characters.last! == "$" {
                components.removeLast()
                if text.characters.count > 1 {
                    components.append(.Text(text.substringToIndex(text.startIndex.advancedBy(text.characters.count - 2))))
                }
            }
        }
        
        return components
    }
}


/// Route reversion
public extension UnchainedResponseHandler {
    
    /// reverse a route with named parameters
    ///
    /// - parameter name: the name of the route URL to produce
    /// - parameter parameters: the parameters to substitute
    /// - parameter absolute: (optional) return relative path (from root, default) or absolute URL with hostname
    /// - returns: URL of route with parameters
    ///
    /// - throws: Throws errors if route could not be reversed
    public func reverseRoute(name: String, parameters:[String:String], absolute: Bool = false) throws -> String {
        guard let route = self.fetchRoute(name) else {
            throw Route.Error.NoRouteWithThatName(name: name)
        }
        
        var result = ""
        if absolute {
            result.appendContentsOf(self.request.config.externalServerURL)
        }

        // Build route string
        for item in route {
            switch item {
            case .NumberedPattern:
                throw Route.Error.MixedNumberedAndNamedParameters
            case .NamedPattern(let name):
                if let param = parameters[name] {
                    result.appendContentsOf(param)
                } else {
                    throw Route.Error.MissingParameterForRoute(name: name)
                }
            case .Text(let text):
                result.appendContentsOf(text)
            }
        }
        
        return result
    }

    /// reverse a route with numbered parameters
    ///
    /// - parameter name: the name of the route URL to produce
    /// - parameter parameters: the parameters to substitute
    /// - parameter absolute: (optional) return relative path (from root, default) or absolute URL with hostname
    /// - returns: URL of route with parameters
    ///
    /// - throws: Throws errors if route could not be reversed
    public func reverseRoute(name: String, parameters:[String], absolute: Bool = false) throws -> String {
        guard let route = self.fetchRoute(name) else {
            throw Route.Error.NoRouteWithThatName(name: name)
        }

        var result = ""
        if absolute {
            result.appendContentsOf(self.request.config.externalServerURL)
        }
        
        // Build route string
        for item in route {
            switch item {
            case .NumberedPattern(let num):
                if parameters.count > num - 1 {
                    result.appendContentsOf(parameters[num - 1])
                } else {
                    throw Route.Error.WrongParameterCountForRoute
                }
            case .NamedPattern:
                throw Route.Error.MixedNumberedAndNamedParameters
            case .Text(let text):
                result.appendContentsOf(text)
            }
        }
        
        return result
    }

    /// reverse a route without parameters
    ///
    /// - parameter name: the name of the route URL to produce
    /// - parameter absolute: (optional) return relative path (from root, default) or absolute URL with hostname
    /// - returns: URL of route with parameters
    ///
    /// - throws: Throws errors if route could not be reversed
    public func reverseRoute(name: String, absolute: Bool = false) throws -> String {
        guard let route = self.fetchRoute(name) else {
            throw Route.Error.NoRouteWithThatName(name: name)
        }

        var result = ""
        if absolute {
            result.appendContentsOf(self.request.config.externalServerURL)
        }
        
        // Build route string
        for item in route {
            switch item {
            case .NumberedPattern:
                throw Route.Error.WrongParameterCountForRoute
            case .NamedPattern(let name):
                throw Route.Error.MissingParameterForRoute(name: name)
            case .Text(let text):
                result.appendContentsOf(text)
            }
        }
        
        return result
    }

    /// Fetch a route by name
    ///
    /// - parameter name: Name to search
    /// - returns: Route instance or nil if not found
    private func fetchRoute(name: String) -> [Route.RouteComponentType]? {
        for route in self.request.config.routes {
            if route.name == name {
                return route.splitIntoComponents()
            }
        }
        return nil
    }

}
