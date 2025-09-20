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

// ===================================================================
// MAIN FUNCTION (Entry Point with Full Argument Parsing)
// ===================================================================
Future<void> main(List<String> args) async {
  // --- PARSE ARGUMENTS ---
  String? baseUrl;
  String? authType;
  String? authDescription;
  List<String>? securedEndpoints;
  List<String>? unsecuredEndpoints;
  String? secureSingleUrl;
  String? unsecureSingleUrl;
  bool disableAuthGlobally = false;
  bool verbose = false;
  bool updateMode = false;
  Map<String, String> customHttpMethods = {};

  for (var arg in args) {
    if (arg.startsWith('--base-url=')) {
      baseUrl = arg.substring('--base-url='.length);
    } else if (arg.startsWith('--auth=')) {
      authType = arg.substring('--auth='.length);
    } else if (arg.startsWith('--auth-description=')) {
      authDescription = arg.substring('--auth-description='.length);
    } else if (arg.startsWith('--secure-endpoints=')) {
      securedEndpoints = arg.substring('--secure-endpoints='.length).split(',');
    } else if (arg.startsWith('--unsecure-endpoints=')) {
      unsecuredEndpoints =
          arg.substring('--unsecure-endpoints='.length).split(',');
    } else if (arg.startsWith('--secure-single-url=')) {
      secureSingleUrl = arg.substring('--secure-single-url='.length);
    } else if (arg.startsWith('--unsecure-single-url=')) {
      unsecureSingleUrl = arg.substring('--unsecure-single-url='.length);
    } else if (arg.startsWith('--http-method=')) {
      final methodSpec = arg.substring('--http-method='.length);
      final parts = methodSpec.split(':');
      if (parts.length == 2) {
        final path = parts[0].startsWith('/') ? parts[0] : '/${parts[0]}';
        final method = parts[1].toLowerCase();
        customHttpMethods[path] = method;
      } else {
        print(
            '[Warning] Invalid --http-method format. Use /endpoint/method:POST. Skipping: "$arg"');
      }
    } else if (arg == '--unauth' || arg == '--disable-auth') {
      disableAuthGlobally = true;
    } else if (arg == '--verbose') {
      verbose = true;
    } else if (arg == '--update') {
      updateMode = true;
    }
  }

  final projectPath = Directory.current.path;
  final outputFile = File(p.join(projectPath, 'apispec.json'));
  Map<String, dynamic>? openApiJson;

  // --- Step 1: GET THE BASE OPENAPI SPEC ---
  if (updateMode && outputFile.existsSync()) {
    try {
      print('📝 Update mode: Loading existing OpenAPI specification...');
      openApiJson =
          jsonDecode(outputFile.readAsStringSync()) as Map<String, dynamic>;
    } catch (e) {
      print(
          '⚠️ Error reading existing apispec.json: $e. Falling back to full regeneration.');
      updateMode = false;
    }
  }

  if (!updateMode) {
    print('🚀 Generating new OpenAPI specification from source...');
    final specGenerator = OpenApiSpecGenerator(projectPath);
    await specGenerator.generate();
    openApiJson = specGenerator.toJson();
  }

  if (openApiJson == null) {
    print('❌ Error: Failed to generate or load the OpenAPI specification.');
    exit(1);
  }

  // --- Step 2: APPLY CLI ARGUMENTS TO THE SPEC ---
  print('\n🔧 Applying command-line arguments to the specification...');
  final modifiedApiJson = applyCliArguments(
      spec: openApiJson,
      baseUrl: baseUrl,
      authType: authType,
      authDescription: authDescription,
      securedEndpoints: securedEndpoints,
      unsecuredEndpoints: unsecuredEndpoints,
      secureSingleUrl: secureSingleUrl,
      unsecureSingleUrl: unsecureSingleUrl,
      disableAuthGlobally: disableAuthGlobally,
      customHttpMethods: customHttpMethods,
      updateMode: updateMode);

  // --- Step 3: WRITE THE FINAL RESULT ---
  final prettyJson = JsonEncoder.withIndent('  ').convert(modifiedApiJson);
  outputFile.writeAsStringSync(prettyJson);

  if (verbose) {
    print('\n--- Verbose Output ---');
    print('Final OpenAPI specification file: ${outputFile.path}');
    print('Specification contains ${modifiedApiJson['paths'].length} paths.');
    if (modifiedApiJson.containsKey('components') &&
        (modifiedApiJson['components'] as Map).containsKey('securitySchemes')) {
      final schemes = modifiedApiJson['components']['securitySchemes'] as Map;
      print('Security schemes defined: ${schemes.keys.join(', ')}');
    }
    print('----------------------');
  }

  print(
      '\n✅ Successfully ${updateMode ? 'updated' : 'generated'} apispec.json!');
}

