# Routing

Routing is used to map a Response Handler to a request URL. Static Webservers used to map the paths on disk to URLs in a more or less one to one mapping. This obviously won't work for a modern Web framework so a set of rules is defined to map a URL to a Response Handler class.

## Route definitions

The configuration of Unchained contains an array of `Route` instances for route definitions. This is just a class named `Route` that will be initialized with a regular expression, a request handler and optionally a name.

~~~swift
Route("^/$", handler: ResponseHandlerClass.forRoute(), name: "index")
~~~

To determine which route to use for a requested URL all route definitions are matched against the URL in the configured order. The first route to match is executed.

### Regular expressions

For determining which route to use you define a regular expression (see [Regular expression tutorial](http://www.regular-expressions.info/tutorial.html)) that defines the shape of the URL.

Why regular expressions you may ask, but the answer is rather simple: They are fast and flexible yet a strong enough definition to do simple parameter validation right on matching time.

If you want Response Handlers that take parameters just define capture groups in the URLs. But beware: if you want to reverse the URL programmatically all regular expression code has to be wrapped in capture groups of one type (either named or unnamed).

Do not include get parameters in your regular expressions, those will be stripped off before matching. If you want to handle them do so in the Response Handler.

#### Examples

- `^/$` matches the page index without any path
- `^/login$` matches the `/login` path
- `^/files/(<file_id>[0-9]+)$` matches all URLs that start with `/files/` and contain a numeric only parameter of at least one digit that will be put into the named parameter `file_id`
- `^/users/([0-9]+)$` matches all URLs that start with `/users/` and have a numeric user id of at least one digit. The parameter will be in the unnamed parameter set at position 1 (zero is always the full string if it matched)

## Request Handler

The request handler in the `handler:` part of the initializer is a closure that takes three parameters (`request`, `parameters` and `namedParameters`) and returns a `HTTPResponseBase` object.

You probably won't have to create those closures by yourself as every Response Handler that speaks the `UnchainedResponseHandler` protocol has a implicit function named `forRoute()` that returns exactly the closure to be used here.

For more information about Response Handlers read [6. Response handler](responsehandler.html).

## Route reversing

If you want to redirect or link to another URL you could create the URLs by yourself but if the server name or domain changes or you migrate from HTTP to HTTPS you would have to edit all your code to reflect that change. To avoid that additional work there is a route reversing functionality built in.

Every `UnchainedResponseHandler` has a function `reverseRoute` that takes a route name, some parameters and an optional `absolute` boolean.

The route name is the name you define when setting up the route with the `name` parameter.

To reverse the `index` route from the first example you could write the following in a Response Handler:

~~~swift
self.reverseRoute("index")
~~~

This yields probably a string of `/` or the base url of the server if you specified `absolute: true` additionally (something like `http://example.com/`)

If the RegEx pattern contained parameters supply them with the `parameters` attribute like this:

~~~swift
self.reverseRoute("files", parameters: [ "file_id" : "1234" ], absolute: true)
~~~

This will recreate a `files` URL with a `file_id` of `1234` (for example: `http://example.com/files/1234`)

### Restrictions

For route reversing to work all text that is part of a regular expression has to be in capture groups or the URL that will be generated is most probably invalid:

- RegEx pattern: `^/files/([0-9]+).*$`
- Reversed URL: `/files/1234.*`

This is probably not what you want.

Additionally you may not mix and match named and unnamed parameters in a RegEx pattern that should be reversable:

This for example would lead to an exception: `^/files/([0-9]+).(<extension>[a-z]+)`
