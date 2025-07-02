// custom_generator.dart
import 'dart:convert';
import 'dart:io';

import 'package:serverpod_swagger/src/models/swagger.dart';

void main(List<String> args) async {
  // Parse your command line arguments here
  String? baseUrl;
  // ... other argument parsing
  
  // Create your own SwaggerSpec or use the existing parser to generate one
  final spec = SwaggerSpec(); // You'll need to populate this
  
  // Call the customized version of generateOpenApiMap
  final openApiJson = generateOpenApiMap(
    spec,
    baseUrl: baseUrl,
    // Add your customizations here
    // For example, customize the info section:
    customInfo: {
      'title': 'My Custom API',
      'version': '2.0.0',
      'description': 'My detailed API documentation'
    },
  );
  
  // Write the output
  final outputFile = File('apispec.json');
  final prettyJson = JsonEncoder.withIndent('  ').convert(openApiJson);
  outputFile.writeAsStringSync(prettyJson);
}

// Your customized version of generateOpenApiMap
Map<String, dynamic> generateOpenApiMap(
  SwaggerSpec spec, {
  String? baseUrl,
  String? authType,
  String? authDescription,
  List<String>? securedEndpoints,
  List<String>? unsecuredEndpoints,
  String? secureSingleUrl,
  bool disableAuthGlobally = false,
  Map<String, String>? customHttpMethods,
  Map<String, dynamic>? customInfo,
}) {
  final paths = <String, dynamic>{};
  // ... copy the implementation from parser.dart
  
  // Customize the OpenAPI map
  final openApiMap = {
    'openapi': '3.0.0',
    'info': customInfo ?? {'title': 'Serverpod API', 'version': '1.0.0'},
    'paths': paths
  };
  
  // ... rest of the implementation
  
  return openApiMap;
}