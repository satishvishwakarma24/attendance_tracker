import 'package:dio/dio.dart';
import '../utils/logger.dart';
import 'api_exception.dart';

class ApiClient {
  final Dio _dio;

  ApiClient({
    required Dio dio,
    String? baseUrl,
  }) : _dio = dio {
    if (baseUrl != null) {
      _dio.options.baseUrl = baseUrl;
    }
    _dio.options.connectTimeout = const Duration(seconds: 15);
    _dio.options.receiveTimeout = const Duration(seconds: 15);
    _dio.options.sendTimeout = const Duration(seconds: 15);
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onReceiveProgress,
  }) async {
    try {
      Logger.info('GET Request: ${_dio.options.baseUrl}$path');
      if (queryParameters != null) {
        Logger.debug('GET Query Parameters: $queryParameters');
      }
      
      final response = await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      
      Logger.info('GET Response [${response.statusCode}]: ${_dio.options.baseUrl}$path');
      return response;
    } on DioException catch (e) {
      Logger.error('DioException on GET: ${_dio.options.baseUrl}$path', e, e.stackTrace);
      throw ApiException.fromDioException(e);
    } catch (e, s) {
      Logger.error('Unexpected error on GET: ${_dio.options.baseUrl}$path', e, s);
      throw ApiException(message: e.toString());
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    try {
      Logger.info('POST Request: ${_dio.options.baseUrl}$path');
      if (data != null) {
        Logger.debug('POST Request Body: $data');
      }
      
      final response = await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      
      Logger.info('POST Response [${response.statusCode}]: ${_dio.options.baseUrl}$path');
      return response;
    } on DioException catch (e) {
      Logger.error('DioException on POST: ${_dio.options.baseUrl}$path', e, e.stackTrace);
      throw ApiException.fromDioException(e);
    } catch (e, s) {
      Logger.error('Unexpected error on POST: ${_dio.options.baseUrl}$path', e, s);
      throw ApiException(message: e.toString());
    }
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    try {
      Logger.info('PUT Request: ${_dio.options.baseUrl}$path');
      if (data != null) {
        Logger.debug('PUT Request Body: $data');
      }
      
      final response = await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      
      Logger.info('PUT Response [${response.statusCode}]: ${_dio.options.baseUrl}$path');
      return response;
    } on DioException catch (e) {
      Logger.error('DioException on PUT: ${_dio.options.baseUrl}$path', e, e.stackTrace);
      throw ApiException.fromDioException(e);
    } catch (e, s) {
      Logger.error('Unexpected error on PUT: ${_dio.options.baseUrl}$path', e, s);
      throw ApiException(message: e.toString());
    }
  }

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    try {
      Logger.info('PATCH Request: ${_dio.options.baseUrl}$path');
      if (data != null) {
        Logger.debug('PATCH Request Body: $data');
      }
      
      final response = await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      
      Logger.info('PATCH Response [${response.statusCode}]: ${_dio.options.baseUrl}$path');
      return response;
    } on DioException catch (e) {
      Logger.error('DioException on PATCH: ${_dio.options.baseUrl}$path', e, e.stackTrace);
      throw ApiException.fromDioException(e);
    } catch (e, s) {
      Logger.error('Unexpected error on PATCH: ${_dio.options.baseUrl}$path', e, s);
      throw ApiException(message: e.toString());
    }
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      Logger.info('DELETE Request: ${_dio.options.baseUrl}$path');
      if (data != null) {
        Logger.debug('DELETE Request Body: $data');
      }
      
      final response = await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      
      Logger.info('DELETE Response [${response.statusCode}]: ${_dio.options.baseUrl}$path');
      return response;
    } on DioException catch (e) {
      Logger.error('DioException on DELETE: ${_dio.options.baseUrl}$path', e, e.stackTrace);
      throw ApiException.fromDioException(e);
    } catch (e, s) {
      Logger.error('Unexpected error on DELETE: ${_dio.options.baseUrl}$path', e, s);
      throw ApiException(message: e.toString());
    }
  }
}
