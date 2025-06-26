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

### Updating Existing Specifications

Instead of regenerating the entire OpenAPI specification from scratch each time you want to make a change, you can use the `--update` flag to modify an existing specification file:

```bash
dart run serverpod_swagger_ui:generate --update --http-method=greeting/hello:post
```

This command will:
1. Read the existing `apispec.json` file
2. Apply the specified changes (in this case, changing the HTTP method for the `greeting/hello` endpoint to POST)
3. Save the updated specification back to the file

#### Benefits of Using the Update Mode

- **Efficiency**: No need to reprocess all endpoints when making small changes
- **Convenience**: You don't need to remember and specify all original parameters
- **Consistency**: Maintains other aspects of your API specification while updating specific parts
- **Time-saving**: Particularly useful in large projects with many endpoints

#### When to Use Update Mode

- When modifying HTTP methods for specific endpoints
- When changing authentication requirements
- When updating the base URL
- When making any incremental changes to an existing specification

#### When to Avoid Update Mode

- When your endpoints.dart file has changed significantly
- When you want to regenerate the entire specification from scratch
- When the apispec.json file doesn't exist yet

#### Combining with Other Parameters

The `--update` flag can be combined with any other parameter to modify specific aspects of your API documentation:

```bash
# Update HTTP method and secure a specific endpoint
dart run serverpod_swagger_ui:generate --update --http-method=users/profile:put --secure-single-url=/users/profile

# Update base URL only
dart run serverpod_swagger_ui:generate --update --base-url=https://api.example.com

# Update authentication type
dart run serverpod_swagger_ui:generate --update --auth=apikey
```

This approach is more efficient and convenient for making incremental changes to your API documentation.

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