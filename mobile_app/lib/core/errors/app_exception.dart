class AppException implements Exception {
  final int statusCode;
  final String message;
  final String? code;

  AppException({
    required this.statusCode,
    required this.message,
    this.code,
  });

  @override
  String toString() => 'AppException($statusCode): $message';
}

class NetworkException extends AppException {
  NetworkException({String? message})
      : super(
          statusCode: 0,
          message: message ?? 'ไม่มีการเชื่อมต่ออินเตอร์เน็ต',
          code: 'NETWORK_ERROR',
        );
}

class TimeoutException extends AppException {
  TimeoutException({String? message})
      : super(
          statusCode: 408,
          message: message ?? 'การเชื่อมต่อใช้เวลานานเกินไป',
          code: 'TIMEOUT',
        );
}

class UnauthorizedException extends AppException {
  UnauthorizedException({String? message})
      : super(
          statusCode: 401,
          message: message ?? 'ไม่มีสิทธิ์เข้าถึง',
          code: 'UNAUTHORIZED',
        );
}

class NotFoundException extends AppException {
  NotFoundException({String? message})
      : super(
          statusCode: 404,
          message: message ?? 'ไม่พบข้อมูล',
          code: 'NOT_FOUND',
        );
}

class ValidationException extends AppException {
  final Map<String, dynamic>? errors;

  ValidationException({String? message, this.errors})
      : super(
          statusCode: 422,
          message: message ?? 'ข้อมูลไม่ถูกต้อง',
          code: 'VALIDATION_ERROR',
        );
}

class ServerException extends AppException {
  ServerException({String? message})
      : super(
          statusCode: 500,
          message: message ?? 'เกิดข้อผิดพลาดในระบบ',
          code: 'SERVER_ERROR',
        );
}
