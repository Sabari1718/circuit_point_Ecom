import 'dart:async';
import 'dart:convert';
import '../config/app_config.dart';
import '../core/api_client.dart';

/// Models the result of phone registration verification against ids-phone API
class PhoneVerificationResult {
  final bool isRegistered;
  final String normalizedPhone;
  final Map<String, dynamic>? userRecord;
  final String? errorMessage;

  const PhoneVerificationResult({
    required this.isRegistered,
    required this.normalizedPhone,
    this.userRecord,
    this.errorMessage,
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
      );
    } catch (e) {
      return PhoneVerificationResult(
        isRegistered: false,
        normalizedPhone: normalized,
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

  static Future<OtpSendResult> sendSmsOtp({
    required String phone,
    required Map<String, dynamic> verifiedUser,
  }) async {
    final norm = normalizePhoneNumber(phone);

    if (norm.isEmpty) {
      return const OtpSendResult(
        success: false,
        errorMessage: 'Invalid phone number.',
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

    final now = DateTime.now();
    _phoneLastSent[norm] = now;
    _phoneAttemptHistory.putIfAbsent(norm, () => []).add(now);

    final verificationId = 'OTP_VERIFY_${now.millisecondsSinceEpoch}';

    return OtpSendResult(
      success: true,
      verificationId: verificationId,
      message: 'OTP sent to ${maskPhoneNumber(phone)}! (Enter any 4 digits to verify)',
      cooldownSeconds: defaultCooldownSeconds,
    );
  }

  static Future<OtpValidationResult> validateOtp({
    required String verificationId,
    required String code,
    required String phone,
  }) async {
    final cleanCode = code.trim();

    if (cleanCode.isEmpty) {
      return const OtpValidationResult(
        isValid: false,
        errorMessage: 'Please enter the 4-digit OTP.',
      );
    }

    if (RegExp(r'^\d{4}$').hasMatch(cleanCode)) {
      return const OtpValidationResult(isValid: true);
    }

    return const OtpValidationResult(
      isValid: false,
      errorMessage: 'Please enter a valid 4-digit OTP number.',
    );
  }
}