/// Enum to represent the three possible states for an endpoint's security.
enum _SecurityAction { secure, unsecure, noChange }

/// Determines the security action for an endpoint based on the provided lists.
/// This is the core logic for handling security policies correctly.
_SecurityAction _getSecurityAction(
  String endpointName,
  String methodName,
  List<String>? securedEndpoints,
  List<String>? unsecuredEndpoints,
) {
  final fullPath = '$endpointName/$methodName';

  // Rule 1: --unsecure-endpoints list has the highest priority.
  if (unsecuredEndpoints != null &&
      (unsecuredEndpoints.contains(fullPath) ||
          unsecuredEndpoints.contains(endpointName))) {
    return _SecurityAction.unsecure;
  }

  // Rule 2: --secure-endpoints list is next.
  if (securedEndpoints != null &&
      (securedEndpoints.contains(fullPath) ||
          securedEndpoints.contains(endpointName))) {
    return _SecurityAction.secure;
  }

  // Rule 3: Determine the default action if the endpoint isn't in any list.
  if (securedEndpoints != null && securedEndpoints.isNotEmpty) {
    // If a secure list was provided, the user is defining a full policy.
    // Anything not in that list should be UNSECURED.
    return _SecurityAction.unsecure;
  } else if (unsecuredEndpoints != null && unsecuredEndpoints.isNotEmpty) {
    // If ONLY an unsecure list was provided, the user is "patching".
    // Anything not in that list should be LEFT AS IS.
    return _SecurityAction.noChange;
  } else {
    // If NO lists were provided, the default policy is to SECURE EVERYTHING.
    // This applies during initial generation or when --auth is used alone.
    return _SecurityAction.secure;
  }
}

