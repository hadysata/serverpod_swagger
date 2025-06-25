import 'dart:io';
import 'package:yaml/yaml.dart';

void main() {
  final file = File('/Users/ryan/Desktop/Mako/ryan_serverpod/serverpod_swagger_ui/lib/src/generated/protocol.yaml');
  final content = file.readAsStringSync();
  print('File content: $content');
  
  final yaml = loadYaml(content);
  print('YAML type: ${yaml.runtimeType}');
  print('YAML content: $yaml');
  
  // Check if the YAML has the expected structure
  if (yaml is YamlMap) {
    print('\nYAML is a YamlMap');
  } else {
    print('\nYAML is NOT a YamlMap, it is a ${yaml.runtimeType}');
  }
}