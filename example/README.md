# Serverpod Swagger Example

This example demonstrates how to integrate Serverpod Swagger into your Serverpod project.

## Getting Started

1. Add the `serverpod_swagger` package to your `pubspec.yaml` file:

```yaml
dependencies:
  serverpod_swagger: ^0.1.3
```

2. Run `dart pub get` to install the package.

3. Add the Swagger UI route to your server file as shown in `server.dart`:

```dart
import 'dart:io';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_swagger/serverpod_swagger.dart';

void run(List<String> args) async {
  final pod = Serverpod(
    args,
    // Your protocol and endpoints classes
  );
  
  // Add the Swagger UI route
  final swaggerRoute = SwaggerUIRoute(Directory.current);
  pod.webServer.addRoute(swaggerRoute, '/swagger*');

  await pod.start();
}
```

4. Generate the OpenAPI specification for your Serverpod project:

```bash
dart run serverpod_swagger:generate --base-url=http://localhost:8080
```

5. Start your Serverpod server and access the Swagger UI at:

```
http://localhost:8082/swagger/
```

## Additional Configuration

You can customize the OpenAPI specification generation with various command-line arguments:

```bash
# Specify authentication type
dart run serverpod_swagger:generate --auth=jwt

# Specify HTTP methods for endpoints
dart run serverpod_swagger:generate --method=post:createUser,get:getUser

# Secure specific endpoints
dart run serverpod_swagger:generate --secure=createUser,updateUser
```

See the main package documentation for more details on available options.