// ===================================================================
// HELPER FUNCTIONS (For Modifying the Spec based on CLI Args)
// ===================================================================
/// Applies all command-line modifications to a given OpenAPI map.
Map<String, dynamic> applyCliArguments({
  required Map<String, dynamic> spec,
  String? baseUrl,
  String? authType,
  String? authDescription,
  List<String>? securedEndpoints,
  List<String>? unsecuredEndpoints,
  String? secureSingleUrl,
  String? unsecureSingleUrl,
  bool disableAuthGlobally = false,
  Map<String, String>? customHttpMethods,
  required bool updateMode,
}) {
  final updatedSpec = jsonDecode(jsonEncode(spec)) as Map<String, dynamic>;
  final paths = updatedSpec['paths'] as Map<String, dynamic>;

  // --- RESTRUCTURED LOGIC: Handle each action type independently ---

  final normalizedSecuredEndpoints = securedEndpoints
      ?.map((e) => e.startsWith('/') ? e.substring(1) : e)
      .toList();
  final normalizedUnsecuredEndpoints = unsecuredEndpoints
      ?.map((e) => e.startsWith('/') ? e.substring(1) : e)
      .toList();

  // Determine which actions were requested by the user.
  bool isSecurityActionRequested = authType != null ||
      secureSingleUrl != null ||
      unsecureSingleUrl != null ||
      (normalizedSecuredEndpoints?.isNotEmpty ?? false) ||
      (normalizedUnsecuredEndpoints?.isNotEmpty ?? false) ||
      disableAuthGlobally;

  bool isHttpMethodActionRequested =
      customHttpMethods != null && customHttpMethods.isNotEmpty;
  bool isBaseUrlActionRequested = baseUrl != null && baseUrl.isNotEmpty;

  // Case: An update was run with no valid action flags.
  if (updateMode &&
      !isSecurityActionRequested &&
      !isHttpMethodActionRequested &&
      !isBaseUrlActionRequested) {
    print('  -> No update flags provided. Nothing to do.');
    return updatedSpec;
  }

  // --- Action 1: Handle Base URL ---
  if (isBaseUrlActionRequested) {
    print('  -> Setting base URL to: $baseUrl');
    updatedSpec['servers'] = [
      {'url': baseUrl, 'description': 'Main API Server'}
    ];
  }

  // --- Action 2: Handle Security (This block only runs if a security flag is present) ---
  if (isSecurityActionRequested) {
    String? effectiveAuthType = authType;
    if (effectiveAuthType == null && !disableAuthGlobally) {
      print(
          '  -> Auth type not provided via CLI. Attempting to infer from existing spec...');
      final components = updatedSpec['components'] as Map<String, dynamic>?;
      final securitySchemes =
          components?['securitySchemes'] as Map<String, dynamic>?;
      if (securitySchemes != null && securitySchemes.isNotEmpty) {
        effectiveAuthType = securitySchemes.keys.first;
        print('    - Inferred auth type: "$effectiveAuthType"');
      } else {
        print(
            '    - [ERROR] Cannot apply security: No --auth type provided and no securitySchemes found in apispec.json.');
        return updatedSpec;
      }
    }

    if (authType != null) {
      print('  -> Defining/updating security scheme for type: $authType');
      final components =
          (updatedSpec['components'] as Map<String, dynamic>?) ?? {};
      final securitySchemes =
          (components['securitySchemes'] as Map<String, dynamic>?) ?? {};
      switch (authType.toLowerCase()) {
        case 'jwt':
        case 'bearer':
          securitySchemes[authType] = {
            'type': 'http',
            'scheme': 'bearer',
            'bearerFormat': 'JWT',
            'description': authDescription ?? 'JWT authentication token'
          };
          break;
        case 'apikey':
          securitySchemes[authType] = {
            'type': 'apiKey',
            'in': 'header',
            'name': 'X-API-Key',
            'description': authDescription ?? 'API key authentication'
          };
          break;
        case 'basic':
          securitySchemes[authType] = {
            'type': 'http',
            'scheme': 'basic',
            'description': authDescription ?? 'Basic authentication'
          };
          break;
        case 'oauth2':
          securitySchemes[authType] = {
            'type': 'oauth2',
            'flows': {
              'implicit': {
                'authorizationUrl': '$baseUrl/oauth/authorize',
                'scopes': {'read': 'Read access', 'write': 'Write access'}
              }
            },
            'description': authDescription ?? 'OAuth2 authentication'
          };
          break;
        default:
          securitySchemes[authType] = {
            'type': 'apiKey',
            'in': 'header',
            'name': 'Authorization',
            'description': authDescription ?? 'Custom authentication'
          };
      }
      components['securitySchemes'] = securitySchemes;
      updatedSpec['components'] = components;
    }

    if (disableAuthGlobally) {
      print('  -> Globally disabling authentication for all endpoints...');
      for (final pathEntry in paths.entries) {
        for (var op in (pathEntry.value as Map<String, dynamic>).values) {
          (op as Map<String, dynamic>).remove('security');
        }
      }
    } else if (effectiveAuthType != null) {
      final isRewriteMode = !updateMode || authType != null;
      if (isRewriteMode) {
        print(
            '  -> Applying full security policy using auth type "$effectiveAuthType"...');
        for (final pathEntry in paths.entries) {
          final path = pathEntry.key;
          final pathItem = pathEntry.value as Map<String, dynamic>;
          final pathParts = path.split('/').where((s) => s.isNotEmpty).toList();
          if (pathParts.length >= 2) {
            final endpointName = pathParts[0];
            final methodName = pathParts[1];
            final action = _getSecurityAction(endpointName, methodName,
                normalizedSecuredEndpoints, normalizedUnsecuredEndpoints);
            for (final operation
                in pathItem.values.cast<Map<String, dynamic>>()) {
              final wasSecured = operation.containsKey('security');
              switch (action) {
                case _SecurityAction.secure:
                  if (!wasSecured) {
                    print('    - SECURING endpoint: $path');
                    operation['security'] = [
                      {effectiveAuthType: []}
                    ];
                  }
                  break;
                case _SecurityAction.unsecure:
                  if (wasSecured) {
                    print('    - UNSECURING endpoint: $path');
                    operation.remove('security');
                  }
                  break;
                case _SecurityAction.noChange:
                  break;
              }
            }
          }
        }
      } else {
        print(
            '  -> Applying security patches using auth type "$effectiveAuthType"...');
        if (normalizedSecuredEndpoints != null) {
          for (final itemToSecure in normalizedSecuredEndpoints) {
            for (final pathEntry in paths.entries) {
              final path = pathEntry.key.startsWith('/')
                  ? pathEntry.key.substring(1)
                  : pathEntry.key;
              if (path == itemToSecure || path.startsWith('$itemToSecure/')) {
                print('    - SECURING endpoint: ${pathEntry.key}');
                for (var op
                    in (pathEntry.value as Map<String, dynamic>).values) {
                  (op as Map<String, dynamic>)['security'] = [
                    {effectiveAuthType: []}
                  ];
                }
              }
            }
          }
        }
        if (normalizedUnsecuredEndpoints != null) {
          for (final itemToUnsecure in normalizedUnsecuredEndpoints) {
            for (final pathEntry in paths.entries) {
              final path = pathEntry.key.startsWith('/')
                  ? pathEntry.key.substring(1)
                  : pathEntry.key;
              if (path == itemToUnsecure ||
                  path.startsWith('$itemToUnsecure/')) {
                print('    - UNSECURING endpoint: ${pathEntry.key}');
                for (var op
                    in (pathEntry.value as Map<String, dynamic>).values) {
                  (op as Map<String, dynamic>).remove('security');
                }
              }
            }
          }
        }
      }
      if (secureSingleUrl != null && paths.containsKey(secureSingleUrl)) {
        print('    - Overriding: Securing single URL: $secureSingleUrl');
        for (var op
            in (paths[secureSingleUrl] as Map<String, dynamic>).values) {
          (op as Map<String, dynamic>)['security'] = [
            {effectiveAuthType: []}
          ];
        }
      }
      if (unsecureSingleUrl != null && paths.containsKey(unsecureSingleUrl)) {
        print('    - Overriding: Unsecuring single URL: $unsecureSingleUrl');
        for (var op
            in (paths[unsecureSingleUrl] as Map<String, dynamic>).values) {
          (op as Map<String, dynamic>).remove('security');
        }
      }
    }
  } else if (!isHttpMethodActionRequested && !isBaseUrlActionRequested) {
    // This case now ONLY runs for a fresh `generate` with no flags at all.
    print(
        '  -> No security flags provided. Generating spec without authentication.');
    (updatedSpec['components'] as Map<String, dynamic>?)
        ?.remove('securitySchemes');
    for (final pathEntry in paths.entries) {
      for (var op in (pathEntry.value as Map<String, dynamic>).values) {
        (op as Map<String, dynamic>).remove('security');
      }
    }
  }

  // --- Action 3: Handle HTTP Methods (This block now runs independently) ---
  if (isHttpMethodActionRequested) {
    print('  -> Applying custom HTTP methods...');
    for (final entry in customHttpMethods.entries) {
      final path = entry.key;
      final newMethod = entry.value;
      if (paths.containsKey(path)) {
        final pathItem = paths[path] as Map<String, dynamic>;
        final currentMethod = pathItem.keys.firstWhere(
            (k) => ['get', 'post', 'put', 'delete', 'patch'].contains(k),
            orElse: () => '');
        if (currentMethod.isNotEmpty && currentMethod != newMethod) {
          final operation = pathItem.remove(currentMethod);
          pathItem[newMethod] = operation;
          print(
              '    - Changed $path from ${currentMethod.toUpperCase()} to ${newMethod.toUpperCase()}');
        }
      } else {
        print(
            '    - [Warning] Path $path not found for custom HTTP method assignment.');
      }
    }
  }

  return updatedSpec;
}

