// lib/serverpod_swagger_ui.dart
import 'dart:io';
import 'package:serverpod/serverpod.dart';
import 'package:path/path.dart' as p;

/// A development-friendly route that serves a live-reloading Swagger UI.
/// It re-reads the apispec.json on every request to show changes instantly.
class SwaggerUIRoute extends Route {
  final Directory _projectRoot;
  final String _swaggerHtml;
  final String _mountPath;
  final String _redirectPath;
  final String _specPath;

  SwaggerUIRoute(Directory projectRoot, {String mountPath = '/swagger/'})
      : assert(mountPath.endsWith('/'), 'mountPath must end with a trailing slash.'),
        _projectRoot = projectRoot,
        _mountPath = mountPath,
        _redirectPath = mountPath.substring(0, mountPath.length - 1),
        _specPath = p.join(mountPath, 'apispec.json'),
        // The HTML is static, so we can generate it once.
        _swaggerHtml = _getSwaggerHtml();

  @override
  Future<bool> handleCall(Session session, HttpRequest request) async {
    final path = request.uri.path;

    // --- ORDER IS CRITICAL: Most specific paths first ---

    // 1. Handle the request for the JSON spec file.
    if (path == _specPath) {
      session.log('Serving LIVE version of API spec at $path');
      
      // --- FIX FOR BROWSER CACHING ---
      // Add headers to tell the browser to NEVER cache this specific file.
      request.response.headers.set('Cache-Control', 'no-store, no-cache, must-revalidate');
      request.response.headers.set('Pragma', 'no-cache');
      request.response.headers.set('Expires', '0');
      // --- END OF FIX ---

      // Read the file from disk ON EVERY REQUEST. This solves server-side caching.
      final specFile = File(p.join(_projectRoot.path, 'apispec.json'));
      if (await specFile.exists()) {
        request.response.headers.contentType = ContentType.json;
        request.response.write(await specFile.readAsString());
      } else {
        request.response.statusCode = HttpStatus.notFound;
        request.response.write('Error: apispec.json not found at ${specFile.path}');
      }

      await request.response.close();
      return true; // We handled this request.
    }

    // 2. Handle the request for the main UI page.
    if (path == _mountPath) {
      session.log('Serving Swagger UI main page at $path');
      request.response.headers.contentType = ContentType.html;
      request.response.write(_swaggerHtml);
      await request.response.close();
      return true;
    }

    // 3. Handle the redirect from '/swagger' to '/swagger/'.
    if (path == _redirectPath) {
      session.log('Redirecting from $path to $_mountPath');
      request.response.statusCode = HttpStatus.movedPermanently;
      request.response.headers.set('Location', _mountPath);
      await request.response.close();
      return true;
    }

    return false;
  }
  
  // This helper is static and can be called from the constructor.
  static String _getSwaggerHtml() {
    return '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Serverpod API - Swagger UI</title>
  <link rel="stylesheet" href="https://unpkg.com/swagger-ui-dist@5.11.0/swagger-ui.css" />
</head>
<body>
  <div id="swagger-ui"></div>
  <script src="https://unpkg.com/swagger-ui-dist@5.11.0/swagger-ui-bundle.js"></script>
  <script>
    window.onload = function() {
      const ui = SwaggerUIBundle({
        url: "apispec.json", // Relative URL is robust
        dom_id: '#swagger-ui',
        deepLinking: true,
        // Enable all OAuth-related functionality
        oauth2RedirectUrl: window.location.origin + window.location.pathname + 'oauth2-redirect.html',
        // Show auth buttons at the top
        displayOperationId: true,
        // Persist auth data in localStorage
        persistAuthorization: true,
        // Improve the auth UX
        withCredentials: true,
        // Enable the try it out feature by default
        tryItOutEnabled: true,
      });
      window.ui = ui;
    };
  </script>
</body>
</html>''';
  }
}