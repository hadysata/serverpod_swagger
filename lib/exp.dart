import 'dart:convert';
import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

// --- MAIN FUNCTION (MODIFIED FOR ON-DEMAND LOGIC) ---
Future<void> main(List<String> args) async {
  print('Starting OpenAPI spec generation with on-demand parsing...');

  final projectPath = Directory.current.path;
  final specGenerator = OpenApiSpecGenerator(projectPath);

  // Step 1: Initialize by mapping all package locations.
  print('\nInitializing package locations...');
  await specGenerator.initialize();

  // Step 2: Parse only the local project's models to start the process.
  print('\nParsing local project models...');
  final localModelsPath = p.join(projectPath, 'lib', 'src', 'models');
  final localModelsDir = Directory(localModelsPath);
  if (localModelsDir.existsSync()) {
    final localModelFiles = findModelFilesRecursively(localModelsDir);
    print('  Found ${localModelFiles.length} local model files.');
    for (final file in localModelFiles) {
      // This is now an async operation.
      await specGenerator.parseYamlModelFile(file.path);
    }
  }

  // Step 3: Parse endpoints. This will trigger on-demand parsing of package models.
  print('\nParsing Dart endpoint files...');
  final endpointsPath = p.join(projectPath, 'lib', 'src', 'endpoints');
  final endpointsDir = Directory(endpointsPath);
  if (endpointsDir.existsSync()) {
    final endpointFiles = endpointsDir
        .listSync(recursive: true)
        .where((e) => e is File && e.path.endsWith('.dart'))
        .cast<File>();

    for (final file in endpointFiles) {
      print('  Parsing endpoint: ${p.relative(file.path, from: projectPath)}');
      await specGenerator.parseFile(file.path);
    }
  } else {
    print('  [WARN] Endpoints directory not found at: $endpointsPath');
  }

  // Step 4: Generate the final JSON.
  final openApiJson = specGenerator.toJson();
  final encoder = JsonEncoder.withIndent('  ');
  final jsonString = encoder.convert(openApiJson);
  final outputFile = File(p.join(projectPath, 'api_spec.json'));
  outputFile.writeAsStringSync(jsonString);

  print('\n✅ Successfully generated spec with ${specGenerator.schemas.length} schemas at: ${outputFile.path}');
}

/// Helper function to find model files in a directory.
List<File> findModelFilesRecursively(Directory dir) {
  final List<File> files = [];
  if (!dir.existsSync()) return files;
  for (final entity in dir.listSync()) {
    if (entity is Directory) {
      files.addAll(findModelFilesRecursively(entity));
    } else if (entity is File &&
        (entity.path.endsWith('.yaml') || entity.path.endsWith('.spy.yaml'))) {
      files.add(entity);
    }
  }
  return files;
}

// --- GENERATOR CLASS (MODIFIED FOR ON-DEMAND LOGIC) ---
class OpenApiSpecGenerator {
  final String projectPath;
  final AnalysisContextCollection _collection;

  final Map<String, dynamic> _paths = {};
  final Map<String, dynamic> _schemas = {};
  Map<String, dynamic> get schemas => _schemas;

  /// Maps a package name (e.g., 'serverpod_auth_server') to its root path on disk.
  final Map<String, String> _packageLocations = {};

  OpenApiSpecGenerator(this.projectPath)
      : _collection = AnalysisContextCollection(includedPaths: [projectPath]);


  /// Reads the package_config.json file to map out where all dependencies live.
  Future<void> initialize() async {
    final packageConfigFile =
        File(p.join(projectPath, '.dart_tool', 'package_config.json'));
    if (!await packageConfigFile.exists()) {
      print('  [WARN] package_config.json not found. Cannot search in dependencies.');
      return;
    }
    final packageConfigContent = await packageConfigFile.readAsString();
    final packageConfig =
        jsonDecode(packageConfigContent) as Map<String, dynamic>;
    final packages = packageConfig['packages'] as List<dynamic>;

    for (final package in packages) {
      final packageName = package['name'] as String;
      final rootUriString = package['rootUri'] as String;
      final packageRootPath =
          Uri.parse(rootUriString).toFilePath(windows: Platform.isWindows);
      _packageLocations[packageName] = packageRootPath;
    }
    print('  Found locations for ${_packageLocations.length} packages.');
  }

