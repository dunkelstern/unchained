# Unchained

Django like Swift Web-Framework

See `demo/FileExchange` for a OSX demonstration app.

## Roadmap

### In progress

- Request dispatcher
- Templating engine (Stencil + Glue code)

### TODO

- User model
- Session middleware
- CSRF middleware
- HTTP Server Linux (Swift is missing GCD on linux)
- Multipart Request bodies (file uploads from browser)
- WWW-URL-Encoded forms
- Big file caching while upload
- Chunked responses (continuing file downloads)
- JSON Response Serializer
- Database backend (we'll need at least SQLite and PostgreSQL, probably MySQL)
- Configuration for static files, media uploads and temporary files
- Configuration for DB backends
- Caching mechanism (perhaps backed by redis)

### Done

- HTTP Server OSX (twohundred)
- HTTP Request parser (twohundred)
- HTTP Response serializer (twohundred)
- HTTP KeepAlive and Pipelining
- Streaming download of files
- RegEx processing for routes
- Request routing

