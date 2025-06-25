// parser.dart (DEFINITIVE VERSION USING RecursiveAstVisitor)

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:serverpod_swagger_ui/src/models/swagger.dart';

// --- THE FIX IS HERE: We change the base class ---
class EndpointsVisitor extends RecursiveAstVisitor<void> {
  final SwaggerSpec spec = SwaggerSpec();

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    // Because RecursiveAstVisitor visits EVERY node, we just need to check if
    // the current node is the one we're interested in.
    if (node.constructorName.type.toSource().endsWith('EndpointConnector')) {
      print('✅ Found an EndpointConnector, parsing its details...');
      _parseEndpointConnector(node);

      // IMPORTANT: By returning here, we stop this visitor from recursing
      // into the children of EndpointConnector, which is correct because
      // our _parse... methods have already handled them.
      return;
    }

    // If it's not the node we want, we let the base class continue its
    // automatic recursion into the children of the current node.
    super.visitInstanceCreationExpression(node);
  }

  //
  // --- ALL THE PARSING LOGIC BELOW IS CORRECT AND REMAINS UNCHANGED ---
  //

  void _parseEndpointConnector(InstanceCreationExpression connectorNode) {
    try {
      final endpointNameArg = connectorNode.argumentList.arguments
          .whereType<NamedExpression>()
          .firstWhere((arg) => arg.name.label.name == 'name');
      final endpointName = (endpointNameArg.expression as SimpleStringLiteral).value;
      print('  -> Parsing endpoint: $endpointName');

      final endpoint = SwaggerEndpoint(endpointName);

      final methodConnectorsArg = connectorNode.argumentList.arguments
          .whereType<NamedExpression>()
          .firstWhere((arg) => arg.name.label.name == 'methodConnectors');
      final methodConnectorsMap = methodConnectorsArg.expression as SetOrMapLiteral;

      for (var entry in methodConnectorsMap.elements.whereType<MapLiteralEntry>()) {
        final methodName = (entry.key as SimpleStringLiteral).value;
        print('    -> Parsing method: $methodName');
        final method = SwaggerMethod(methodName);

        if (entry.value is InstanceCreationExpression) {
          _parseMethodConnector(entry.value as InstanceCreationExpression, method);
        }
        endpoint.methods[methodName] = method;
      }
      spec.endpoints[endpointName] = endpoint;
    } catch (e, st) {
      print('❌ ERROR parsing EndpointConnector: $e');
      print(st);
    }
  }

  void _parseMethodConnector(InstanceCreationExpression methodNode, SwaggerMethod method) {
    final paramsArg = methodNode.argumentList.arguments
        .whereType<NamedExpression>()
        .firstWhere((arg) => arg.name.label.name == 'params');
    final paramsMap = paramsArg.expression as SetOrMapLiteral;

    for (var entry in paramsMap.elements.whereType<MapLiteralEntry>()) {
      final paramName = (entry.key as SimpleStringLiteral).value;

      if (entry.value is InstanceCreationExpression) {
        final param = _parseParameterDescription(entry.value as InstanceCreationExpression);
        method.parameters[paramName] = param;
      }
    }
  }

  SwaggerParameter _parseParameterDescription(InstanceCreationExpression paramNode) {
    final nameArg = paramNode.argumentList.arguments
        .whereType<NamedExpression>()
        .firstWhere((arg) => arg.name.label.name == 'name');
    final paramName = (nameArg.expression as SimpleStringLiteral).value;

    final nullableArg = paramNode.argumentList.arguments
        .whereType<NamedExpression>()
        .firstWhere((arg) => arg.name.label.name == 'nullable');
    final isNullable = (nullableArg.expression as BooleanLiteral).value;

    final typeArg = paramNode.argumentList.arguments
        .whereType<NamedExpression>()
        .firstWhere((arg) => arg.name.label.name == 'type');

    String paramType = 'dynamic';
    if (typeArg.expression is MethodInvocation) {
      final typeInvocation = typeArg.expression as MethodInvocation;
      if (typeInvocation.typeArguments != null && typeInvocation.typeArguments!.arguments.isNotEmpty) {
        final typeNode = typeInvocation.typeArguments!.arguments.first;
        paramType = typeNode.toSource();
      }
    }

    print('      -> Found parameter: $paramName (type: $paramType)');
    return SwaggerParameter(name: paramName, type: paramType, isNullable: isNullable);
  }
}


// ADD THIS NEW CLASS to the bottom of your parser.dart file

class BruteForceVisitor extends GeneralizingAstVisitor<void> {
  int _indent = 0;

  @override
  void visitNode(AstNode node) {
    final output = '  ' * _indent;
    // This will print every single node type the visitor encounters
    print('$output Node Type: ${node.runtimeType}');
    
    _indent++;
    super.visitNode(node); // This is crucial to continue walking the tree
    _indent--;
  }
}