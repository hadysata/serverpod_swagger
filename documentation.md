# Serverpod Swagger UI Documentation

## Authentication and Endpoint Security

### Securing Specific URL Endpoints

The Serverpod Swagger UI package allows you to secure specific URL endpoints with authentication. This is useful when you want to apply authentication requirements to individual API endpoints while leaving others unsecured.

#### Using the `--secure-single-url` Parameter

To secure a specific URL endpoint, use the `--secure-single-url` parameter when generating your OpenAPI specification:

```bash
dart run serverpod_swagger_ui:generate --auth=jwt --secure-single-url=/jwtAuth/getCurrentUser --base-url=http://localhost:8080
```

This command will:

1. Generate an OpenAPI specification with JWT authentication
2. Apply authentication requirements **only** to the `/jwtAuth/getCurrentUser` endpoint
3. Leave all other endpoints unsecured

#### Example: Securing an Endpoint with JWT Authentication

If you have an endpoint that requires JWT authentication with an authorization token in the header (like `/jwtAuth/getCurrentUser`), you can generate the API specification like this:

```bash
dart run serverpod_swagger_ui:generate --auth=jwt --secure-single-url=/jwtAuth/getCurrentUser --base-url=http://localhost:8080
```

When accessing the Swagger UI, you'll need to:

1. Click the "Authorize" button
2. Enter your JWT token in the format: `Bearer your_token_here`
3. The authorization header will only be applied to the `/jwtAuth/getCurrentUser` endpoint

#### Multiple Secure URLs

If you need to secure multiple specific URL endpoints, you can use the `--secure-endpoints` parameter instead:

```bash
dart run serverpod_swagger_ui:generate --auth=jwt --secure-endpoints=jwtAuth/getCurrentUser,users/profile --base-url=http://localhost:8080
```

### Customizing HTTP Methods

By default, all endpoints in the OpenAPI specification are generated with the HTTP GET method. However, you can customize the HTTP method for specific endpoints using the `--http-method` parameter.

#### Using the `--http-method` Parameter

To specify a custom HTTP method for an endpoint, use the following format:

```bash
dart run serverpod_swagger_ui:generate --http-method=endpoint/method:HTTP_METHOD --base-url=http://localhost:8080
```

Where:
- `endpoint/method` is the path to your endpoint (with or without a leading slash)
- `HTTP_METHOD` is the HTTP method you want to use (e.g., POST, PUT, DELETE, PATCH)

### Verbose Output

If you want to see detailed information about the OpenAPI specification generation process, you can use the `--verbose` flag:

```bash
dart run serverpod_swagger_ui:generate --base-url=http://localhost:8080 --verbose
```

This will display additional information such as:
- The path to the generated specification file
- The number of endpoints included in the specification
- Security schemes defined in the specification

#### Example: Setting a POST Method for a Profile Endpoint

```bash
dart run serverpod_swagger_ui:generate --http-method=profile/user:post --base-url=http://localhost:8080
```

This will configure the `/profile/user` endpoint to use the POST method instead of the default GET method.

#### Multiple HTTP Method Customizations

You can specify multiple `--http-method` parameters to customize different endpoints:

```bash
dart run serverpod_swagger_ui:generate \
  --http-method=profile/user:post \
  --http-method=users/create:put \
  --http-method=documents/delete:delete \
  --base-url=http://localhost:8080
```

### Integrating with Your Serverpod Server

After generating the API specification with secured endpoints, make sure to add the SwaggerUIRoute to your server:

```dart
// In your bin/server.dart file
import 'dart:io';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_swagger_ui/serverpod_swagger_ui.dart';

void main(List<String> args) async {
  // Create your Serverpod server
  final pod = Serverpod(
    args,
    Protocol(),
    Endpoints(),
  );
  
  // Get the project root directory
  final projectRoot = Directory(Directory.current.path);
  
  // Create a SwaggerUIRoute
  final swaggerRoute = SwaggerUIRoute(projectRoot);
  
  // Add the route to your web server
  pod.webServer.addRoute(swaggerRoute, '/swagger/');
  
  // Start the server
  await pod.start();
}
```

Access the Swagger UI at `http://localhost:8082/swagger/` to test your secured endpoint.