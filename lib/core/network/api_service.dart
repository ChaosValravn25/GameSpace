import 'package:dio/dio.dart';
import 'package:gamespace/core/network/conectivity_service.dart';

/// Excepción genérica de la capa de red.
class ApiException implements Exception {
	final String message;
	final int? statusCode;

	ApiException(this.message, [this.statusCode]);

	@override
	String toString() => 'ApiException(status: $statusCode, message: $message)';
}

/// Servicio HTTP basado en `dio` con comprobación de conectividad.
class ApiService {
	final Dio _dio;
	final ConnectivityService connectivity;

	ApiService({
		required String baseUrl,
		ConnectivityService? connectivityService,
		Map<String, dynamic>? defaultHeaders,
	})  : connectivity = connectivityService ?? ConnectivityService(),
				_dio = Dio(BaseOptions(
					baseUrl: baseUrl,
					connectTimeout: const Duration(milliseconds: 15000),
					receiveTimeout: const Duration(milliseconds: 15000),
					headers: defaultHeaders,
				)) {
		_dio.interceptors.add(InterceptorsWrapper(
			onRequest: (options, handler) async {
				final connected = await connectivity.isConnected;
				if (!connected) {
					return handler.reject(DioException(
						requestOptions: options,
						error: ApiException('No internet connection'),
					));
				}
				return handler.next(options);
			},
			onError: (err, handler) {
				return handler.next(err);
			},
		));
	}

	Future<T> get<T>(String path,
			{Map<String, dynamic>? queryParameters, Options? options}) async {
		try {
			final resp = await _dio.get(path,
					queryParameters: queryParameters, options: options);
			return resp.data as T;
		} on DioException catch (e) {
			throw _handleDioError(e);
		} catch (e) {
			throw ApiException(e.toString());
		}
	}

	Future<T> post<T>(String path,
			{dynamic data, Map<String, dynamic>? queryParameters, Options? options}) async {
		try {
			final resp = await _dio.post(path,
					data: data, queryParameters: queryParameters, options: options);
			return resp.data as T;
		} on DioException catch (e) {
			throw _handleDioError(e);
		} catch (e) {
			throw ApiException(e.toString());
		}
	}

	Future<T> put<T>(String path,
			{dynamic data, Map<String, dynamic>? queryParameters, Options? options}) async {
		try {
			final resp = await _dio.put(path,
					data: data, queryParameters: queryParameters, options: options);
			return resp.data as T;
		} on DioException catch (e) {
			throw _handleDioError(e);
		} catch (e) {
			throw ApiException(e.toString());
		}
	}

	Future<T> delete<T>(String path,
			{dynamic data, Map<String, dynamic>? queryParameters, Options? options}) async {
		try {
			final resp = await _dio.delete(path,
					data: data, queryParameters: queryParameters, options: options);
			return resp.data as T;
		} on DioException catch (e) {
			throw _handleDioError(e);
		} catch (e) {
			throw ApiException(e.toString());
		}
	}

	ApiException _handleDioError(DioException error) {
		int? status;
		String message = error.message ?? 'Unknown error';
		if (error.response != null) {
			status = error.response?.statusCode;
			final data = error.response?.data;
			if (data is Map && data['message'] != null) {
				message = data['message'].toString();
			} else if (data is String) {
				message = data;
			}
		}
		return ApiException('[$status] $message', status);
	}
}

/*
Example usage:

final api = ApiService(baseUrl: 'https://api.example.com',
		defaultHeaders: {'Accept': 'application/json'});

// GET
final data = await api.get<Map<String, dynamic>>('/v1/items');

// POST
final created = await api.post<Map<String, dynamic>>('/v1/items', data: {'name': 'New'});

*/
