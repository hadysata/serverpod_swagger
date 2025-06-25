// import 'dart:io';
// import 'package:serverpod/protocol.dart';
// import 'package:serverpod/server.dart';
// import 'package:serverpod/serverpod.dart';
// import 'package:serverpod_swagger_ui/serverpod_swagger_ui.dart';

// /// This example shows how to add Swagger UI to a Serverpod server.
// /// 
// /// In a real project, you would add this to your server.dart file.
// void main(List<String> args) async {
//   // Create a Serverpod server
//   final pod = Serverpod(
//     args,
//     // In a real project, you would pass your Protocol and Endpoints classes here
//     Protocol(),
//     Endpoints(),
//     // You can also provide a custom configuration
//     config: ServerpodConfig(
//       apiServer: ServerConfig(
//         port: 8080,
//         publicHost: 'localhost',
//         publicPort: 8080,
//         publicScheme: 'http',
//       ),
//       webServer: ServerConfig(
//         port: 8082,
//         publicHost: 'localhost',
//         publicPort: 8082,
//         publicScheme: 'http',
//       ),
//     ),
//   );
  
//   // Get the project root directory
//   final projectRoot = Directory(Directory.current.path);
  
//   // Create a SwaggerUIRoute
//   final swaggerRoute = SwaggerUIRoute(projectRoot);
  
//   // Add the route to your server
//   pod.webServer.addRoute(swaggerRoute, '/swagger/');
  
//   // Start the server
//   await pod.start();
  
//   print('Server started with Swagger UI available at: http://localhost:8082/swagger/');
//   print('Note: Make sure to include the trailing slash in the URL');
// }
