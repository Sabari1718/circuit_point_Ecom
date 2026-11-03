import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../core/api_client.dart';

/// Models the result of phone/email registration verification against APIs
class PhoneVerificationResult {
  final bool isRegistered;
  final String normalizedPhone;
  final Map<String, dynamic>? userRecord;
  final String? errorMessage;
  final String? userName;
  final String? userEmail;
  final String? userMainId;

  const PhoneVerificationResult({
    required this.isRegistered,
    required this.normalizedPhone,
    this.userRecord,
    this.errorMessage,
    this.userName,
    this.userEmail,
    this.userMainId,
  });
}

/// Models the result of sending SMS OTP
class OtpSendResult {
  final bool success;
  final String? verificationId;
  final String? message;
  final String? errorMessage;
  final int cooldownSeconds;

  const OtpSendResult({
    required this.success,
    this.verificationId,
    this.message,
    this.errorMessage,
    this.cooldownSeconds = 60,
  });
}

/// Models the result of validating SMS OTP
class OtpValidationResult {
  final bool isValid;
  final String? errorMessage;

  const OtpValidationResult({
    required this.isValid,
    this.errorMessage,
  });
}

/// Dedicated service for Phone Number Verification and 4-Digit OTP Handling
class PhoneVerificationService {
  static const int defaultCooldownSeconds = 60;
  static const int maxAttemptsPerWindow = 5;
  static const Duration rateLimitWindow = Duration(minutes: 10);

  static final Map<String, List<DateTime>> _phoneAttemptHistory = {};
  static final Map<String, DateTime> _phoneLastSent = {};

  static String normalizePhoneNumber(String raw) {
    if (raw.isEmpty) return '';
    String digits = raw.replaceAll(RegExp(r'\D'), '');

    if (digits.length == 12 && digits.startsWith('91')) {
      digits = digits.substring(2);
    } else if (digits.length == 11 && digits.startsWith('0')) {
      digits = digits.substring(1);
    }

    return digits;
  }

  static String maskPhoneNumber(String raw) {
    final norm = normalizePhoneNumber(raw);
    if (norm.length >= 10) {
      final last4 = norm.substring(norm.length - 4);
      return '+91 ******$last4';
    }
    return raw;
  }

