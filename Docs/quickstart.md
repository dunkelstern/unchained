# Quickstart

This document is a very rough overview of how to start a new project with Unchained. When you complete the following steps you'll have a working web application you may deploy to a server.

## Installation

Please go on read [2. Installation](install.html) and then return here.

## The web application

The next step is creating a Swift Package to contain your Web-application:

~~~bash
mkdir UnchainedTestProject
cd UnchainedTestProject

cat > Package.swift <<EOF
import PackageDescription
let package = Package(
    name: "UnchainedTestProject",
    dependencies: [
        .Package(url:"https://github.com/dunkelstern/unchained.git", majorVersion: 0),
        .Package(url:"https://github.com/dunkelstern/UnchainedGlibc.git", majorVersion: 0)
    ]
)
EOF

mkdir Sources
cat > Sources/main.swift <<EOF
#if os(Linux)
    import UnchainedGlibc
#else
    import Darwin
#endif

import Unchained
let server = UnchainedServer(config: UnchainedTestConfig())
server.start()

while true {
    sleep(42)
}
EOF

git init .
~~~

This basically creates a `Package.swift` with Unchained as a dependency (and a `UnchainedGlibc` as a workaround for a bug in Swift's `Glibc` package) and a `main.swift` that runs the server. But it is missing a config (won't compile as of now!), so read on.

## Creating base configuration

The most basic config file looks like this:

~~~swift
import Unchained

public class UnchainedTestConfig: UnchainedConfig {

    public var serverName: String = "localhost"
    public var externalServerURL: String = "http://localhost:8000"

    public lazy var middleware: [Middleware] = [
        SessionMiddleware(store: InMemorySessionStore()),
        CSRFMiddleware()
    ]

    public lazy var routes: [Route] = [
        Route("^/$", handler: IndexHandler.forRoute(), name: "index")
    ]
}
~~~

As you can see you'll have to set up a `serverName`, an `externalServerURL` and at least one route. The middleware set you see here should be the absolute minimum. If you want to support Webbrowser forms you'll need at least the following two in addition:

- `URLEncodedPostMiddleware()`
- `MultipartPostMiddleware()`

This configuration has to be saved somewhere in `Sources` and references a single Response Handler `IndexHandler`, all other URLs that don't match the regular expression from the route will just return an empty page with a HTTP status code of 404 (Not found). For your first Response Handler read on.

## Your first Response Handler

The configuration created a single route with the name of `index` calling the `IndexHandler`. A Response Handler looks like this:

~~~swift
import TwoHundred
import Unchained

public class IndexHandler: UnchainedResponseHandler {
    public let request: HTTPRequest

    public required init(request: HTTPRequest) {
        self.request = request
    }

    public func get(parameters: [String], namedParameters: [String : String]) -> HTTPResponseBase {
        return HTTPResponse(.Ok, body: [.StringData("Hello world!")])
    }
}
~~~

This handler just responds to `GET` and returns the string `Hello world!` to the caller with an HTTP status code of 200 (Ok).

Let us look at what the handler does:

- At first we need `Unchained` because this is an `UnchainedResponseHandler` and we need `TwoHundred` (the name of the Webserver module) for the `HTTPResponse`
- Now we create a class that implements the `UnchainedResponseHandler` protocol
- Requirements of this protocol are a public variable `request` of type `HTTPRequest` and an init function that takes a `HTTPRequest` as a parameter. We are expected to save the request into that variable. Each request from the HTTP client instanciates a new object and all state that we have to carry is in the `request` object
- At last we implement the `get` method to tell the dispatcher we want to handle `GET` requests. There are similar functions for all the other HTTP verbs. All take a `parameters` array that will contain all unnamed parameters (RegEx capture groups from the route) and a `namedParameters` dictionary that will contain all named parameters (named capture groups from the route).
- The function is expected to return a `HTTPResponseBase` object. There are some response objects that implement that protocol: `HTTPResponse`, `JSONResponse`, `StaticFileResponse`, `MediaFileResponse`, `TemplateResponse` and `RedirectResponse` are defined in the Unchained core but you may create more if you want to.
- The body we return is a list of `SocketData` enum instances in case of the basic `HTTPResponse` that will be concatenated together to build the response body. Currently there are 3 options of data you may want to return:
    - `.StringData()` has an associated string value that is copied to the body
    - `.Data()` has an associated `UInt8` array to return
    - `.File()` has an associated file name for a file that will be streamed out to the client.

## Running the thing

At first you'll need to compile the source, this will be made very easy by the Swift package manager:

~~~bash
swift build
~~~

The Package Manager will now download all needed dependencies and compile everything.

The last line of output should look similar to this:

~~~
Linking Executable:  .build/debug/UnchainedTestProject
~~~

Run the server by calling that binary. On Linux the binary will be completely static so it is the only thing you'll have to copy to your server (plus your static resources like images and css of course). If everything worked you should be greeted by something like this:

~~~
2016-01-04T18:33:43Z [INFO ]: Starting server, listening on *:8000
~~~

And if you call the index from a webbrowser (or curl):

~~~
2016-01-04T18:33:51Z [DEBUG]: GET /login, SessionMiddleware modified request
2016-01-04T18:33:51Z [INFO ]: GET /login, 200 OK, login
2016-01-04T18:33:51Z [DEBUG]: GET /login, SessionMiddleware modified response
~~~

As you can see the session middleware just created a fresh session for the user and sent a cookie with the session ID to the browser too.

## Further reading

Just read on in [3. Configuration](config.html) for more information or look into the source code of Unchained (all functionality is documented there too).
