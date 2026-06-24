import 'dart:developer' as developer;

import 'package:dio/dio.dart';

class PiHttpClient {
  PiHttpClient({required String baseUrl})
      : _dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 10),
          headers: {'Content-Type': 'application/json'},
        )) {
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (o) => developer.log('$o', name: 'dio'),
    ));
  }

  final Dio _dio;

  Future<bool> startMission() async {
    return _sendGet('/start', 'startMission');
  }

  Future<bool> stopMission() async {
    return _sendGet('/stop', 'stopMission');
  }

  Future<bool> isRunning() async {
    try {
      final response = await _dio.get('/status');
      final data = response.data as Map<String, dynamic>;
      return data['motors_running'] == true;
    } catch (e) {
      developer.log('[PiHttpClient] isRunning error: $e', name: 'pi_http');
      return false;
    }
  }

  Future<Map<String, dynamic>> getStatus() async {
    final response = await _dio.get('/status');
    return response.data as Map<String, dynamic>;
  }

  Future<bool> _sendGet(String path, String tag) async {
    try {
      final response = await _dio.get(path);
      developer.log('[PiHttpClient] $tag succeeded (${response.statusCode})',
          name: 'pi_http');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['status'] == 'ok') {
          return true;
        }
        return data is Map<String, dynamic> || data == null;
      }
      developer.log('[PiHttpClient] $tag failed: ${response.statusCode}',
          name: 'pi_http');
      return false;
    } on DioException catch (e) {
      developer.log('[PiHttpClient] $tag error: ${e.type} — ${e.message}',
          name: 'pi_http');

      if (e.type == DioExceptionType.connectionTimeout) {
        developer.log('[PiHttpClient] $tag connection timeout', name: 'pi_http');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        developer.log('[PiHttpClient] $tag receive timeout', name: 'pi_http');
      } else if (e.type == DioExceptionType.connectionError) {
        developer.log('[PiHttpClient] $tag connection refused', name: 'pi_http');
      }
      rethrow;
    } catch (e) {
      developer.log('[PiHttpClient] $tag unexpected error: $e', name: 'pi_http');
      rethrow;
    }
  }
}
