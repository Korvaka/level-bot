class ServerException implements Exception {
  const ServerException({required this.message, this.statusCode});
  final String message;
  final int? statusCode;

  @override
  String toString() => 'ServerException: $message (status: $statusCode)';
}

class CacheException implements Exception {
  const CacheException({required this.message});
  final String message;

  @override
  String toString() => 'CacheException: $message';
}

class NetworkException implements Exception {
  const NetworkException({this.message = 'No internet connection'});
  final String message;

  @override
  String toString() => 'NetworkException: $message';
}

class AuthException implements Exception {
  const AuthException({required this.message, this.code});
  final String message;
  final String? code;

  @override
  String toString() => 'AuthException: $message (code: $code)';
}

class PermissionException implements Exception {
  const PermissionException({required this.message});
  final String message;

  @override
  String toString() => 'PermissionException: $message';
}

class ValidationException implements Exception {
  const ValidationException({required this.message});
  final String message;

  @override
  String toString() => 'ValidationException: $message';
}
