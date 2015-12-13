# Unchained

Django like Swift Web-Framework

See `demo/FileExchange` for a OSX demonstration app.

## Roadmap

### In progress

- Templating engine (Stencil + Glue code)
- JSON Response Serializer

### TODO

- Configuration for static files, media uploads and temporary files
- Static file server response handlers (Should support HEAD requests)
- CSRF middleware
- Database backend (we'll need at least SQLite and PostgreSQL, probably MySQL)
- Configuration for DB backends
- User model
- Session Middleware backends other than in memory
- HTTP Server Linux (Swift is missing GCD on linux)
- Big file caching while upload
- Caching mechanism (perhaps backed by redis)
- Chunked responses (continuing file downloads)

### Done

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

