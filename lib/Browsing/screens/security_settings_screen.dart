// ignore_for_file: avoid_print
import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/security_service.dart';

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  String _userId = '';
  bool _isLoading = true;
  String? _errorMessage;

  // Toggle States from Live API
  bool _isFingerprintEnabled = false;
  bool _isPinEnabled = false;
  bool _hasPin = false;

  // Action Loading States
  bool _isTogglingFingerprint = false;
  bool _isTogglingPin = false;

  @override
  void initState() {
    super.initState();
    _loadSecuritySettings();
  }

  void _logTerminalLockEvent({
    required String lockName,
    required String endpoint,
    required String action,
    required Map<String, dynamic> requestPayload,
    required int statusCode,
    required dynamic responseData,
  }) {
    final timeStr = DateTime.now().toIso8601String().substring(11, 19);
    print('\n======================================================================');
    print('🌐 [LOCK API EVENT] $endpoint  [$timeStr]');
    print('----------------------------------------------------------------------');
    print('🔒 Lock Type : $lockName');
    print('⚡ Action    : $action');
    print('👤 User ID   : $_userId');
    print('📤 Request   : ${jsonEncode(requestPayload)}');
    print('📊 Status    : $statusCode OK');
    print('📥 Response  : ${responseData is String ? responseData : jsonEncode(responseData)}');
    print('======================================================================\n');
  }

  Future<void> _loadSecuritySettings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userId = await SecurityService.getStoredUserId();
      _userId = userId;

      // 1. Fetch real status from API: GET /security/status?userId={userId}
      final status = await SecurityService.getSecurityStatus(userId);

      if (mounted) {
        setState(() {
          _isFingerprintEnabled = status.isFingerprintEnabled;
          _isPinEnabled = status.isPinEnabled;
          _hasPin = status.hasPin;
          _isLoading = false;
        });

        print('\n======================================================================');
        print('📋 [SECURITY SETTINGS LOADED] Live Status from Gateway API');
        print('----------------------------------------------------------------------');
        print('👤 User ID          : $_userId');
        print('👆 Fingerprint Lock : ${_isFingerprintEnabled ? "✅ ENABLED (ON)" : "❌ DISABLED (OFF)"}');
        print('🔢 PIN Code Lock    : ${_isPinEnabled ? "✅ ENABLED (ON)" : "❌ DISABLED (OFF)"} (Configured: $_hasPin)');
        print('======================================================================\n');
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
      // 1. Step 1: Scan New Fingerprint
      print('\n======================================================================');
      print('👆 [FINGERPRINT LOCK] Step 1 of 2: Scan your new fingerprint to register');
      print('======================================================================');
      final firstScan = await SecurityService.promptDeviceBiometric(
        reason: 'Step 1 of 2: Scan your fingerprint to set up Biometric Lock',
      );
      if (!firstScan) {
        print('\n======================================================================');
        print('⚠️ [FINGERPRINT LOCK] Step 1: Fingerprint scan was cancelled or unavailable.');
        print('======================================================================\n');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Fingerprint scan cancelled or unavailable.'),
              backgroundColor: Color(0xFFEF4444),
            ),
          );
        }
        return;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Expanded(child: Text('Step 1 verified! Now scan the same fingerprint again to confirm.')),
              ],
            ),
            backgroundColor: Color(0xFF0284C7),
            duration: Duration(seconds: 2),
          ),
        );
      }

      await Future.delayed(const Duration(milliseconds: 600));

      // 2. Step 2: Confirm Fingerprint Scan
      print('\n======================================================================');
      print('👆 [FINGERPRINT LOCK] Step 2 of 2: Scan the same fingerprint again to CONFIRM');
      print('======================================================================');
      final confirmScan = await SecurityService.promptDeviceBiometric(
        reason: 'Step 2 of 2: Scan your fingerprint again to confirm',
      );
      if (!confirmScan) {
        print('\n======================================================================');
        print('⚠️ [FINGERPRINT LOCK] Step 2: Fingerprint confirmation scan was cancelled.');
        print('======================================================================\n');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Fingerprint confirmation cancelled or did not match.'),
              backgroundColor: Color(0xFFEF4444),
            ),
          );
        }
        return;
      }

      // Both scans verified! Directly enable Fingerprint on Gateway API without asking for PIN
      setState(() => _isTogglingFingerprint = true);
      try {
        final res = await SecurityService.toggleFingerprint(
          enabled: true,
          explicitUserId: _userId,
        );

        _logTerminalLockEvent(
          lockName: 'Fingerprint / Biometric Lock',
          endpoint: 'POST /api/security/fingerprint',
          action: '✅ ENABLED (ON) - New & Confirmed Fingerprint Verified',
          requestPayload: {'userId': _userId, 'enabled': true},
          statusCode: 200,
          responseData: res,
        );

        if (mounted) {
          setState(() {
            _isFingerprintEnabled = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(res['message'] ?? 'Fingerprint security enabled successfully!'),
              backgroundColor: const Color(0xFF10B981),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error enabling fingerprint: ${e.toString().replaceAll("Exception: ", "")}'),
              backgroundColor: const Color(0xFFEF4444),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isTogglingFingerprint = false);
        }
      }
      return;
    }

    // Disabling Fingerprint
    setState(() => _isTogglingFingerprint = true);
    try {
      final res = await SecurityService.toggleFingerprint(
        enabled: false,
        explicitUserId: _userId,
      );

      _logTerminalLockEvent(
        lockName: 'Fingerprint / Biometric Lock',
        endpoint: 'POST /api/security/fingerprint',
        action: '❌ DISABLED (OFF)',
        requestPayload: {'userId': _userId, 'enabled': false},
        statusCode: 200,
        responseData: res,
      );

      if (mounted) {
        setState(() {
          _isFingerprintEnabled = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['message'] ?? 'Fingerprint security Disabled'),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceAll("Exception: ", "")}'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isTogglingFingerprint = false);
      }
    }
  }

  Future<void> _handleTogglePin(bool value) async {
    if (value) {
      // Always prompt user to enter New Password/PIN and Confirm Password/PIN when enabling
      await _showSetPinDialog(
        titleText: 'Set 4-Digit Security PIN',
      );
      return;
    }

    // Disabling PIN
    setState(() => _isTogglingPin = true);
    try {
      // Call API: POST /security/pin/toggle
      final res = await SecurityService.togglePin(
        enabled: false,
        explicitUserId: _userId,
      );

      _logTerminalLockEvent(
        lockName: '4-Digit PIN Code Protection',
        endpoint: 'POST /api/security/pin/toggle',
        action: '❌ DISABLED (OFF)',
        requestPayload: {'userId': _userId, 'enabled': false},
        statusCode: 200,
        responseData: res,
      );

      if (mounted) {
        setState(() {
          _isPinEnabled = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['message'] ?? 'PIN security Disabled'),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceAll("Exception: ", "")}'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isTogglingPin = false);
      }
    }
  }

  Future<void> _showSetPinDialog({
    String titleText = 'Set 4-Digit Security PIN',
  }) async {
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
                  child: const Icon(
                    Icons.password_rounded,
                    color: Color(0xFF38BDF8),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    titleText,
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
                    'Enter a new 4-digit PIN and confirm it to protect BrowsingApp.',
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                  ),
                  const SizedBox(height: 20),

                  // Field 1: New PIN
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

                  // Field 2: Confirm PIN
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
                        const Icon(Icons.lock_rounded, color: Color(0xFF64748B), size: 20),
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
                onPressed: () {
                  Navigator.of(ctx).pop();
                  print('\n======================================================================');
                  print('ℹ️ [LOCK SETUP] User cancelled PIN dialog.');
                  print('======================================================================\n');
                },
                child: const Text('Cancel', style: TextStyle(color: Color(0xFF94A3B8))),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF38BDF8),
                  foregroundColor: const Color(0xFF090D16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                onPressed: () async {
                  final pin = pinController.text.trim();
                  final confirm = confirmController.text.trim();

                  if (pin.length != 4 || int.tryParse(pin) == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('PIN must be exactly 4 numeric digits.'),
                        backgroundColor: Color(0xFFEF4444),
                      ),
                    );
                    return;
                  }
                  if (pin != confirm) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('New PIN and Confirm PIN do not match!'),
                        backgroundColor: Color(0xFFEF4444),
                      ),
                    );
                    return;
                  }

                  final messenger = ScaffoldMessenger.of(context);
                  Navigator.of(ctx).pop();

                  setState(() => _isTogglingPin = true);

                  try {
                    // 1. Set PIN on Live API: POST /security/pin/set
                    final pinRes = await SecurityService.setPin(pin: pin, explicitUserId: _userId);

                    _logTerminalLockEvent(
                      lockName: '4-Digit PIN Code',
                      endpoint: 'POST /api/security/pin/set',
                      action: '🔑 NEW PIN SAVED & CONFIGURED',
                      requestPayload: {'userId': _userId, 'pin': pin},
                      statusCode: 200,
                      responseData: pinRes,
                    );

                    // 2. Enable PIN on Live API: POST /security/pin/toggle
                    final toggleRes = await SecurityService.togglePin(
                      enabled: true,
                      explicitUserId: _userId,
                    );

                    _logTerminalLockEvent(
                      lockName: '4-Digit PIN Code Protection',
                      endpoint: 'POST /api/security/pin/toggle',
                      action: '✅ ENABLED (ON)',
                      requestPayload: {'userId': _userId, 'enabled': true},
                      statusCode: 200,
                      responseData: toggleRes,
                    );

                    if (mounted) {
                      setState(() {
                        _hasPin = true;
                        _isPinEnabled = true;
                      });
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(toggleRes['message'] ?? 'PIN configured and enabled successfully!'),
                          backgroundColor: const Color(0xFF10B981),
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text('Error: ${e.toString().replaceAll("Exception: ", "")}'),
                          backgroundColor: const Color(0xFFEF4444),
                        ),
                      );
                    }
                  } finally {
                    if (mounted) {
                      setState(() => _isTogglingPin = false);
                    }
                  }
                },
                child: const Text('Save & Enable', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
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
        title: const Text(
          'Security Settings',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF38BDF8)),
            tooltip: 'Refresh Status',
            onPressed: _loadSecuritySettings,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF38BDF8)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Zero-Trust status card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.shield_outlined, color: Color(0xFF38BDF8), size: 28),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Zero-Trust Security Core',
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'User ID: $_userId • Sync with Live Gateway',
                                    style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (_errorMessage != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(_errorMessage!, style: const TextStyle(color: Color(0xFFFCA5A5), fontSize: 12)),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Locks Section (Only Fingerprint & PIN)
                      const Text(
                        'APP LOCK & AUTHENTICATION',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF38BDF8), letterSpacing: 1),
                      ),
                      const SizedBox(height: 10),

                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                        ),
                        child: Column(
                          children: [
                            SwitchListTile(
                              value: _isFingerprintEnabled,
                              activeThumbColor: const Color(0xFF38BDF8),
                              title: const Text('Fingerprint / Biometric', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                              subtitle: const Text('Live API Toggle • 2-Step Biometric verification (New & Confirm)', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                              secondary: _isTogglingFingerprint
                                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF38BDF8)))
                                  : const Icon(Icons.fingerprint_rounded, color: Color(0xFF38BDF8)),
                              onChanged: _isTogglingFingerprint ? null : _handleToggleFingerprint,
                            ),
                            const Divider(color: Color(0xFF1E293B), height: 1),
                            SwitchListTile(
                              value: _isPinEnabled,
                              activeThumbColor: const Color(0xFF38BDF8),
                              title: const Text('PIN Code Protection', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                              subtitle: Text(
                                _hasPin ? 'Live API Toggle • 4-digit security code active' : 'Live API • Enter New PIN & Confirm to enable',
                                style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                              ),
                              secondary: _isTogglingPin
                                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF818CF8)))
                                  : const Icon(Icons.pin_rounded, color: Color(0xFF818CF8)),
                              onChanged: _isTogglingPin ? null : _handleTogglePin,
                            ),
                            if (_hasPin || _isPinEnabled) ...[
                              const Divider(color: Color(0xFF1E293B), height: 1),
                              ListTile(
                                dense: true,
                                leading: const Icon(Icons.edit_rounded, color: Color(0xFF38BDF8), size: 18),
                                title: const Text(
                                  'Change PIN / Password',
                                  style: TextStyle(color: Color(0xFF38BDF8), fontSize: 13, fontWeight: FontWeight.w600),
                                ),
                                trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF64748B), size: 20),
                                onTap: () => _showSetPinDialog(
                                  titleText: 'Change 4-Digit Security PIN',
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
