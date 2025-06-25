## 0.2.1

- Fixed critical issue with package URI resolution that caused "Cannot extract a file path from a package URI" error
- Improved static file path resolution with multiple fallback strategies
- Added detailed logging for easier troubleshooting
- Added user-friendly error pages when static files cannot be found
- Fixed path handling to require trailing slash in route definition
- Added better error handling for file serving

## 0.2.0

- Updated for Serverpod 2.8.0 compatibility
- Updated example to use the correct constructor format for Serverpod 2.8.0
- Removed dependency on shelf and shelf_static packages
- Improved static file handling
- Fixed path resolution for static files

## 0.1.0

- Initial beta release
- Automatically generate OpenAPI 3.0 specification from Serverpod protocol definitions
- Serve Swagger UI directly from your Serverpod server
- Support for all Serverpod data types and custom classes
