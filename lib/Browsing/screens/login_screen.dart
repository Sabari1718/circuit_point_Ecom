import 'package:flutter/material.dart';
import '../../../core/constants/asset_constants.dart';
import '../navigation/dashboard_router.dart';
import '../services/auth_service.dart';
import '../services/phone_verification_service.dart';

class LoginOption {
  final String label;
  final String apiKey;
  final IconData icon;
  final String hintText;
  final TextInputType keyboardType;

  const LoginOption({
    required this.label,
    required this.apiKey,
    required this.icon,
    required this.hintText,
    required this.keyboardType,
  });
}

class LoginScreen extends StatefulWidget {
  final String appId;
  final String? initialErrorMessage;
  const LoginScreen({super.key, required this.appId, this.initialErrorMessage});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const List<LoginOption> _loginOptions = [
    LoginOption(
      label: 'Phone Number',
      apiKey: 'phone_number',
      icon: Icons.phone_outlined,
      hintText: 'Enter your phone number',
      keyboardType: TextInputType.phone,
    ),
    LoginOption(
      label: 'Email id',
      apiKey: 'email',
      icon: Icons.mail_outline_rounded,
      hintText: 'Enter your email id',
      keyboardType: TextInputType.emailAddress,
    ),
    LoginOption(
      label: 'User Id',
      apiKey: 'user_main_id',
      icon: Icons.person_outline_rounded,
      hintText: 'Enter your user ID',
      keyboardType: TextInputType.text,
    ),
    LoginOption(
      label: 'PAN Number',
      apiKey: 'pan_number',
      icon: Icons.credit_card_rounded,
      hintText: 'Enter PAN number (e.g. ABCDE1234F)',
      keyboardType: TextInputType.text,
    ),
  ];

  late LoginOption _selectedOption;
  final _identifierController = TextEditingController(); // Empty by default
  final _passwordController = TextEditingController();   // Empty by default
  final PageController _pageController = PageController();

  int _currentStep = 0; // 0 = Method & ID, 1 = Password, 2 = Captcha
  bool _isLoading = false;
  bool _isValidatingStep1 = false;
  bool _obscurePassword = true;
  String _authStepStatus = '';

  List<Map<String, dynamic>> _captchaCategories = [];
  bool _isLoadingCaptcha = true;
  Map<String, dynamic>? _selectedCaptchaCategory;

