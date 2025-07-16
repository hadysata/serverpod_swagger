import React from 'react';
import CodeBlock from '@/components/CodeBlock';
import Link from 'next/link';

export default function SwaggerUIRoute() {
  return (
    <div className="prose dark:prose-invert">
      <h1>SwaggerUIRoute</h1>
      
      <p>
        The <code>SwaggerUIRoute</code> class is the main entry point for adding Swagger UI to your Serverpod server.
        It handles the serving of the Swagger UI interface and the OpenAPI specification.
      </p>

      <h2>Overview</h2>
      
      <p>
        <code>SwaggerUIRoute</code> implements the <code>RouteHandler</code> interface from Serverpod, allowing it to be
        registered with your server's router to handle requests to the Swagger UI path.
      </p>

      <h2>Constructor</h2>
      
      <CodeBlock
        language="dart"
        code={`SwaggerUIRoute(
  Directory projectDirectory, {
  String mountPath = '/swagger/',
})`}
      />
      
      <h3>Parameters</h3>
      
      <table className="min-w-full divide-y divide-gray-300 dark:divide-gray-700 my-4">
        <thead>
          <tr>
            <th className="px-4 py-3 text-left text-sm font-semibold text-gray-900 dark:text-gray-100">Parameter</th>
            <th className="px-4 py-3 text-left text-sm font-semibold text-gray-900 dark:text-gray-100">Type</th>
            <th className="px-4 py-3 text-left text-sm font-semibold text-gray-900 dark:text-gray-100">Description</th>
          </tr>
        </thead>
        <tbody className="divide-y divide-gray-200 dark:divide-gray-800">
          <tr>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300"><code>projectDirectory</code></td>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300"><code>Directory</code></td>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300">The root directory of your Serverpod project. This is used to locate the OpenAPI specification file.</td>
          </tr>
          <tr>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300"><code>mountPath</code></td>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300"><code>String</code></td>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300">The base path where Swagger UI will be served (must end with a trailing slash). Default is <code>/swagger/</code>.</td>
          </tr>
          <tr>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300"><code>apiSpecPath</code></td>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300"><code>String</code></td>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300">Path to the OpenAPI specification file relative to the project directory. Default is <code>apispec.json</code>.</td>
          </tr>
          <tr>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300"><code>title</code></td>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300"><code>String</code></td>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300">Title displayed in the Swagger UI browser tab and header. Default is <code>Swagger UI</code>.</td>
          </tr>
          <tr>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300"><code>customCssUrl</code></td>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300"><code>String?</code></td>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300">URL to a custom CSS file for styling Swagger UI. If not provided, the default Swagger UI styling is used.</td>
          </tr>
          <tr>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300"><code>customJsUrl</code></td>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300"><code>String?</code></td>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300">URL to a custom JavaScript file for extending Swagger UI functionality. If not provided, no custom JavaScript is loaded.</td>
          </tr>
          <tr>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300"><code>enableDeepLinking</code></td>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300"><code>bool</code></td>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300">If set to true, enables deep linking for tags and operations. This allows direct linking to specific operations. Default is <code>true</code>.</td>
          </tr>
          <tr>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300"><code>showExtensions</code></td>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300"><code>bool</code></td>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300">Controls the display of vendor extension (x-) fields and values. Default is <code>false</code>.</td>
          </tr>
          <tr>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300"><code>showCommonExtensions</code></td>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300"><code>bool</code></td>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300">Controls the display of extensions (pattern, maxLength, minLength, maximum, minimum) fields and values. Default is <code>false</code>.</td>
          </tr>
          <tr>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300"><code>defaultModelsExpandDepth</code></td>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300"><code>int</code></td>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300">The default expansion depth for models in the models section. Default is <code>1</code>.</td>
          </tr>
          <tr>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300"><code>defaultModelExpandDepth</code></td>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300"><code>int</code></td>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300">The default expansion depth for the model on the model-example section. Default is <code>1</code>.</td>
          </tr>
          <tr>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300"><code>displayOperationId</code></td>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300"><code>bool</code></td>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300">Controls the display of operationId in operations list. Default is <code>false</code>.</td>
          </tr>
          <tr>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300"><code>displayRequestDuration</code></td>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300"><code>bool</code></td>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300">Controls the display of the request duration (in milliseconds) for Try-It-Out requests. Default is <code>false</code>.</td>
          </tr>
          <tr>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300"><code>filter</code></td>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300"><code>bool</code></td>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300">If set, enables filtering. The top bar will show an edit box that you can use to filter the tagged operations that are shown. Default is <code>false</code>.</td>
          </tr>
          <tr>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300"><code>showMutatedRequest</code></td>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300"><code>bool</code></td>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300">If set, uses the mutated request returned from a requestInterceptor to produce the curl command in the UI. Default is <code>true</code>.</td>
          </tr>
          <tr>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300"><code>tryItOutEnabled</code></td>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300"><code>bool</code></td>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300">Controls whether the "Try it out" section should be enabled by default. Default is <code>false</code>.</td>
          </tr>
          <tr>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300"><code>persistAuthorization</code></td>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300"><code>bool</code></td>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300">If set, it persists authorization data and it would not be lost on browser close/refresh. Default is <code>false</code>.</td>
          </tr>
        </tbody>
      </table>

      <h2>Methods</h2>
      
      <h3><code>handleCall</code></h3>
      
      <CodeBlock
        language="dart"
        code={`@override\nFuture<bool> handleCall(HttpRequest request) async`}
      />
      
      <p>
        Handles incoming HTTP requests to the Swagger UI route. This method is called by the Serverpod web server when a request is made to the configured mount path.
      </p>

      <h4>Parameters</h4>

      <table className="min-w-full divide-y divide-gray-300 dark:divide-gray-700 my-4">
        <thead>
          <tr>
            <th className="px-4 py-3 text-left text-sm font-semibold text-gray-900 dark:text-gray-100">Parameter</th>
            <th className="px-4 py-3 text-left text-sm font-semibold text-gray-900 dark:text-gray-100">Type</th>
            <th className="px-4 py-3 text-left text-sm font-semibold text-gray-900 dark:text-gray-100">Description</th>
          </tr>
        </thead>
        <tbody className="divide-y divide-gray-200 dark:divide-gray-800">
          <tr>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300"><code>request</code></td>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300"><code>HttpRequest</code></td>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300">The HTTP request to handle.</td>
          </tr>
        </tbody>
      </table>

      <h4>Returns</h4>

      <p>
        Returns <code>true</code> if the request was handled successfully, <code>false</code> otherwise.
      </p>

      <h4>Implementation Details</h4>

      <p>
        The <code>handleCall</code> method performs the following tasks:
      </p>

      <ol>
        <li>Checks if the request path matches the configured mount path.</li>
        <li>If the request is for the API specification file, serves the JSON file.</li>
        <li>If the request is for the Swagger UI, serves the HTML page with the configured options.</li>
        <li>If the request is for static assets (CSS, JavaScript, etc.), serves those files.</li>
      </ol>

      <h2>Usage Example</h2>

      <p>
        Here's an example of how to register the <code>SwaggerUIRoute</code> with your Serverpod server:
      </p>

      <CodeBlock
        language="dart"
        code={`import 'dart:io';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_swagger/serverpod_swagger.dart';

class Server extends SerializationManagerServer {
  @override
  Future<void> initialize() async {
    await super.initialize();
    
    // Register the Swagger UI route
    router.addRoute(
      SwaggerUIRoute(
        Directory(Directory.current.path),
        mountPath: '/docs/',
        title: 'My API Documentation',
        tryItOutEnabled: true,
        persistAuthorization: true,
      ),
    );
  }
}`}
      />

      <h2>Related Documentation</h2>

      <ul>
        <li>
          <Link href="/docs/configuration/swagger-ui-options" className="text-primary-600 hover:text-primary-700 dark:text-primary-400 dark:hover:text-primary-300">
            Swagger UI Options Configuration
          </Link>
        </li>
        <li>
          <Link href="/docs/configuration/openapi-generation" className="text-primary-600 hover:text-primary-700 dark:text-primary-400 dark:hover:text-primary-300">
            OpenAPI Generation Configuration
          </Link>
        </li>
        <li>
          <Link href="/docs/advanced-usage/custom-schemas" className="text-primary-600 hover:text-primary-700 dark:text-primary-400 dark:hover:text-primary-300">
            Custom Schema Definitions
          </Link>
        </li>
      </ul>
    </div>
  );
}