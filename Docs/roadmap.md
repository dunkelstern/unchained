# Roadmap

Basically a TODO list

## In progress

- Database backend (we'll need at least SQLite and PostgreSQL, probably MySQL)
- Configuration for DB backends

## TODO

- User model
- Session Middleware backends other than in memory
- Big file caching while upload
- Caching mechanism (perhaps backed by redis)
- Chunked responses (continuing file downloads)
- e-mail sending
- gzip middleware
- SSL/TLS
- Session timeouts
- Markdown renderer

## Done

- HTTP Server OSX (twohundred)
- HTTP Request parser (twohundred)
- HTTP Response serializer (twohundred)
- HTTP KeepAlive and Pipelining
- Streaming download of files
- RegEx processing for routes
- Request routing
- Request dispatcher
- Session middleware
- WWW-URL-Encoded forms
- Multipart Request bodies (file uploads from browser)
- JSON parser middleware (parses JSON and puts it in request.json)
- JSON Response Serializer
- Templating engine (Stencil + Glue code)
- Configuration for static files, media uploads and temporary files
- Static/Media file Response
- Static file server response handlers (Should support HEAD requests)
- Redirect Response
- Centralized logging
- URL reversing
- CSRF middleware
- HTTP Server Linux (Swift is missing GCD on linux)
- Connection timeouts
