// ignore_for_file: avoid_print
import 'dart:convert';
import 'package:package_info_plus/package_info_plus.dart';
import '../config/app_config.dart';
import '../core/api_client.dart';

/// Service dedicated to App Identity Registration & Version Validation for BrowsingApp
class AppValidationService {
  /// Step 1: Register BrowsingApp with the gateway and return appId
  static Future<String> getOrRegisterAppId() async {
    String appName = AppConfig.appName;
    String appVersion = AppConfig.appVersion;
    String softwareVersion = AppConfig.softwareVersion;

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      if (packageInfo.appName.isNotEmpty) appName = packageInfo.appName;
      if (packageInfo.version.isNotEmpty) appVersion = packageInfo.version;
      final buildNum =
          packageInfo.buildNumber.isNotEmpty ? packageInfo.buildNumber : '1';
      final parts = appVersion.split('.');
      softwareVersion = parts.length >= 2
          ? '${parts[0]}.${parts[1]}.$buildNum'
          : '$appVersion.$buildNum';
    } catch (e) {
      print('⚠️ [AppValidationService] PackageInfo error: $e');
    }

    try {
      final response = await ApiClient.post(
        endpoint: '/app',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'appId': AppConfig.appId,
          'appKey': AppConfig.appKey,
        },
        body: {
          'appId': AppConfig.appId,
          'appKey': AppConfig.appKey,
          'appName': appName,
          'appVersion': appVersion,
          'softwareVersion': softwareVersion,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ [AppValidationService] BrowsingApp registered with gateway');
      } else {
        print(
            '⚠️ [AppValidationService] Registration returned: ${response.statusCode}');
      }
    } catch (e) {
      print('⚠️ [AppValidationService] Registration error (non-fatal): $e');
    }

    print('⚡ [AppValidationService] Active App ID: ${AppConfig.appId}');
    return AppConfig.appId;
  }

  /// Step 2: Validate App & Software Version on /api/app/validate
  /// Returns { 'status': 1 or 2, 'message': String, ... }
  static Future<Map<String, dynamic>> validateApp() async {
    String appVersion = AppConfig.appVersion;
    String softwareVersion = AppConfig.softwareVersion;

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      if (packageInfo.version.isNotEmpty) appVersion = packageInfo.version;
      final buildNum =
          packageInfo.buildNumber.isNotEmpty ? packageInfo.buildNumber : '1';
      final parts = appVersion.split('.');
      softwareVersion = parts.length >= 2
          ? '${parts[0]}.${parts[1]}.$buildNum'
          : '$appVersion.$buildNum';
    } catch (e) {
      print('⚠️ [AppValidationService] PackageInfo error in validateApp: $e');
    }

    final response = await ApiClient.post(
      endpoint: '/app/validate',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'appId': AppConfig.appId,
        'appKey': AppConfig.appKey,
      },
      body: {
        'appId': AppConfig.appId,
        'appKey': AppConfig.appKey,
        'appVersion': appVersion,
        'softwareVersion': softwareVersion,
      },
    );

    if (response.statusCode == 200) {
      try {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } catch (_) {
        throw Exception('Invalid response format received from server.');
      }
    } else if (response.statusCode == 503) {
      throw Exception('Server 503 (Service Unavailable): Gateway server is currently under maintenance. Please try again later.');
    } else {
      throw Exception('Server Error (Status ${response.statusCode}): Unable to complete app validation.');
    }
  }
}


/// Helper class for direct endpoint validation testing
class BrowsingAppValidationService {
  static const String appId = AppConfig.appId;
  static const String appKey = AppConfig.appKey;
  static const String appName = AppConfig.appName;
  static const String appVersion = AppConfig.appVersion;
  static const String softwareVersion = AppConfig.softwareVersion;

  static const String primaryValidateUrl = 'https://mobile-management.srivagroups.in/api/app/validate';
  static const String fallbackRegisterUrl = 'https://mobile-management.srivagroups.in/api/app';

  static Future<Map<String, dynamic>> validateBrowsingApp({
    String? targetUrl,
    String? customAppName,
    String? customAppVersion,
    String? customSoftwareVersion,
  }) async {
    final url = targetUrl ?? primaryValidateUrl;
    final isValidate = url.contains('/validate');

    final payload = isValidate
        ? {
            'appId': appId,
            'appKey': appKey,
            'appVersion': customAppVersion ?? appVersion,
            'softwareVersion': customSoftwareVersion ?? softwareVersion,
          }
        : {
            'appId': appId,
            'appKey': appKey,
            'appName': customAppName ?? appName,
            'appVersion': customAppVersion ?? appVersion,
            'softwareVersion': customSoftwareVersion ?? softwareVersion,
          };

    try {
      final res = await ApiClient.post(
        endpoint: url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'appId': appId,
          'appKey': appKey,
        },
        body: payload,
      );
      final dynamic bodyData = jsonDecode(res.body);
      return {
        'statusCode': res.statusCode,
        'success': res.statusCode == 200 || res.statusCode == 201,
        'data': bodyData,
        'message': bodyData is Map ? (bodyData['message'] ?? 'OK') : 'OK',
      };
    } catch (e) {
      return {
        'statusCode': 500,
        'success': false,
        'error': e.toString(),
        'message': 'Failed: $e',
      };
    }
  }
}

