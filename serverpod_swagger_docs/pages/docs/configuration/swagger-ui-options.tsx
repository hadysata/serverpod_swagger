import React from 'react';
import CodeBlock from '@/components/CodeBlock';
import Link from 'next/link';

export default function SwaggerUIOptions() {
  return (
    <div className="prose dark:prose-invert">
      <h1>Swagger UI Configuration</h1>
      
      <p>
        Serverpod Swagger allows you to customize the Swagger UI interface to match your needs.
        This page explains the available configuration options for the Swagger UI route.
      </p>

      <h2>Basic Configuration</h2>
      
      <p>
        When adding the Swagger UI route to your server, you can customize it with several options:
      </p>
      
      <CodeBlock
        language="dart"
        code={`pod.webServer.addRoute(\n  SwaggerUIRoute(\n    Directory(Directory.current.path),\n    mountPath: '/swagger/',\n    apiSpecPath: 'apispec.json',\n    title: 'My API Documentation',\n    customCssUrl: '/custom/swagger.css',\n    customJsUrl: '/custom/swagger.js',\n    enableDeepLinking: true,\n    showExtensions: true,\n    showCommonExtensions: true,\n    defaultModelsExpandDepth: 1,\n    defaultModelExpandDepth: 1,\n    displayOperationId: false,\n    displayRequestDuration: true,\n    filter: true,\n    showMutatedRequest: true,\n    tryItOutEnabled: true,\n    persistAuthorization: true,\n  ),\n);`}
        fileName="main.dart"
      />

      <h2>Available Options</h2>
      
      <table className="min-w-full divide-y divide-gray-300 dark:divide-gray-700 my-4">
        <thead>
          <tr>
            <th className="px-4 py-3 text-left text-sm font-semibold text-gray-900 dark:text-gray-100">Option</th>
            <th className="px-4 py-3 text-left text-sm font-semibold text-gray-900 dark:text-gray-100">Description</th>
            <th className="px-4 py-3 text-left text-sm font-semibold text-gray-900 dark:text-gray-100">Default</th>
          </tr>
        </thead>
        <tbody className="divide-y divide-gray-200 dark:divide-gray-800">
          <tr>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300"><code>mountPath</code></td>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300">The base path where Swagger UI will be served</td>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300"><code>/swagger/</code></td>
          </tr>
          <tr>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300"><code>apiSpecPath</code></td>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300">Path to the OpenAPI specification file</td>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300"><code>apispec.json</code></td>
          </tr>
          <tr>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300"><code>title</code></td>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300">Title displayed in the Swagger UI</td>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300"><code>Swagger UI</code></td>
          </tr>
          <tr>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300"><code>customCssUrl</code></td>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300">URL to a custom CSS file for styling Swagger UI</td>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300"><code>null</code></td>
          </tr>
          <tr>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300"><code>customJsUrl</code></td>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300">URL to a custom JavaScript file for extending Swagger UI</td>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300"><code>null</code></td>
          </tr>
          <tr>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300"><code>enableDeepLinking</code></td>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300">If set to true, enables deep linking for tags and operations</td>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300"><code>true</code></td>
          </tr>
          <tr>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300"><code>showExtensions</code></td>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300">Controls the display of vendor extension (x-) fields and values</td>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300"><code>false</code></td>
          </tr>
          <tr>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300"><code>showCommonExtensions</code></td>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300">Controls the display of extensions (pattern, maxLength, minLength, maximum, minimum) fields and values</td>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300"><code>false</code></td>
          </tr>
          <tr>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300"><code>defaultModelsExpandDepth</code></td>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300">The default expansion depth for models</td>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300"><code>1</code></td>
          </tr>
          <tr>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300"><code>defaultModelExpandDepth</code></td>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300">The default expansion depth for the model on the model-example section</td>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300"><code>1</code></td>
          </tr>
          <tr>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300"><code>displayOperationId</code></td>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300">Controls the display of operationId in operations list</td>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300"><code>false</code></td>
          </tr>
          <tr>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300"><code>displayRequestDuration</code></td>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300">Controls the display of the request duration (in milliseconds) for Try-It-Out requests</td>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300"><code>false</code></td>
          </tr>
          <tr>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300"><code>filter</code></td>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300">If set, enables filtering. The top bar will show an edit box that you can use to filter the tagged operations that are shown</td>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300"><code>false</code></td>
          </tr>
          <tr>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300"><code>showMutatedRequest</code></td>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300">If set, uses the mutated request returned from a requestInterceptor to produce the curl command in the UI</td>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300"><code>true</code></td>
          </tr>
          <tr>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300"><code>tryItOutEnabled</code></td>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300">Controls whether the "Try it out" section should be enabled by default</td>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300"><code>false</code></td>
          </tr>
          <tr>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300"><code>persistAuthorization</code></td>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300">If set, it persists authorization data and it would not be lost on browser close/refresh</td>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300"><code>false</code></td>
          </tr>
        </tbody>
      </table>

      <h2>Custom CSS Styling</h2>
      
      <p>
        You can customize the appearance of Swagger UI by providing a custom CSS file. First, create a CSS file in your project's <code>web</code> directory:
      </p>
      
      <CodeBlock
        language="css"
        code={`.swagger-ui .topbar {\n  background-color: #1a365d;\n}\n\n.swagger-ui .info .title {\n  color: #2c5282;\n}\n\n.swagger-ui .opblock-tag {\n  background-color: #ebf8ff;\n}\n\n.swagger-ui .opblock.opblock-get {\n  border-color: #4299e1;\n  background-color: #ebf8ff;\n}\n\n.swagger-ui .opblock.opblock-post {\n  border-color: #48bb78;\n  background-color: #f0fff4;\n}\n\n.swagger-ui .btn.execute {\n  background-color: #2c5282;\n}`}
        fileName="web/custom/swagger.css"
      />
      
      <p>Then, reference this file in your Swagger UI route configuration:</p>
      
      <CodeBlock
        language="dart"
        code={`pod.webServer.addRoute(\n  SwaggerUIRoute(\n    Directory(Directory.current.path),\n    mountPath: '/swagger/',\n    customCssUrl: '/custom/swagger.css',\n  ),\n);`}
        fileName="main.dart"
      />

      <h2>Custom JavaScript Extensions</h2>
      
      <p>
        You can extend Swagger UI's functionality by providing a custom JavaScript file. First, create a JavaScript file in your project's <code>web</code> directory:
      </p>
      
      <CodeBlock
        language="javascript"
        code={`// This script will be executed after Swagger UI is initialized\nwindow.onload = function() {\n  // Access the Swagger UI instance\n  const ui = window.ui;\n  \n  // Add a custom authorization button\n  const authButton = document.createElement('button');\n  authButton.innerText = 'Quick Auth';\n  authButton.className = 'btn authorize';\n  authButton.onclick = function() {\n    // Set a predefined token\n    ui.preauthorizeApiKey('BearerAuth', 'YOUR_TEST_TOKEN');\n    console.log('API automatically authenticated with test token');\n  };\n  \n  // Add the button to the topbar\n  const topbar = document.querySelector('.swagger-ui .topbar');\n  if (topbar) {\n    topbar.appendChild(authButton);\n  }\n};`}
        fileName="web/custom/swagger.js"
      />
      
      <p>Then, reference this file in your Swagger UI route configuration:</p>
      
      <CodeBlock
        language="dart"
        code={`pod.webServer.addRoute(\n  SwaggerUIRoute(\n    Directory(Directory.current.path),\n    mountPath: '/swagger/',\n    customJsUrl: '/custom/swagger.js',\n  ),\n);`}
        fileName="main.dart"
      />

      <h2>Multiple Swagger UI Instances</h2>
      
      <p>
        You can add multiple Swagger UI routes to your server, each with its own configuration and API specification:
      </p>
      
      <CodeBlock
        language="dart"
        code={`// Add a Swagger UI route for the public API\npod.webServer.addRoute(\n  SwaggerUIRoute(\n    Directory(Directory.current.path),\n    mountPath: '/swagger/public/',\n    apiSpecPath: 'apispec.public.json',\n    title: 'Public API Documentation',\n  ),\n);\n\n// Add a Swagger UI route for the admin API\npod.webServer.addRoute(\n  SwaggerUIRoute(\n    Directory(Directory.current.path),\n    mountPath: '/swagger/admin/',\n    apiSpecPath: 'apispec.admin.json',\n    title: 'Admin API Documentation',\n  ),\n);`}
        fileName="main.dart"
      />

      <h2>Next Steps</h2>
      
      <ul>
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
        <li>
          <Link href="/examples" className="text-primary-600 hover:text-primary-700 dark:text-primary-400 dark:hover:text-primary-300">
            Explore examples
          </Link>
        </li>
      </ul>
    </div>
  );
}