  static Future<PhoneVerificationResult> verifyPhoneNumber(String enteredPhone) async {
    final normalized = normalizePhoneNumber(enteredPhone);

    if (normalized.isEmpty || normalized.length < 10) {
      return const PhoneVerificationResult(
        isRegistered: false,
        normalizedPhone: '',
        errorMessage: 'Please enter a valid 10-digit mobile number.',
      );
    }

    try {
      // 1. Primary check via dedicated live API: /api/login/check-phone/<phone>
      try {
        final checkRes = await ApiClient.get(
          endpoint: '${AppConfig.checkPhoneApiBase}/$normalized',
          timeout: const Duration(seconds: 10),
        );

        if (checkRes.statusCode == 200) {
          final decoded = jsonDecode(checkRes.body);
          final data = decoded['data'];
          if (data != null && data['exists'] == true) {
            final users = data['users'] as List? ?? [];
            final firstUser = users.isNotEmpty ? users.first as Map<String, dynamic> : null;
            return PhoneVerificationResult(
              isRegistered: true,
              normalizedPhone: normalized,
              userRecord: firstUser ?? data,
              userName: firstUser?['user_name']?.toString() ?? data['user_name']?.toString(),
              userEmail: firstUser?['email']?.toString() ?? data['email']?.toString(),
              userMainId: firstUser?['user_main_id']?.toString() ?? data['user_main_id']?.toString(),
            );
          } else if (data != null && data['exists'] == false) {
            return PhoneVerificationResult(
              isRegistered: false,
              normalizedPhone: normalized,
              errorMessage: 'This mobile number is not registered. Please enter a registered number.',
            );
          }
        }
      } catch (_) {
        // Fallback to ids-phone
      }

      // 2. Fallback check via ids-phone registry API
      final response = await ApiClient.get(
        endpoint: AppConfig.idsPhoneApiUrl,
        timeout: const Duration(seconds: 12),
      );

      if (response.statusCode != 200) {
        return PhoneVerificationResult(
          isRegistered: false,
          normalizedPhone: normalized,
          errorMessage: 'Verification service error (HTTP ${response.statusCode}). Please try again later.',
        );
      }

      final dynamic decoded = jsonDecode(response.body);
      if (decoded == null || decoded['data'] == null) {
        return PhoneVerificationResult(
          isRegistered: false,
          normalizedPhone: normalized,
          errorMessage: 'Unexpected response from verification server.',
        );
      }

      final List<dynamic> users = decoded['data']['data'] ?? [];
      Map<String, dynamic>? matchedUser;

      for (final user in users) {
        final rawDbPhone = (user['phone_number'] ?? '').toString().trim();
        if (rawDbPhone.isEmpty) continue;

        final normDbPhone = normalizePhoneNumber(rawDbPhone);

        if (rawDbPhone == enteredPhone ||
            normDbPhone == normalized ||
            (normalized.length == 10 && normDbPhone.endsWith(normalized)) ||
            (normDbPhone.length == 10 && normalized.endsWith(normDbPhone))) {
          matchedUser = Map<String, dynamic>.from(user);
          break;
        }
      }

      if (matchedUser == null) {
        return PhoneVerificationResult(
          isRegistered: false,
          normalizedPhone: normalized,
          errorMessage: 'This mobile number is not registered. Please enter your registered mobile number.',
        );
      }

      return PhoneVerificationResult(
        isRegistered: true,
        normalizedPhone: normalized,
        userRecord: matchedUser,
        userMainId: matchedUser['user_main_id']?.toString(),
      );
    } catch (e) {
      return PhoneVerificationResult(
        isRegistered: false,
        normalizedPhone: normalized,
        errorMessage: 'Unable to connect to verification server: $e',
      );
    }
  }

  static Future<PhoneVerificationResult> verifyEmail(String enteredEmail) async {
    final cleanEmail = enteredEmail.trim();

    if (cleanEmail.isEmpty || !RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$').hasMatch(cleanEmail)) {
      return const PhoneVerificationResult(
        isRegistered: false,
        normalizedPhone: '',
        errorMessage: 'Please enter a valid email address.',
      );
    }

    try {
      final checkRes = await ApiClient.get(
        endpoint: '${AppConfig.checkEmailApiBase}/$cleanEmail',
        timeout: const Duration(seconds: 10),
      );

      if (checkRes.statusCode == 200) {
        final decoded = jsonDecode(checkRes.body);
        final data = decoded['data'];
        if (data != null && data['exists'] == true) {
          final users = data['users'] as List? ?? [];
          final firstUser = users.isNotEmpty ? users.first as Map<String, dynamic> : null;
          return PhoneVerificationResult(
            isRegistered: true,
            normalizedPhone: firstUser?['phone_number']?.toString() ?? '',
            userRecord: firstUser ?? data,
            userName: firstUser?['user_name']?.toString() ?? data['user_name']?.toString(),
            userEmail: cleanEmail,
            userMainId: firstUser?['user_main_id']?.toString() ?? data['user_main_id']?.toString(),
          );
        } else if (data != null && data['exists'] == false) {
          return PhoneVerificationResult(
            isRegistered: false,
            normalizedPhone: '',
            errorMessage: 'This email is not registered. Please enter your registered email address.',
          );
        }
      }

      return PhoneVerificationResult(
        isRegistered: false,
        normalizedPhone: '',
        errorMessage: 'Verification service returned HTTP ${checkRes.statusCode}. Please try again.',
      );
    } catch (e) {
      return PhoneVerificationResult(
        isRegistered: false,
        normalizedPhone: '',
        errorMessage: 'Unable to connect to verification server: $e',
      );
    }
  }

