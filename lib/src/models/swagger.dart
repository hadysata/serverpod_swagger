// data_models.dart

class SwaggerSpec {
  final Map<String, SwaggerEndpoint> endpoints = {};
}

class SwaggerEndpoint {
  final String name;
  final Map<String, SwaggerMethod> methods = {};
  SwaggerEndpoint(this.name);
}

class SwaggerMethod {
  final String name;
  final Map<String, SwaggerParameter> parameters = {};
  // The return type is the one piece of information NOT easily available in this file.
  // See the explanation below the code.
  String? returnType; 
  SwaggerMethod(this.name);
}

class SwaggerParameter {
  final String name;
  final String type;
  final bool isNullable;

  SwaggerParameter({
    required this.name,
    required this.type,
    required this.isNullable,
  });

  @override
  String toString() => 'Param($name: $type, nullable: $isNullable)';
}