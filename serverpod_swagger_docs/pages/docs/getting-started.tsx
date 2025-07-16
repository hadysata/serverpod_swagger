import React from 'react';
import CodeBlock from '@/components/CodeBlock';
import Link from 'next/link';

export default function GettingStarted() {
  return (
    <div className="prose dark:prose-invert">
      <h1>Getting Started with Serverpod Swagger</h1>
      
      <p>
        Serverpod Swagger is a package that automatically generates OpenAPI specifications from your 
        Serverpod protocol definitions and serves a Swagger UI interface directly from your Serverpod server.
      </p>

      <h2>Prerequisites</h2>
      
      <p>Before you begin, make sure you have:</p>
      
      <ul>
        <li>Serverpod 2.8.0 or higher</li>
        <li>Dart 3.0.0 or higher</li>
        <li>A working Serverpod project</li>
      </ul>

      <h2>Installation</h2>
      
      <p>Add the package to your <code>pubspec.yaml</code> file:</p>
      
      <CodeBlock
        language="yaml"
        code={`dependencies:\n  serverpod: ^2.8.0\n  serverpod_swagger: ^0.1.5`}
        fileName="pubspec.yaml"
      />
      
      <p>Then run:</p>
      
      <CodeBlock
        language="bash"
        code={`dart pub get`}
        showLineNumbers={false}
      />

      <h2>Basic Setup</h2>
      
      <p>To add Swagger UI to your Serverpod server, follow these steps:</p>
      
      <h3>1. Import the package</h3>
      
      <CodeBlock
        language="dart"
        code={`import 'dart:io';\nimport 'package:serverpod/serverpod.dart';\nimport 'package:serverpod_swagger/serverpod_swagger.dart';`}
        fileName="main.dart"
      />
      
      <h3>2. Add the Swagger UI route to your server</h3>
      
      <CodeBlock
        language="dart"
        code={`// In your server's main.dart file\n\nfuture<void> main() async {\n  // Create the server\n  final pod = Serverpod(\n    // ... your configuration\n  );\n  \n  // Add the Swagger UI route\n  pod.webServer.addRoute(\n    SwaggerUIRoute(\n      Directory(Directory.current.path),\n      mountPath: '/swagger/',\n    ),\n  );\n  \n  // Start the server\n  await pod.start();\n}`}
        fileName="main.dart"
      />
      
      <div className="bg-yellow-50 dark:bg-yellow-900/20 border-l-4 border-yellow-400 p-4 my-4">
        <p className="text-yellow-800 dark:text-yellow-200 text-sm">
          <strong>Note:</strong> The <code>mountPath</code> parameter must end with a trailing slash.
        </p>
      </div>

      <h3>3. Generate the OpenAPI specification</h3>
      
      <p>
        Run the following command from your project root to generate the OpenAPI specification:
      </p>
      
      <CodeBlock
        language="bash"
        code={`dart run serverpod_swagger:generate`}
        showLineNumbers={false}
      />
      
      <p>
        This will create an <code>apispec.json</code> file in your project root directory.
      </p>

      <h3>4. Start your server and access the Swagger UI</h3>
      
      <p>
        Start your Serverpod server and navigate to <code>http://localhost:8082/swagger/</code> in your browser.
      </p>
      
      <div className="bg-blue-50 dark:bg-blue-900/20 border-l-4 border-blue-400 p-4 my-4">
        <p className="text-blue-800 dark:text-blue-200 text-sm">
          <strong>Tip:</strong> Make sure to include the trailing slash in the URL. If you navigate to <code>/swagger</code> (without the trailing slash), you'll be redirected to <code>/swagger/</code>.
        </p>
      </div>

      <h2>Next Steps</h2>
      
      <p>Now that you have Swagger UI integrated with your Serverpod server, you can:</p>
      
      <ul>
        <li>
          <Link href="/docs/configuration/openapi-generation" className="text-primary-600 hover:text-primary-700 dark:text-primary-400 dark:hover:text-primary-300">
            Customize the OpenAPI generation
          </Link>
        </li>
        <li>
          <Link href="/docs/configuration/swagger-ui-options" className="text-primary-600 hover:text-primary-700 dark:text-primary-400 dark:hover:text-primary-300">
            Configure Swagger UI options
          </Link>
        </li>
        <li>
          <Link href="/docs/configuration/authentication" className="text-primary-600 hover:text-primary-700 dark:text-primary-400 dark:hover:text-primary-300">
            Add authentication to your API documentation
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