  static Future<PhoneVerificationResult> verifyUserId(String enteredUserId) async {
    final cleanId = enteredUserId.trim();

    if (cleanId.isEmpty) {
      return const PhoneVerificationResult(
        isRegistered: false,
        normalizedPhone: '',
        errorMessage: 'Please enter a valid User ID.',
      );
    }

    try {
      final response = await ApiClient.get(
        endpoint: AppConfig.idsPhoneApiUrl,
        timeout: const Duration(seconds: 12),
      );

      if (response.statusCode != 200) {
        return PhoneVerificationResult(
          isRegistered: false,
          normalizedPhone: cleanId,
          errorMessage: 'Verification service error (HTTP ${response.statusCode}). Please try again later.',
        );
      }

      final dynamic decoded = jsonDecode(response.body);
      if (decoded == null || decoded['data'] == null) {
        return PhoneVerificationResult(
          isRegistered: false,
          normalizedPhone: cleanId,
          errorMessage: 'Unexpected response from verification server.',
        );
      }

      final List<dynamic> users = decoded['data']['data'] ?? [];
      Map<String, dynamic>? matchedUser;

      for (final user in users) {
        final rawUserMainId = (user['user_main_id'] ?? '').toString().trim();
        final rawId = (user['id'] ?? '').toString().trim();

        if (rawUserMainId == cleanId || rawId == cleanId) {
          matchedUser = Map<String, dynamic>.from(user);
          break;
        }
      }

      if (matchedUser == null) {
        return PhoneVerificationResult(
          isRegistered: false,
          normalizedPhone: cleanId,
          errorMessage: 'User ID "$cleanId" is not registered. Please enter a valid registered User ID.',
        );
      }

      return PhoneVerificationResult(
        isRegistered: true,
        normalizedPhone: matchedUser['phone_number']?.toString() ?? cleanId,
        userRecord: matchedUser,
      );
    } catch (e) {
      return PhoneVerificationResult(
        isRegistered: false,
        normalizedPhone: cleanId,
        errorMessage: 'Unable to connect to verification server: $e',
      );
    }
  }

  static int getRemainingCooldownSeconds(String phone) {
    final norm = normalizePhoneNumber(phone);
    final last = _phoneLastSent[norm];
    if (last == null) return 0;

    final diff = DateTime.now().difference(last).inSeconds;
    final remaining = defaultCooldownSeconds - diff;
    return remaining > 0 ? remaining : 0;
  }

  static String? checkRateLimit(String phone) {
    final norm = normalizePhoneNumber(phone);
    final now = DateTime.now();

    final remaining = getRemainingCooldownSeconds(phone);
    if (remaining > 0) {
      return 'Please wait $remaining seconds before requesting another OTP.';
    }

    final history = _phoneAttemptHistory[norm] ?? [];
    final recentAttempts = history.where((t) => now.difference(t) < rateLimitWindow).toList();
    _phoneAttemptHistory[norm] = recentAttempts;

    if (recentAttempts.length >= maxAttemptsPerWindow) {
      return 'Maximum OTP requests exceeded. Please try again after 10 minutes.';
    }

    return null;
  }

  static const String _cpaasBaseUrl = 'https://cpaas.messagecentral.com';
  static const String _cpaasCustomerId = 'C-836DB70B5587493';
  static const String _cpaasAuthToken =
      'eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJDLTgzNkRCNzBCNTU4NzQ5MyIsImlhdCI6MTc3MzA0NzU5OSwiZXhwIjoxOTMwNzI3NTk5fQ.pgnC_7IQgwfh3QGRuu4APflRX9VCpt_RQNR-QX1SP425KXn4PUmAohdQTWtEWhDx7Z9lOVfAevCVHCed4uemew';

  static final Map<String, String> _verificationStore = {};

