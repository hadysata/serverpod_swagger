import React from 'react';
import Link from 'next/link';
import CodeBlock from '@/components/CodeBlock';

export default function Examples() {
  return (
    <div className="prose dark:prose-invert">
      <h1>Serverpod Swagger Examples</h1>
      
      <p>
        This page provides practical examples of how to use Serverpod Swagger in different scenarios.
        Each example includes code snippets and explanations to help you implement Swagger UI in your Serverpod application.
      </p>

      <h2>Basic Example</h2>
      
      <p>
        This example shows the minimal setup required to add Swagger UI to your Serverpod server.
      </p>
      
      <CodeBlock
        language="dart"
        code={`import 'dart:io';\nimport 'package:serverpod/serverpod.dart';\nimport 'package:serverpod_swagger/serverpod_swagger.dart';\n\nfuture<void> main() async {\n  // Create the server\n  final pod = Serverpod(\n    args,\n    [\n      // Your endpoint classes\n    ],\n  );\n  \n  // Add the Swagger UI route\n  pod.webServer.addRoute(\n    SwaggerUIRoute(\n      Directory(Directory.current.path),\n      mountPath: '/swagger/',\n    ),\n  );\n  \n  // Start the server\n  await pod.start();\n}`}
        fileName="main.dart"
      />
      
      <p>
        With this setup, you can access the Swagger UI at <code>http://localhost:8082/swagger/</code> after generating the OpenAPI specification with <code>dart run serverpod_swagger:generate</code>.
      </p>

      <h2>Complete Example with Authentication</h2>
      
      <p>
        This example shows a more complete setup with authentication, custom styling, and multiple API versions.
      </p>
      
      <h3>Step 1: Create security definitions</h3>
      
      <CodeBlock
        language="yaml"
        code={`security:\n  - BearerAuth: []\n\ncomponents:\n  securitySchemes:\n    BearerAuth:\n      type: http\n      scheme: bearer\n      bearerFormat: JWT\n      description: Enter your JWT token in the format 'Bearer {token}'`}
        fileName="openapi_security.yaml"
      />
      
      <h3>Step 2: Create custom CSS for Swagger UI</h3>
      
      <CodeBlock
        language="css"
        code={`.swagger-ui .topbar {\n  background-color: #1a365d;\n}\n\n.swagger-ui .info .title {\n  color: #2c5282;\n}\n\n.swagger-ui .opblock-tag {\n  background-color: #ebf8ff;\n}\n\n.swagger-ui .opblock.opblock-get {\n  border-color: #4299e1;\n  background-color: #ebf8ff;\n}\n\n.swagger-ui .opblock.opblock-post {\n  border-color: #48bb78;\n  background-color: #f0fff4;\n}`}
        fileName="web/custom/swagger.css"
      />
      
      <h3>Step 3: Configure the server with Swagger UI</h3>
      
      <CodeBlock
        language="dart"
        code={`import 'dart:io';\nimport 'package:serverpod/serverpod.dart';\nimport 'package:serverpod_swagger/serverpod_swagger.dart';\n\nfuture<void> main() async {\n  // Create the server\n  final pod = Serverpod(\n    args,\n    [\n      // Your endpoint classes\n    ],\n  );\n  \n  // Add the Swagger UI route for the current version\n  pod.webServer.addRoute(\n    SwaggerUIRoute(\n      Directory(Directory.current.path),\n      mountPath: '/swagger/',\n      apiSpecPath: 'apispec.json',\n      title: 'API Documentation (Current)',\n      customCssUrl: '/custom/swagger.css',\n      persistAuthorization: true,\n      tryItOutEnabled: true,\n    ),\n  );\n  \n  // Add the Swagger UI route for the v1 version\n  pod.webServer.addRoute(\n    SwaggerUIRoute(\n      Directory(Directory.current.path),\n      mountPath: '/swagger/v1/',\n      apiSpecPath: 'apispec.v1.json',\n      title: 'API Documentation (v1)',\n      customCssUrl: '/custom/swagger.css',\n      persistAuthorization: true,\n      tryItOutEnabled: true,\n    ),\n  );\n  \n  // Start the server\n  await pod.start();\n}`}
        fileName="main.dart"
      />
      
      <h3>Step 4: Generate OpenAPI specifications for different versions</h3>
      
      <CodeBlock
        language="bash"
        code={`# Generate current version\ndart run serverpod_swagger:generate --output=apispec.json --title="My API" --version="2.0.0"\n\n# Generate v1 version\ndart run serverpod_swagger:generate --output=apispec.v1.json --title="My API (v1)" --version="1.0.0"`}
        showLineNumbers={false}
      />

      <h2>Example with Custom Schemas</h2>
      
      <p>
        This example shows how to define custom schemas for complex types that aren't automatically handled by the generator.
      </p>
      
      <h3>Step 1: Create custom schema definitions</h3>
      
      <CodeBlock
        language="yaml"
        code={`schemas:\n  GeoPoint:\n    type: object\n    properties:\n      latitude:\n        type: number\n        format: double\n      longitude:\n        type: number\n        format: double\n    required:\n      - latitude\n      - longitude\n  \n  Address:\n    type: object\n    properties:\n      street:\n        type: string\n      city:\n        type: string\n      state:\n        type: string\n      zipCode:\n        type: string\n      country:\n        type: string\n      location:\n        $ref: '#/components/schemas/GeoPoint'\n    required:\n      - street\n      - city\n      - state\n      - zipCode\n      - country`}
        fileName="openapi_schemas.yaml"
      />
      
      <h3>Step 2: Use the custom types in your endpoints</h3>
      
      <CodeBlock
        language="dart"
        code={`/// Get nearby locations\n/// \n/// Returns a list of locations near the specified coordinates\n@Route('/locations/nearby')\nFuture<List<Location>> getNearbyLocations(\n  Session session,\n  @Param('latitude') double latitude,\n  @Param('longitude') double longitude,\n  @Param('radius') double radius,\n);\n\n/// Add a new address\n/// \n/// Adds a new address to the user's profile\n@Route('/users/addresses')\nFuture<Address> addAddress(\n  Session session,\n  @Param('address') Address address,\n);`}
        fileName="location_endpoint.dart"
      />

      <h2>Example with File Upload</h2>
      
      <p>
        This example shows how to document file upload endpoints in your OpenAPI specification.
      </p>
      
      <h3>Step 1: Create a custom schema for file uploads</h3>
      
      <CodeBlock
        language="yaml"
        code={`paths:\n  /users/avatar:\n    post:\n      summary: Upload user avatar\n      description: Uploads a new avatar image for the user\n      operationId: uploadAvatar\n      security:\n        - BearerAuth: []\n      requestBody:\n        content:\n          multipart/form-data:\n            schema:\n              type: object\n              properties:\n                avatar:\n                  type: string\n                  format: binary\n                  description: The avatar image file\n              required:\n                - avatar\n      responses:\n        '200':\n          description: Avatar uploaded successfully\n          content:\n            application/json:\n              schema:\n                type: object\n                properties:\n                  success:\n                    type: boolean\n                  avatarUrl:\n                    type: string\n        '400':\n          description: Invalid file format\n        '401':\n          description: Unauthorized`}
        fileName="openapi_file_upload.yaml"
      />
      
      <h3>Step 2: Implement the file upload endpoint</h3>
      
      <CodeBlock
        language="dart"
        code={`/// Upload user avatar\n/// \n/// Uploads a new avatar image for the user\n@Route('/users/avatar')\nFuture<Map<String, dynamic>> uploadAvatar(Session session) async {\n  // Get the uploaded file from the request\n  final request = session.request!;\n  if (!request.isMultipart) {\n    session.response.statusCode = 400;\n    return {'success': false, 'error': 'Not a multipart request'};\n  }\n\n  // Process the multipart request\n  await for (final part in request.multipartFormData) {\n    if (part.name == 'avatar' && part.filename != null) {\n      // Read the file data\n      final bytes = await part.readBytes();\n      \n      // Save the file (implementation depends on your storage solution)\n      final avatarUrl = await saveAvatarFile(bytes, part.filename!);\n      \n      return {\n        'success': true,\n        'avatarUrl': avatarUrl,\n      };\n    }\n  }\n\n  session.response.statusCode = 400;\n  return {'success': false, 'error': 'No avatar file found'};\n}`}
        fileName="user_endpoint.dart"
      />

      <h2>More Examples</h2>
      
      <p>Explore more specific examples:</p>
      
      <ul>
        <li>
          <Link href="/examples/authentication" className="text-primary-600 hover:text-primary-700 dark:text-primary-400 dark:hover:text-primary-300">
            Authentication Examples
          </Link>
        </li>
        <li>
          <Link href="/examples/custom-schemas" className="text-primary-600 hover:text-primary-700 dark:text-primary-400 dark:hover:text-primary-300">
            Custom Schema Examples
          </Link>
        </li>
        <li>
          <Link href="/examples/response-examples" className="text-primary-600 hover:text-primary-700 dark:text-primary-400 dark:hover:text-primary-300">
            Response Examples
          </Link>
        </li>
        <li>
          <Link href="/examples/pagination" className="text-primary-600 hover:text-primary-700 dark:text-primary-400 dark:hover:text-primary-300">
            Pagination Examples
          </Link>
        </li>
      </ul>
    </div>
  );
}