class ApiException implements Exception {
  ApiException(this.message, {this.code = -1});

  final String message;
  final int code;

  @override
  String toString() => message;
}
