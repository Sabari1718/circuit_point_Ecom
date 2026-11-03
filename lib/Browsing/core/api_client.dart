// ignore_for_file: avoid_print
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Centralized API Logger for formatting requests and responses in terminal
/// Prevents Logcat truncation by chunking/line-splitting large outputs.
class ApiLogger {
  /// Safely print text line-by-line to prevent Android Logcat from truncating long strings
  static void safePrint(String text) {
    if (text.isEmpty) return;
    final lines = const LineSplitter().convert(text);
    for (final line in lines) {
      if (line.length <= 800) {
        print(line);
      } else {
        // Chunk long single lines safely without dropping characters
        for (int i = 0; i < line.length; i += 800) {
          final end = (i + 800 < line.length) ? i + 800 : line.length;
          print(line.substring(i, end));
        }
      }
    }
  }

  static void logRequest({
    required String method,
    required Uri url,
    Map<String, String>? headers,
    dynamic body,
  }) {
    final timeStr = DateTime.now().toIso8601String().substring(11, 19);
    final safeUrl = _sanitizeUrl(url);
    print('\n======================================================================');
    print('🌐 [API REQUEST] $method $safeUrl  [$timeStr]');
    print('----------------------------------------------------------------------');
    if (headers != null && headers.isNotEmpty) {
      final sanitizedHeaders = _sanitizeMap(headers);
      print('📋 Headers: ${jsonEncode(sanitizedHeaders)}');
    }
    if (body != null) {
      print('📤 Request Body:');
      safePrint(_formatBody(_sanitizeData(body)));
    } else {
      print('📤 Request Body: (empty)');
    }
    print('======================================================================');
  }

  static void logResponse({
    required String method,
    required Uri url,
    required int statusCode,
    required int durationMs,
    required dynamic body,
  }) {
    final isSuccess = statusCode >= 200 && statusCode < 300;
    final icon = isSuccess ? '✅' : '⚠️';
    final safeUrl = _sanitizeUrl(url);
    print('\n======================================================================');
    print('$icon [API RESPONSE] $method $safeUrl');
    print('📊 Status: $statusCode  |  ⏱️ Time: ${durationMs}ms');
    print('----------------------------------------------------------------------');
    print('📥 Response Body:');
    safePrint(_formatBody(_sanitizeData(body)));
    print('======================================================================\n');
  }

  static void logError({
    required String method,
    required Uri url,
    required int durationMs,
    required Object error,
    StackTrace? stackTrace,
  }) {
    final safeUrl = _sanitizeUrl(url);
    print('\n======================================================================');
    print('❌ [API ERROR] $method $safeUrl (after ${durationMs}ms)');
    print('----------------------------------------------------------------------');
    print('💥 Error Details: $error');
    if (stackTrace != null) {
      print('📜 StackTrace:');
      safePrint(stackTrace.toString().split('\n').take(8).join('\n'));
    }
    print('======================================================================\n');
  }

  static String _sanitizeUrl(Uri uri) {
    if (uri.queryParameters.isEmpty) return uri.toString();
    final newParams = Map<String, String>.from(uri.queryParameters);
    for (final k in newParams.keys.toList()) {
      final lower = k.toLowerCase();
      if (lower == 'code' || lower.contains('token') || lower.contains('key') || lower.contains('secret') || lower.contains('password')) {
        newParams[k] = '***REDACTED***';
      }
    }
    return uri.replace(queryParameters: newParams).toString();
  }

  static Map<String, dynamic> _sanitizeMap(Map<dynamic, dynamic> map) {
    final res = <String, dynamic>{};
    for (final entry in map.entries) {
      final key = entry.key.toString();
      final lower = key.toLowerCase();
      if (lower.contains('token') || lower.contains('auth') || lower.contains('key') || lower.contains('secret') || lower.contains('password') || lower == 'code' || lower == 'otp') {
        res[key] = '***REDACTED***';
      } else if (entry.value is Map) {
        res[key] = _sanitizeMap(entry.value as Map);
      } else {
        res[key] = entry.value;
      }
    }
    return res;
  }