// ===================================================================
// SPEC GENERATOR CLASS (Your Original On-Demand Logic)
// ===================================================================
// (The OpenApiSpecGenerator and _EndpointVisitor classes from the previous answer go here, unchanged)
class OpenApiSpecGenerator {
  /// The root path of the project being analyzed.  
  final String projectPath;
  
  /// The analysis context collection used for parsing Dart files.
  final AnalysisContextCollection _collection;

  /// Stores the OpenAPI paths information generated during analysis.
  final Map<String, dynamic> _paths = {};
  
  /// Stores the OpenAPI schema definitions generated during analysis.
  final Map<String, dynamic> _schemas = {};
  
  /// Public getter for accessing the generated schemas.
  Map<String, dynamic> get schemas => _schemas;

  /// Maps package names to their file system locations.
  final Map<String, String> _packageLocations = {};

  /// Creates a new OpenAPI specification generator for the given project path.
  /// 
  /// [projectPath] is the root directory of the Serverpod project to analyze.
  OpenApiSpecGenerator(this.projectPath)
      : _collection = AnalysisContextCollection(includedPaths: [projectPath]);

  /// Generates the complete OpenAPI specification by analyzing the project.
  /// 
  /// This is the main entry point for the generation process. It performs the following steps:
  /// 1. Initializes package locations by reading the package configuration
  /// 2. Parses all local model files (.yaml and .spy.yaml) in the project
  /// 3. Parses all endpoint Dart files to extract API information
  /// 
  /// The results are stored in the [_paths] and [_schemas] maps, which can be
  /// accessed via [toJson] to get the complete OpenAPI specification.
  Future<void> generate() async {
    print('\n--- Starting OpenAPI Spec Generation ---');
    // Step 1: Initialize by mapping all package locations.
    print('\n[1/3] Initializing package locations...');
    await _initialize();

    // Step 2: Parse all project models to start the process.
    print('\n[2/3] Parsing local project models...');
    final localModelsPath = p.join(projectPath, 'lib', 'src');
    final localModelsDir = Directory(localModelsPath);
    if (localModelsDir.existsSync()) {
      final localModelFiles = _findModelFilesRecursively(localModelsDir);
      print('  Found ${localModelFiles.length} local model files.');
      for (final file in localModelFiles) {
        await parseYamlModelFile(file.path);
      }
    } else {
      print('  [INFO] No local models directory found. Skipping.');
    }

    // Step 3: Parse endpoints, which triggers on-demand parsing of package models.
    print('\n[3/3] Parsing Dart endpoint files...');
    final endpointsPath = p.join(projectPath, 'lib', 'src');
    final endpointsDir = Directory(endpointsPath);
    if (endpointsDir.existsSync()) {
      final endpointFiles = endpointsDir
          .listSync(recursive: true)
          .where((e) => e is File && e.path.endsWith('endpoint.dart'))
          .cast<File>();

      for (final file in endpointFiles) {
        print(
            '  Parsing endpoint: ${p.relative(file.path, from: projectPath)}');
        await parseDartFile(file.path);
      }
    } else {
      print('  [WARN] Endpoints directory not found at: $endpointsPath');
    }
    print('--- Generation Complete ---');
  }

