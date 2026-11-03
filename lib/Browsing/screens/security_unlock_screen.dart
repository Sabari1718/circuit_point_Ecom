// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import '../services/security_service.dart';
import 'business_selection_screen.dart';

class SecurityUnlockScreen extends StatefulWidget {
  final bool initialBiometricPrompt;
  const SecurityUnlockScreen({super.key, this.initialBiometricPrompt = true});

  @override
  State<SecurityUnlockScreen> createState() => _SecurityUnlockScreenState();
}

class _SecurityUnlockScreenState extends State<SecurityUnlockScreen> {
  String _enteredPin = '';
  bool _isVerifying = false;
  bool _isBiometricAvailable = false;
  bool _isFingerprintEnabled = false;
  bool _isPinEnabled = false;
  bool _isFingerprintVerified = false;
  bool _isPinVerified = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricsAndPrompt();
  }

  Future<void> _checkBiometricsAndPrompt() async {
    final canAuth = await SecurityService.canCheckBiometrics();
    setState(() => _isBiometricAvailable = canAuth);

    try {
      final status = await SecurityService.getSecurityStatus();
      _isFingerprintEnabled = status.isFingerprintEnabled;
      _isPinEnabled = status.isPinEnabled;
    } catch (_) {}

    if (widget.initialBiometricPrompt && canAuth && _isFingerprintEnabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleBiometricAuth();
      });
    }
  }

  Future<void> _handleBiometricAuth() async {
    print('\n======================================================================');
    print('👆 [SECURITY UNLOCK] Biometric Authentication Prompted');
    print('======================================================================');

    final success = await SecurityService.promptDeviceBiometric(
      reason: 'Scan your fingerprint to unlock BrowsingApp',
    );

    if (success) {
      print('✅ [SECURITY UNLOCK] Biometric Scan Passed! Verifying with gateway...');
      try {
        await SecurityService.verifyFingerprint(success: true);
      } catch (_) {}

      _isFingerprintVerified = true;
      if (_isPinEnabled && !_isPinVerified) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fingerprint Verified (1/2) ✅ Please enter your PIN.'),
            backgroundColor: Color(0xFF10B981),
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }

      print('🎉 [SECURITY UNLOCK] Biometric Access Granted -> Proceeding to Dashboard\n');
      if (!mounted) return;
      _proceedToDashboard();
    } else {
      print('⚠️ [SECURITY UNLOCK] Biometric Scan Cancelled or Failed.\n');
    }
  }

  Future<void> _onKeyPress(String val) async {
    if (_isVerifying || _enteredPin.length >= 4) return;

    setState(() => _enteredPin += val);

    if (_enteredPin.length == 4) {
      setState(() => _isVerifying = true);
      print('\n======================================================================');
      print('🔢 [SECURITY UNLOCK] 4-Digit PIN Entered -> Verifying via Gateway API');
      print('======================================================================');
      try {
        // Verify PIN with API: POST /security/pin/verify
        final res = await SecurityService.verifyPin(pin: _enteredPin);
        if (res['status'] == 1 || res['status'] == true || res['success'] == true) {
          _isPinVerified = true;
          if (_isFingerprintEnabled && !_isFingerprintVerified) {
            if (!mounted) return;
            setState(() {
              _enteredPin = '';
              _isVerifying = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('PIN Verified (1/2) ✅ Please scan your fingerprint to unlock.'),
                backgroundColor: Color(0xFF10B981),
                duration: Duration(seconds: 3),
              ),
            );
            _handleBiometricAuth();
            return;
          }

          print('🎉 [SECURITY UNLOCK] PIN Authenticated Successfully! Access Granted -> Dashboard\n');
          if (!mounted) return;
          _proceedToDashboard();
        } else {
          throw Exception(res['message'] ?? 'Invalid PIN');
        }
      } catch (e) {
        print('❌ [SECURITY UNLOCK] PIN Verification Failed: $e\n');
        if (!mounted) return;
        setState(() {
          _enteredPin = '';
          _isVerifying = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Verification Failed: ${e.toString().replaceAll("Exception: ", "")}'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  void _onDelete() {
    if (_enteredPin.isNotEmpty && !_isVerifying) {
      setState(() => _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1));
    }
  }

  void _proceedToDashboard() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const BusinessSelectionScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.lock_rounded, color: Color(0xFF38BDF8), size: 38),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'App Security Lock',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Authenticate using PIN or Biometrics to proceed',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                  ),
                  const SizedBox(height: 32),

                  // PIN indicator dots
                  if (_isVerifying) ...[
                    const SizedBox(
                      height: 32,
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFF38BDF8)),
                      ),
                    ),
                  ] else ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(4, (index) {
                        final isFilled = index < _enteredPin.length;
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isFilled ? const Color(0xFF38BDF8) : Colors.transparent,
                            border: Border.all(
                              color: isFilled ? const Color(0xFF38BDF8) : const Color(0xFF475569),
                              width: 2,
                            ),
                          ),
                        );
                      }),
                    ),
                  ],

                  const SizedBox(height: 36),

                  // Numeric Keypad
                  Column(
                    children: [
                      for (var row in [
                        ['1', '2', '3'],
                        ['4', '5', '6'],
                        ['7', '8', '9'],
                        ['bio', '0', 'del'],
                      ])
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: row.map((val) {
                              if (val == 'del') {
                                return InkWell(
                                  onTap: _onDelete,
                                  borderRadius: BorderRadius.circular(36),
                                  child: Container(
                                    width: 68,
                                    height: 68,
                                    alignment: Alignment.center,
                                    child: const Icon(Icons.backspace_outlined, color: Colors.white70, size: 22),
                                  ),
                                );
                              } else if (val == 'bio') {
                                return InkWell(
                                  onTap: _isBiometricAvailable ? _handleBiometricAuth : null,
                                  borderRadius: BorderRadius.circular(36),
                                  child: Container(
                                    width: 68,
                                    height: 68,
                                    alignment: Alignment.center,
                                    child: Icon(
                                      Icons.fingerprint_rounded,
                                      color: _isBiometricAvailable ? const Color(0xFF38BDF8) : const Color(0xFF334155),
                                      size: 30,
                                    ),
                                  ),
                                );
                              }
                              return InkWell(
                                onTap: () => _onKeyPress(val),
                                borderRadius: BorderRadius.circular(36),
                                child: Container(
                                  width: 68,
                                  height: 68,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0F172A),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    val,
                                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