  /// Parses a single YAML model file. This is the entry point for all model parsing.
  Future<void> parseYamlModelFile(String path) async {
    try {
      final content = await File(path).readAsString();
      if (content.trim().isEmpty) return;

      final yaml = loadYaml(content);
      if (yaml is! YamlMap) return;

      final className = (yaml['class'] ?? yaml['exception']) as String?;
      if (className == null) return;

      final sanitizedClassName = _sanitizeClassName(className);
      if (_schemas.containsKey(sanitizedClassName)) return;

      print('  Parsing model: ${p.relative(path, from: projectPath)} (as $sanitizedClassName)');

      // Add a placeholder to prevent infinite recursion if models reference each other.
      _schemas[sanitizedClassName] = {};

      final fields = yaml['fields'] as YamlMap?;
      final properties = <String, dynamic>{};
      final requiredFields = <String>[];
      if (fields != null) {
        for (final entry in fields.entries) {
          final fieldName = entry.key as String;
          final fieldValue = entry.value;
          final fieldType = (fieldValue is YamlMap ? fieldValue['type'] : fieldValue) as String;
          if (!fieldType.endsWith('?')) {
            requiredFields.add(fieldName);
          }
          // The mapping function is now async to handle on-demand lookups.
          properties[fieldName] = await _mapYamlTypeToOpenApiSchema(fieldType);
        }
      }

      // Now, populate the real schema, replacing the placeholder.
      final schema = <String, dynamic>{'type': 'object', 'properties': properties};
      if (requiredFields.isNotEmpty) {
        schema['required'] = requiredFields;
      }
      _schemas[sanitizedClassName] = schema;

    } catch (e) {
      print('  [ERROR] Failed to parse YAML file $path: $e');
    }
  }

  /// The core of the on-demand logic for YAML types.
  Future<Map<String, dynamic>> _mapYamlTypeToOpenApiSchema(String yamlType) async {
    final isNullable = yamlType.endsWith('?');
    final cleanType = isNullable ? yamlType.substring(0, yamlType.length - 1) : yamlType;

    if (cleanType.startsWith('List<') && cleanType.endsWith('>')) {
      final innerType = cleanType.substring(5, cleanType.length - 1);
      return {'type': 'array', 'items': await _mapYamlTypeToOpenApiSchema(innerType)};
    }
    if (cleanType.startsWith('Map<')) {
      return {'type': 'object', 'additionalProperties': true};
    }

    switch (cleanType) {
      case 'String': return {'type': 'string'};
      case 'int': return {'type': 'integer', 'format': 'int64'};
      case 'double': return {'type': 'number', 'format': 'double'};
      case 'bool': return {'type': 'boolean'};
      case 'DateTime': return {'type': 'string', 'format': 'date-time'};
      case 'ByteData': return {'type': 'string', 'format': 'byte'};
      case 'Duration': return {'type': 'string', 'description': 'Duration in ISO 8601 format'};
      case 'Uri': return {'type': 'string', 'format': 'uri'};
      default:
        final sanitizedClassName = _sanitizeClassName(cleanType);

        // ON-DEMAND: If we haven't seen this schema, find and parse it.
        if (!_schemas.containsKey(sanitizedClassName)) {
          print('    -> Discovered dependency: $cleanType. Attempting to parse...');
          final parts = cleanType.split(':');
          if (parts.length == 3 && parts[0] == 'module') {
            final module = parts[1];
            final className = parts[2];
            await _findAndParseModel(module, className);
          }
        }
        return {'\$ref': '#/components/schemas/$sanitizedClassName'};
    }
  }
  
