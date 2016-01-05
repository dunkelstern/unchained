# Middleware

Middleware are all classes that are inserted into all request and response handling. Middleware will be executed in the order that is defined in the configuration for all requests that Unchained will process.

## How it works

The `Middleware` protocol is rather short and simple, it just defines two methods:

- `request(request: HTTPRequest, config: UnchainedConfig) -> (request: HTTPRequest?, response: HTTPResponseBase?)?`
- `response(request: HTTPRequest, response: HTTPResponseBase, config: UnchainedConfig) -> HTTPResponseBase?`

### Request middleware

The `request` function is called for each request in order of middleware configuration and the middleware may change the `request` object and then return it again or return a premature `response`. If a response is returned from a middleware processing stops immediately and the response is returned.

If the middleware does not want to change anything in the `request` and neither return a premature `response` it should just return `nil`.

If you want to add any data to a response use the `middlewareData` dictionary with a, unique to your middleware, key to save the data and extend the `HTTPRequest` class with a computed property to access it.

**Example from `JSONMiddleware`:**

~~~swift
public extension HTTPRequest {
    public var json:JSONObject? {

        get {
            if case let json as JSONObject = self.middlewareData["json"] {
                return json
            }
            return nil
        }

        set(newValue) {
            self.middlewareData["json"] = newValue
        }
    }
}
~~~

### Response middleware

The `response` function is called after the router finished with its Response Handler (or the request middleware returned a premature response) in the order that is defined by the configuration.

If the response middleware does not want to change anything in the response it should just return `nil`. Do not return the response verbatim without changing it!

## Available middleware in Unchained core

You are free to implement any middleware you want to but to make your work easier we have defined some middleware for you.

Be aware that there is a minimal set of middleware that should always be active:

- Session
- CSRF

The default Response Handler dispatcher relies on the CSRF middleware to work, so if you want to remove it look at the Response Handler default implementation.

### Session middleware

Session middleware has to be instanciated with a `SessionStore` compliant storage class to store the session data. Currently only one such store is supported: `InMemorySessionStore`, this store looses all data if Unchained is restarted.

#### Initialization

~~~swift
SessionMiddleware(store: InMemorySessionStore())
~~~

#### What it provides

The session middleware creates a session with a random `UUID` for each user that visits and sends a cookie with that session id to the client.

It provides a `session` variable in `HTTPRequest` which stores the current session data (access data with `self.request.session.data["key"]` in any Response Handler).

Session serialization and deserialization is done automatically without manual intervention.

### CSRF middleware

CSRF stands for "Cross Site Request Forgery", and the CSRF middleware is a means of protection against that.

The CSRF middleware needs the session middleware to work.

The middleware has no special configuration, just initialize it with an empty initializer.

#### What it provides

The default Response Handler dispatcher checks if the CSRF token has been included in forms submitted or data POSTed and if it is valid. If that is not the case the request is canceled instantly. (This is configurable, see [6. Response handler](responsehandler.html) for details)

It provides two additional variables in `HTTPRequest`:

- `csrfToken` the token to include in HTML forms (query parameter `CSRFToken`, hidden form field named `CSRFToken` or HTTP header named `X-CSRFToken`)
- `csrfTestPassed` a boolean set to `true` if the request did contain the correct token

### JSON middleware

The JSON middleware decodes JSON request bodies. It has no configuration so just initialize with an empty initializer.

#### What it provides

If the `Content-Type` of the request is `text/json` or `application/json` and the body has a length greater than zero the middleware decodes the body and stores the decoded object in the `json` attribute of `HTTPRequest`

### URL encoded forms middleware

This middleware handles URL encoded request bodies. It has no configuration so just initialize with an empty initializer.

#### What it provides

If the `Content-Type` of the request is `application/x-www-form-urlencoded` it decodes the body data and stores it in the `postData` attribute of `HTTPRequest`

### Multipart Mime encoded forms middleware

This middleware handles Multipart MIME encoded request bodies (file upload HTML forms). It has no configuration so just initialize with an empty initializer.

#### What it provides

If the `Content-Type` of the request is `multipart/form-data` it decodes the body data and stores it in the `postData` attribute of `HTTPRequest`.

If the request contains a file upload field the uploaded files are stored in the `files` attribute of `HTTPRequest`
