// ignore_for_file: avoid_print
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api_client.dart';

/// BrowsingApp Auth Service
/// Handles login-only flow (no device hardware registration / telemetry)
class AuthService {
  /// Default fallback captcha categories
  static const List<Map<String, dynamic>> defaultCaptchaCategories = [
    {
      "id": 14,
      "category_name": "Traffic Lights",
      "image": "https://admin.jobes24x7.com/api/uploads/1785136131964_traffic_lights_category.png"
    },
    {
      "id": 11,
      "category_name": "flower",
      "image": "https://admin.jobes24x7.com/api/uploads/1783668547025_flower_category.png"
    },
    {
      "id": 10,
      "category_name": "buildings",
      "image": "https://admin.jobes24x7.com/api/uploads/1783668507489_buildings_category.png"
    },
    {
      "id": 9,
      "category_name": "furniture",
      "image": "https://admin.jobes24x7.com/api/uploads/1783668524791_furniture_category.png"
    },
    {
      "id": 8,
      "category_name": "electronics",
      "image": "https://admin.jobes24x7.com/api/uploads/1783668714082_electronics_category.png"
    },
    {
      "id": 7,
      "category_name": "nature",
      "image": "https://admin.jobes24x7.com/api/uploads/1783668565003_nature_category.png"
    },
    {
      "id": 6,
      "category_name": "clothing",
      "image": "https://admin.jobes24x7.com/api/uploads/1783668575457_clothing_category.png"
    },
    {
      "id": 5,
      "category_name": "sports",
      "image": "https://admin.jobes24x7.com/api/uploads/1783668585221_sports_category.png"
    },
    {
      "id": 4,
      "category_name": "food",
      "image": "https://admin.jobes24x7.com/api/uploads/1783668601764_food_category.png"
    },
    {
      "id": 3,
      "category_name": "vehicle",
      "image": "https://admin.jobes24x7.com/api/uploads/1783668622800_vehicle_category.png"
    },
    {
      "id": 2,
      "category_name": "animal",
      "image": "https://admin.jobes24x7.com/api/uploads/1783665540216_animal_category.png"
    },
    {
      "id": 1,
      "category_name": "bird",
      "image": "https://admin.jobes24x7.com/api/uploads/1785136067020_bird_category.png"
    }
  ];