 /// Finds a model file in packages based on module/class name and parses it.
  Future<void> _findAndParseModel(String module, String className) async {
    final packageName = 'serverpod_${module}_server';
    final packagePath = _packageLocations[packageName];
    if (packagePath == null) {
        print('      [WARN] Could not find package location for "$packageName"');
        return;
    }

    final modelFileName = _classNameToFileName(className);
    final modelFilePath = p.join(packagePath, 'lib', 'src', 'models', modelFileName);
    
    if (await File(modelFilePath).exists()) {
      await parseYamlModelFile(modelFilePath);
    } else {
      print('[WARN] Could not find model file at: $modelFilePath');
    }
  }

  Future<void> parseFile(String path) async {
    final context = _collection.contextFor(path);
    final result = await context.currentSession.getResolvedUnit(path);
    if (result is ResolvedUnitResult) {
      final visitor = _EndpointVisitor(this);
      await visitor.visitUnit(result.unit);
    }
  }

  bool _isPrimitiveType(DartType type) {
    return type.isDartCoreString || type.isDartCoreInt || type.isDartCoreDouble ||
           type.isDartCoreBool || type.element?.name == 'DateTime' ||
           type.element?.name == 'ByteData' || type.element?.name == 'Uri' ||
           type.isDartCoreMap || (type is InterfaceType && type.element is EnumElement);
  }

  Future<Map<String, dynamic>> mapDartTypeToOpenApiSchema(DartType type) async {
    if (type.isDartCoreString) return {'type': 'string'};
    if (type.isDartCoreInt) return {'type': 'integer', 'format': 'int64'};
    if (type.isDartCoreDouble) return {'type': 'number', 'format': 'double'};
    if (type.isDartCoreBool) return {'type': 'boolean'};
    if (type.element?.name == 'DateTime') return {'type': 'string', 'format': 'date-time'};
    if (type.element?.name == 'ByteData') return {'type': 'string', 'format': 'byte'};
    if (type.element?.name == 'Uri' && type.element?.library?.isDartCore == true) return {'type': 'string', 'format': 'uri'};

    if (type is InterfaceType) {
      if (type.isDartCoreList) {
        final itemType = type.typeArguments.first;
        return {'type': 'array', 'items': await mapDartTypeToOpenApiSchema(itemType)};
      }
      if (type.isDartCoreMap) return {'type': 'object', 'additionalProperties': true};

      final className = type.element.name;
      // ON-DEMAND for Dart types
      if (!_schemas.containsKey(className)) {
          final libraryUri = type.element.library.source.uri;
          if (libraryUri.scheme == 'package') {
            final packageName = libraryUri.pathSegments.first;
            if (packageName.startsWith('serverpod_') && packageName.endsWith('_server')) {
                final moduleName = packageName.replaceAll('serverpod_', '').replaceAll('_server', '');
                print('    -> Discovered dependency: $className from module $moduleName. Attempting to parse...');
                await _findAndParseModel(moduleName, className);
            }
          }
      }
      return {'\$ref': '#/components/schemas/$className'};
    }
    return {};
  }
  
  Map<String, dynamic> toJson() => {'openapi': '3.0.0','info': {'title': 'My Serverpod API', 'version': '1.0.0'},'servers': [{'url': 'http://localhost:8080'}],'paths': _paths,'components': {'schemas': _schemas}};
  String _sanitizeClassName(String className) => className.split(':').last;
  String _classNameToFileName(String className) {
    final regExp = RegExp(r'(?<=[a-z])(?=[A-Z])');
    return '${className.replaceAllMapped(regExp, (m) => '_').toLowerCase()}.spy.yaml';
  }
}

// --- ENDPOINT VISITOR (YOUR LOGIC, MINIMALLY MODIFIED TO BE ASYNC) ---
class _EndpointVisitor extends RecursiveAstVisitor<void> {
  final OpenApiSpecGenerator generator;
  String? _currentEndpointName;

