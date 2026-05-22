import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic details;

  const ApiException({
    required this.message,
    this.statusCode,
    this.details,
  });

  factory ApiException.fromDioException(DioException error) {
    String message = 'An unexpected error occurred. Please try again.';
    int? statusCode = error.response?.statusCode;
    dynamic details = error.response?.data;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        message = 'Connection timeout. Please check your internet connection.';
        break;
      case DioExceptionType.sendTimeout:
        message = 'Send timeout in association with server.';
        break;
      case DioExceptionType.receiveTimeout:
        message = 'Receive timeout in association with server.';
        break;
      case DioExceptionType.badCertificate:
        message = 'Security certificate verification failed.';
        break;
      case DioExceptionType.badResponse:
        message = _handleBadResponse(statusCode, details);
        break;
      case DioExceptionType.cancel:
        message = 'Request to the server was cancelled.';
        break;
      case DioExceptionType.connectionError:
        message = 'No internet connection. Please verify your connection status.';
        break;
      case DioExceptionType.unknown:
        if (error.message?.contains('SocketException') ?? false) {
          message = 'No internet connection. Please verify your connection status.';
        } else {
          message = error.message ?? message;
        }
        break;
    }

    return ApiException(
      message: message,
      statusCode: statusCode,
      details: details,
    );
  }

  static String _handleBadResponse(int? statusCode, dynamic details) {
    if (details is Map) {
      if (details.containsKey('message')) {
        return details['message'].toString();
      }
      if (details.containsKey('error')) {
        return details['error'].toString();
      }
    }

    switch (statusCode) {
      case 400:
        return 'Bad request. Please verify the request parameters.';
      case 401:
        return 'Unauthorized access. Please login again.';
      case 403:
        return 'Access forbidden. You do not have permission to perform this action.';
      case 404:
        return 'Requested resource not found.';
      case 409:
        return 'Conflict occurred. The resource already exists.';
      case 500:
        return 'Internal server error. Please try again later.';
      case 502:
        return 'Bad gateway. The server is temporarily down.';
      case 503:
        return 'Service unavailable. The server is temporarily overloaded or down.';
      default:
        return 'Received invalid response status: $statusCode';
    }
  }

  @override
  String toString() => message;
}
