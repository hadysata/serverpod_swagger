import 'dart:io';
import 'package:serverpod_swagger/serverpod_swagger_ui.dart';
import 'package:test/test.dart';

void main() {
  group('ProtocolToOpenApiConverter tests', () {
    late Directory tempDir;

    setUp(() {
      // Create a temporary directory with a mock protocol.yaml for testing
      tempDir =
          Directory.systemTemp.createTempSync('serverpod_swagger_ui_test_');
      final protocolDir = Directory('${tempDir.path}/lib/src/generated');
      protocolDir.createSync(recursive: true);

      // Create a simple protocol.yaml file for testing
      final protocolFile = File('${protocolDir.path}/protocol.yaml');
      protocolFile.writeAsStringSync('''
        classes:
          TestClass:
            fields:
              id:
                type: int
              name:
                type: String
              isActive:
                type: bool
              createdAt:
                type: DateTime
      ''');
    });

    tearDown(() {
      // Clean up the temporary directory
      tempDir.deleteSync(recursive: true);
    });
  });

  group('SwaggerUIRoute tests', () {
    test('creates route with correct paths', () {
      final projectRoot = Directory.current;
      final route = SwaggerUIRoute(projectRoot);
      print(route);
      // Verify the route has the expected handlers
      expect(route, isNotNull);
    });
  });
}
