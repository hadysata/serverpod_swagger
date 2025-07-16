import React from 'react';
import CodeBlock from '@/components/CodeBlock';
import Link from 'next/link';

export default function CustomSchemas() {
  return (
    <div className="prose dark:prose-invert">
      <h1>Custom Schema Definitions</h1>
      
      <p>
        While Serverpod automatically generates OpenAPI schemas from your Dart classes,
        there are cases where you might need to define custom schemas or override the generated ones.
        This page explains how to create and use custom schema definitions in your Serverpod Swagger documentation.
      </p>

      <h2>Why Use Custom Schemas?</h2>
      
      <p>Custom schemas are useful when you need to:</p>
      
      <ul>
        <li>Define complex data structures that don't have corresponding Dart classes</li>
        <li>Override the automatically generated schemas with more detailed information</li>
        <li>Add examples, descriptions, or constraints to your schemas</li>
        <li>Define schemas for third-party libraries or external systems</li>
      </ul>

      <h2>Creating Custom Schema Definitions</h2>
      
      <p>
        You can define custom schemas by creating a YAML file with your schema definitions.
        Create a file named <code>openapi_schemas.yaml</code> in your project root:
      </p>
      
      <CodeBlock
        language="yaml"
        code={`components:
  schemas:
    CustomResponse:
      type: object
      properties:
        status:
          type: string
          enum: [success, error, pending]
          description: The status of the operation
        data:
          type: object
          description: The response data
          nullable: true
        message:
          type: string
          description: A human-readable message
      required:
        - status
    PaginatedResult:
      type: object
      properties:
        items:
          type: array
          items:
            type: object
          description: The list of items in the current page
        total:
          type: integer
          format: int32
          description: Total number of items
        page:
          type: integer
          format: int32
          description: Current page number
        pageSize:
          type: integer
          format: int32
          description: Number of items per page
      required:
        - items
        - total
        - page
        - pageSize`}
        fileName="openapi_schemas.yaml"
      />
      
      <p>
        The generator will include these schema definitions in the generated OpenAPI specification.
      </p>

      <h2>Referencing Custom Schemas in Endpoint Annotations</h2>
      
      <p>
        You can reference your custom schemas in endpoint annotations using the <code>@Schema</code> annotation:
      </p>
      
      <CodeBlock
        language="dart"
        code={`/// Get paginated users
/// 
/// Returns a paginated list of users
@Route('/users')
@Method('GET')
@Schema(response: 'PaginatedResult')
Future<String> getUsers(Session session, {@Param('page') int page = 1, @Param('pageSize') int pageSize = 10});

/// Create user
/// 
/// Creates a new user and returns a custom response
@Route('/users')
@Method('POST')
@Schema(response: 'CustomResponse')
Future<String> createUser(Session session, User user);`}
        fileName="example_endpoint.dart"
      />
      
      <p>
        In this example, the <code>getUsers</code> endpoint returns a <code>PaginatedResult</code> schema,
        and the <code>createUser</code> endpoint returns a <code>CustomResponse</code> schema.
      </p>

      <h2>Adding Examples to Custom Schemas</h2>
      
      <p>
        You can add examples to your custom schemas to help API consumers understand the expected data format:
      </p>
      
      <CodeBlock
        language="yaml"
        code={`components:
  schemas:
    CustomResponse:
      type: object
      properties:
        status:
          type: string
          enum: [success, error, pending]
          description: The status of the operation
        data:
          type: object
          description: The response data
          nullable: true
        message:
          type: string
          description: A human-readable message
      required:
        - status
      example:
        status: success
        data:
          id: 123
          name: "John Doe"
        message: "User created successfully"`}
        fileName="openapi_schemas.yaml"
      />

      <h2>Overriding Generated Schemas</h2>
      
      <p>
        If you want to override a schema that is automatically generated from a Dart class,
        simply define a schema with the same name in your YAML file:
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
          description: The unique identifier for the user
        email:
          type: string
          format: email
          description: The user's email address
        name:
          type: string
          description: The user's full name
        role:
          type: string
          enum: [admin, user, guest]
          description: The user's role
      required:
        - email
        - name
      example:
        id: 123
        email: "john.doe@example.com"
        name: "John Doe"
        role: "user"`}
        fileName="openapi_schemas.yaml"
      />

      <h2>Using References in Schema Definitions</h2>
      
      <p>
        You can use references to reuse schema components within your definitions:
      </p>
      
      <CodeBlock
        language="yaml"
        code={`components:
  schemas:
    Error:
      type: object
      properties:
        code:
          type: string
          description: Error code
        message:
          type: string
          description: Error message
      required:
        - code
        - message
    
    ApiResponse:
      type: object
      properties:
        data:
          type: object
          nullable: true
          description: Response data
        error:
          $ref: '#/components/schemas/Error'
          description: Error information if the request failed
        success:
          type: boolean
          description: Whether the request was successful
      required:
        - success`}
        fileName="openapi_schemas.yaml"
      />

      <h2>Combining Custom Schemas with Security Definitions</h2>
      
      <p>
        You can combine custom schemas with security definitions in a single YAML file:
      </p>
      
      <CodeBlock
        language="yaml"
        code={`security:
  - BearerAuth: []

components:
  securitySchemes:
    BearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT
      description: Enter your JWT token in the format 'Bearer {token}'
  
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
        - success`}
        fileName="openapi_custom.yaml"
      />

      <h2>Next Steps</h2>
      
      <ul>
        <li>
          <Link href="/docs/advanced-usage/response-examples" className="text-primary-600 hover:text-primary-700 dark:text-primary-400 dark:hover:text-primary-300">
            Add response examples
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