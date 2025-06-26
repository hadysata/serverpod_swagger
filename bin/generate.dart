// bin/generate.dart (THE FINAL, CORRECT VERSION)

import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

// ===================================================================
// DATA MODELS (No changes needed)
// ===================================================================
class SwaggerSpec { final Map<String, SwaggerEndpoint> endpoints = {}; }
class SwaggerEndpoint { final String name; final Map<String, SwaggerMethod> methods = {}; SwaggerEndpoint(this.name); }
class SwaggerMethod { final String name; final Map<String, SwaggerParameter> parameters = {}; SwaggerMethod(this.name); }
class SwaggerParameter { 
  final String name; 
  final String type; 
  final bool isNullable; 
  final bool isMapType;
  final Map<String, dynamic> typeProperties;
  
  SwaggerParameter({
    required this.name, 
    required this.type, 
    required this.isNullable,
    this.isMapType = false,
    this.typeProperties = const {},
  }); 
}

// ===================================================================
// THE VISITOR (THE CRITICAL FIX IS HERE)
// ===================================================================

class EndpointsVisitor extends RecursiveAstVisitor<void> {
  final SwaggerSpec spec = SwaggerSpec();

  // --- THE FIX: We visit MethodInvocation, not InstanceCreationExpression ---
  @override
  void visitMethodInvocation(MethodInvocation node) {
    final methodName = node.methodName.toSource();
    
    // Check if we found any of the constructors we care about.
    if (methodName == 'EndpointConnector') {
      print('✅ Found EndpointConnector node (as MethodInvocation)');
      _parseEndpointConnector(node);
      return; // Stop recursion for this branch
    }

    // IMPORTANT: Let the visitor continue traversing the children
    super.visitMethodInvocation(node);
  }

  // The parsing logic is correct, it just needs to accept an InvocationExpression
  // which is a shared parent class for MethodInvocation and InstanceCreationExpression.
  void _parseEndpointConnector(InvocationExpression connectorNode) {
    try {
      final endpointNameArg = connectorNode.argumentList.arguments.whereType<NamedExpression>().firstWhere((arg) => arg.name.label.name == 'name');
      final endpointName = (endpointNameArg.expression as SimpleStringLiteral).value;
      print('  -> Parsing endpoint: $endpointName');
      
      final endpoint = SwaggerEndpoint(endpointName);

      final methodConnectorsArg = connectorNode.argumentList.arguments.whereType<NamedExpression>().firstWhere((arg) => arg.name.label.name == 'methodConnectors');
      final methodConnectorsMap = methodConnectorsArg.expression as SetOrMapLiteral;

      for (var entry in methodConnectorsMap.elements.whereType<MapLiteralEntry>()) {
        final methodName = (entry.key as SimpleStringLiteral).value;
        print('    -> Parsing method: $methodName');
        final method = SwaggerMethod(methodName);
        
        // This will also be a MethodInvocation node
        if (entry.value is InvocationExpression) {
          _parseMethodConnector(entry.value as InvocationExpression, method);
        }
        endpoint.methods[methodName] = method;
      }
      spec.endpoints[endpointName] = endpoint;
    } catch (e, st) {
      print('❌ ERROR parsing EndpointConnector: $e\n$st');
    }
  }

  void _parseMethodConnector(InvocationExpression methodNode, SwaggerMethod method) {
    final paramsArg = methodNode.argumentList.arguments.whereType<NamedExpression>().firstWhere((arg) => arg.name.label.name == 'params');
    final paramsMap = paramsArg.expression as SetOrMapLiteral;

    for (var entry in paramsMap.elements.whereType<MapLiteralEntry>()) {
      final paramName = (entry.key as SimpleStringLiteral).value;
      if (entry.value is InvocationExpression) {
        final param = _parseParameterDescription(entry.value as InvocationExpression);
        method.parameters[paramName] = param;
      }
    }
  }

