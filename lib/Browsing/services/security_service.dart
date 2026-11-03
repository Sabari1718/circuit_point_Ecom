// ignore_for_file: avoid_print
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api_client.dart';

/// Data model representing the Security Settings Status
class SecurityStatus {
  final int status;
  final String userId;
  final bool isFingerprintEnabled;
  final bool isPinEnabled;
  final bool hasPin;
  final String? message;

  SecurityStatus({
    required this.status,
    required this.userId,
    required this.isFingerprintEnabled,
    required this.isPinEnabled,
    required this.hasPin,
    this.message,
  });

  factory SecurityStatus.fromJson(Map<String, dynamic> json) {
    return SecurityStatus(
      status: json['status'] is int ? json['status'] as int : (int.tryParse(json['status']?.toString() ?? '0') ?? 0),
      userId: json['userId']?.toString() ?? '',
      isFingerprintEnabled: json['isFingerprintEnabled'] == true,
      isPinEnabled: json['isPinEnabled'] == true,
      hasPin: json['hasPin'] == true,
      message: json['message']?.toString(),
    );
  }

  SecurityStatus copyWith({
    int? status,
    String? userId,
    bool? isFingerprintEnabled,
    bool? isPinEnabled,
    bool? hasPin,
    String? message,
  }) {
    return SecurityStatus(
      status: status ?? this.status,
      userId: userId ?? this.userId,
      isFingerprintEnabled: isFingerprintEnabled ?? this.isFingerprintEnabled,
      isPinEnabled: isPinEnabled ?? this.isPinEnabled,
      hasPin: hasPin ?? this.hasPin,
      message: message ?? this.message,
    );
  }
}

/// Service dedicated to handling Fingerprint & PIN Code Security Settings APIs
class SecurityService {
  static final LocalAuthentication _localAuth = LocalAuthentication();

  /// Keys for saving toggles locally in SharedPreferences
  static const String keyPrefFingerprint = 'pref_fingerprint_enabled';
  static const String keyPrefPin = 'pref_pin_enabled';
  static const String keyPrefSTab = 'pref_s_tab_enabled';
  static const String keyPrefGridCard = 'pref_grid_card_enabled';

