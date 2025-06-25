# Serverpod Swagger UI

A package to automatically generate and serve Swagger UI for a Serverpod backend. This package makes it easy to add interactive API documentation to your Serverpod project.

## Features

- Automatically generates OpenAPI 3.0 specification from Serverpod protocol definitions
- Serves Swagger UI directly from your Serverpod server
- Provides an interactive interface for exploring and testing your API endpoints
- Supports all Serverpod data types and custom classes
- Compatible with Serverpod 2.8.0

## Requirements

- Serverpod 2.8.0 or higher
- Dart 3.0.0 or higher

## Installation

Add the package to your `pubspec.yaml` file:

```yaml
dependencies:
  serverpod_swagger_ui: ^0.2.0
```

Then run:

```bash
dart pub get
```

## Usage

In your Serverpod server's `server.dart` file, add the SwaggerUIRoute to your server's routes:

```dart
import 'dart:io';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_swagger_ui/serverpod_swagger_ui.dart';

Future<void> run(List<String> args) async {
  // Create the server
  final pod = Serverpod(
    args,
    Protocol(), // Your protocol class
    Endpoints(), // Your endpoints class
    // Optional configuration
  );

  // Get the project root directory
  final projectRoot = Directory.current;
  
  // Create a SwaggerUIRoute
  final swaggerRoute = SwaggerUIRoute(projectRoot);
  
  // Add the route to your server
  // IMPORTANT: The path must end with a trailing slash
  pod.webServer.addRoute(swaggerRoute, '/swagger*');

  // Start the server
  await pod.start();
}
```

After starting your server, you can access the Swagger UI at:

```
http://localhost:8082/swagger/
```

**IMPORTANT: Note the trailing slash in the URL - this is required for the Swagger UI to work correctly.**

## How it works

The package works by:

1. Reading your Serverpod endpoints.dart file to understand your API structure
2. Converting the protocol definitions to OpenAPI 3.0 format
3. Serving the Swagger UI interface with your API documentation

## Generating API Specification

The package includes a script to generate the OpenAPI specification file (`apispec.json`) from your Serverpod endpoints:

```bash
dart bin/generate.dart [--base-url=<your-api-base-url>]
```

Options:
- `--base-url`: Specifies the base URL for your API server. This is important for the "Try it out" feature in Swagger UI to work correctly. Example: `--base-url=https://api.example.com`

The script will:
1. Parse your Serverpod endpoints from the generated code
2. Create an OpenAPI 3.0 specification
3. Save it as `apispec.json` in your project root

## Troubleshooting

### Common Issues

1. **"This localhost page can't be found" error**:
   - Make sure you're accessing the URL with a trailing slash: `/swagger/` not `/swagger`
   - Verify that your server is running and the web server port is correct (usually 8082)
   - Check server logs for any error messages related to file paths

2. **Static files not found**:
   - If you see errors about missing static files in the logs, make sure the package is properly installed
   - Try running `dart pub get` again to ensure all dependencies are correctly resolved

3. **Empty API documentation**:
   - Verify that your protocol.yaml file exists and contains valid endpoint definitions
   - Check that you're passing the correct project root directory to the SwaggerUIRoute constructor
   
4. **"Try it out" feature not working**:
   - If the "Try it out" feature sends requests to the wrong host, regenerate your API spec with the `--base-url` parameter
   - Run `dart bin/generate.dart --base-url=http://localhost:8082` (adjust the URL to match your server)

## Customization

You can customize the OpenAPI specification by modifying the `generate.dart` script or by providing command-line arguments:

### Using Command-Line Arguments

The simplest way to customize your API documentation is by using the `--base-url` parameter when generating the specification:

```bash
dart bin/generate.dart --base-url=https://api.example.com
```

### Modifying the OpenAPI Generation

For more advanced customization, you can modify the `generateOpenApiMap` function in the `generate.dart` script to include additional information:

```dart
// Example of how you might customize the OpenAPI generation
Map<String, dynamic> generateOpenApiMap(SwaggerSpec spec, {String? baseUrl}) {
  final openApiMap = {
    'openapi': '3.0.0',
    'info': {
      'title': 'My Custom API Title',
      'version': '2.0.0',
      'description': 'Detailed documentation for my API'
    },
    // ... rest of the implementation
  };
  
  // ... add servers section if baseUrl is provided
  
  return openApiMap;
}
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