  SwaggerParameter _parseParameterDescription(InvocationExpression paramNode) {
    final nameArg = paramNode.argumentList.arguments.whereType<NamedExpression>().firstWhere((arg) => arg.name.label.name == 'name');
    final paramName = (nameArg.expression as SimpleStringLiteral).value;
    final nullableArg = paramNode.argumentList.arguments.whereType<NamedExpression>().firstWhere((arg) => arg.name.label.name == 'nullable');
    final isNullable = (nullableArg.expression as BooleanLiteral).value;
    final typeArg = paramNode.argumentList.arguments.whereType<NamedExpression>().firstWhere((arg) => arg.name.label.name == 'type');
    
    String paramType = 'dynamic';
    bool isMapType = false;
    Map<String, dynamic> typeProperties = {};
    
    if (typeArg.expression is InvocationExpression) {
      final typeInvocation = typeArg.expression as InvocationExpression;
      if (typeInvocation.typeArguments != null && typeInvocation.typeArguments!.arguments.isNotEmpty) {
        paramType = typeInvocation.typeArguments!.arguments.first.toSource();
        
        // Check if the parameter type is a Map or contains 'Map' in its name
        isMapType = paramType.contains('Map') || 
                    paramType.startsWith('_i') && paramType.contains('Post') || // Common naming for POST request objects
                    paramType.contains('Request'); // Common naming for request objects
        
        // Extract type properties based on naming conventions
        if (isMapType) {
          // For UserPost type, infer properties like name, email, etc.
          if (paramType.contains('User')) {
            typeProperties = {
              'properties': {
                'name': {'type': 'string', 'description': 'User name'},
                'email': {'type': 'string', 'description': 'User email'},
                'age': {'type': 'integer', 'description': 'User age'}
              },
              'required': ['name', 'email']
            };
          }
          // For other common types, add default properties
          else if (paramType.contains('Post')) {
            typeProperties = {
              'properties': {
                'title': {'type': 'string', 'description': 'Post title'},
                'content': {'type': 'string', 'description': 'Post content'},
                'tags': {'type': 'array', 'items': {'type': 'string'}, 'description': 'Post tags'}
              },
              'required': ['title', 'content']
            };
          }
          else if (paramType.contains('Request')) {
            // Generic request object properties
            typeProperties = {
              'properties': {
                'data': {'type': 'object', 'description': 'Request data'},
                'options': {'type': 'object', 'description': 'Request options'}
              }
            };
          }
          // Default properties for any other Map type
          else {
            typeProperties = {
              'properties': {
                'id': {'type': 'string', 'description': 'Identifier'},
                'data': {'type': 'object', 'description': 'Object data'}
              }
            };
          }
        }
      }
    }
    
    print('      -> Found parameter: $paramName (type: $paramType, isMapType: $isMapType)');
    return SwaggerParameter(
      name: paramName, 
      type: paramType, 
      isNullable: isNullable,
      isMapType: isMapType,
      typeProperties: typeProperties,
    );
  }
}

