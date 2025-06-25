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
class SwaggerParameter { final String name; final String type; final bool isNullable; SwaggerParameter({required this.name, required this.type, required this.isNullable}); }

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
    if (typeArg.expression is InvocationExpression) {
      final typeInvocation = typeArg.expression as InvocationExpression;
      if (typeInvocation.typeArguments != null && typeInvocation.typeArguments!.arguments.isNotEmpty) {
        paramType = typeInvocation.typeArguments!.arguments.first.toSource();
      }
    }
    
    print('      -> Found parameter: $paramName (type: $paramType)');
    return SwaggerParameter(name: paramName, type: paramType, isNullable: isNullable);
  }
}

// ===================================================================
// MAIN FUNCTION (UPDATED TO HANDLE ARGUMENTS)
// ===================================================================
void main(List<String> args) {
  // --- ADD THIS BLOCK TO PARSE ARGUMENTS ---
  String? baseUrl;
  for (var arg in args) {
    if (arg.startsWith('--base-url=')) {
      baseUrl = arg.substring('--base-url='.length);
    }
  }

  if (baseUrl != null) {
    print('Using custom base URL: $baseUrl');
  } else {
    print('Warning: No --base-url provided. "Try it out" may use the wrong host.');
  }
  // --- END OF ADDED BLOCK ---


  final projectRoot = Directory.current;
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

  // --- PASS THE BASE URL TO THE HELPER FUNCTION ---
  final openApiJson = generateOpenApiMap(visitor.spec, baseUrl: baseUrl);

  final outputFile = File(p.join(projectRoot.path, 'apispec.json'));
  final prettyJson = JsonEncoder.withIndent('  ').convert(openApiJson);
  outputFile.writeAsStringSync(prettyJson);

  print('✅ Successfully generated apispec.json!');
}

// ===================================================================
// HELPER FUNCTIONS (UPDATED TO HANDLE BASE URL)
// ===================================================================
Map<String, dynamic> generateOpenApiMap(SwaggerSpec spec, {String? baseUrl}) {
  final paths = <String, dynamic>{};
  spec.endpoints.forEach((endpointName, endpoint) {
    endpoint.methods.forEach((methodName, method) {
      final path = '/$endpointName/$methodName';
      final parameters = <Map<String, dynamic>>[];
      method.parameters.forEach((paramName, param) {
        parameters.add({
          'name': param.name, 'in': 'query', 'required': !param.isNullable,
          'schema': {'type': _mapDartTypeToOpenApi(param.type)}
        });
      });
      paths[path] = {
        'get': {
          'summary': 'Call the $methodName method.', 'tags': [endpointName],
          'parameters': parameters, 'responses': {'200': {'description': 'Success'}}
        }
      };
    });
  });

  final openApiMap = {
    'openapi': '3.0.0', 
    'info': {'title': 'Serverpod API', 'version': '1.0.0'}, 
    'paths': paths
  };

  // --- ADD THIS BLOCK TO INCLUDE THE SERVERS SECTION ---
  if (baseUrl != null && baseUrl.isNotEmpty) {
    openApiMap['servers'] = [
      {
        'url': baseUrl,
        'description': 'Main API Server',
      }
    ];
  }
  // --- END OF ADDED BLOCK ---

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