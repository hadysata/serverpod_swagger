import 'dart:io';
import 'package:yaml/yaml.dart';

void main() {
  final file = File('/Users/ryan/Desktop/Mako/ryan_serverpod/serverpod_swagger_ui/test_swagger_project/test_swagger_project_server/lib/src/generated/protocol.yaml');
  final content = file.readAsStringSync();
  final yaml = loadYaml(content);
  print('YAML type: ${yaml.runtimeType}');
  print('YAML content: $yaml');
  
  // Check if the YAML has the expected structure
  if (yaml is YamlMap) {
    print('\nYAML is a YamlMap');
    
    // Check endpoints
    if (yaml['endpoints'] != null) {
      print('\nEndpoints:');
      final endpoints = yaml['endpoints'] as YamlMap;
      endpoints.forEach((key, value) {
        print('  $key: ${value.runtimeType}');
        
        if (value is YamlMap && value['methods'] != null) {
          print('    Methods:');
          final methods = value['methods'] as YamlMap;
          methods.forEach((methodName, methodDef) {
            print('      $methodName: ${methodDef.runtimeType}');
          });
        }
      });
    }
    
    // Check classes
    if (yaml['classes'] != null) {
      print('\nClasses:');
      final classes = yaml['classes'] as YamlMap;
      classes.forEach((key, value) {
        print('  $key: ${value.runtimeType}');
        
        if (value is YamlMap && value['fields'] != null) {
          print('    Fields:');
          final fields = value['fields'] as YamlMap;
          fields.forEach((fieldName, fieldDef) {
            print('      $fieldName: ${fieldDef.runtimeType}');
          });
        }
      });
    }
  } else {
    print('\nYAML is NOT a YamlMap, it is a ${yaml.runtimeType}');
  }
}