  @override
  void initState() {
    super.initState();
    _selectedOption = _loginOptions.first;
    _loadCaptchaCategories();

    if (widget.initialErrorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _showErrorSnackBar(widget.initialErrorMessage!);
      });
    }
  }

  Future<void> _loadCaptchaCategories() async {
    setState(() => _isLoadingCaptcha = true);
    final categories = await AuthService.fetchCaptchaCategories();
    if (mounted) {
      setState(() {
        _captchaCategories = categories;
        _isLoadingCaptcha = false;
        _selectedCaptchaCategory = null; // Do NOT auto-select. Require user to choose.
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _goToStep(int step) {
    setState(() => _currentStep = step);
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOutCubic,
    );
  }

  void _onSelectOption(LoginOption option) {
    setState(() {
      _selectedOption = option;
      _identifierController.clear(); // Clear so user types fresh
    });
  }

  Future<void> _validateStep1AndProceed() async {
    final rawValue = _identifierController.text.trim();
    if (rawValue.isEmpty) {
      _showErrorSnackBar('Please enter your ${_selectedOption.label}');
      return;
    }

    // Auto-detect input type (Phone vs Email) so user doesn't get blocked even if wrong dropdown option is picked
    final cleanDigits = PhoneVerificationService.normalizePhoneNumber(rawValue);
    final bool isPhoneFormat = cleanDigits.length == 10 && !rawValue.contains('@');
    final bool isEmailFormat = rawValue.contains('@');

    setState(() => _isValidatingStep1 = true);

    try {
      // 1. Phone number check (via dedicated live endpoint /api/login/check-phone/<phone>)
      if (isPhoneFormat || _selectedOption.apiKey == 'phone_number') {
        if (_selectedOption.apiKey != 'phone_number') {
          setState(() {
            _selectedOption = _loginOptions.firstWhere((o) => o.apiKey == 'phone_number');
          });
        }

        final digits = PhoneVerificationService.normalizePhoneNumber(rawValue);
        if (digits.length != 10) {
          _showErrorSnackBar('Please enter a valid 10-digit mobile number.');
          return;
        }

        final result = await PhoneVerificationService.verifyPhoneNumber(rawValue);
        if (!mounted) return;

        if (!result.isRegistered) {
          _showErrorSnackBar(
            result.errorMessage ??
                'This mobile number is not registered. Please enter a registered number.',
          );
          return;
        }

        final welcomeName = result.userName != null && result.userName!.isNotEmpty
            ? ' (${result.userName})'
            : '';
        _showSuccessSnackBar('Mobile verified$welcomeName! Please enter your password.');
        _goToStep(1);
        return;
      }

      // 2. Email check (via dedicated live endpoint /api/login/check-email/<email>)
      if (isEmailFormat || _selectedOption.apiKey == 'email') {
        if (_selectedOption.apiKey != 'email') {
          setState(() {
            _selectedOption = _loginOptions.firstWhere((o) => o.apiKey == 'email');
          });
        }

        final result = await PhoneVerificationService.verifyEmail(rawValue);
        if (!mounted) return;

        if (!result.isRegistered) {
          _showErrorSnackBar(
            result.errorMessage ??
                'This email is not registered. Please enter a registered email address.',
          );
          return;
        }

        final welcomeName = result.userName != null && result.userName!.isNotEmpty
            ? ' (${result.userName})'
            : '';
        _showSuccessSnackBar('Email verified$welcomeName! Please enter your password.');
        _goToStep(1);
        return;
      }

      // 3. User ID check (via live registry API /api/user/ids-phone)
      if (_selectedOption.apiKey == 'user_main_id') {
        if (rawValue.length < 3) {
          _showErrorSnackBar('Please enter a valid User ID.');
          return;
        }

        final result = await PhoneVerificationService.verifyUserId(rawValue);
        if (!mounted) return;

        if (!result.isRegistered) {
          _showErrorSnackBar(
            result.errorMessage ??
                'User ID "$rawValue" is not registered. Please check and try again.',
          );
          return;
        }

        final welcomeName = result.userName != null && result.userName!.isNotEmpty
            ? ' (${result.userName})'
            : '';
        _showSuccessSnackBar('User ID verified$welcomeName! Please enter your password.');
        _goToStep(1);
        return;
      }

      // 4. PAN format validation
      if (_selectedOption.apiKey == 'pan_number') {
        if (rawValue.length != 10) {
          _showErrorSnackBar('Please enter a valid 10-character PAN number.');
          return;
        }
        _goToStep(1);
        return;
      }

      _goToStep(1);
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('Verification error: $e');
    } finally {
      if (mounted) setState(() => _isValidatingStep1 = false);
    }
  }

  void _validateStep2AndProceed() {
    final pass = _passwordController.text.trim();
    if (pass.isEmpty) {
      _showErrorSnackBar('Please enter your Password');
      return;
    }
    _goToStep(2);
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFFEF4444),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  IconData _getCategoryIcon(String? name) {
    final lower = (name ?? '').toLowerCase();
    if (lower.contains('traffic')) return Icons.traffic_rounded;
    if (lower.contains('flower')) return Icons.local_florist_rounded;
    if (lower.contains('building')) return Icons.apartment_rounded;
    if (lower.contains('furniture')) return Icons.chair_rounded;
    if (lower.contains('electronic')) return Icons.devices_other_rounded;
    if (lower.contains('nature')) return Icons.park_rounded;
    if (lower.contains('clothing')) return Icons.checkroom_rounded;
    if (lower.contains('sport')) return Icons.sports_soccer_rounded;
    if (lower.contains('food')) return Icons.restaurant_rounded;
    if (lower.contains('vehicle') || lower.contains('car')) return Icons.directions_car_rounded;
    if (lower.contains('animal')) return Icons.pets_rounded;
    if (lower.contains('bird')) return Icons.flutter_dash_rounded;
    return Icons.category_rounded;
  }

  Future<void> _handleLogin() async {
    final identifier = _identifierController.text.trim();
    final password = _passwordController.text.trim();

    if (identifier.isEmpty) {
      _goToStep(0);
      _showErrorSnackBar('Please enter your ${_selectedOption.label}');
      return;
    }

    if (password.isEmpty) {
      _goToStep(1);
      _showErrorSnackBar('Please enter your Password');
      return;
    }

    if (_selectedCaptchaCategory == null) {
      _showErrorSnackBar('Please select a Captcha category');
      return;
    }

    setState(() {
      _isLoading = true;
      _authStepStatus = 'Authenticating with Gateway...';
    });

    try {
      final result = await AuthService.login(
        loginField: _selectedOption.apiKey,
        loginValue: identifier,
        password: password,
        captchaCategory: _selectedCaptchaCategory,
      );

      if (!mounted) return;

      if (result['success'] == true && (result['userAppToken']?.toString().isNotEmpty ?? false)) {
        FocusScope.of(context).unfocus();
        debugPrint('🚀 [LoginScreen] Authentication successful! Navigating to Circuit Point Ecom Store...');

        _showSuccessSnackBar('Login successful! Welcome to Circuit Point Ecom.');
        if (!mounted) return;
        
        // Go DIRECTLY to Circuit Point Ecom Dashboard (Bypass Business Profile Selection)
        DashboardRouter.navigateToDashboard(context, clearStack: true);
      } else {
        throw Exception('Session authorization rejected by server.');
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('Authentication Failed: ${e.toString().replaceAll("Exception: ", "")}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _authStepStatus = '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Branding Header
                  _buildHeader(),
                  const SizedBox(height: 24),

                  // Step Indicator Bar
                  _buildStepIndicator(),
                  const SizedBox(height: 20),

                  // Main Card with PageView
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE94560).withValues(alpha: 0.08),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(22),
                    child: AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: SizedBox(
                        height: _currentStep == 2 ? 460 : 380,
                        child: PageView(
                          controller: _pageController,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            _buildStep1Page(),
                            _buildStep2Page(),
                            _buildStep3Page(),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Footer info
                  Center(
                    child: Text(
                      'Circuit Point Ecom  •  Secure Gateway v1.0.0',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w600,
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

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE94560).withValues(alpha: 0.18),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(6),
          child: Image.asset(
            AssetConstants.logo,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.memory_rounded,
              color: Color(0xFFE94560),
              size: 28,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Text(
                    'CIRCUIT ',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    'POINT',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFE94560),
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              const Text(
                'Electronics & Components Store',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepIndicator() {
    final steps = [
      {'title': 'Select Method', 'icon': Icons.badge_outlined},
      {'title': 'Password', 'icon': Icons.lock_outline_rounded},
      {'title': 'Captcha', 'icon': Icons.security_rounded},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (index) {
          if (index.isOdd) {
            final stepBefore = index ~/ 2;
            final isCompleted = _currentStep > stepBefore;
            return Expanded(
              child: Container(
                height: 3,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: isCompleted ? const Color(0xFFE94560) : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }

          final stepIndex = index ~/ 2;
          final isActive = _currentStep == stepIndex;
          final isDone = _currentStep > stepIndex;

          return InkWell(
            onTap: () {
              if (stepIndex < _currentStep) {
                _goToStep(stepIndex);
              }
            },
            borderRadius: BorderRadius.circular(10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: isDone
                        ? const Color(0xFF10B981)
                        : (isActive ? const Color(0xFFE94560) : const Color(0xFFF1F5F9)),
                    shape: BoxShape.circle,
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: const Color(0xFFE94560).withValues(alpha: 0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: isDone
                        ? const Icon(Icons.check_rounded, color: Colors.white, size: 15)
                        : Text(
                            '${stepIndex + 1}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: isActive ? Colors.white : const Color(0xFF64748B),
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  steps[stepIndex]['title'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    color: isActive ? const Color(0xFF0F172A) : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ==========================================
  // STEP 1: DROPDOWN METHOD & USER INPUT
  // ==========================================
  Widget _buildStep1Page() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'STEP 1 OF 3',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: Color(0xFFE94560),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'Select Login Method',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 16),

        // Dropdown selection container
        const Text(
          'Choose Login Type',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 8),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE94560), width: 1.5),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<LoginOption>(
              value: _selectedOption,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFFE94560), size: 24),
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(14),
              items: _loginOptions.map((opt) {
                final isSelected = opt.apiKey == _selectedOption.apiKey;
                return DropdownMenuItem<LoginOption>(
                  value: opt,
                  child: Row(
                    children: [
                      Icon(
                        opt.icon,
                        color: isSelected ? const Color(0xFFE94560) : const Color(0xFF64748B),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        opt.label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                          color: isSelected ? const Color(0xFFC81E45) : const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (LoginOption? newOption) {
                if (newOption != null) {
                  _onSelectOption(newOption);
                }
              },
            ),
          ),
        ),

        const SizedBox(height: 18),

        // Text input field for user to manually type
        Text(
          _selectedOption.label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: TextField(
            controller: _identifierController,
            keyboardType: _selectedOption.keyboardType,
            textCapitalization: _selectedOption.apiKey == 'pan_number'
                ? TextCapitalization.characters
                : TextCapitalization.none,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: _selectedOption.hintText,
              hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
              prefixIcon: Icon(_selectedOption.icon, color: const Color(0xFFE94560), size: 20),
              suffixIcon: _identifierController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18, color: Color(0xFF94A3B8)),
                      onPressed: () {
                        setState(() => _identifierController.clear());
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            ),
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _isValidatingStep1 ? null : _validateStep1AndProceed(),
          ),
        ),

        const Spacer(),

        // Next Button
        ElevatedButton(
          onPressed: _isValidatingStep1 ? null : _validateStep1AndProceed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE94560),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
          ),
          child: _isValidatingStep1
              ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Verifying with server...',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                  ],
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Next: Enter Password',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded, size: 18),
                  ],
                ),
        ),
      ],
    );
  }

  // ==========================================
  // STEP 2: USER TYPES PASSWORD
  // ==========================================
  Widget _buildStep2Page() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'STEP 2 OF 3',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: Color(0xFFE94560),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'Enter Your Password',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 14),

        // Summary badge of chosen identifier
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFEEF2FF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFC7D2FE)),
          ),
          child: Row(
            children: [
              Icon(_selectedOption.icon, color: const Color(0xFFE94560), size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedOption.label.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFE94560),
                      ),
                    ),
                    Text(
                      _identifierController.text.trim(),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E1B4B),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => _goToStep(0),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFC81E45),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Change', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // Password input field (empty by default)
        const Text(
          'Password',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: 'Enter your account password',
              hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
              prefixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xFFE94560), size: 20),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: const Color(0xFF64748B),
                  size: 20,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            ),
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _validateStep2AndProceed(),
          ),
        ),

        const Spacer(),

        // Bottom Navigation (Back & Next)
        Row(
          children: [
            OutlinedButton(
              onPressed: () => _goToStep(0),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF64748B),
                side: const BorderSide(color: Color(0xFFCBD5E1)),
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.arrow_back_rounded, size: 18),
                  SizedBox(width: 6),
                  Text('Back', style: TextStyle(fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _validateStep2AndProceed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE94560),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Next: Verify Captcha',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ==========================================
  // STEP 3: CAPTCHA VERIFICATION & LOGIN
  // ==========================================
  Widget _buildStep3Page() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'STEP 3 OF 3',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFE94560),
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Select Captcha Category',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Color(0xFFE94560), size: 20),
              tooltip: 'Reload Captchas',
              onPressed: _loadCaptchaCategories,
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Captcha Category List / Cards
        if (_isLoadingCaptcha) ...[
          const Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFFE94560)),
                  SizedBox(height: 12),
                  Text(
                    'Loading security captchas...',
                    style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
          ),
        ] else if (_captchaCategories.isNotEmpty) ...[
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.15,
              ),
              itemCount: _captchaCategories.length,
              itemBuilder: (context, index) {
                final cat = _captchaCategories[index];
                final isSelected = _selectedCaptchaCategory?['id'] == cat['id'];
                final catName = cat['category_name']?.toString() ?? 'Category';
                final imgUrl = cat['image']?.toString() ?? '';

                return InkWell(
                  onTap: () {
                    setState(() => _selectedCaptchaCategory = cat);
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFEEF2FF) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? const Color(0xFFE94560) : const Color(0xFFE2E8F0),
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: const Color(0xFFE94560).withValues(alpha: 0.18),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Stack(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Center(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    imgUrl,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, progress) {
                                      if (progress == null) return child;
                                      return const Center(
                                        child: SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Color(0xFFE94560),
                                          ),
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? const Color(0xFFC7D2FE)
                                            : const Color(0xFFE2E8F0),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        _getCategoryIcon(catName),
                                        color: const Color(0xFFC81E45),
                                        size: 26,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              catName,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                color: isSelected
                                    ? const Color(0xFFC81E45)
                                    : const Color(0xFF334155),
                              ),
                            ),
                          ],
                        ),
                        if (isSelected)
                          const Positioned(
                            top: 0,
                            right: 0,
                            child: Icon(
                              Icons.check_circle_rounded,
                              color: Color(0xFFE94560),
                              size: 16,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ] else ...[
          const Expanded(
            child: Center(
              child: Text(
                'No captchas available',
                style: TextStyle(color: Color(0xFF94A3B8)),
              ),
            ),
          ),
        ],

        if (_authStepStatus.isNotEmpty) ...[
          const SizedBox(height: 8),
          Center(
            child: Text(
              _authStepStatus,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFFE94560),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],

        const SizedBox(height: 12),

        // Bottom Navigation (Back & Complete Login)
        Row(
          children: [
            OutlinedButton(
              onPressed: _isLoading ? null : () => _goToStep(1),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF64748B),
                side: const BorderSide(color: Color(0xFFCBD5E1)),
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.arrow_back_rounded, size: 18),
                  SizedBox(width: 6),
                  Text('Back', style: TextStyle(fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.lock_open_rounded, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Authenticate & Login',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