  static Future<OtpSendResult> sendSmsOtp({
    required String phone,
    Map<String, dynamic>? verifiedUser,
  }) async {
    final norm = normalizePhoneNumber(phone);

    if (norm.isEmpty || norm.length != 10) {
      return const OtpSendResult(
        success: false,
        errorMessage: 'Please enter a valid 10-digit mobile number.',
      );
    }

    final rateLimitError = checkRateLimit(phone);
    if (rateLimitError != null) {
      return OtpSendResult(
        success: false,
        errorMessage: rateLimitError,
        cooldownSeconds: getRemainingCooldownSeconds(phone),
      );
    }

    try {
      debugPrint('📱 [SMS Gateway] Calling MessageCentral send API for: $norm');
      final url = Uri.parse(
        '$_cpaasBaseUrl/verification/v3/send?countryCode=91&customerId=$_cpaasCustomerId&flowType=SMS&mobileNumber=$norm',
      );

      final response = await http.post(
        url,
        headers: {
          'authToken': _cpaasAuthToken,
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 12));

      debugPrint('📱 [SMS Gateway] Response HTTP ${response.statusCode}: ${response.body}');
      final dynamic decoded = jsonDecode(response.body);

      if (decoded is Map && decoded['responseCode'] == 200) {
        final verificationId = decoded['data']?['verificationId']?.toString() ?? '';
        final timeout = (decoded['data']?['timeout'] as int?) ?? defaultCooldownSeconds;
        _verificationStore[norm] = verificationId;

        final now = DateTime.now();
        _phoneLastSent[norm] = now;
        _phoneAttemptHistory.putIfAbsent(norm, () => []).add(now);

        return OtpSendResult(
          success: true,
          verificationId: verificationId,
          message: 'OTP sent successfully to ${maskPhoneNumber(phone)}',
          cooldownSeconds: timeout,
        );
      } else if (decoded is Map &&
          (decoded['message'] == 'REQUEST_ALREADY_EXISTS' || decoded['responseCode'] == 409)) {
        // Retry OTP if request already exists
        final existingId = _verificationStore[norm];
        if (existingId != null && existingId.isNotEmpty) {
          return await _retrySmsOtp(norm, existingId);
        }
        return OtpSendResult(
          success: true,
          verificationId: existingId,
          message: 'OTP was already sent to ${maskPhoneNumber(phone)}. Please check SMS.',
          cooldownSeconds: 60,
        );
      } else {
        final errMsg = (decoded is Map)
            ? (decoded['data']?['errorMessage'] ??
                decoded['message'] ??
                'Failed to send OTP (${decoded['responseCode'] ?? response.statusCode})')
            : 'SMS API returned HTTP ${response.statusCode}';
        return OtpSendResult(
          success: false,
          errorMessage: errMsg.toString(),
        );
      }
    } catch (e) {
      debugPrint('❌ [SMS Gateway] Error calling send API: $e');
      return OtpSendResult(
        success: false,
        errorMessage: 'Network error calling SMS gateway: $e',
      );
    }
  }

  /// Internal helper to retry SMS OTP via MessageCentral API
  static Future<OtpSendResult> _retrySmsOtp(String normPhone, String verificationId) async {
    try {
      final url = Uri.parse(
        '$_cpaasBaseUrl/verification/v3/retry?countryCode=91&mobileNumber=$normPhone&verificationId=$verificationId&customerId=$_cpaasCustomerId',
      );

      final response = await http.post(
        url,
        headers: {
          'authToken': _cpaasAuthToken,
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 12));

      final dynamic decoded = jsonDecode(response.body);
      if (decoded is Map && decoded['responseCode'] == 200) {
        final newVerId = decoded['data']?['verificationId']?.toString() ?? verificationId;
        _verificationStore[normPhone] = newVerId;
        return OtpSendResult(
          success: true,
          verificationId: newVerId,
          message: 'OTP resent successfully to +91 $normPhone',
          cooldownSeconds: (decoded['data']?['timeout'] as int?) ?? 60,
        );
      } else {
        final msg = (decoded is Map) ? (decoded['message'] ?? 'Failed to resend OTP') : 'Error';
        return OtpSendResult(success: false, errorMessage: msg.toString());
      }
    } catch (e) {
      return OtpSendResult(success: false, errorMessage: 'Retry error: $e');
    }
  }