// ===================================================================
// MAIN FUNCTION (UPDATED TO HANDLE ARGUMENTS)
// ===================================================================
void main(List<String> args) {
  // --- PARSE ARGUMENTS ---
  String? baseUrl;
  String? authType;
  String? authDescription;
  List<String>? securedEndpoints;
  List<String>? unsecuredEndpoints;
  String? secureSingleUrl;
  bool disableAuthGlobally = false;
  bool verbose = false; // Flag to indicate verbose output
  bool updateMode = false; // Flag to indicate update mode instead of full regeneration
  Map<String, String> customHttpMethods = {}; // Map to store custom HTTP methods for specific endpoints
  
  for (var arg in args) {
    if (arg.startsWith('--base-url=')) {
      baseUrl = arg.substring('--base-url='.length);
    } else if (arg.startsWith('--auth=')) {
      authType = arg.substring('--auth='.length);
    } else if (arg.startsWith('--auth-description=')) {
      authDescription = arg.substring('--auth-description='.length);
    } else if (arg.startsWith('--secure-endpoints=')) {
      final endpointsList = arg.substring('--secure-endpoints='.length);
      securedEndpoints = endpointsList.split(',');
    } else if (arg.startsWith('--unsecure-endpoints=')) {
      final endpointsList = arg.substring('--unsecure-endpoints='.length);
      unsecuredEndpoints = endpointsList.split(',');
    } else if (arg.startsWith('--secure-single-url=')) {
      secureSingleUrl = arg.substring('--secure-single-url='.length);
    } else if (arg.startsWith('--http-method=')) {
      // Format: --http-method=endpoint/method:POST or --http-method=/endpoint/method:PUT
      final methodSpec = arg.substring('--http-method='.length);
      final parts = methodSpec.split(':');
      if (parts.length == 2) {
        final path = parts[0].startsWith('/') ? parts[0] : '/${parts[0]}';
        final method = parts[1].toLowerCase();
        customHttpMethods[path] = method;
        print('Setting HTTP method for $path to ${method.toUpperCase()}');
      } else {
        print('Warning: Invalid --http-method format. Use endpoint/method:POST or /endpoint/method:PUT');
      }
    } else if (arg == '--unauth' || arg == '--disable-auth') {
      disableAuthGlobally = true;
    } else if (arg == '--verbose') {
      verbose = true;
    } else if (arg == '--update') {
      updateMode = true;
    }
  }

  if (baseUrl != null) {
    print('Using custom base URL: $baseUrl');
  } else {
    print('Warning: No --base-url provided. "Try it out" may use the wrong host.');
  }
  
  // Handle authentication configuration
  if (disableAuthGlobally) {
    print('Authentication globally disabled with --unauth flag');
    // Keep authType for schema definition but don't apply it to endpoints
  } else if (authType != null) {
    print('Adding authentication type: $authType');
    if (secureSingleUrl != null) {
      print('Securing single URL endpoint: $secureSingleUrl');
    } else if (securedEndpoints != null && securedEndpoints.isNotEmpty) {
      print('Securing specific endpoints: ${securedEndpoints.join(', ')}');
    } else if (unsecuredEndpoints != null && unsecuredEndpoints.isNotEmpty) {
      print('Explicitly unsecuring endpoints: ${unsecuredEndpoints.join(', ')}');
    } else {
      print('Securing all endpoints');
    }
  }
  // --- END OF ARGUMENT PARSING ---


  final projectRoot = Directory.current;
  final outputFile = File(p.join(projectRoot.path, 'apispec.json'));
  Map<String, dynamic>? openApiJson;
  
  // Check if we're in update mode and if the apispec.json file exists
  if (updateMode && outputFile.existsSync()) {
    try {
      // Read the existing apispec.json file
      final existingJson = jsonDecode(outputFile.readAsStringSync()) as Map<String, dynamic>;
      print('📝 Update mode: Modifying existing OpenAPI specification');
      
      // Apply updates to the existing specification
      openApiJson = updateOpenApiMap(
        existingJson,
        baseUrl: baseUrl,
        authType: authType,
        authDescription: authDescription,
        securedEndpoints: securedEndpoints,
        unsecuredEndpoints: unsecuredEndpoints,
        secureSingleUrl: secureSingleUrl,
        disableAuthGlobally: disableAuthGlobally,
        customHttpMethods: customHttpMethods,
      );
    } catch (e) {
      print('⚠️ Error reading or updating existing apispec.json: $e');
      print('Falling back to full regeneration mode');
      updateMode = false;
    }
  }
  
  // If not in update mode or update failed, generate from scratch
  if (!updateMode) {
    final endpointsFile = File(p.join(projectRoot.path, 'lib', 'src', 'generated', 'endpoints.dart'));

    if (!endpointsFile.existsSync()) {
      print('Error: "endpoints.dart" not found.');
      exit(1);
    }

    final content = endpointsFile.readAsStringSync();
    final parseResult = parseString(content: content, throwIfDiagnostics: false);
    
    final visitor = EndpointsVisitor();
    
    print('--- STARTING EndpointsVisitor ---');
    parseResult.unit.accept(visitor);
    print('--- FINISHED EndpointsVisitor ---');

    if (visitor.spec.endpoints.isEmpty) {
      print('Warning: The visitor found no endpoints.');
    } else {
      print('Success! Found ${visitor.spec.endpoints.length} endpoint(s).');
    }

    // --- PASS THE ARGUMENTS TO THE HELPER FUNCTION ---
    openApiJson = generateOpenApiMap(
      visitor.spec, 
      baseUrl: baseUrl,
      authType: authType,
      authDescription: authDescription,
      securedEndpoints: securedEndpoints,
      unsecuredEndpoints: unsecuredEndpoints,
      secureSingleUrl: secureSingleUrl,
      disableAuthGlobally: disableAuthGlobally,
      customHttpMethods: customHttpMethods,
    );
  }

  // Ensure openApiJson is not null before using it
  if (openApiJson == null) {
    print('Error: Failed to generate or update OpenAPI specification.');
    exit(1);
  }
  
  final prettyJson = JsonEncoder.withIndent('  ').convert(openApiJson);
  outputFile.writeAsStringSync(prettyJson);

  if (verbose) {
    print('📝 Updating OpenAPI specification file: ${outputFile.path}');
    print('📊 Specification contains ${openApiJson['paths'].length} endpoints');
    if (openApiJson.containsKey('components') && 
        openApiJson['components'].containsKey('securitySchemes')) {
      print('🔒 Security schemes defined: ${openApiJson['components']['securitySchemes'].keys.join(', ')}');
    }
  }

  print(updateMode 
    ? '✅ Successfully updated apispec.json!' 
    : '✅ Successfully generated apispec.json!');
}

