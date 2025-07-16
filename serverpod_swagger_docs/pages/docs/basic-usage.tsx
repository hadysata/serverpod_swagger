import React from 'react';
import CodeBlock from '@/components/CodeBlock';
import Link from 'next/link';

export default function BasicUsage() {
  return (
    <div className="prose dark:prose-invert">
      <h1>Basic Usage</h1>
      
      <p>
        This guide will walk you through the basic steps to integrate Swagger UI into your Serverpod project
        and generate OpenAPI documentation for your endpoints.
      </p>

      <h2>Setting Up Swagger UI</h2>
      
      <p>
        To add Swagger UI to your Serverpod server, you need to create a route that serves the Swagger UI interface.
        This is done by adding a <code>SwaggerUIRoute</code> to your server's routes.
      </p>
      
      <h3>Step 1: Import the Package</h3>
      
      <p>
        First, import the Serverpod Swagger package in your server file:
      </p>
      
      <CodeBlock
        language="dart"
        code={`import 'package:serverpod/serverpod.dart';
import 'package:serverpod_swagger/serverpod_swagger.dart';`}
        fileName="server.dart"
      />
      
      <h3>Step 2: Add the Swagger UI Route</h3>
      
      <p>
        Next, add the Swagger UI route to your server's routes in the <code>initializeServer</code> method:
      </p>
      
      <CodeBlock
        language="dart"
        code={`Future<void> initializeServer() async {
  // Initialize the server
  await Serverpod.initialize(
    // ... other configuration
  );

  // Create the pod
  final pod = Serverpod(
    // ... pod configuration
  );

  // Add the Swagger UI route
  pod.addRoute(
    SwaggerUIRoute(
      apiSpecPath: '/api/openapi.json',
      title: 'My API Documentation',
    ),
  );

  // Start the server
  await pod.start();
}`}
        fileName="server.dart"
      />
      
      <p>
        This adds a route that serves the Swagger UI interface at <code>/swagger</code> (the default path).
        The Swagger UI will load the OpenAPI specification from <code>/api/openapi.json</code>.
      </p>

      <h2>Generating OpenAPI Specification</h2>
      
      <p>
        Serverpod Swagger can automatically generate an OpenAPI specification from your Serverpod endpoints.
        This specification is used by the Swagger UI to display your API documentation.
      </p>
      
      <h3>Step 1: Create a Generator</h3>
      
      <p>
        Create a file that will generate the OpenAPI specification. For example, create a file named <code>generate_openapi.dart</code> in your server's <code>bin</code> directory:
      </p>
      
      <CodeBlock
        language="dart"
        code={`import 'package:serverpod_swagger/serverpod_swagger.dart';
import 'package:your_project_server/server.dart';

Future<void> main() async {
  // Initialize the server
  await initializeServer();

  // Generate the OpenAPI specification
  await generateOpenAPI(
    title: 'My API',
    version: '1.0.0',
    description: 'API documentation for My Project',
    outputDirectory: 'generated',
  );
}`}
        fileName="bin/generate_openapi.dart"
      />
      
      <h3>Step 2: Run the Generator</h3>
      
      <p>
        Run the generator to create the OpenAPI specification:
      </p>
      
      <CodeBlock
        language="bash"
        code={`dart run bin/generate_openapi.dart`}
      />
      
      <p>
        This will generate an OpenAPI specification file in the <code>generated</code> directory.
      </p>

      <h3>Step 3: Serve the OpenAPI Specification</h3>
      
      <p>
        To serve the generated OpenAPI specification, add a route to your server that returns the specification file:
      </p>
      
      <CodeBlock
        language="dart"
        code={`import 'dart:io';

class OpenAPIEndpoint extends Endpoint {
  @override
  Future<void> handleRequest(Session session) async {
    // Read the OpenAPI specification file
    final file = File('generated/openapi.json');
    final content = await file.readAsString();

    // Set the content type and return the specification
    session.response.contentType = 'application/json';
    session.response.write(content);
  }
}

// In your server initialization
pod.addEndpoint(
  'api/openapi.json',
  OpenAPIEndpoint(),
);`}
        fileName="lib/src/endpoints/openapi_endpoint.dart"
      />

      <h2>Documenting Your Endpoints</h2>
      
      <p>
        To make your API documentation more useful, you should add documentation to your endpoints.
        Serverpod Swagger uses Dart documentation comments to generate the OpenAPI specification.
      </p>
      
      <CodeBlock
        language="dart"
        code={`/// Get user by ID
///
/// Returns a user by their ID
@Route('/users/:id')
Future<User> getUserById(Session session, int id) async {
  // Implementation
}

/// Create a new user
///
/// Creates a new user with the provided information
@Route('/users', 'POST')
Future<User> createUser(Session session, User user) async {
  // Implementation
}`}
        fileName="lib/src/endpoints/user_endpoint.dart"
      />
      
      <p>
        The first line of the documentation comment is used as the summary, and the rest is used as the description.
      </p>

      <h2>Accessing Swagger UI</h2>
      
      <p>
        Once you have set up Swagger UI and generated the OpenAPI specification, you can access the Swagger UI interface at <code>http://localhost:8080/swagger</code> (assuming your server is running on port 8080).
      </p>
      
      <p>
        The Swagger UI interface allows you to browse your API documentation, see the available endpoints, and even try out the endpoints directly from the UI.
      </p>

      <div className="bg-blue-50 dark:bg-blue-900/20 border-l-4 border-blue-400 p-4 my-4">
        <p className="text-blue-800 dark:text-blue-200 text-sm">
          <strong>Tip:</strong> You can customize the appearance and behavior of the Swagger UI interface by passing additional options to the <code>SwaggerUIRoute</code> constructor. See the
          <Link href="/docs/configuration/swagger-ui-options" className="text-primary-600 hover:text-primary-700 dark:text-primary-400 dark:hover:text-primary-300 ml-1">
            Swagger UI Options
          </Link> page for more information.
        </p>
      </div>

      <h2>Next Steps</h2>
      
      <p>
        Now that you have set up basic Swagger UI integration, you can explore more advanced features:
      </p>
      
      <ul>
        <li>
          <Link href="/docs/configuration/openapi-generation" className="text-primary-600 hover:text-primary-700 dark:text-primary-400 dark:hover:text-primary-300">
            Configure OpenAPI generation
          </Link>
        </li>
        <li>
          <Link href="/docs/configuration/swagger-ui-options" className="text-primary-600 hover:text-primary-700 dark:text-primary-400 dark:hover:text-primary-300">
            Customize Swagger UI options
          </Link>
        </li>
        <li>
          <Link href="/docs/configuration/authentication" className="text-primary-600 hover:text-primary-700 dark:text-primary-400 dark:hover:text-primary-300">
            Add authentication to your API documentation
          </Link>
        </li>
        <li>
          <Link href="/docs/advanced-usage/custom-schemas" className="text-primary-600 hover:text-primary-700 dark:text-primary-400 dark:hover:text-primary-300">
            Define custom schemas
          </Link>
        </li>
      </ul>
    </div>
  );
}