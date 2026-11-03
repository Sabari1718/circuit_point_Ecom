// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/asset_constants.dart';
import '../core/api_client.dart';
import '../config/app_config.dart';
import '../navigation/dashboard_router.dart';
import '../services/auth_service.dart';
import '../services/security_service.dart';
import 'login_screen.dart';

class SecurityUnlockScreen extends StatefulWidget {
  final bool initialBiometricPrompt;
  const SecurityUnlockScreen({super.key, this.initialBiometricPrompt = true});

  @override
  State<SecurityUnlockScreen> createState() => _SecurityUnlockScreenState();
}

class _SecurityUnlockScreenState extends State<SecurityUnlockScreen>
    with SingleTickerProviderStateMixin {
  bool _isAuthenticating = false;
  String _userName = 'Valued Customer';
  String _userEmail = '';
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _loadUserData();

    if (widget.initialBiometricPrompt) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _triggerDeviceUnlock();
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(ApiClient.keyUserName);
    final email = prefs.getString(ApiClient.keyUserEmail);
    if (mounted) {
      setState(() {
        if (name != null && name.isNotEmpty) _userName = name;
        if (email != null && email.isNotEmpty) _userEmail = email;
      });
    }
  }

  Future<void> _triggerDeviceUnlock() async {
    if (_isAuthenticating) return;
    setState(() => _isAuthenticating = true);

    print('\n======================================================================');
    print('🔐 [SECURITY UNLOCK] Prompting Phone Lock / Biometric for Circuit Point Ecom');
    print('======================================================================');

    final bool success = await SecurityService.authenticateWithDeviceLock(
      reason: 'Scan your fingerprint or enter your phone lock PIN to unlock Circuit Point Ecom',
    );

    if (!mounted) return;
    setState(() => _isAuthenticating = false);

    if (success) {
      print('🎉 [SECURITY UNLOCK] Verified! Proceeding to Circuit Point Ecom Store...\n');
      DashboardRouter.navigateToDashboard(context, clearStack: true);
    } else {
      print('⚠️ [SECURITY UNLOCK] Authentication cancelled or failed.\n');
    }
  }

  Future<void> _handleSwitchAccount() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => LoginScreen(appId: AppConfig.appId)),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Circuit Point Logo with pulse glow
                  ScaleTransition(
                    scale: _pulseAnimation,
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE94560).withValues(alpha: 0.25),
                            blurRadius: 28,
                            spreadRadius: 4,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Image.asset(
                        AssetConstants.logo,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.memory_rounded,
                          size: 56,
                          color: Color(0xFFE94560),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Brand Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'CIRCUIT ',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        'POINT',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                          color: Color(0xFFE94560),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Electronics & Components Store',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),

                  const SizedBox(height: 36),

                  // User greeting card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE94560).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.fingerprint_rounded,
                            size: 34,
                            color: Color(0xFFE94560),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Welcome back, $_userName!',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        if (_userEmail.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            _userEmail,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        const Text(
                          'Scan your fingerprint or enter your phone lock PIN to unlock your store.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF475569),
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Primary Unlock Button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: _isAuthenticating ? null : _triggerDeviceUnlock,
                            icon: _isAuthenticating
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.lock_open_rounded, size: 22),
                            label: Text(
                              _isAuthenticating ? 'Authenticating...' : 'Unlock with Fingerprint / PIN',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE94560),
                              foregroundColor: Colors.white,
                              elevation: 3,
                              shadowColor: const Color(0xFFE94560).withValues(alpha: 0.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Switch account / Sign out button
                  TextButton.icon(
                    onPressed: _handleSwitchAccount,
                    icon: const Icon(Icons.logout_rounded, size: 16, color: Color(0xFF64748B)),
                    label: const Text(
                      'Log In with Another Account',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
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
