import React from 'react';
import CodeBlock from '@/components/CodeBlock';
import Link from 'next/link';

export default function ResponseExamples() {
  return (
    <div className="prose dark:prose-invert">
      <h1>Response Examples</h1>
      
      <p>
        Adding response examples to your OpenAPI specification helps API consumers understand what to expect from your endpoints.
        This page explains how to add response examples to your Serverpod Swagger documentation.
      </p>

      <h2>Why Add Response Examples?</h2>
      
      <p>Response examples provide several benefits:</p>
      
      <ul>
        <li>Help API consumers understand the expected response format</li>
        <li>Serve as documentation for different response scenarios (success, error, etc.)</li>
        <li>Make your API documentation more user-friendly</li>
        <li>Reduce the need for trial-and-error when integrating with your API</li>
      </ul>

      <h2>Adding Response Examples in YAML</h2>
      
      <p>
        You can add response examples by creating a YAML file with your examples.
        Create a file named <code>openapi_examples.yaml</code> in your project root:
      </p>
      
      <CodeBlock
        language="yaml"
        code={`components:
  examples:
    UserSuccessResponse:
      summary: Successful user response
      value:
        id: 123
        name: "John Doe"
        email: "john.doe@example.com"
        createdAt: "2023-01-15T08:30:00Z"
    
    UserNotFoundError:
      summary: User not found error
      value:
        error: "User not found"
        code: "USER_NOT_FOUND"
        statusCode: 404
    
    ValidationError:
      summary: Validation error
      value:
        error: "Validation failed"
        code: "VALIDATION_ERROR"
        statusCode: 400
        details:
          - field: "email"
            message: "Invalid email format"
          - field: "password"
            message: "Password must be at least 8 characters long"`}
        fileName="openapi_examples.yaml"
      />
      
      <p>
        The generator will include these examples in the generated OpenAPI specification.
      </p>

      <h2>Referencing Examples in Endpoint Annotations</h2>
      
      <p>
        You can reference your examples in endpoint annotations using the <code>@Example</code> annotation:
      </p>
      
      <CodeBlock
        language="dart"
        code={`/// Get user by ID
/// 
/// Returns a user by their ID
@Route('/users/:id')
@Method('GET')
@Example(response: 'UserSuccessResponse', statusCode: '200')
@Example(response: 'UserNotFoundError', statusCode: '404')
Future<User> getUserById(Session session, int id);

/// Create user
/// 
/// Creates a new user
@Route('/users')
@Method('POST')
@Example(response: 'UserSuccessResponse', statusCode: '201')
@Example(response: 'ValidationError', statusCode: '400')
Future<User> createUser(Session session, User user);`}
        fileName="example_endpoint.dart"
      />
      
      <p>
        In this example, the <code>getUserById</code> endpoint has examples for both successful and not found responses,
        and the <code>createUser</code> endpoint has examples for both successful and validation error responses.
      </p>

      <h2>Inline Examples in Annotations</h2>
      
      <p>
        For simpler cases, you can define examples directly in your annotations:
      </p>
      
      <CodeBlock
        language="dart"
        code={`/// Get user by ID
/// 
/// Returns a user by their ID
@Route('/users/:id')
@Method('GET')
@Example(response: '{"id": 123, "name": "John Doe", "email": "john.doe@example.com"}', statusCode: '200')
@Example(response: '{"error": "User not found", "code": "USER_NOT_FOUND", "statusCode": 404}', statusCode: '404')
Future<User> getUserById(Session session, int id);`}
        fileName="example_endpoint.dart"
      />
      
      <p>
        While this approach is convenient for simple examples, it's recommended to use the YAML file for more complex examples
        to keep your code clean and maintainable.
      </p>

      <h2>Adding Examples to Schema Definitions</h2>
      
      <p>
        You can also add examples directly to your schema definitions:
      </p>
      
      <CodeBlock
        language="yaml"
        code={`components:
  schemas:
    User:
      type: object
      properties:
        id:
          type: integer
          format: int64
        name:
          type: string
        email:
          type: string
          format: email
        createdAt:
          type: string
          format: date-time
      required:
        - name
        - email
      example:
        id: 123
        name: "John Doe"
        email: "john.doe@example.com"
        createdAt: "2023-01-15T08:30:00Z"`}
        fileName="openapi_schemas.yaml"
      />

      <h2>Multiple Examples for a Single Schema</h2>
      
      <p>
        You can define multiple examples for a single schema:
      </p>
      
      <CodeBlock
        language="yaml"
        code={`components:
  schemas:
    User:
      type: object
      properties:
        id:
          type: integer
          format: int64
        name:
          type: string
        email:
          type: string
          format: email
        role:
          type: string
          enum: [admin, user, guest]
      required:
        - name
        - email
      examples:
        admin:
          summary: Admin user example
          value:
            id: 1
            name: "Admin User"
            email: "admin@example.com"
            role: "admin"
        regularUser:
          summary: Regular user example
          value:
            id: 123
            name: "John Doe"
            email: "john.doe@example.com"
            role: "user"
        guestUser:
          summary: Guest user example
          value:
            id: 456
            name: "Guest User"
            email: "guest@example.com"
            role: "guest"`}
        fileName="openapi_schemas.yaml"
      />

      <h2>Examples for Different Response Codes</h2>
      
      <p>
        You can define examples for different response codes in your YAML file:
      </p>
      
      <CodeBlock
        language="yaml"
        code={`paths:
  /users/{id}:
    get:
      responses:
        '200':
          description: Successful operation
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/User'
              examples:
                userExample:
                  $ref: '#/components/examples/UserSuccessResponse'
        '404':
          description: User not found
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
              examples:
                notFoundExample:
                  $ref: '#/components/examples/UserNotFoundError'`}
        fileName="openapi_paths.yaml"
      />
      
      <div className="bg-yellow-50 dark:bg-yellow-900/20 border-l-4 border-yellow-400 p-4 my-4">
        <p className="text-yellow-800 dark:text-yellow-200 text-sm">
          <strong>Note:</strong> The <code>paths</code> section in the YAML file is more advanced and might override the automatically generated paths.
          Use this approach with caution and only when you need fine-grained control over your API documentation.
        </p>
      </div>

      <h2>Combining Examples with Custom Schemas</h2>
      
      <p>
        You can combine examples with custom schemas in a single YAML file:
      </p>
      
      <CodeBlock
        language="yaml"
        code={`components:
  schemas:
    ApiResponse:
      type: object
      properties:
        data:
          type: object
          nullable: true
        error:
          type: object
          nullable: true
          properties:
            code:
              type: string
            message:
              type: string
        success:
          type: boolean
      required:
        - success
  
  examples:
    SuccessResponse:
      summary: Successful response
      value:
        data:
          id: 123
          name: "John Doe"
        error: null
        success: true
    
    ErrorResponse:
      summary: Error response
      value:
        data: null
        error:
          code: "INTERNAL_ERROR"
          message: "An unexpected error occurred"
        success: false`}
        fileName="openapi_custom.yaml"
      />

      <h2>Next Steps</h2>
      
      <ul>
        <li>
          <Link href="/docs/advanced-usage/custom-schemas" className="text-primary-600 hover:text-primary-700 dark:text-primary-400 dark:hover:text-primary-300">
            Define custom schemas
          </Link>
        </li>
        <li>
          <Link href="/docs/configuration/authentication" className="text-primary-600 hover:text-primary-700 dark:text-primary-400 dark:hover:text-primary-300">
            Configure authentication
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