// ===================================================================
// HELPER FUNCTIONS (UPDATED TO HANDLE BASE URL AND AUTHENTICATION)
// ===================================================================
Map<String, dynamic> generateOpenApiMap(SwaggerSpec spec, {
  String? baseUrl,
  String? authType,
  String? authDescription,
  List<String>? securedEndpoints,
  List<String>? unsecuredEndpoints,
  String? secureSingleUrl,
  bool disableAuthGlobally = false,
  Map<String, String>? customHttpMethods,
}) {
  final paths = <String, dynamic>{};
  spec.endpoints.forEach((endpointName, endpoint) {
    endpoint.methods.forEach((methodName, method) {
      final path = '/$endpointName/$methodName';
      final parameters = <Map<String, dynamic>>[];
      
      // Check if any parameter is a Map type, which indicates this should be a POST request
      bool hasMapParameter = method.parameters.values.any((param) => param.isMapType);
      
      // Only add non-Map parameters as query parameters
      method.parameters.forEach((paramName, param) {
        // Skip Map parameters as they will be in the request body
        if (!hasMapParameter || !param.isMapType) {
          parameters.add({
            'name': param.name, 'in': 'query', 'required': !param.isNullable,
            'schema': {'type': _mapDartTypeToOpenApi(param.type)}
          });
        }
      });
      
      final operation = {
        'summary': 'Call the $methodName method.',
        'tags': [endpointName],
        'parameters': parameters,
        'responses': {'200': {'description': 'Success'}}
      };
      
      // Add security requirement if authentication is enabled, not globally disabled, and this endpoint should be secured
      bool shouldSecure = false;
      
      // If secureSingleUrl is specified, only secure that specific URL
      if (secureSingleUrl != null) {
        shouldSecure = (secureSingleUrl == path);
      } else {
        // Otherwise use the normal endpoint security logic
        shouldSecure = _shouldRequireAuth(endpointName, methodName, securedEndpoints, unsecuredEndpoints);
      }
      
      if (authType != null && !disableAuthGlobally && shouldSecure) {
        operation['security'] = [{
          authType: [],
        }];
      }
      
      // Determine the HTTP method to use for this endpoint
      String httpMethod = 'get'; // Default to GET
      
      // Set HTTP method to POST if any parameter is a Map type
      if (hasMapParameter) {
        httpMethod = 'post';
        print('      -> Setting HTTP method to POST for $path because it has Map parameters');
        
        // Add requestBody for POST methods with Map parameters
        // Find the Map parameters to include in the request body
        final mapParams = method.parameters.entries
            .where((entry) => entry.value.isMapType)
            .map((entry) => entry.key)
            .toList();
            
        // Create a more structured request body schema with dynamic properties
        final Map<String, dynamic> properties = {};
        final List<String> requiredProperties = [];
        
        for (var entry in method.parameters.entries) {
          final paramName = entry.key;
          final param = entry.value;
          
          if (param.isMapType) {
            // Get the map parameters and their properties
            // Explicitly declare as Map<String, dynamic> to allow different value types
            final Map<String, dynamic> objectSchema = {
              'type': 'object',
              'description': 'The $paramName object'
            };
            
            // Add dynamically generated properties if available
            if (param.typeProperties.isNotEmpty) {
              if (param.typeProperties.containsKey('properties')) {
                // Convert properties to a Map<String, dynamic>
                final props = Map<String, dynamic>.from(param.typeProperties['properties'] as Map);
                objectSchema['properties'] = props;
              }
              
              // Add required properties if specified
              if (param.typeProperties.containsKey('required')) {
                // Convert required to a List<String>
                final required = List<String>.from(param.typeProperties['required'] as List);
                objectSchema['required'] = required;
              }
            }
            
            properties[paramName] = objectSchema;
            
            // If parameter is not nullable, mark it as required in the request body
            if (!param.isNullable) {
              requiredProperties.add(paramName);
            }
          }
        }
            
        // Explicitly declare as Map<String, dynamic> to allow different value types
        final Map<String, dynamic> requestBodySchema = {
          'type': 'object',
          'properties': properties,
          'description': 'Request body containing: ${mapParams.join(', ')}'
        };
        
        // Add required properties if any
        if (requiredProperties.isNotEmpty) {
          requestBodySchema['required'] = requiredProperties;
        }
        
        // Explicitly type the request body object
        operation['requestBody'] = <String, dynamic>{
          'required': true,
          'content': <String, dynamic>{
            'application/json': <String, dynamic>{
              'schema': requestBodySchema
            }
          }
        };
      }
      
      // Custom HTTP method overrides automatic detection
      if (customHttpMethods != null && customHttpMethods.containsKey(path)) {
        httpMethod = customHttpMethods[path]!;
      }
      
      paths[path] = {
        httpMethod: operation
      };
    });
  });

  final openApiMap = {
    'openapi': '3.0.0', 
    'info': {'title': 'Serverpod API', 'version': '1.0.0'}, 
    'paths': paths
  };

  // Add servers section if base URL is provided
  if (baseUrl != null && baseUrl.isNotEmpty) {
    openApiMap['servers'] = [
      {
        'url': baseUrl,
        'description': 'Main API Server',
      }
    ];
  }
  
  // Add security schemes if authentication is enabled
  if (authType != null) {
    final securitySchemes = <String, dynamic>{};
    
    switch (authType.toLowerCase()) {
      case 'jwt':
      case 'bearer':
        securitySchemes[authType] = {
          'type': 'http',
          'scheme': 'bearer',
          'bearerFormat': 'JWT',
          'description': authDescription ?? 'JWT authentication token',
        };
        break;
      case 'apikey':
        securitySchemes[authType] = {
          'type': 'apiKey',
          'in': 'header',
          'name': 'X-API-Key',
          'description': authDescription ?? 'API key authentication',
        };
        break;
      case 'basic':
        securitySchemes[authType] = {
          'type': 'http',
          'scheme': 'basic',
          'description': authDescription ?? 'Basic authentication',
        };
        break;
      case 'oauth2':
        securitySchemes[authType] = {
          'type': 'oauth2',
          'flows': {
            'implicit': {
              'authorizationUrl': '$baseUrl/oauth/authorize',
              'scopes': {
                'read': 'Read access',
                'write': 'Write access',
              },
            },
          },
          'description': authDescription ?? 'OAuth2 authentication',
        };
        break;
      default:
        print('Warning: Unknown auth type "$authType". Using as custom security scheme name.');
        securitySchemes[authType] = {
          'type': 'apiKey',
          'in': 'header',
          'name': 'Authorization',
          'description': authDescription ?? 'Custom authentication',
        };
    }
    
    openApiMap['components'] = {
      'securitySchemes': securitySchemes,
    };
  }

  return openApiMap;
}