  /// Send OTP via WhatsApp API (Dedicated Live Endpoint: /api/send-whatsapp-otp)
  static Future<OtpSendResult> sendWhatsAppOtp({required String phone}) async {
    final norm = normalizePhoneNumber(phone);

    if (norm.isEmpty || norm.length != 10) {
      return const OtpSendResult(
        success: false,
        errorMessage: 'Please enter a valid 10-digit mobile number.',
      );
    }

    final rateLimitError = checkRateLimit(phone);
    if (rateLimitError != null) {
      return OtpSendResult(
        success: false,
        errorMessage: rateLimitError,
        cooldownSeconds: getRemainingCooldownSeconds(phone),
      );
    }

    try {
      debugPrint('💬 [WhatsApp Gateway] Calling live /api/send-whatsapp-otp for: $norm');
      final response = await ApiClient.post(
        endpoint: 'https://managelogin.jobes24x7.com/api/send-whatsapp-otp',
        body: {
          'phone': norm,
          'phone_number': norm,
          'mobileNumber': norm,
        },
        timeout: const Duration(seconds: 15),
      );

      debugPrint('💬 [WhatsApp Gateway] Response HTTP ${response.statusCode}: ${response.body}');
      final dynamic decoded = jsonDecode(response.body);

      if (response.statusCode == 200 && (decoded['success'] == true || decoded['result'] == 'Success')) {
        final timeout = (decoded['data']?['timeout'] as int?) ?? defaultCooldownSeconds;
        _verificationStore[norm] = 'wa_$norm';

        final now = DateTime.now();
        _phoneLastSent[norm] = now;
        _phoneAttemptHistory.putIfAbsent(norm, () => []).add(now);

        return OtpSendResult(
          success: true,
          verificationId: 'wa_$norm',
          message: decoded['message'] ?? 'OTP sent successfully to your WhatsApp (+91 $norm)',
          cooldownSeconds: timeout,
        );
      } else {
        // Fallback to MessageCentral if needed
        debugPrint('⚠️ [WhatsApp Gateway] Primary endpoint returned non-200. Trying fallback...');
        return await _sendWhatsAppMessageCentralFallback(norm);
      }
    } catch (e) {
      debugPrint('❌ [WhatsApp Gateway] Primary failed with $e. Trying fallback...');
      return await _sendWhatsAppMessageCentralFallback(norm);
    }
  }

  /// Internal MessageCentral fallback for WhatsApp OTP
  static Future<OtpSendResult> _sendWhatsAppMessageCentralFallback(String norm) async {
    try {
      final url = Uri.parse(
        '$_cpaasBaseUrl/verification/v3/send?countryCode=91&customerId=$_cpaasCustomerId&flowType=WHATSAPP&mobileNumber=$norm',
      );

      final response = await http.post(
        url,
        headers: {
          'authToken': _cpaasAuthToken,
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 12));

      debugPrint('📱 [WhatsApp MessageCentral] Response HTTP ${response.statusCode}: ${response.body}');
      final dynamic decoded = jsonDecode(response.body);

      if (decoded is Map && decoded['responseCode'] == 200) {
        final verificationId = decoded['data']?['verificationId']?.toString() ?? '';
        final timeout = (decoded['data']?['timeout'] as int?) ?? defaultCooldownSeconds;
        _verificationStore[norm] = verificationId;

        final now = DateTime.now();
        _phoneLastSent[norm] = now;
        _phoneAttemptHistory.putIfAbsent(norm, () => []).add(now);

        return OtpSendResult(
          success: true,
          verificationId: verificationId,
          message: 'OTP sent successfully to WhatsApp (+91 $norm)',
          cooldownSeconds: timeout,
        );
      } else {
        final errMsg = (decoded is Map)
            ? (decoded['message'] ??
                decoded['data']?['errorMessage'] ??
                'WhatsApp API error (${response.statusCode})')
            : 'WhatsApp API returned HTTP ${response.statusCode}';
        return OtpSendResult(
          success: false,
          errorMessage: errMsg.toString(),
        );
      }
    } catch (e) {
      return OtpSendResult(
        success: false,
        errorMessage: 'Network error calling WhatsApp gateway: $e',
      );
    }
  }

