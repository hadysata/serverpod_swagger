import React from 'react';
import Link from 'next/link';

export default function AdvancedUsage() {
  return (
    <div className="prose dark:prose-invert">
      <h1>Advanced Usage</h1>
      
      <p>
        This section covers advanced topics for using Serverpod Swagger to its full potential.
        These features allow you to customize your API documentation, add detailed examples,
        and create a more comprehensive developer experience.
      </p>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mt-8">
        <div className="bg-white dark:bg-gray-800 rounded-lg shadow-md p-6 border border-gray-200 dark:border-gray-700">
          <h3 className="text-xl font-semibold mb-2">Custom Schema Definitions</h3>
          <p className="text-gray-600 dark:text-gray-300 mb-4">
            Learn how to define custom schemas or override the automatically generated ones
            to provide more detailed information about your API's data structures.
          </p>
          <Link 
            href="/docs/advanced-usage/custom-schemas" 
            className="text-primary-600 hover:text-primary-700 dark:text-primary-400 dark:hover:text-primary-300 font-medium"
          >
            Learn more →
          </Link>
        </div>

        <div className="bg-white dark:bg-gray-800 rounded-lg shadow-md p-6 border border-gray-200 dark:border-gray-700">
          <h3 className="text-xl font-semibold mb-2">Response Examples</h3>
          <p className="text-gray-600 dark:text-gray-300 mb-4">
            Add detailed response examples to your API documentation to help developers
            understand what to expect from your endpoints.
          </p>
          <Link 
            href="/docs/advanced-usage/response-examples" 
            className="text-primary-600 hover:text-primary-700 dark:text-primary-400 dark:hover:text-primary-300 font-medium"
          >
            Learn more →
          </Link>
        </div>
      </div>

      <h2 className="mt-12">Additional Resources</h2>
      
      <p>
        For more information on customizing your Serverpod Swagger documentation, check out these related topics:
      </p>
      
      <ul className="space-y-2">
        <li>
          <Link 
            href="/docs/configuration/authentication" 
            className="text-primary-600 hover:text-primary-700 dark:text-primary-400 dark:hover:text-primary-300"
          >
            Authentication Configuration
          </Link>
          {" "}- Configure different authentication methods for your API
        </li>
        <li>
          <Link 
            href="/docs/configuration/swagger-ui-options" 
            className="text-primary-600 hover:text-primary-700 dark:text-primary-400 dark:hover:text-primary-300"
          >
            Swagger UI Options
          </Link>
          {" "}- Customize the appearance and behavior of the Swagger UI
        </li>
        <li>
          <Link 
            href="/docs/configuration/openapi-generation" 
            className="text-primary-600 hover:text-primary-700 dark:text-primary-400 dark:hover:text-primary-300"
          >
            OpenAPI Generation
          </Link>
          {" "}- Configure how the OpenAPI specification is generated
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
          <strong>Tip:</strong> For the most comprehensive API documentation, combine custom schemas, response examples, and authentication configuration in your Serverpod Swagger setup.
        </p>
      </div>
    </div>
  );
}