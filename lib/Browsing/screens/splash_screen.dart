import 'package:flutter/material.dart';

import '../../../core/constants/asset_constants.dart';
import '../config/app_config.dart';
import '../services/app_validation_service.dart';
import '../services/auth_service.dart';
import '../navigation/dashboard_router.dart';
import 'login_screen.dart';
import 'security_unlock_screen.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  String _statusMessage = 'Initializing Circuit Point Store...';
  bool _isChecking = true;
  bool _isUpdateRequired = false;
  String _updateMessage = '';
  String _currentVersion = '';
  String _latestVersion = '';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _animController.forward();
    _validateAndInitApp();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _validateAndInitApp() async {
    setState(() {
      _isChecking = true;
      _isUpdateRequired = false;
      _errorMessage = null;
      _statusMessage = 'Verifying Application Identity...';
    });

    try {
      final appId = await AppValidationService.getOrRegisterAppId();
      debugPrint('BrowsingApp Initialized — App ID: $appId');

      await Future.delayed(const Duration(milliseconds: 400));
      setState(() => _statusMessage = 'Validating App & Software Version...');

      final valResult = await AppValidationService.validateApp();
      final status = valResult['status'];
      final message = valResult['message'] ?? '';

      debugPrint('Validation -> Status: $status | Message: $message');

      if (!mounted) return;

      // Status 2 → Update required, block entry
      if (status == 2) {
        setState(() {
          _isChecking = false;
          _isUpdateRequired = true;
          _updateMessage = message.isNotEmpty
              ? message
              : 'Update required. Please update your app version.';
          _currentVersion =
              valResult['currentSoftwareVersion']?.toString() ??
                  valResult['currentAppVersion']?.toString() ??
                  '1.0.0';
          _latestVersion =
              valResult['latestSoftwareVersion']?.toString() ??
                  valResult['latestAppVersion']?.toString() ??
                  'Latest';
        });
        return;
      }

      // Status 1 → OK, proceed according to login session & security locks
      if (status == 1) {
        setState(
            () => _statusMessage = 'Validation Successful. Initializing Session...');
        await Future.delayed(const Duration(milliseconds: 400));
        await _proceedNext(appId);
        return;
      } else {
        setState(() {
          _isChecking = false;
          _errorMessage = message.isNotEmpty
              ? message
              : 'Unexpected response status: $status';
        });
      }
    } catch (e) {
      if (!mounted) return;
      final rawError = e.toString();
      final cleanMsg = rawError.contains('Failed to fetch')
          ? 'Network / CORS Error: Unable to fetch gateway on Web browser.'
          : 'Validation Error: ${rawError.replaceAll("Exception: ", "")}';

      setState(() {
        _isChecking = false;
        _errorMessage = cleanMsg;
      });
    }
  }

  Future<void> _proceedNext([String? customAppId]) async {
    if (!mounted) return;

    // Check if user has an active login session saved
    final hasSession = await AuthService.hasActiveSession();

    if (hasSession) {
      // User has logged in before!
      // Require device lock / biometric unlock (Fingerprint or Phone PIN/Pattern)
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const SecurityUnlockScreen(),
        ),
      );
      return;
    }

    // No active session -> Prompt LoginScreen
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => LoginScreen(appId: customAppId ?? AppConfig.appId),
      ),
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
                  // Circuit Point Logo
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE94560).withValues(alpha: 0.25),
                            blurRadius: 24,
                            spreadRadius: 2,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Image.asset(
                        AssetConstants.logo,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.memory_rounded,
                          size: 52,
                          color: Color(0xFFE94560),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'CIRCUIT ',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 3,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        'POINT',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 3,
                          color: Color(0xFFE94560),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Electronics & Components Store',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Case 1: Checking in progress
                  if (_isChecking) ...[
                    const SizedBox(
                      width: 34,
                      height: 34,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFFE94560),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      _statusMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],

                  // Case 2: Update required
                  if (_isUpdateRequired) ...[
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.4)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 15,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.warning_amber_rounded,
                                  color: Color(0xFFF59E0B), size: 24),
                              SizedBox(width: 8),
                              Text(
                                'App Update Required!',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _updateMessage,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFFCBD5E1),
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  children: [
                                    const Text('Your Version',
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: Color(0xFF94A3B8))),
                                    const SizedBox(height: 2),
                                    Text(_currentVersion,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFFEF4444),
                                            fontFamily: 'monospace')),
                                  ],
                                ),
                                const Text('➔',
                                    style: TextStyle(color: Color(0xFF64748B))),
                                Column(
                                  children: [
                                    const Text('Latest Version',
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: Color(0xFF94A3B8))),
                                    const SizedBox(height: 2),
                                    Text(_latestVersion,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF10B981),
                                            fontFamily: 'monospace')),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.refresh_rounded, size: 18),
                              label: const Text('Check Again / Retry',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w700)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF59E0B),
                                foregroundColor: const Color(0xFF090D16),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: _validateAndInitApp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Case 3: Error fallback
                  if (_errorMessage != null &&
                      !_isChecking &&
                      !_isUpdateRequired) ...[
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color:
                                const Color(0xFFEF4444).withValues(alpha: 0.4)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.error_outline_rounded,
                              color: Color(0xFFEF4444), size: 36),
                          const SizedBox(height: 12),
                          const Text(
                            'Validation Failed',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFFCBD5E1),
                                height: 1.4),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 46,
                            child: ElevatedButton.icon(
                              onPressed: _validateAndInitApp,
                              icon: const Icon(Icons.refresh_rounded, size: 20),
                              label: const Text('Retry Connection',
                                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE94560),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextButton(
                            onPressed: () {
                              DashboardRouter.navigateToDashboard(context, clearStack: true);
                            },
                            child: const Text(
                              'Skip & Continue to Store (Demo Mode)',
                              style: TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],


                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
