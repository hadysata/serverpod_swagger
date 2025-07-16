import React from 'react';
import CodeBlock from '@/components/CodeBlock';
import Link from 'next/link';

export default function ServerpodSwaggerVersion() {
  return (
    <div className="prose dark:prose-invert">
      <h1>ServerpodSwaggerVersion</h1>
      
      <p>
        The <code>ServerpodSwaggerVersion</code> class provides version information for the Serverpod Swagger package.
        This class is useful for checking the current version of the package at runtime.
      </p>

      <h2>Overview</h2>
      
      <p>
        <code>ServerpodSwaggerVersion</code> is a simple class that contains a single static property that returns the current version of the Serverpod Swagger package.
        This can be useful for logging, debugging, or displaying version information in your application.
      </p>

      <h2>Properties</h2>
      
      <table className="min-w-full divide-y divide-gray-300 dark:divide-gray-700 my-4">
        <thead>
          <tr>
            <th className="px-4 py-3 text-left text-sm font-semibold text-gray-900 dark:text-gray-100">Property</th>
            <th className="px-4 py-3 text-left text-sm font-semibold text-gray-900 dark:text-gray-100">Type</th>
            <th className="px-4 py-3 text-left text-sm font-semibold text-gray-900 dark:text-gray-100">Description</th>
          </tr>
        </thead>
        <tbody className="divide-y divide-gray-200 dark:divide-gray-800">
          <tr>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300"><code>version</code></td>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300"><code>String</code></td>
            <td className="px-4 py-3 text-sm text-gray-700 dark:text-gray-300">The current version of the Serverpod Swagger package. This is a static property that returns the version as a string in semantic versioning format (e.g., <code>1.0.0</code>).</td>
          </tr>
        </tbody>
      </table>

      <h2>Usage Example</h2>

      <p>
        Here's an example of how to use the <code>ServerpodSwaggerVersion</code> class to get the current version of the package:
      </p>

      <CodeBlock
        language="dart"
        code={`import 'package:serverpod_swagger/serverpod_swagger.dart';

void main() {
  // Get the current version of the Serverpod Swagger package
  String version = ServerpodSwaggerVersion.version;
  
  // Print the version
  print('Serverpod Swagger version: $version');
}`}
      />

      <h2>Version Checking</h2>

      <p>
        You can use the version information to ensure compatibility with other components or to conditionally enable features based on the package version.
      </p>

      <CodeBlock
        language="dart"
        code={`import 'package:serverpod_swagger/serverpod_swagger.dart';
import 'package:version/version.dart';

void checkCompatibility() {
  // Get the current version
  String versionString = ServerpodSwaggerVersion.version;
  Version version = Version.parse(versionString);
  
  // Check if the version is compatible with your requirements
  if (version < Version.parse('1.0.0')) {
    print('Warning: You are using an older version of Serverpod Swagger.');
    print('Some features may not be available.');
  }
}`}
      />

      <h2>Implementation Details</h2>

      <p>
        The <code>ServerpodSwaggerVersion</code> class is implemented as a simple class with a static property. The version value is hardcoded in the package and is updated with each release.
      </p>

      <CodeBlock
        language="dart"
        code={`class ServerpodSwaggerVersion {
  static const String version = '1.0.0'; // Example version
}`}
      />

      <h2>Related Documentation</h2>

      <ul>
        <li>
          <Link href="/docs/installation" className="text-primary-600 hover:text-primary-700 dark:text-primary-400 dark:hover:text-primary-300">
            Installation Guide
          </Link>
        </li>
        <li>
          <Link href="/api-reference/swagger-ui-route" className="text-primary-600 hover:text-primary-700 dark:text-primary-400 dark:hover:text-primary-300">
            SwaggerUIRoute API Reference
          </Link>
        </li>
        <li>
          <Link href="/api-reference/cli-options" className="text-primary-600 hover:text-primary-700 dark:text-primary-400 dark:hover:text-primary-300">
            CLI Options Reference
          </Link>
        </li>
      </ul>
    </div>
  );
}