  /// Initializes the generator by mapping package names to their file system locations.
  /// 
  /// Reads the package_config.json file to determine the locations of all dependencies,
  /// which is necessary for resolving references to models in external packages.
  Future<void> _initialize() async {
    final packageConfigFile =
        File(p.join(projectPath, '.dart_tool', 'package_config.json'));
    if (!await packageConfigFile.exists()) {
      print(
          '  [WARN] package_config.json not found. Cannot search in dependencies.');
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

  /// Parses a YAML model file and adds its schema to the OpenAPI specification.
  /// 
  /// Extracts class information, fields, and their types from the YAML file and
  /// converts them to OpenAPI schema definitions. Also handles dependencies by
  /// recursively parsing referenced model files.
  /// 
  /// [path] The file system path to the YAML model file to parse.
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

      print(
          '    - Parsing model: ${p.basename(path)} (as $sanitizedClassName)');

      _schemas[sanitizedClassName] = {}; // Placeholder for recursion

      final fields = yaml['fields'] as YamlMap?;
      final properties = <String, dynamic>{};
      final requiredFields = <String>[];
      if (fields != null) {
        for (final entry in fields.entries) {
          final fieldName = entry.key as String;
          final fieldValue = entry.value;
          final fieldType = (fieldValue is YamlMap
              ? fieldValue['type']
              : fieldValue) as String;
          if (!fieldType.endsWith('?')) {
            requiredFields.add(fieldName);
          }
          properties[fieldName] = await _mapYamlTypeToOpenApiSchema(fieldType);
        }
      }

      final schema = <String, dynamic>{
        'type': 'object',
        'properties': properties
      };
      if (requiredFields.isNotEmpty) {
        schema['required'] = requiredFields;
      }
      _schemas[sanitizedClassName] = schema;
    } catch (e) {
      print('  [ERROR] Failed to parse YAML file $path: $e');
    }
  }