  /// Validates OTP code received on WhatsApp (/api/verify-whatsapp-otp)
  static Future<OtpValidationResult> validateWhatsAppOtp({
    required String phone,
    required String code,
  }) async {
    final norm = normalizePhoneNumber(phone);
    final cleanCode = code.trim();

    if (cleanCode.isEmpty) {
      return const OtpValidationResult(
        isValid: false,
        errorMessage: 'Please enter the 4-digit OTP received on WhatsApp.',
      );
    }

    try {
      debugPrint('💬 [WhatsApp Gateway] Validating OTP code: $cleanCode for $norm');
      final response = await ApiClient.post(
        endpoint: 'https://managelogin.jobes24x7.com/api/verify-whatsapp-otp',
        body: {
          'phone': norm,
          'phone_number': norm,
          'otp': cleanCode,
        },
        timeout: const Duration(seconds: 15),
      );

      debugPrint('💬 [WhatsApp Gateway] Validation Response HTTP ${response.statusCode}: ${response.body}');
      final dynamic decoded = jsonDecode(response.body);

      if (response.statusCode == 200 && (decoded['success'] == true || decoded['result'] == 'Success')) {
        _verificationStore.remove(norm);
        return const OtpValidationResult(isValid: true);
      } else {
        final errMsg = decoded['message'] ?? decoded['data']?['message'] ?? 'Invalid WhatsApp OTP. Please check and try again.';
        return OtpValidationResult(
          isValid: false,
          errorMessage: errMsg.toString(),
        );
      }
    } catch (e) {
      debugPrint('❌ [WhatsApp Gateway] Validation error: $e');
      return OtpValidationResult(
        isValid: false,
        errorMessage: 'Error validating WhatsApp OTP: $e',
      );
    }
  }

  static Future<OtpValidationResult> validateOtp({
    required String verificationId,
    required String code,
    required String phone,
  }) async {
    final norm = normalizePhoneNumber(phone);
    final cleanCode = code.trim();

    if (cleanCode.isEmpty) {
      return const OtpValidationResult(
        isValid: false,
        errorMessage: 'Please enter the OTP received.',
      );
    }

    // 1. Primary validation via dedicated WhatsApp endpoint
    final waRes = await validateWhatsAppOtp(phone: norm, code: cleanCode);
    if (waRes.isValid) {
      return waRes;
    }

    // 2. Secondary fallback via MessageCentral validateOtp (if verificationId exists and not purely local)
    final effectiveVerId = verificationId.isNotEmpty
        ? verificationId
        : (_verificationStore[norm] ?? '');

    if (effectiveVerId.isNotEmpty && !effectiveVerId.startsWith('wa_')) {
      try {
        debugPrint('📱 [SMS Gateway] Validating OTP code: $cleanCode for $norm (verId: $effectiveVerId)');
        final url = Uri.parse(
          '$_cpaasBaseUrl/verification/v3/validateOtp?countryCode=91&mobileNumber=$norm&verificationId=$effectiveVerId&customerId=$_cpaasCustomerId&code=$cleanCode',
        );

        final response = await http.get(
          url,
          headers: {
            'authToken': _cpaasAuthToken,
            'Content-Type': 'application/json',
          },
        ).timeout(const Duration(seconds: 12));

        debugPrint('📱 [SMS Gateway] Validation Response HTTP ${response.statusCode}: ${response.body}');
        final dynamic decoded = jsonDecode(response.body);

        if (decoded is Map && decoded['responseCode'] == 200) {
          _verificationStore.remove(norm);
          return const OtpValidationResult(isValid: true);
        }
      } catch (e) {
        debugPrint('❌ [SMS Gateway] Error validating OTP: $e');
      }
    }

    return waRes;
  }