  /// Retrieve the logged-in user's Main ID from SharedPreferences
  static Future<String> getStoredUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final savedId = prefs.getString(ApiClient.keyUserMainId);
    if (savedId != null && savedId.trim().isNotEmpty) {
      return savedId.trim();
    }
    throw Exception('User session not found. Please login first.');
  }

  /// 1️⃣ Screen Load (Fetch Toggle States from API)
  /// GET https://mobile-management.srivagroups.in/api/security/status?userId={userId}
  static Future<SecurityStatus> getSecurityStatus([String? explicitUserId]) async {
    final userId = explicitUserId ?? await getStoredUserId();
    final endpoint = '/security/status?userId=${Uri.encodeComponent(userId)}';

    print('\n======================================================================');
    print('🔍 [SECURITY STATUS] Checking Security Status for User: $userId');
    print('📡 GET https://mobile-management.srivagroups.in/api$endpoint');
    print('======================================================================');

    try {
      final res = await ApiClient.get(
        endpoint: endpoint,
        headers: {'Accept': 'application/json'},
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final status = SecurityStatus.fromJson(data);
        
        // Cache to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(keyPrefFingerprint, status.isFingerprintEnabled);
        await prefs.setBool(keyPrefPin, status.isPinEnabled);

        print('✅ [SECURITY STATUS] Fetched Successfully:');
        print('   - User ID: ${status.userId}');
        print('   - Fingerprint Enabled: ${status.isFingerprintEnabled}');
        print('   - PIN Enabled: ${status.isPinEnabled} (Has PIN: ${status.hasPin})');
        print('======================================================================\n');

        return status;
      } else {
        Map<String, dynamic> errData = {};
        try {
          errData = jsonDecode(res.body);
        } catch (_) {}
        final msg = errData['message'] ?? 'Failed to fetch security status (${res.statusCode})';
        throw Exception(msg);
      }
    } catch (e) {
      print('❌ [SecurityService] Error in getSecurityStatus: $e');
      rethrow;
    }
  }

  static Map<String, dynamic> _parseResponse(dynamic res, String actionName) {
    if (res.statusCode >= 500) {
      throw Exception('Security service is temporarily unavailable (${res.statusCode}). Please try again later.');
    }
    try {
      final data = jsonDecode(res.body);
      if (data is Map<String, dynamic>) {
        return data;
      }
    } catch (_) {}
    throw Exception('Failed to $actionName (${res.statusCode})');
  }

  /// 2️⃣ Fingerprint Toggle (Enable / Disable)
  /// POST https://mobile-management.srivagroups.in/api/security/fingerprint
  /// Body: { "userId": "USR_ID", "enabled": true / false }
  static Future<Map<String, dynamic>> toggleFingerprint({
    required bool enabled,
    String? explicitUserId,
  }) async {
    final userId = explicitUserId ?? await getStoredUserId();
    final body = {
      'userId': userId,
      'enabled': enabled,
    };

    print('\n======================================================================');
    print('👆 [SECURITY ACTION] Toggle Fingerprint: ${enabled ? "ENABLE" : "DISABLE"}');
    print('👤 User ID: $userId');
    print('📡 POST /security/fingerprint');
    print('======================================================================');

    try {
      final res = await ApiClient.post(
        endpoint: '/security/fingerprint',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: body,
      );

      final data = _parseResponse(res, 'update fingerprint setting');
      if (res.statusCode == 200 && (data['status'] == 1 || data['status'] == true)) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(keyPrefFingerprint, enabled);
        
        print('🎉 [SECURITY ACTION] Fingerprint lock is now: ${enabled ? "ENABLED" : "DISABLED"}');
        print('======================================================================\n');
        return data;
      } else {
        final msg = data['message'] ?? 'Failed to update fingerprint setting (${res.statusCode})';
        throw Exception(msg);
      }
    } catch (e) {
      print('❌ [SecurityService] Error in toggleFingerprint: $e');
      rethrow;
    }
  }

  /// 3️⃣ Fingerprint Verification (App Unlock / Login Check)
  /// POST https://mobile-management.srivagroups.in/api/security/fingerprint/verify
  /// Body: { "userId": "USR_ID", "signature": "BIO_PASS_FINGERPRINT_VERIFIED" }
  static Future<Map<String, dynamic>> verifyFingerprint({
    required bool success,
    String? explicitUserId,
  }) async {
    final userId = explicitUserId ?? await getStoredUserId();
    final body = {
      'userId': userId,
      'signature': 'BIO_PASS_FINGERPRINT_VERIFIED',
      'success': success,
    };

    print('\n======================================================================');
    print('👆 [SECURITY ACTION] Verifying Fingerprint Biometrics with Gateway');
    print('👤 User ID: $userId');
    print('📡 POST /security/fingerprint/verify');
    print('======================================================================');

    try {
      final res = await ApiClient.post(
        endpoint: '/security/fingerprint/verify',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: body,
      );

      final data = _parseResponse(res, 'verify fingerprint');
      print('✅ [SECURITY ACTION] Fingerprint Biometrics Verified successfully!');
      print('======================================================================\n');
      return data;
    } catch (e) {
      print('❌ [SecurityService] Error in verifyFingerprint: $e');
      rethrow;
    }
  }

  /// 4️⃣ Set / Update PIN Code
  /// POST https://mobile-management.srivagroups.in/api/security/pin/set
  /// Body: { "userId": "USR_ID", "pin": "5678" }
  static Future<Map<String, dynamic>> setPin({
    required String pin,
    String? explicitUserId,
  }) async {
    final userId = explicitUserId ?? await getStoredUserId();
    final body = {
      'userId': userId,
      'pin': pin,
    };

    print('\n======================================================================');
    print('🔑 [SECURITY ACTION] Setting / Updating Security PIN Code');
    print('👤 User ID: $userId');
    print('🔢 PIN: $pin');
    print('📡 POST /security/pin/set');
    print('======================================================================');

    try {
      final res = await ApiClient.post(
        endpoint: '/security/pin/set',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: body,
      );

      final data = _parseResponse(res, 'set PIN');
      if (res.statusCode == 200 && (data['status'] == 1 || data['status'] == true)) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(keyPrefPin, true);
        
        print('🎉 [SECURITY ACTION] Security PIN saved and enabled successfully!');
        print('======================================================================\n');
        return data;
      } else {
        final msg = data['message'] ?? 'Failed to set PIN (${res.statusCode})';
        throw Exception(msg);
      }
    } catch (e) {
      print('❌ [SecurityService] Error in setPin: $e');
      rethrow;
    }
  }

  /// 5️⃣ PIN Code Verification (App Unlock / Security Check)
  /// POST https://mobile-management.srivagroups.in/api/security/pin/verify
  /// Body: { "userId": "USR_ID", "pin": "ENTERED_PIN" }
  static Future<Map<String, dynamic>> verifyPin({
    required String pin,
    String? explicitUserId,
  }) async {
    final userId = explicitUserId ?? await getStoredUserId();
    final body = {
      'userId': userId,
      'pin': pin,
    };

    print('\n======================================================================');
    print('🔐 [SECURITY ACTION] Verifying Security PIN with Gateway');
    print('👤 User ID: $userId');
    print('🔢 Entered PIN: $pin');
    print('📡 POST /security/pin/verify');
    print('======================================================================');

    try {
      final res = await ApiClient.post(
        endpoint: '/security/pin/verify',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: body,
      );

      final data = _parseResponse(res, 'verify PIN');
      print('✅ [SECURITY ACTION] PIN verification response received!');
      print('======================================================================\n');
      return data;
    } catch (e) {
      print('❌ [SecurityService] Error in verifyPin: $e');
      rethrow;
    }
  }

  /// 6️⃣ PIN Code Toggle (Enable / Disable without deleting PIN)
  /// POST https://mobile-management.srivagroups.in/api/security/pin/toggle
  /// Body: { "userId": "USR_ID", "enabled": false / true }
  static Future<Map<String, dynamic>> togglePin({
    required bool enabled,
    String? explicitUserId,
  }) async {
    final userId = explicitUserId ?? await getStoredUserId();
    final body = {
      'userId': userId,
      'enabled': enabled,
    };

    print('\n======================================================================');
    print('🔐 [SECURITY ACTION] Toggle PIN Lock: ${enabled ? "ENABLE" : "DISABLE"}');
    print('👤 User ID: $userId');
    print('📡 POST /security/pin/toggle');
    print('======================================================================');

    try {
      final res = await ApiClient.post(
        endpoint: '/security/pin/toggle',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: body,
      );

      final data = _parseResponse(res, 'toggle PIN');
      if (res.statusCode == 200 && (data['status'] == 1 || data['status'] == true)) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(keyPrefPin, enabled);
        
        print('🎉 [SECURITY ACTION] PIN lock is now: ${enabled ? "ENABLED" : "DISABLED"}');
        print('======================================================================\n');
        return data;
      } else {
        final msg = data['message'] ?? 'Failed to toggle PIN (${res.statusCode})';
        throw Exception(msg);
      }
    } catch (e) {
      print('❌ [SecurityService] Error in togglePin: $e');
      rethrow;
    }
  }

  // -------------------------------------------------------------
  // Device Biometrics Integration (Local Authentication)
  // -------------------------------------------------------------

  /// Check if device hardware supports biometric authentication
  static Future<bool> canCheckBiometrics() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();
      return canCheck || isSupported;
    } on PlatformException catch (e) {
      print('⚠️ [SecurityService] Biometric support check error: $e');
      return false;
    }
  }

  /// Get list of available biometric types (e.g. fingerprint, face)
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      print('⚠️ [SecurityService] Error getting available biometrics: $e');
      return [];
    }
  }

  /// Prompt device biometric hardware
  /// Returns true if authentication succeeded on device
  static Future<bool> promptDeviceBiometric({
    String reason = 'Please authenticate with your fingerprint to proceed',
  }) async {
    try {
      final canAuth = await canCheckBiometrics();
      if (!canAuth) {
        print('ℹ️ [SecurityService] Biometrics not available on device hardware');
        return false;
      }

      print('👆 [SecurityService] Prompting device biometric sensor...');
      final authenticated = await _localAuth.authenticate(
        localizedReason: reason,
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );

      print('👆 [SecurityService] Biometric sensor response: ${authenticated ? "AUTHENTICATED" : "NOT AUTHENTICATED"}');
      return authenticated;
    } on PlatformException catch (e) {
      print('⚠️ [SecurityService] Local biometric prompt error: ${e.message} (${e.code})');
      return false;
    } catch (e) {
      print('⚠️ [SecurityService] Local biometric exception: $e');
      return false;
    }
  }
}
