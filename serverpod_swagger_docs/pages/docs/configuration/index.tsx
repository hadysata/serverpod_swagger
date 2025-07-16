import React from 'react';
import Link from 'next/link';

export default function Configuration() {
  return (
    <div className="prose dark:prose-invert">
      <h1>Configuration</h1>
      
      <p>
        This section covers the various configuration options available for Serverpod Swagger.
        You can customize both the OpenAPI specification generation and the Swagger UI interface
        to suit your project's needs.
      </p>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mt-8">
        <div className="bg-white dark:bg-gray-800 rounded-lg shadow-md p-6 border border-gray-200 dark:border-gray-700">
          <h3 className="text-xl font-semibold mb-2">OpenAPI Generation</h3>
          <p className="text-gray-600 dark:text-gray-300 mb-4">
            Learn how to configure the OpenAPI specification generation process, including
            customizing endpoint documentation, HTTP methods, and more.
          </p>
          <Link 
            href="/docs/configuration/openapi-generation" 
            className="text-primary-600 hover:text-primary-700 dark:text-primary-400 dark:hover:text-primary-300 font-medium"
          >
            Learn more →
          </Link>
        </div>

        <div className="bg-white dark:bg-gray-800 rounded-lg shadow-md p-6 border border-gray-200 dark:border-gray-700">
          <h3 className="text-xl font-semibold mb-2">Swagger UI Options</h3>
          <p className="text-gray-600 dark:text-gray-300 mb-4">
            Customize the appearance and behavior of the Swagger UI interface, including
            themes, layout, and interactive features.
          </p>
          <Link 
            href="/docs/configuration/swagger-ui-options" 
            className="text-primary-600 hover:text-primary-700 dark:text-primary-400 dark:hover:text-primary-300 font-medium"
          >
            Learn more →
          </Link>
        </div>

        <div className="bg-white dark:bg-gray-800 rounded-lg shadow-md p-6 border border-gray-200 dark:border-gray-700">
          <h3 className="text-xl font-semibold mb-2">Authentication</h3>
          <p className="text-gray-600 dark:text-gray-300 mb-4">
            Configure authentication for your API documentation, including OAuth, API keys,
            and JWT authentication.
          </p>
          <Link 
            href="/docs/configuration/authentication" 
            className="text-primary-600 hover:text-primary-700 dark:text-primary-400 dark:hover:text-primary-300 font-medium"
          >
            Learn more →
          </Link>
        </div>
      </div>

      <h2 className="mt-12">Configuration Best Practices</h2>
      
      <p>
        When configuring Serverpod Swagger for your project, consider the following best practices:
      </p>
      
      <ul className="space-y-2">
        <li>
          <strong>Keep documentation up-to-date:</strong> Regenerate your OpenAPI specification whenever you make changes to your API endpoints.
        </li>
        <li>
          <strong>Use descriptive documentation:</strong> Provide clear and concise documentation for your endpoints, including parameters, responses, and examples.
        </li>
        <li>
          <strong>Organize endpoints logically:</strong> Group related endpoints together using tags to make your API documentation easier to navigate.
        </li>
        <li>
          <strong>Include authentication information:</strong> Document authentication requirements for your API to help users understand how to authenticate their requests.
        </li>
        <li>
          <strong>Provide examples:</strong> Include example requests and responses to help users understand how to use your API.
        </li>
      </ul>

      <h2 className="mt-8">Related Topics</h2>
      
      <ul className="space-y-2">
        <li>
          <Link 
            href="/docs/advanced-usage/custom-schemas" 
            className="text-primary-600 hover:text-primary-700 dark:text-primary-400 dark:hover:text-primary-300"
          >
            Custom Schema Definitions
          </Link>
          {" "}- Define custom schemas for your API documentation
        </li>
        <li>
          <Link 
            href="/docs/advanced-usage/response-examples" 
            className="text-primary-600 hover:text-primary-700 dark:text-primary-400 dark:hover:text-primary-300"
          >
            Response Examples
          </Link>
          {" "}- Add examples to your API responses
        </li>
        <li>
          <Link 
            href="/examples" 
            className="text-primary-600 hover:text-primary-700 dark:text-primary-400 dark:hover:text-primary-300"
          >
            Examples
          </Link>
          {" "}- See practical examples of Serverpod Swagger in action
        </li>
      </ul>

      <div className="bg-blue-50 dark:bg-blue-900/20 border-l-4 border-blue-400 p-4 my-8">
        <p className="text-blue-800 dark:text-blue-200 text-sm">
          <strong>Tip:</strong> You can automate the OpenAPI specification generation process by adding it to your build pipeline or using a file watcher to regenerate the specification whenever your code changes.
        </p>
      </div>
    </div>
  );
}