  /// Verify credentials (password check against database record)
  static Future<Map<String, dynamic>> verifyCredentials({
    required String loginField,
    required String loginValue,
    required String password,
  }) async {
    try {
      final payload = {
        loginField: loginValue,
        'password': password,
      };

      final response = await ApiClient.post(
        endpoint: 'https://managelogin.jobes24x7.com/api/login/authenticate',
        body: payload,
        timeout: const Duration(seconds: 12),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return {
          'isValid': true,
          'data': decoded['data'] ?? decoded,
          'message': 'Password verified successfully.',
        };
      } else {
        Map<String, dynamic> errorData = {};
        try {
          errorData = jsonDecode(response.body);
        } catch (_) {}
        final msg = errorData['data']?['message'] ??
            errorData['message'] ??
            'Incorrect password. Please enter the correct password for this account.';
        return {
          'isValid': false,
          'message': msg,
        };
      }
    } catch (e) {
      return {
        'isValid': false,
        'message': 'Unable to connect to verification server: $e',
      };
    }
  }

  /// Send Email OTP using the live /api/send-otp endpoint
  static Future<Map<String, dynamic>> sendEmailOtp(String email) async {
    final cleanEmail = email.trim().toLowerCase();
    try {
      final response = await ApiClient.post(
        endpoint: 'https://managelogin.jobes24x7.com/api/send-otp',
        body: {'email': cleanEmail},
        timeout: const Duration(seconds: 12),
      );

      final decoded = jsonDecode(response.body);
      if (response.statusCode == 200 && (decoded['success'] == true || decoded['result'] == 'Success')) {
        return {
          'success': true,
          'message': decoded['message'] ?? 'OTP sent to $cleanEmail',
        };
      } else {
        return {
          'success': false,
          'message': decoded['message'] ?? 'Failed to send Email OTP. Please try again.',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error sending Email OTP: $e',
      };
    }
  }

  /// Verify Email OTP using the live /api/verify-otp endpoint
  static Future<Map<String, dynamic>> verifyEmailOtp(String email, String otp) async {
    final cleanEmail = email.trim().toLowerCase();
    final cleanOtp = otp.trim();
    try {
      final response = await ApiClient.post(
        endpoint: 'https://managelogin.jobes24x7.com/api/verify-otp',
        body: {'email': cleanEmail, 'otp': cleanOtp},
        timeout: const Duration(seconds: 12),
      );

      final decoded = jsonDecode(response.body);
      if (response.statusCode == 200 && (decoded['success'] == true || decoded['result'] == 'Success')) {
        return {
          'success': true,
          'message': decoded['message'] ?? 'Email OTP verified successfully!',
        };
      } else {
        final errorMsg = decoded['message'] ??
            decoded['data']?['message'] ??
            'Invalid or expired OTP. Please try again.';
        return {
          'success': false,
          'message': errorMsg,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error verifying Email OTP: $e',
      };
    }
  }

  /// Register a newly verified user
  static Future<Map<String, dynamic>> registerNewUser({
    required String identifier,
    required String password,
    required bool isPhone,
  }) async {
    final cleanId = identifier.trim();
    final isPhoneNum = isPhone || RegExp(r'^\d{10}$').hasMatch(cleanId.replaceAll(RegExp(r'\D'), ''));
    final normPhone = isPhoneNum ? normalizePhoneNumber(cleanId) : '';
    final emailVal = isPhoneNum ? '$normPhone@circuitpoint.com' : cleanId.toLowerCase();

    final payload = {
      'phone_number': isPhoneNum ? normPhone : null,
      'email': emailVal,
      'password': password,
      'user_name': isPhoneNum ? 'User_$normPhone' : cleanId.split('@').first,
      'created_by': 'mobile_app',
      'user_type': 'registered',
      'status': 1,
      'is_verified': 1,
      'email_otp': !isPhoneNum,
      'mobile_otp': isPhoneNum,
    };

    try {
      final response = await ApiClient.post(
        endpoint: 'https://managelogin.jobes24x7.com/api/login/create',
        body: payload,
        timeout: const Duration(seconds: 12),
      );

      final decoded = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': decoded};
      } else {
        final msg = decoded['data']?['message'] ?? decoded['message'] ?? 'Failed to create account.';
        return {'success': false, 'message': msg};
      }
    } catch (e) {
      return {'success': false, 'message': 'Registration server error: $e'};
    }
  }
}