  static dynamic _sanitizeData(dynamic data) {
    if (data == null) return null;
    if (data is Map) return _sanitizeMap(data);
    if (data is List) return data.map((item) => _sanitizeData(item)).toList();
    if (data is String) {
      final trimmed = data.trim();
      if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
        try {
          return _sanitizeMap(jsonDecode(trimmed));
        } catch (_) {}
      } else if (trimmed.startsWith('[') && trimmed.endsWith(']')) {
        try {
          final list = jsonDecode(trimmed);
          if (list is List) return list.map((item) => _sanitizeData(item)).toList();
        } catch (_) {}
      }
    }
    return data;
  }

  static String _formatBody(dynamic body) {
    if (body == null) return 'null';
    try {
      dynamic decoded;
      if (body is String) {
        final trimmed = body.trim();
        if (trimmed.startsWith('{') || trimmed.startsWith('[')) {
          decoded = jsonDecode(trimmed);
        } else {
          return body;
        }
      } else {
        decoded = body;
      }
      return const JsonEncoder.withIndent('  ').convert(decoded);
    } catch (_) {
      return body.toString();
    }
  }
}

/// Base HTTP Client with logging and timeouts for BrowsingApp
class ApiClient {
  static const String defaultGatewayUrl = 'https://mobile-management.srivagroups.in/api';

  static const String keyAppId = 'browsing_app_id';
  static const String keyAppKey = 'browsing_app_key';
  static const String keyUserAppToken = 'browsing_user_app_token';
  static const String keyUserMainId = 'browsing_user_main_id';
  static const String keyUserEmail = 'browsing_user_email';
  static const String keyUserName = 'browsing_user_name';
  static const String keyUserPhone = 'browsing_user_phone';
  static const String keyExpiresAt = 'browsing_expires_at';
  static const String keySelectedBusinessId = 'browsing_selected_business_id';
  static const String keySelectedBusinessName = 'browsing_selected_business_name';

  /// Centralized POST with full terminal logging & no truncation
  static Future<http.Response> post({
    required String endpoint,
    Map<String, String>? headers,
    dynamic body,
    Duration timeout = const Duration(seconds: 15),
  }) async {
    final fullUrl = Uri.parse(endpoint.startsWith('http') ? endpoint : '$defaultGatewayUrl$endpoint');
    final actualHeaders = headers ?? {'Content-Type': 'application/json'};
    final encodedBody = body is String ? body : (body != null ? jsonEncode(body) : null);

    ApiLogger.logRequest(
      method: 'POST',
      url: fullUrl,
      headers: actualHeaders,
      body: body,
    );

    final sw = Stopwatch()..start();
    try {
      final response = await http.post(
        fullUrl,
        headers: actualHeaders,
        body: encodedBody,
      ).timeout(timeout);
      sw.stop();

      ApiLogger.logResponse(
        method: 'POST',
        url: fullUrl,
        statusCode: response.statusCode,
        durationMs: sw.elapsedMilliseconds,
        body: response.body,
      );

      return response;
    } catch (e, stack) {
      sw.stop();
      ApiLogger.logError(
        method: 'POST',
        url: fullUrl,
        durationMs: sw.elapsedMilliseconds,
        error: e,
        stackTrace: stack,
      );
      rethrow;
    }
  }

  /// Centralized GET with full terminal logging & no truncation
  static Future<http.Response> get({
    required String endpoint,
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 15),
  }) async {
    final fullUrl = Uri.parse(endpoint.startsWith('http') ? endpoint : '$defaultGatewayUrl$endpoint');

    ApiLogger.logRequest(
      method: 'GET',
      url: fullUrl,
      headers: headers,
      body: null,
    );

    final sw = Stopwatch()..start();
    try {
      final response = await http.get(
        fullUrl,
        headers: headers,
      ).timeout(timeout);
      sw.stop();

      ApiLogger.logResponse(
        method: 'GET',
        url: fullUrl,
        statusCode: response.statusCode,
        durationMs: sw.elapsedMilliseconds,
        body: response.body,
      );

      return response;
    } catch (e, stack) {
      sw.stop();
      ApiLogger.logError(
        method: 'GET',
        url: fullUrl,
        durationMs: sw.elapsedMilliseconds,
        error: e,
        stackTrace: stack,
      );
      rethrow;
    }
  }
}