  _EndpointVisitor(this.generator);

  Future<void> visitUnit(CompilationUnit unit) async {
    for (final declaration in unit.declarations) {
      if (declaration is ClassDeclaration) {
        await visitClassDeclaration(declaration);
      }
    }
  }

  @override
  Future<void> visitClassDeclaration(ClassDeclaration node) async {
    final superclass = node.extendsClause?.superclass.name2.lexeme;
    if (superclass == 'Endpoint') {
      final rawName = node.name.lexeme.replaceAll('Endpoint', '');
      _currentEndpointName = toCamelCase(rawName);
      print('  -> Found Endpoint: $_currentEndpointName');
      for (final member in node.members) {
        if (member is MethodDeclaration) {
          await visitMethodDeclaration(member);
        }
      }
      _currentEndpointName = null;
    }
  }

  String toCamelCase(String input) {
    if (input.isEmpty) return input;
    return input[0].toLowerCase() + input.substring(1);
  }

  @override
  Future<void> visitMethodDeclaration(MethodDeclaration node) async {
    if (_currentEndpointName == null) return;
    final methodName = node.name.lexeme;
    if (methodName.startsWith('_') ||
        ['initialize', 'streamOpened', 'streamClosed', 'handleStreamMessage']
            .contains(methodName)) {
      return;
    }
    print('    -> Found Method: $methodName');
    final path = '/$_currentEndpointName/$methodName';
    final apiParams = node.parameters?.parameters
            .map((p) => p.declaredElement)
            .where((p) => p != null && p.type.element?.name != 'Session')
            .cast<ParameterElement>()
            .toList() ??
        [];
    final bool isPostRequest =
        apiParams.any((p) => !generator._isPrimitiveType(p.type));
    print('        - Detected as ${isPostRequest ? 'POST' : 'GET'} request.');
    final pathItem = <String, dynamic>{};
    if (isPostRequest) {
      final properties = <String, dynamic>{};
      for (final param in apiParams) {
        properties[param.name] =
            await generator.mapDartTypeToOpenApiSchema(param.type);
      }
      final requestBody = {'content': {'application/json': {'schema': {'type': 'object', 'properties': properties}}}};
      pathItem['post'] = {'summary': methodName, 'operationId': '$_currentEndpointName.$methodName', 'tags': [_currentEndpointName], if (properties.isNotEmpty) 'requestBody': requestBody};
    } else {
      final openApiParameters = <Map<String, dynamic>>[];
      for (final param in apiParams) {
        openApiParameters.add({
          'name': param.name, 'in': 'query', 'required': param.type.nullabilitySuffix != NullabilitySuffix.question, 'schema': await generator.mapDartTypeToOpenApiSchema(param.type),
        });
      }
      pathItem['get'] = {'summary': methodName, 'operationId': '$_currentEndpointName.$methodName', 'tags': [_currentEndpointName], if (openApiParameters.isNotEmpty) 'parameters': openApiParameters};
    }
    final DartType? returnTypeFromElement = node.declaredElement?.returnType;
    Map<String, dynamic> responseSchema = {};
    if (returnTypeFromElement != null) {
      DartType finalType = returnTypeFromElement;
      if (finalType.isDartAsyncFuture && finalType is InterfaceType && finalType.typeArguments.isNotEmpty) {
        finalType = finalType.typeArguments.first;
      }
      if (!finalType.isDartCoreNull && finalType.element?.name != 'void') {
        responseSchema = await generator.mapDartTypeToOpenApiSchema(finalType);
      }
    }
    final responses = {'200': {'description': 'Successful operation', if (responseSchema.isNotEmpty) 'content': {'application/json': {'schema': responseSchema}}}};
    (pathItem['get'] ?? pathItem['post'])['responses'] = responses;
    generator._paths[path] = pathItem;
  }
}