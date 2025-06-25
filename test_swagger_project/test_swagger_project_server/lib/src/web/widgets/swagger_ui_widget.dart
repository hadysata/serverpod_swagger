import 'package:serverpod/serverpod.dart';

/// A widget that displays the Swagger UI documentation.
/// It uses the swagger.html template to render the page.
class SwaggerUIWidget extends Widget {
  /// Creates a new SwaggerUIWidget.
  SwaggerUIWidget() : super(name: 'swagger') {
    // Add any values that might be needed by the template
    values = {
      'title': 'Serverpod API Documentation',
      'openApiUrl': '/openapi.json',
      'cssUrl': 'https://unpkg.com/swagger-ui-dist@4.5.0/swagger-ui.css',
      'bundleUrl': 'https://unpkg.com/swagger-ui-dist@4.5.0/swagger-ui-bundle.js',
      'standalonePresetUrl': 'https://unpkg.com/swagger-ui-dist@4.5.0/swagger-ui-standalone-preset.js',
    };
  }
}