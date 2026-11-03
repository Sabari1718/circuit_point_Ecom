// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../core/api_client.dart';
import '../services/auth_service.dart';
import '../services/security_service.dart';
import 'business_selection_screen.dart';
import 'login_screen.dart';

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  bool _isLoading = true;
  String? _errorMessage;

  // Profile data
  String _userId = '';
  String _userEmail = '';
  String _userName = '';
  String _userPhone = '';
  String _deviceModel = '';
  String _publicIp = '';
  String _appId = '';
  String _selectedBusinessId = '';
  String _selectedBusinessName = '';

  // Security Lock states from Live API
  bool _isFingerprintEnabled = false;
  bool _isPinEnabled = false;
  bool _hasPin = false;

  bool _isTogglingFingerprint = false;
  bool _isTogglingPin = false;

  @override
  void initState() {
    super.initState();
    _loadAllSettings();
  }

  Future<void> _loadAllSettings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      _userId = prefs.getString(ApiClient.keyUserMainId) ?? await SecurityService.getStoredUserId();
      _userEmail = prefs.getString(ApiClient.keyUserEmail) ?? '';
      _userName = prefs.getString(ApiClient.keyUserName) ?? (_userEmail.contains('@') ? _userEmail.split('@').first : '');
      _userPhone = prefs.getString(ApiClient.keyUserPhone) ?? '';
      _appId = prefs.getString(ApiClient.keyAppId) ?? AppConfig.appId;
      _selectedBusinessId = prefs.getString(ApiClient.keySelectedBusinessId) ?? '';
      _selectedBusinessName = prefs.getString(ApiClient.keySelectedBusinessName) ?? '';

      // Real Device Info
      try {
        final deviceInfo = DeviceInfoPlugin();
        if (Platform.isAndroid) {
          final androidInfo = await deviceInfo.androidInfo;
          _deviceModel = '${androidInfo.brand.toUpperCase()} ${androidInfo.model}'.trim();
        } else if (Platform.isIOS) {
          final iosInfo = await deviceInfo.iosInfo;
          _deviceModel = '${iosInfo.name} ${iosInfo.model}'.trim();
        } else if (Platform.isWindows) {
          final winInfo = await deviceInfo.windowsInfo;
          _deviceModel = 'Windows PC (${winInfo.computerName})';
        }
      } catch (e) {
        print('⚠️ [AppSettingsScreen] Device info note: $e');
      }

      // Real Public IP
      try {
        final ipRes = await ApiClient.get(
          endpoint: 'https://api.ipify.org?format=json',
          timeout: const Duration(seconds: 4),
        );
        if (ipRes.statusCode == 200) {
          final ipData = jsonDecode(ipRes.body);
          _publicIp = ipData['ip']?.toString().trim() ?? '';
        }
      } catch (_) {
        try {
          final ipRes2 = await ApiClient.get(
            endpoint: 'https://icanhazip.com',
            timeout: const Duration(seconds: 4),
          );
          if (ipRes2.statusCode == 200) {
            _publicIp = ipRes2.body.trim();
          }
        } catch (_) {}
      }

      // Fetch live locks status from API
      final status = await SecurityService.getSecurityStatus(_userId);
      if (mounted) {
        setState(() {
          _isFingerprintEnabled = status.isFingerprintEnabled;
          _isPinEnabled = status.isPinEnabled;
          _hasPin = status.hasPin;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  Future<void> _handleToggleFingerprint(bool value) async {
    if (value) {
      final canAuth = await SecurityService.canCheckBiometrics();
      if (canAuth) {
        final firstScan = await SecurityService.promptDeviceBiometric(
          reason: 'Scan your fingerprint to enable Biometric Lock',
        );
        if (!firstScan) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Biometric verification cancelled.'),
                backgroundColor: Color(0xFFEF4444),
              ),
            );
          }
          return;
        }
      }
    }

    if (!mounted) return;
    setState(() => _isTogglingFingerprint = true);
    final messenger = ScaffoldMessenger.of(context);

    try {
      final res = await SecurityService.toggleFingerprint(
        enabled: value,
        explicitUserId: _userId,
      );

      if (mounted) {
        setState(() {
          _isFingerprintEnabled = value;
          _isTogglingFingerprint = false;
        });
        messenger.showSnackBar(
          SnackBar(
            content: Text(res['message'] ?? 'Fingerprint Lock ${value ? "Enabled" : "Disabled"}'),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isTogglingFingerprint = false);
        messenger.showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceAll("Exception: ", "")}'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  Future<void> _handleTogglePin(bool value) async {
    if (value && !_hasPin) {
      await _showSetPinDialog(isFirstTime: true);
      return;
    }

    setState(() => _isTogglingPin = true);
    final messenger = ScaffoldMessenger.of(context);

    try {
      final res = await SecurityService.togglePin(
        enabled: value,
        explicitUserId: _userId,
      );

      if (mounted) {
        setState(() {
          _isPinEnabled = value;
          _isTogglingPin = false;
        });
        messenger.showSnackBar(
          SnackBar(
            content: Text(res['message'] ?? 'PIN Lock ${value ? "Enabled" : "Disabled"}'),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isTogglingPin = false);
        messenger.showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceAll("Exception: ", "")}'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  Future<void> _showSetPinDialog({bool isFirstTime = false}) async {
    final pinController = TextEditingController();
    final confirmController = TextEditingController();
    bool obscurePin = true;
    bool obscureConfirm = true;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF0F172A),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.password_rounded, color: Color(0xFF38BDF8), size: 22),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isFirstTime ? 'Set 4-Digit Security PIN' : 'Change Security PIN',
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Enter a 4-digit PIN and confirm it to protect the application.',
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'NEW 4-DIGIT PIN',
                    style: TextStyle(color: Color(0xFF38BDF8), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF334155)),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      children: [
                        const Icon(Icons.lock_outline_rounded, color: Color(0xFF64748B), size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: pinController,
                            keyboardType: TextInputType.number,
                            maxLength: 4,
                            obscureText: obscurePin,
                            style: const TextStyle(color: Colors.white, letterSpacing: 8, fontSize: 18, fontWeight: FontWeight.bold),
                            decoration: const InputDecoration(
                              hintText: '• • • •',
                              hintStyle: TextStyle(color: Color(0xFF475569), letterSpacing: 8, fontSize: 18),
                              counterText: '',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            obscurePin ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: const Color(0xFF64748B),
                            size: 20,
                          ),
                          onPressed: () => setDialogState(() => obscurePin = !obscurePin),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'CONFIRM 4-DIGIT PIN',
                    style: TextStyle(color: Color(0xFF38BDF8), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF334155)),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF64748B), size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: confirmController,
                            keyboardType: TextInputType.number,
                            maxLength: 4,
                            obscureText: obscureConfirm,
                            style: const TextStyle(color: Colors.white, letterSpacing: 8, fontSize: 18, fontWeight: FontWeight.bold),
                            decoration: const InputDecoration(
                              hintText: '• • • •',
                              hintStyle: TextStyle(color: Color(0xFF475569), letterSpacing: 8, fontSize: 18),
                              counterText: '',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: const Color(0xFF64748B),
                            size: 20,
                          ),
                          onPressed: () => setDialogState(() => obscureConfirm = !obscureConfirm),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel', style: TextStyle(color: Color(0xFF94A3B8))),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF38BDF8),
                  foregroundColor: const Color(0xFF090D16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () async {
                  final pin = pinController.text.trim();
                  final confirm = confirmController.text.trim();

                  if (pin.length != 4 || int.tryParse(pin) == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('PIN must be exactly 4 numeric digits.'), backgroundColor: Color(0xFFEF4444)),
                    );
                    return;
                  }
                  if (pin != confirm) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('PIN and Confirm PIN do not match!'), backgroundColor: Color(0xFFEF4444)),
                    );
                    return;
                  }

                  final messenger = ScaffoldMessenger.of(context);
                  Navigator.of(ctx).pop();
                  setState(() => _isTogglingPin = true);

                  try {
                    await SecurityService.setPin(pin: pin, explicitUserId: _userId);
                    await SecurityService.togglePin(enabled: true, explicitUserId: _userId);

                    if (mounted) {
                      setState(() {
                        _hasPin = true;
                        _isPinEnabled = true;
                        _isTogglingPin = false;
                      });
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('PIN saved and enabled successfully!'),
                          backgroundColor: Color(0xFF10B981),
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      setState(() => _isTogglingPin = false);
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text('Failed to set PIN: ${e.toString().replaceAll("Exception: ", "")}'),
                          backgroundColor: const Color(0xFFEF4444),
                        ),
                      );
                    }
                  }
                },
                child: const Text('Save PIN', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout Session', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
        content: const Text(
          'Are you sure you want to log out? You will need your credentials to log in again.',
          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF94A3B8))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), foregroundColor: Colors.white),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AuthService.logout();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen(appId: '')),
        (route) => false,
      );
    }
  }

  void _copyToClipboard(String label, String value) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard'),
        backgroundColor: const Color(0xFF6366F1),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Settings & Security',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white),
            ),
            Text(
              'Profile • Locks • App Version',
              style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF38BDF8)),
            onPressed: _loadAllSettings,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF38BDF8)))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(_errorMessage!, style: const TextStyle(color: Color(0xFFFCA5A5), fontSize: 12)),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // ---------------------------------------------------
                      // SECTION 1: PROFILE
                      // ---------------------------------------------------
                      _buildSectionHeader(title: 'USER PROFILE', icon: Icons.person_outline_rounded, color: const Color(0xFF6366F1)),
                      const SizedBox(height: 10),
                      _buildCard(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF6366F1), Color(0xFF38BDF8)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Center(
                                  child: Text(
                                    (_userName.isNotEmpty ? _userName[0] : (_userEmail.isNotEmpty ? _userEmail[0] : '#')).toUpperCase(),
                                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _userName.isNotEmpty ? _userName : (_userEmail.isNotEmpty ? _userEmail : _userId),
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                    if (_userEmail.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        _userEmail,
                                        style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Divider(color: Color(0xFF1E293B), height: 26),
                          _buildDetailRow(
                            label: 'User Main ID',
                            value: _userId,
                            icon: Icons.badge_outlined,
                            onCopy: () => _copyToClipboard('User ID', _userId),
                          ),
                          if (_userPhone.isNotEmpty)
                            _buildDetailRow(
                              label: 'Phone / SIM',
                              value: _userPhone,
                              icon: Icons.phone_outlined,
                              onCopy: () => _copyToClipboard('Phone', _userPhone),
                            ),
                          if (_deviceModel.isNotEmpty)
                            _buildDetailRow(
                              label: 'Device Hardware',
                              value: _deviceModel,
                              icon: Icons.phone_android_rounded,
                            ),
                          if (_publicIp.isNotEmpty)
                            _buildDetailRow(
                              label: 'Public IP',
                              value: _publicIp,
                              icon: Icons.wifi_rounded,
                            ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // ---------------------------------------------------
                      // SECTION: ACTIVE BUSINESS PROFILE
                      // ---------------------------------------------------
                      _buildSectionHeader(
                        title: 'ACTIVE BUSINESS PROFILE',
                        icon: Icons.business_center_outlined,
                        color: const Color(0xFF0D9488),
                      ),
                      const SizedBox(height: 10),
                      _buildCard(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F3836),
                                  borderRadius: BorderRadius.circular(14),
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF0F3836), Color(0xFF064E3B)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: const Center(
                                  child: Icon(Icons.business_center_outlined, color: Colors.white, size: 24),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _selectedBusinessName.isNotEmpty
                                          ? _selectedBusinessName
                                          : 'No Business Selected',
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      _selectedBusinessId.isNotEmpty
                                          ? 'Business ID: #$_selectedBusinessId'
                                          : 'Tap below to select an active business profile',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: _selectedBusinessId.isNotEmpty
                                            ? const Color(0xFF0D9488)
                                            : const Color(0xFF94A3B8),
                                        fontWeight: _selectedBusinessId.isNotEmpty ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                final changed = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const BusinessSelectionScreen(isSwitching: true),
                                  ),
                                );
                                if (changed == true) {
                                  _loadAllSettings();
                                }
                              },
                              icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                              label: Text(_selectedBusinessId.isNotEmpty ? 'Change Business Profile' : 'Select Business Profile'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF0D9488),
                                side: const BorderSide(color: Color(0xFF0D9488), width: 1.2),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // ---------------------------------------------------
                      // SECTION 2: SECURITY LOCKS
                      // ---------------------------------------------------
                      _buildSectionHeader(title: 'SECURITY LOCKS', icon: Icons.lock_outline_rounded, color: const Color(0xFF10B981)),
                      const SizedBox(height: 10),
                      _buildCard(
                        children: [
                          // Fingerprint Lock Row
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF38BDF8).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.fingerprint_rounded, color: Color(0xFF38BDF8), size: 24),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Fingerprint Lock',
                                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _isFingerprintEnabled ? 'Enabled • Biometric scan required' : 'Disabled • Toggle to activate',
                                      style: TextStyle(fontSize: 12, color: _isFingerprintEnabled ? const Color(0xFF10B981) : const Color(0xFF64748B)),
                                    ),
                                  ],
                                ),
                              ),
                              if (_isTogglingFingerprint)
                                const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF38BDF8)))
                              else
                                Switch.adaptive(
                                  value: _isFingerprintEnabled,
                                  activeTrackColor: const Color(0xFF38BDF8),
                                  onChanged: _handleToggleFingerprint,
                                ),
                            ],
                          ),

                          const Divider(color: Color(0xFF1E293B), height: 26),

                          // PIN Code Lock Row
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF818CF8).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.pin_outlined, color: Color(0xFF818CF8), size: 24),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      '4-Digit PIN Code Lock',
                                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _isPinEnabled ? 'Enabled • PIN required on unlock' : (_hasPin ? 'Disabled • Configured' : 'Not configured'),
                                      style: TextStyle(fontSize: 12, color: _isPinEnabled ? const Color(0xFF10B981) : const Color(0xFF64748B)),
                                    ),
                                  ],
                                ),
                              ),
                              if (_isTogglingPin)
                                const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF818CF8)))
                              else
                                Switch.adaptive(
                                  value: _isPinEnabled,
                                  activeTrackColor: const Color(0xFF818CF8),
                                  onChanged: _handleTogglePin,
                                ),
                            ],
                          ),

                          const SizedBox(height: 12),
                          // Change / Setup PIN button
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () => _showSetPinDialog(isFirstTime: !_hasPin),
                              icon: const Icon(Icons.key_rounded, size: 16),
                              label: Text(_hasPin ? 'Change 4-Digit PIN' : 'Set Up New PIN'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF38BDF8),
                                side: const BorderSide(color: Color(0xFF38BDF8), width: 1.2),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // ---------------------------------------------------
                      // SECTION 3: APP & VERSION INFO
                      // ---------------------------------------------------
                      _buildSectionHeader(title: 'VERSION & IDENTITY', icon: Icons.info_outline_rounded, color: const Color(0xFF38BDF8)),
                      const SizedBox(height: 10),
                      _buildCard(
                        children: [
                          _buildDetailRow(
                            label: 'Application ID',
                            value: _appId,
                            icon: Icons.fingerprint_rounded,
                            onCopy: () => _copyToClipboard('App ID', _appId),
                          ),
                          _buildDetailRow(
                            label: 'Application Name',
                            value: AppConfig.appName,
                            icon: Icons.apps_rounded,
                          ),
                          _buildDetailRow(
                            label: 'App Version',
                            value: AppConfig.appVersion,
                            icon: Icons.code_rounded,
                          ),
                          _buildDetailRow(
                            label: 'Software Version',
                            value: AppConfig.softwareVersion,
                            icon: Icons.system_update_rounded,
                          ),
                          const Divider(color: Color(0xFF1E293B), height: 20),
                          Row(
                            children: const [
                              Icon(Icons.verified_rounded, color: Color(0xFF10B981), size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Gateway Status: Verified & Connected',
                                style: TextStyle(fontSize: 12, color: Color(0xFF10B981), fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // ---------------------------------------------------
                      // SECTION 4: LOGOUT BUTTON
                      // ---------------------------------------------------
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: _handleLogout,
                          icon: const Icon(Icons.logout_rounded, size: 18),
                          label: const Text('Log Out Session', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEF4444).withValues(alpha: 0.15),
                            foregroundColor: const Color(0xFFEF4444),
                            elevation: 0,
                            side: const BorderSide(color: Color(0xFFEF4444), width: 1.2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildSectionHeader({required String title, required IconData icon, required Color color}) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: color,
            letterSpacing: 1.1,
          ),
        ),
      ],
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    required IconData icon,
    VoidCallback? onCopy,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF64748B)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                const SizedBox(height: 2),
                Text(
                  value.isNotEmpty ? value : 'N/A',
                  style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (onCopy != null)
            IconButton(
              icon: const Icon(Icons.copy_rounded, size: 16, color: Color(0xFF38BDF8)),
              tooltip: 'Copy',
              onPressed: onCopy,
            ),
        ],
      ),
    );
  }
}
