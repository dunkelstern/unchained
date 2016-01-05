# Unchained a Swift-Web-Framework

Welcome to Unchained, a simple Swift-Web-Framework with a structure that is similar to [Django](http://djangoproject.com).

The aim of this framework is implementing a complete Web-Application stack in Swift. Because of the very beta nature of Swift on Linux this is currently not one hundred percent possible, so a simple socket abstraction is used underneath the Swift layer.

## Table of contents

1. [Quickstart](quickstart.html)
    - Install
    - Web application structure
    - Configuration
    - Response Handler
2. [Installation](install.html)
    - Swift
    - External dependencies
    - Socket support library
3. [Configuration](config.html)
4. [Routing](routing.html)
    - Route definitions
    - Request handler
    - Route reversing
5. [Middleware](middleware.html)
    - What is middleware
    - Available middleware in Unchained core
6. [Response handler](responsehandler.html)
    - Structure
    - CSRF protection
    - HTTPRequest
    - HTTPResponseBase
    - SocketData
    - Predefined Response Classes
    - Predefined Response Handlers
7. TODO: [Database layer](database.html)
8. [Roadmap](roadmap.html)