import React from 'react';
import CodeBlock from '@/components/CodeBlock';
import Link from 'next/link';

export default function Authentication() {
  return (
    <div className="prose dark:prose-invert">
      <h1>Authentication Configuration</h1>
      
      <p>
        Adding authentication information to your OpenAPI specification allows users to authenticate with your API directly from the Swagger UI interface.
        This page explains how to configure different authentication methods for your Serverpod Swagger documentation.
      </p>

      <h2>Adding Authentication to OpenAPI Specification</h2>
      
      <p>
        You can add authentication schemes to your OpenAPI specification by creating a YAML file with security definitions.
      </p>
      
      <p>Create a file named <code>openapi_security.yaml</code> in your project root:</p>
      
      <CodeBlock
        language="yaml"
        code={`security:\n  - BearerAuth: []\n\ncomponents:\n  securitySchemes:\n    BearerAuth:\n      type: http\n      scheme: bearer\n      bearerFormat: JWT\n      description: Enter your JWT token in the format 'Bearer {token}'`}
        fileName="openapi_security.yaml"
      />
      
      <p>
        The generator will include these security definitions in the generated OpenAPI specification.
      </p>

      <h2>Common Authentication Types</h2>
      
      <h3>Bearer Token Authentication</h3>
      
      <CodeBlock
        language="yaml"
        code={`security:\n  - BearerAuth: []\n\ncomponents:\n  securitySchemes:\n    BearerAuth:\n      type: http\n      scheme: bearer\n      bearerFormat: JWT\n      description: Enter your JWT token in the format 'Bearer {token}'`}
        fileName="openapi_security.yaml"
      />
      
      <h3>API Key Authentication</h3>
      
      <CodeBlock
        language="yaml"
        code={`security:\n  - ApiKeyAuth: []\n\ncomponents:\n  securitySchemes:\n    ApiKeyAuth:\n      type: apiKey\n      in: header\n      name: X-API-Key\n      description: Enter your API key`}
        fileName="openapi_security.yaml"
      />
      
      <h3>Basic Authentication</h3>
      
      <CodeBlock
        language="yaml"
        code={`security:\n  - BasicAuth: []\n\ncomponents:\n  securitySchemes:\n    BasicAuth:\n      type: http\n      scheme: basic\n      description: Enter your username and password`}
        fileName="openapi_security.yaml"
      />
      
      <h3>OAuth 2.0 Authentication</h3>
      
      <CodeBlock
        language="yaml"
        code={`security:\n  - OAuth2: []\n\ncomponents:\n  securitySchemes:\n    OAuth2:\n      type: oauth2\n      flows:\n        implicit:\n          authorizationUrl: https://example.com/oauth/authorize\n          scopes:\n            read: Read access to the API\n            write: Write access to the API`}
        fileName="openapi_security.yaml"
      />

      <h2>Applying Security to Specific Endpoints</h2>
      
      <p>
        You can apply security requirements to specific endpoints by using the <code>@Security</code> annotation in your endpoint definitions:
      </p>
      
      <CodeBlock
        language="dart"
        code={`/// Get user profile
/// 
/// Retrieves the profile of the authenticated user
@Security(['BearerAuth'])
@Route('/users/profile')
Future<User> getUserProfile(Session session);\n\n/// List all users
/// 
/// Requires admin privileges
@Security(['BearerAuth', 'ApiKeyAuth'])
@Route('/users')
Future<List<User>> listUsers(Session session);`}
        fileName="example_endpoint.dart"
      />
      
      <p>
        In this example, the <code>getUserProfile</code> endpoint requires Bearer authentication, while the <code>listUsers</code> endpoint requires both Bearer and API Key authentication.
      </p>

      <h2>Implementing Authentication in Serverpod</h2>
      
      <p>
        While Swagger UI allows users to provide authentication credentials for testing, you need to implement the actual authentication logic in your Serverpod server.
      </p>
      
      <h3>Bearer Token Authentication Example</h3>
      
      <CodeBlock
        language="dart"
        code={`import 'package:serverpod/serverpod.dart';\nimport 'package:jwt_decoder/jwt_decoder.dart';\n\nclass AuthenticationInterceptor extends Interceptor {\n  @override\n  Future<bool> beforeHandle(Session session, String methodName) async {\n    // Skip authentication for certain methods\n    if (methodName == 'login' || methodName == 'register') {\n      return true;\n    }\n\n    // Get the authorization header\n    final authHeader = session.request?.headers['authorization'];\n    if (authHeader == null || !authHeader.startsWith('Bearer ')) {\n      session.response.statusCode = 401;\n      session.response.write('Unauthorized');\n      return false;\n    }\n\n    // Extract and validate the token\n    final token = authHeader.substring(7);\n    try {\n      final decodedToken = JwtDecoder.decode(token);\n      \n      // Check if token is expired\n      if (JwtDecoder.isExpired(token)) {\n        session.response.statusCode = 401;\n        session.response.write('Token expired');\n        return false;\n      }\n      \n      // Add user info to session\n      session.auth = decodedToken;\n      return true;\n    } catch (e) {\n      session.response.statusCode = 401;\n      session.response.write('Invalid token');\n      return false;\n    }\n  }\n}\n\n// Register the interceptor in your server setup\nvoid main() async {\n  final pod = Serverpod(...);\n  \n  // Add the authentication interceptor\n  pod.addInterceptor(AuthenticationInterceptor());\n  \n  await pod.start();\n}`}
        fileName="authentication_interceptor.dart"
      />

      <h2>Testing Authentication in Swagger UI</h2>
      
      <p>
        Once you've configured authentication in your OpenAPI specification, users can authenticate in Swagger UI by following these steps:
      </p>
      
      <ol>
        <li>Click the "Authorize" button at the top of the Swagger UI page</li>
        <li>Enter the required credentials for the authentication method</li>
        <li>Click "Authorize" to apply the credentials</li>
        <li>Close the dialog and test the authenticated endpoints</li>
      </ol>
      
      <div className="bg-blue-50 dark:bg-blue-900/20 border-l-4 border-blue-400 p-4 my-4">
        <p className="text-blue-800 dark:text-blue-200 text-sm">
          <strong>Tip:</strong> You can use the <code>persistAuthorization</code> option in your Swagger UI configuration to make the authorization persist between page refreshes.
        </p>
      </div>

      <h2>Next Steps</h2>
      
      <ul>
        <li>
          <Link href="/docs/advanced-usage/custom-schemas" className="text-primary-600 hover:text-primary-700 dark:text-primary-400 dark:hover:text-primary-300">
            Define custom schemas
          </Link>
        </li>
        <li>
          <Link href="/docs/advanced-usage/response-examples" className="text-primary-600 hover:text-primary-700 dark:text-primary-400 dark:hover:text-primary-300">
            Add response examples
          </Link>
        </li>
        <li>
          <Link href="/examples" className="text-primary-600 hover:text-primary-700 dark:text-primary-400 dark:hover:text-primary-300">
            Explore examples
          </Link>
        </li>
      </ul>
    </div>
  );
}