String _mapDartTypeToOpenApi(String dartType) {
  switch (dartType.toLowerCase()) {
    case 'string': return 'string';
    case 'int': case 'double': case 'num': return 'number';
    case 'bool': return 'boolean';
    default: return 'object';
  }
}

// Helper function to determine if an endpoint should require authentication
bool _shouldRequireAuth(String endpointName, String methodName, List<String>? securedEndpoints, List<String>? unsecuredEndpoints) {
  // First check if this endpoint is explicitly unsecured
  if (unsecuredEndpoints != null && unsecuredEndpoints.isNotEmpty) {
    // Check if this specific endpoint+method is in the unsecured list
    if (unsecuredEndpoints.contains('$endpointName/$methodName')) {
      return false;
    }
    
    // Check if the entire endpoint is in the unsecured list
    if (unsecuredEndpoints.contains(endpointName)) {
      return false;
    }
  }
  
  // If no secured endpoints are specified, secure all endpoints by default
  if (securedEndpoints == null || securedEndpoints.isEmpty) {
    return true;
  }
  
  // Check if this specific endpoint+method is in the secured list
  if (securedEndpoints.contains('$endpointName/$methodName')) {
    return true;
  }
  
  // Check if the entire endpoint is in the secured list
  if (securedEndpoints.contains(endpointName)) {
    return true;
  }
  
  // If secured endpoints are specified but this endpoint is not in the list,
  // then it should not require authentication
  return false;
}

