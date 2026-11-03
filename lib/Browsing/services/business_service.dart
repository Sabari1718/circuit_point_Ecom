// ignore_for_file: avoid_print
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../core/api_client.dart';

/// Models a Business Profile returned by the My Businesses API
class BusinessProfile {
  final String id;
  final String name;
  final String? category;
  final String? statusText;
  final bool isGstVerified;
  final Map<String, dynamic> rawData;

  const BusinessProfile({
    required this.id,
    required this.name,
    this.category,
    this.statusText,
    this.isGstVerified = false,
    required this.rawData,
  });

  factory BusinessProfile.fromJson(Map<String, dynamic> json) {
    // 100% Real API fields only - no hardcoded/default strings
    final id = (json['business_id'] ?? json['id'] ?? '').toString();
    final name = (json['business_name'] ?? json['name'] ?? '').toString();
    final category = json['business_type']?.toString() ?? json['category']?.toString();
    final statusText = json['status']?.toString();
    final gstNo = (json['gst_number'] ?? json['gstin'] ?? '').toString();
    final isGstVerified = gstNo.isNotEmpty || (statusText?.toLowerCase().contains('verif') ?? false);

    return BusinessProfile(
      id: id,
      name: name,
      category: category,
      statusText: statusText,
      isGstVerified: isGstVerified,
      rawData: json,
    );
  }
}

/// Service dedicated to fetching real registered businesses for a User Main ID from live API
class BusinessService {
  static String get baseUrl => AppConfig.myBusinessesApiUrl;

  /// Fetches the list of businesses associated with the given userId & bearer token from live API
  static Future<List<BusinessProfile>> fetchPropagatorBusinesses({
    String? userId,
    String? token,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final effectiveUserId = userId ?? prefs.getString(ApiClient.keyUserMainId) ?? '';
    final effectiveToken = token ?? prefs.getString(ApiClient.keyUserAppToken) ?? '';

    if (effectiveUserId.isEmpty) {
      throw Exception('User Main ID is missing. Please log in first.');
    }
    if (effectiveToken.isEmpty) {
      throw Exception('Authorization token is missing. Please log in first.');
    }

    final url = Uri.parse('$baseUrl?user_main_id=$effectiveUserId&userId=$effectiveUserId');

    print('\n======================================================================');
    print('🏢 [BUSINESS API REQUEST] GET $url');
    print('----------------------------------------------------------------------');
    print('👤 User Main ID : $effectiveUserId');
    print('🔑 Token        : ${effectiveToken.isNotEmpty ? "***PRESENT***" : "(none)"}');
    print('======================================================================\n');

    final headers = <String, String>{
      'Accept': 'application/json',
      'Authorization': 'Bearer $effectiveToken',
    };

    final response = await http.get(url, headers: headers).timeout(
      const Duration(seconds: 12),
    );

    print('\n======================================================================');
    print('📥 [BUSINESS API RESPONSE] Status: ${response.statusCode}');
    print('----------------------------------------------------------------------');
    print(response.body);
    print('======================================================================\n');

    if (response.statusCode == 200) {
      final dynamic decoded = jsonDecode(response.body);
      final dynamic data = decoded is Map ? decoded['data'] : null;

      if (data is List) {
        return data.map((item) => BusinessProfile.fromJson(Map<String, dynamic>.from(item))).toList();
      }
      return [];
    } else {
      final errorMsg = 'Failed to load businesses (HTTP ${response.statusCode})';
      print('⚠️ [BusinessService] $errorMsg: ${response.body}');
      throw Exception(errorMsg);
    }
  }

  /// Alias for fetchPropagatorBusinesses
  static Future<List<BusinessProfile>> fetchMyBusinesses({
    String? userId,
    String? token,
  }) => fetchPropagatorBusinesses(userId: userId, token: token);

  /// Saves the selected business details into SharedPreferences
  static Future<void> saveSelectedBusiness(BusinessProfile business) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(ApiClient.keySelectedBusinessId, business.id);
    await prefs.setString(ApiClient.keySelectedBusinessName, business.name);
    print('✅ [BusinessService] Saved active business: ${business.name} (#${business.id})');
  }
}