  /// Maps a YAML type string to an OpenAPI schema definition.
  /// 
  /// Handles primitive types, lists, maps, and references to other model classes.
  /// For references to other models, it may trigger parsing of those models if
  /// they haven't been processed yet.
  /// 
  /// [yamlType] The type string from the YAML model file.
  /// 
  /// Returns a Map representing the OpenAPI schema for the type.
  Future<Map<String, dynamic>> _mapYamlTypeToOpenApiSchema(
      String yamlType) async {
    final isNullable = yamlType.endsWith('?');
    final cleanType =
        isNullable ? yamlType.substring(0, yamlType.length - 1) : yamlType;

    if (cleanType.startsWith('List<') && cleanType.endsWith('>')) {
      final innerType = cleanType.substring(5, cleanType.length - 1);
      return {
        'type': 'array',
        'items': await _mapYamlTypeToOpenApiSchema(innerType)
      };
    }
    if (cleanType.startsWith('Map<')) {
      return {'type': 'object', 'additionalProperties': true};
    }

    switch (cleanType) {
      case 'String':
        return {'type': 'string'};
      case 'int':
        return {'type': 'integer', 'format': 'int64'};
      case 'double':
        return {'type': 'number', 'format': 'double'};
      case 'bool':
        return {'type': 'boolean'};
      case 'DateTime':
        return {'type': 'string', 'format': 'date-time'};
      case 'ByteData':
        return {'type': 'string', 'format': 'byte'};
      case 'Duration':
        return {'type': 'string', 'description': 'Duration in ISO 8601 format'};
      case 'Uri':
        return {'type': 'string', 'format': 'uri'};
      default:
        final sanitizedClassName = _sanitizeClassName(cleanType);
        if (!_schemas.containsKey(sanitizedClassName)) {
          print(
              '      -> Discovered dependency: $cleanType. Attempting to parse...');
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

  /// Finds and parses a model from a Serverpod module.
  /// 
  /// Used when a model references another model from a different module.
  /// Locates the model file in the appropriate package and parses it.
  /// 
  /// [module] The name of the Serverpod module containing the model.
  /// [className] The name of the class to find and parse.
  Future<void> _findAndParseModel(String module, String className) async {
    final packageName = 'serverpod_${module}_server';
    final packagePath = _packageLocations[packageName];
    if (packagePath == null) {
      print('      [WARN] Could not find package location for "$packageName"');
      return;
    }

    final modelFileName = _classNameToFileName(className);
    final modelFilePath =
        p.join(packagePath, 'lib', 'src', 'models', modelFileName);

    if (await File(modelFilePath).exists()) {
      await parseYamlModelFile(modelFilePath);
    } else {
      print('[WARN] Could not find model file at: $modelFilePath');
    }
  }

  /// Parses a Dart file to extract endpoint and method information.
  /// 
  /// Analyzes Dart files containing endpoint classes to extract API information
  /// such as method names, parameters, and return types. The extracted information
  /// is used to build the OpenAPI paths section.
  /// 
  /// [path] The file system path to the Dart file to parse.
  Future<void> parseDartFile(String path) async {
    final context = _collection.contextFor(path);
    final result = await context.currentSession.getResolvedUnit(path);
    if (result is ResolvedUnitResult) {
      final visitor = _EndpointVisitor(this);
      await visitor.visitUnit(result.unit);
    }
  }

  /// Determines if a Dart type is a primitive type in the context of OpenAPI.
  /// 
  /// Primitive types include String, int, double, bool, DateTime, ByteData, Uri,
  /// Map, and enums. These types can be directly mapped to OpenAPI schema types.
  /// 
  /// [type] The Dart type to check.
  /// 
  /// Returns true if the type is considered primitive, false otherwise.
  bool _isPrimitiveType(DartType type) {
    return type.isDartCoreString ||
        type.isDartCoreInt ||
        type.isDartCoreDouble ||
        type.isDartCoreBool ||
        type.element?.name == 'DateTime' ||
        type.element?.name == 'ByteData' ||
        type.element?.name == 'Uri' ||
        type.isDartCoreMap ||
        (type is InterfaceType && type.element is EnumElement);
  }

  /// Maps a Dart type to an OpenAPI schema definition.
  /// 
  /// Handles primitive types, lists, maps, and references to model classes.
  /// For references to model classes, it may trigger parsing of those models
  /// if they haven't been processed yet.
  /// 
  /// [type] The Dart type to map to an OpenAPI schema.
  /// 
  /// Returns a Map representing the OpenAPI schema for the type.
  Future<Map<String, dynamic>> mapDartTypeToOpenApiSchema(DartType type) async {
    if (type.isDartCoreString) return {'type': 'string'};
    if (type.isDartCoreInt) return {'type': 'integer', 'format': 'int64'};
    if (type.isDartCoreDouble) return {'type': 'number', 'format': 'double'};
    if (type.isDartCoreBool) return {'type': 'boolean'};
    if (type.element?.name == 'DateTime') {
      return {'type': 'string', 'format': 'date-time'};
    }
    if (type.element?.name == 'ByteData') {
      return {'type': 'string', 'format': 'byte'};
    }
    if (type.element?.name == 'Uri') return {'type': 'string', 'format': 'uri'};

    if (type is InterfaceType) {
      if (type.isDartCoreList) {
        final itemType = type.typeArguments.first;
        return {
          'type': 'array',
          'items': await mapDartTypeToOpenApiSchema(itemType)
        };
      }
      if (type.isDartCoreMap) {
        return {'type': 'object', 'additionalProperties': true};
      }

      final className = type.element.name;
      if (!_schemas.containsKey(className)) {
        final libraryUri = type.element.library.source.uri;
        if (libraryUri.scheme == 'package') {
          final packageName = libraryUri.pathSegments.first;
          if (packageName.startsWith('serverpod_') &&
              packageName.endsWith('_server')) {
            final moduleName = packageName
                .replaceAll('serverpod_', '')
                .replaceAll('_server', '');
            print(
                '      -> Discovered dependency: $className from module $moduleName. Attempting to parse...');
            await _findAndParseModel(moduleName, className);
          }
        }
      }
      return {'\$ref': '#/components/schemas/$className'};
    }
    return {};
  }

  /// Converts the generated OpenAPI specification to a JSON-compatible Map.
  /// 
  /// This method should be called after [generate] to retrieve the complete
  /// OpenAPI specification as a Map that can be serialized to JSON.
  /// 
  /// Returns a Map containing the complete OpenAPI specification.
  Map<String, dynamic> toJson() => {
        'openapi': '3.0.0',
        'info': {'title': 'My Serverpod API', 'version': '0.1.0'},
        'servers': [
          {'url': 'http://localhost:8080'}
        ],
        'paths': _paths,
        'components': {'schemas': _schemas}
      };

  /// Sanitizes a class name by removing any module prefix.
  /// 
  /// [className] The class name to sanitize.
  /// 
  /// Returns the sanitized class name.
  String _sanitizeClassName(String className) => className.split(':').last;
  
  /// Converts a class name to the corresponding file name based on Serverpod conventions.
  /// 
  /// [className] The class name to convert.
  /// 
  /// Returns the file name for the class.
  String _classNameToFileName(String className) {
    final regExp = RegExp(r'(?<=[a-z])(?=[A-Z])');
    return '${className.replaceAllMapped(regExp, (m) => '_').toLowerCase()}.spy.yaml';
  }

  /// Recursively finds all model files in a directory and its subdirectories.
  /// 
  /// Looks for files with .yaml or .spy.yaml extensions, which are the standard
  /// extensions for Serverpod model files.
  /// 
  /// [dir] The directory to search in.
  /// 
  /// Returns a list of File objects representing the found model files.
  List<File> _findModelFilesRecursively(Directory dir) {
    final List<File> files = [];
    if (!dir.existsSync()) return files;
    for (final entity in dir.listSync()) {
      if (entity is Directory) {
        files.addAll(_findModelFilesRecursively(entity));
      } else if (entity is File &&
          (entity.path.endsWith('.yaml') ||
              entity.path.endsWith('.spy.yaml'))) {
        files.add(entity);
      }
    }
    return files;
  }
}

// --- ENDPOINT VISITOR (Async, as per your original) ---
/// A visitor that traverses the AST of a Dart file to find endpoint classes and methods.
/// 
/// This visitor is responsible for extracting API information from endpoint classes
/// and converting it to OpenAPI path definitions.
class _EndpointVisitor extends RecursiveAstVisitor<void> {
  /// The OpenAPI specification generator that created this visitor.
  final OpenApiSpecGenerator generator;
  
  /// The name of the endpoint class currently being visited, or null if not in an endpoint.
  String? _currentEndpointName;

  /// Creates a new endpoint visitor.
  /// 
  /// [generator] The OpenAPI specification generator that created this visitor.
  _EndpointVisitor(this.generator);

  /// Visits a compilation unit to find endpoint classes.
  /// 
  /// [unit] The compilation unit to visit.
  Future<void> visitUnit(CompilationUnit unit) async {
    for (final declaration in unit.declarations) {
      if (declaration is ClassDeclaration) {
        await visitClassDeclaration(declaration);
      }
    }
  }

  /// Visits a class declaration to check if it's an endpoint class.
  /// 
  /// An endpoint class is one that extends the Endpoint class.
  /// 
  /// [node] The class declaration to visit.
  @override
  Future<void> visitClassDeclaration(ClassDeclaration node) async {
    final superclass = node.extendsClause?.superclass.name2.lexeme;
    if (superclass == 'Endpoint') {
      final rawName = node.name.lexeme.replaceAll('Endpoint', '');
      _currentEndpointName = toCamelCase(rawName);
      print('    -> Found Endpoint: $_currentEndpointName');
      for (final member in node.members) {
        if (member is MethodDeclaration) {
          await visitMethodDeclaration(member);
        }
      }
      _currentEndpointName = null;
    }
  }

  /// Converts a string to camelCase.
  /// 
  /// Used to convert endpoint class names to endpoint paths.
  /// 
  /// [input] The string to convert.
  /// 
  /// Returns the camelCase version of the input string.
  String toCamelCase(String input) {
    if (input.isEmpty) return input;
    return input[0].toLowerCase() + input.substring(1);
  }

  /// Visits a method declaration to extract API information.
  /// 
  /// Extracts method name, parameters, and return type to create an OpenAPI path definition.
  /// Automatically determines if the method should be a GET or POST request based on parameter types.
  /// 
  /// [node] The method declaration to visit.
  @override
  Future<void> visitMethodDeclaration(MethodDeclaration node) async {
    if (_currentEndpointName == null) return;
    final methodName = node.name.lexeme;
    if (methodName.startsWith('_') ||
        ['initialize', 'streamOpened', 'streamClosed', 'handleStreamMessage']
            .contains(methodName)) {
      return;
    }

    print('      -> Found Method: $methodName');
    final path = '/$_currentEndpointName/$methodName';
    final apiParams = node.parameters?.parameters
            .map((p) => p.declaredElement)
            .where((p) => p != null && p.type.element?.name != 'Session')
            .cast<ParameterElement>()
            .toList() ??
        [];
    final bool isPostRequest =
        apiParams.any((p) => !generator._isPrimitiveType(p.type));

    print(
        '        - Auto-detected as ${isPostRequest ? 'POST' : 'GET'} request.');

    final pathItem = <String, dynamic>{};
    final operation = {
      'summary': methodName,
      'operationId': '$_currentEndpointName.$methodName',
      'tags': [_currentEndpointName],
    };

    if (isPostRequest) {
      final properties = <String, dynamic>{};
      for (final param in apiParams) {
        properties[param.name] =
            await generator.mapDartTypeToOpenApiSchema(param.type);
      }
      if (properties.isNotEmpty) {
        operation['requestBody'] = {
          'content': {
            'application/json': {
              'schema': {'type': 'object', 'properties': properties}
            }
          }
        };
      }
      pathItem['post'] = operation;
    } else {
      final openApiParameters = <Map<String, dynamic>>[];
      for (final param in apiParams) {
        openApiParameters.add({
          'name': param.name,
          'in': 'query',
          'required':
              param.type.nullabilitySuffix != NullabilitySuffix.question,
          'schema': await generator.mapDartTypeToOpenApiSchema(param.type),
        });
      }
      if (openApiParameters.isNotEmpty) {
        operation['parameters'] = openApiParameters;
      }
      pathItem['get'] = operation;
    }

    final DartType? returnTypeFromElement = node.declaredElement?.returnType;
    Map<String, dynamic> responseSchema = {};
    if (returnTypeFromElement != null) {
      DartType finalType = returnTypeFromElement;
      if (finalType.isDartAsyncFuture &&
          finalType is InterfaceType &&
          finalType.typeArguments.isNotEmpty) {
        finalType = finalType.typeArguments.first;
      }
      if (!finalType.isDartCoreNull && finalType.element?.name != 'void') {
        responseSchema = await generator.mapDartTypeToOpenApiSchema(finalType);
      }
    }

    operation['responses'] = {
      '200': {
        'description': 'Successful operation',
        if (responseSchema.isNotEmpty)
          'content': {
            'application/json': {'schema': responseSchema}
          }
      }
    };

    generator._paths[path] = pathItem;
  }
}