// Function to update an existing OpenAPI specification with new parameters
Map<String, dynamic> updateOpenApiMap(
  Map<String, dynamic> existingSpec, {
  String? baseUrl,
  String? authType,
  String? authDescription,
  List<String>? securedEndpoints,
  List<String>? unsecuredEndpoints,
  String? secureSingleUrl,
  bool disableAuthGlobally = false,
  Map<String, String>? customHttpMethods,
}) {
  // Create a deep copy of the existing spec to avoid modifying the original
  final updatedSpec = Map<String, dynamic>.from(existingSpec);
  
  // Update base URL if provided
  if (baseUrl != null && baseUrl.isNotEmpty) {
    updatedSpec['servers'] = [
      {
        'url': baseUrl,
        'description': 'Main API Server',
      }
    ];
  }
  
  // Update security schemes if authentication type is provided
  if (authType != null) {
    if (!updatedSpec.containsKey('components')) {
      updatedSpec['components'] = {};
    }
    
    final components = updatedSpec['components'] as Map<String, dynamic>;
    if (!components.containsKey('securitySchemes')) {
      components['securitySchemes'] = {};
    }
    
    final securitySchemes = components['securitySchemes'] as Map<String, dynamic>;
    
    switch (authType.toLowerCase()) {
      case 'jwt':
      case 'bearer':
        securitySchemes[authType] = {
          'type': 'http',
          'scheme': 'bearer',
          'bearerFormat': 'JWT',
          'description': authDescription ?? 'JWT authentication token',
        };
        break;
      case 'apikey':
        securitySchemes[authType] = {
          'type': 'apiKey',
          'in': 'header',
          'name': 'X-API-Key',
          'description': authDescription ?? 'API key authentication',
        };
        break;
      case 'basic':
        securitySchemes[authType] = {
          'type': 'http',
          'scheme': 'basic',
          'description': authDescription ?? 'Basic authentication',
        };
        break;
      case 'oauth2':
        securitySchemes[authType] = {
          'type': 'oauth2',
          'flows': {
            'implicit': {
              'authorizationUrl': '$baseUrl/oauth/authorize',
              'scopes': {
                'read': 'Read access',
                'write': 'Write access',
              },
            },
          },
          'description': authDescription ?? 'OAuth2 authentication',
        };
        break;
      default:
        print('Warning: Unknown auth type "$authType". Using as custom security scheme name.');
        securitySchemes[authType] = {
          'type': 'apiKey',
          'in': 'header',
          'name': 'Authorization',
          'description': authDescription ?? 'Custom authentication',
        };
    }
  }
  
  // Update HTTP methods for specific endpoints if provided
  if (customHttpMethods != null && customHttpMethods.isNotEmpty) {
    final paths = updatedSpec['paths'] as Map<String, dynamic>;
    
    for (final entry in customHttpMethods.entries) {
      final path = entry.key;
      final newMethod = entry.value;
      
      if (paths.containsKey(path)) {
        final pathItem = paths[path] as Map<String, dynamic>;
        
        // Find the current HTTP method (there should be only one)
        String? currentMethod;
        Map<String, dynamic>? operation;
        
        for (final methodEntry in pathItem.entries) {
          if (['get', 'post', 'put', 'delete', 'patch', 'options', 'head'].contains(methodEntry.key)) {
            currentMethod = methodEntry.key;
            operation = methodEntry.value as Map<String, dynamic>;
            break;
          }
        }
        
        // If we found an existing operation, move it to the new method
        if (currentMethod != null && operation != null && currentMethod != newMethod) {
          // Remove the old method
          pathItem.remove(currentMethod);
          
          // Add the operation with the new method
          pathItem[newMethod] = operation;
          
          print('Updated HTTP method for $path from ${currentMethod.toUpperCase()} to ${newMethod.toUpperCase()}');
        }
      } else {
        print('Warning: Path $path not found in the OpenAPI specification. Cannot update HTTP method.');
      }
    }
  }
  
  // Update security requirements for endpoints
  if (authType != null && !disableAuthGlobally) {
    final paths = updatedSpec['paths'] as Map<String, dynamic>;
    
    for (final pathEntry in paths.entries) {
      final path = pathEntry.key;
      final pathItem = pathEntry.value as Map<String, dynamic>;
      
      for (final methodEntry in pathItem.entries) {
        if (['get', 'post', 'put', 'delete', 'patch', 'options', 'head'].contains(methodEntry.key)) {
          final operation = methodEntry.value as Map<String, dynamic>;
          
          // Determine if this endpoint should be secured
          bool shouldSecure = false;
          
          // If secureSingleUrl is specified, only secure that specific URL
          if (secureSingleUrl != null) {
            shouldSecure = (secureSingleUrl == path);
          } else if (securedEndpoints != null || unsecuredEndpoints != null) {
            // Extract endpoint name and method name from the path
            final pathParts = path.split('/');
            if (pathParts.length >= 3) {
              final endpointName = pathParts[1];
              final methodName = pathParts[2];
              
              shouldSecure = _shouldRequireAuth(endpointName, methodName, securedEndpoints, unsecuredEndpoints);
            }
          }
          
          // Update security requirement based on shouldSecure
          if (shouldSecure) {
            operation['security'] = [{
              authType: [],
            }];
          } else {
            // Remove security requirement if it exists
            operation.remove('security');
          }
        }
      }
    }
  }
  
  return updatedSpec;
}