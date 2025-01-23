import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:cricket/services/services.dart';

class ApiBaseHelper {
  static final Dio _dio = Dio();

  static final PrettyDioLogger _prettyDioLogger = PrettyDioLogger(
    requestHeader: true,
    requestBody: true,
    responseBody: true,
    responseHeader: true,
    error: true,
    compact: true,
    maxWidth: 90,
  );

  static void setupDio() async {
    _dio.interceptors.add(_prettyDioLogger);
  }

  static final String baseUrl = dotenv.env['BASE_URL']!;

  static Future<Map<String, dynamic>> getHeaders() async {
    Map<String, dynamic> headers = {
      "Accept": "application/json",
    };

    if (await SessionManagerServcie().hasSession()) {
      String? token = await SessionManagerServcie().getToken();
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  static Future<Response> get(
    String endpoint, {
    Map<String, dynamic>? params,
  }) async {
    try {
      final response = await _dio.get(
        "$baseUrl$endpoint",
        queryParameters: params,
        options: Options(headers: await getHeaders()),
      );
      return response;
    } on DioException catch (error) {
      switch (error.type) {
        case DioExceptionType.connectionError:
          throw DioException(
            type: DioExceptionType.connectionError,
            requestOptions: RequestOptions(path: endpoint),
            error: error.toString(),
          );

        case DioExceptionType.badResponse:
          throw DioException(
            type: DioExceptionType.badResponse,
            requestOptions: RequestOptions(path: endpoint),
            error: error.toString(),
          );

        case DioExceptionType.connectionTimeout:
          throw DioException(
            type: DioExceptionType.connectionTimeout,
            requestOptions: RequestOptions(path: endpoint),
            error: error.toString(),
          );

        default:
          throw DioException(
            requestOptions: RequestOptions(path: endpoint),
            error: error.toString(),
          );
      }
    }
  }

  static Future<Response> post(
    String endpoint,
    dynamic data,
  ) async {
    try {
      final response = await _dio.post(
        "$baseUrl$endpoint",
        data: data,
        options: Options(headers: await getHeaders()),
      );
      return response;
    } on DioException catch (error) {
      switch (error.type) {
        case DioExceptionType.connectionError:
          throw DioException(
            type: DioExceptionType.connectionError,
            requestOptions: RequestOptions(path: endpoint),
            error: error.toString(),
          );

        case DioExceptionType.badResponse:
          throw DioException(
            type: DioExceptionType.badResponse,
            requestOptions: RequestOptions(path: endpoint),
            error: error.toString(),
          );

        case DioExceptionType.connectionTimeout:
          throw DioException(
            type: DioExceptionType.connectionTimeout,
            requestOptions: RequestOptions(path: endpoint),
            error: error.toString(),
          );

        default:
          throw DioException(
            requestOptions: RequestOptions(path: endpoint),
            error: error.toString(),
          );
      }
    }
  }

  static Future<Response> postMultipart(
    String endpoint,
    FormData formData,
  ) async {
    try {
      final response = await _dio.post(
        "$baseUrl$endpoint",
        data: formData,
        options: Options(headers: {
          ...await getHeaders(),
          "Content-Type": "multipart/form-data",
        }),
      );
      return response;
    } on DioException catch (error) {
      switch (error.type) {
        case DioExceptionType.connectionError:
          throw DioException(
            type: DioExceptionType.connectionError,
            requestOptions: RequestOptions(path: endpoint),
            error: error.toString(),
          );

        case DioExceptionType.badResponse:
          throw DioException(
            type: DioExceptionType.badResponse,
            requestOptions: RequestOptions(path: endpoint),
            error: error.toString(),
          );

        case DioExceptionType.connectionTimeout:
          throw DioException(
            type: DioExceptionType.connectionTimeout,
            requestOptions: RequestOptions(path: endpoint),
            error: error.toString(),
          );

        default:
          throw DioException(
            requestOptions: RequestOptions(path: endpoint),
            error: error.toString(),
          );
      }
    }
  }

  static Future<void> download(
    String endpoint,
    String savePath, {
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      await _dio.download(
        "$baseUrl$endpoint",
        savePath,
        onReceiveProgress: onReceiveProgress,
        options: Options(headers: await getHeaders()),
      );
    } on DioException catch (error) {
      switch (error.type) {
        case DioExceptionType.connectionError:
          throw DioException(
            type: DioExceptionType.connectionError,
            requestOptions: RequestOptions(path: endpoint),
            error: error.toString(),
          );

        case DioExceptionType.badResponse:
          throw DioException(
            type: DioExceptionType.badResponse,
            requestOptions: RequestOptions(path: endpoint),
            error: error.toString(),
          );

        case DioExceptionType.connectionTimeout:
          throw DioException(
            type: DioExceptionType.connectionTimeout,
            requestOptions: RequestOptions(path: endpoint),
            error: error.toString(),
          );

        case DioExceptionType.receiveTimeout:
          throw DioException(
            type: DioExceptionType.receiveTimeout,
            requestOptions: RequestOptions(path: endpoint),
            error: error.toString(),
          );

        default:
          throw DioException(
            requestOptions: RequestOptions(path: endpoint),
            error: error.toString(),
          );
      }
    }
  }
}