  /// Fetch captcha categories from the login gateway
  static Future<List<Map<String, dynamic>>> fetchCaptchaCategories() async {
    try {
      final res = await ApiClient.get(
        endpoint:
            'https://managelogin.jobes24x7.com/api/outsideapis/captcha/category',
        timeout: const Duration(seconds: 8),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['data'] is List && (data['data'] as List).isNotEmpty) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      }
    } catch (e) {
      print('⚠️ [AuthService] Error fetching captcha categories: $e');
    }
    return defaultCaptchaCategories;
  }

  /// Authenticate user credentials (no device registration, no telemetry)
  /// On success, session is saved to SharedPreferences and result map returned.
  static Future<Map<String, dynamic>> login({
    required String loginField,
    required String loginValue,
    required String password,
    Map<String, dynamic>? captchaCategory,
  }) async {
    final loginPayload = {
      loginField: loginValue,
      'password': password,
      if (captchaCategory != null && captchaCategory['id'] != null)
        'captcha_image_id': captchaCategory['id'],
    };

    http.Response loginRes;
    if (loginField == 'phone_number' || loginField == 'user_main_id') {
      try {
        loginRes = await ApiClient.post(
          endpoint: 'https://managelogin.jobes24x7.com/api/login/authenticate',
          body: loginPayload,
        );
      } catch (_) {
        loginRes = await ApiClient.post(
          endpoint: 'https://billing.srivagroups.in/api/auth/login',
          body: loginPayload,
        );
      }
    } else {
      try {
        loginRes = await ApiClient.post(
          endpoint: 'https://billing.srivagroups.in/api/auth/login',
          body: loginPayload,
        );
        if (loginRes.statusCode != 200) {
          throw Exception('Billing login HTTP ${loginRes.statusCode}');
        }
      } catch (_) {
        // Fallback to managelogin if billing auth login fails
        loginRes = await ApiClient.post(
          endpoint: 'https://managelogin.jobes24x7.com/api/login/authenticate',
          body: loginPayload,
        );
      }
    }


    if (loginRes.statusCode != 200) {
      Map<String, dynamic> errorData = {};
      try {
        errorData = jsonDecode(loginRes.body);
      } catch (_) {}
      final errorMsg = errorData['data']?['message'] ??
          errorData['message'] ??
          errorData['error'] ??
          'Authentication failed (${loginRes.statusCode})';
      throw Exception(errorMsg);
    }

    final loginData = jsonDecode(loginRes.body);
    final responseData = (loginData['data'] is Map)
        ? loginData['data'] as Map<String, dynamic>
        : <String, dynamic>{};

    final userToken = responseData['token']?.toString() ?? '';
    final expiresAt = responseData['expires_at']?.toString() ?? '';
    final userData = (responseData['data'] is Map)
        ? responseData['data'] as Map<String, dynamic>
        : <String, dynamic>{};

    final userMainId = userData['user_main_id']?.toString() ??
        userData['id']?.toString() ??
        '';
    final userEmail = userData['email']?.toString() ?? loginValue;
    final userName = userData['user_name']?.toString() ??
        userData['name']?.toString() ??
        (userEmail.contains('@') ? userEmail.split('@').first : loginValue);
    final phone = userData['phone_number']?.toString() ??
        userData['phone']?.toString() ??
        (loginField == 'phone_number' ? loginValue : '');

    // Save session credentials to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(ApiClient.keyUserAppToken, userToken);
    await prefs.setString(ApiClient.keyUserMainId, userMainId);
    await prefs.setString(ApiClient.keyUserEmail, userEmail);
    await prefs.setString(ApiClient.keyUserName, userName);
    await prefs.setString(ApiClient.keyUserPhone, phone);
    if (expiresAt.isNotEmpty) {
      await prefs.setString(ApiClient.keyExpiresAt, expiresAt);
    }
    final nowIso = DateTime.now().toIso8601String();
    await prefs.setString(keyLastLoginTimestamp, nowIso);

    print('🎉 [AuthService] Login successful for $userEmail!');

    return {
      'success': true,
      'userAppToken': userToken,
      'userMainId': userMainId,
      'userEmail': userEmail,
      'userName': userName,
      'userData': userData,
    };
  }

  static const String keyLastLoginTimestamp = 'last_login_timestamp';

  /// Check if user has an active login session saved
  static Future<bool> hasActiveSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(ApiClient.keyUserAppToken);
    final userId = prefs.getString(ApiClient.keyUserMainId);
    return token != null && token.isNotEmpty && userId != null && userId.isNotEmpty;
  }

  /// Check if the user has an active login session that occurred within 24 hours (1 day)
  static Future<bool> isSessionValidWithinOneDay() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(ApiClient.keyUserAppToken);
    final userId = prefs.getString(ApiClient.keyUserMainId);
    if (token == null || token.isEmpty || userId == null || userId.isEmpty) {
      return false;
    }

    final lastLoginStr = prefs.getString(keyLastLoginTimestamp);
    if (lastLoginStr == null || lastLoginStr.isEmpty) {
      return false;
    }

    try {
      final lastLogin = DateTime.parse(lastLoginStr);
      final difference = DateTime.now().difference(lastLogin);
      if (difference.inHours >= 24) {
        print('⏰ [AuthService] 24-hour (1 day) session window expired. Re-login required.');
        return false;
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Clear saved session
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(ApiClient.keyUserAppToken);
    await prefs.remove(ApiClient.keyUserMainId);
    await prefs.remove(ApiClient.keyUserEmail);
    await prefs.remove(ApiClient.keyUserName);
    await prefs.remove(ApiClient.keyUserPhone);
    await prefs.remove(ApiClient.keyExpiresAt);
    await prefs.remove(keyLastLoginTimestamp);
    print('🚪 [AuthService] Session cleared.');
  }
}
