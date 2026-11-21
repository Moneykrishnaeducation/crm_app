part of '../main.dart';

const _loginDarkBg = Color(0xFF222427);
const _loginCardBg = Color(0xFF2B2D31);
const _loginCardBorder = Color(0xFF383B41);
const _loginFieldInsetBg = Color(0xFF202226);
const _loginFieldBorder = Color(0xFF383B42);
const _loginLabelMuted = Color(0xFF9EA3AC);
const _loginBtnGradTop = Color(0xFF383B41);
const _loginBtnGradBottom = Color(0xFF2C2E33);
const _loginBtnText = Color(0xFFE4E7ED);

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    this.onLogin,
    this.initialSignUp = false,
    this.biometricSignIn,
  });

  final VoidCallback? onLogin;
  final bool initialSignUp;
  final BiometricSignIn? biometricSignIn;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _loginFormKey = GlobalKey<FormState>();
  final _signUpFormKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _referralController = TextEditingController();
  final _passwordController = TextEditingController();

  late bool _isSignUp = widget.initialSignUp;
  bool _emailVerified = false;
  bool _passwordVisible = false;
  bool _acceptedTerms = true;
  bool _darkModeActive = true;
  String _selectedLanguage = 'English';

  bool _biometricEnabled = false;
  bool _biometricAvailable = false;
  bool _biometricBusy = false;

  BiometricSignIn get _biometricService =>
      widget.biometricSignIn ?? BiometricSignIn.instance;

  @override
  void initState() {
    super.initState();
    unawaited(_loadBiometricSignIn());
  }

  Future<void> _loadBiometricSignIn() async {
    var enabled = false;
    try {
      enabled = await _biometricService.isEnabled();
      if (!mounted) return;
      final available = enabled &&
          await _biometricService.isAvailable(
            platform: Theme.of(context).platform,
          );
      if (!mounted) return;
      setState(() {
        _biometricEnabled = enabled;
        _biometricAvailable = available;
      });
      if (enabled && available) await _signInWithBiometrics();
    } on PlatformException {
      if (mounted) {
        setState(() {
          _biometricEnabled = enabled;
          _biometricAvailable = false;
        });
      }
    } on MissingPluginException {
      if (mounted) {
        setState(() {
          _biometricEnabled = enabled;
          _biometricAvailable = false;
        });
      }
    }
  }

  Future<void> _signInWithBiometrics() async {
    if (_biometricBusy) return;
    HapticFeedback.mediumImpact();

    if (!_biometricEnabled || !_biometricAvailable) {
      if (!_biometricEnabled) {
        showAppMessage('Biometric sign-in is not enabled. Sign in with your password and enable it in Security Center.');
      } else {
        showAppMessage('Biometric sensor is not available on this device.');
      }
      return;
    }

    setState(() => _biometricBusy = true);
    try {
      final authenticated = await _biometricService.authenticate(
        localizedReason: 'Sign in to your VTIndex account',
      );
      if (!mounted) return;
      if (authenticated) {
        _submit();
      } else {
        showAppMessage('Biometric sign-in was canceled. Use your login ID and password instead.');
      }
    } on PlatformException {
      if (mounted) {
        showAppMessage('Biometric sign-in failed. Use your login ID and password instead.');
      }
    } on MissingPluginException {
      if (mounted) {
        showAppMessage('Biometric sign-in is unavailable. Use your login ID and password instead.');
      }
    } finally {
      if (mounted) setState(() => _biometricBusy = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _referralController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() => widget.onLogin?.call();

  void _submitSignUp() {
    if (!_emailVerified) {
      showAppMessage('Verify your email before creating an account.');
      return;
    }
    if (!(_signUpFormKey.currentState?.validate() ?? false)) return;
    if (!_acceptedTerms) {
      showAppMessage('Please accept the Terms & Conditions to continue.');
      return;
    }
    showAppMessage('Account creation is not connected yet.');
  }

  String? _required(String? value, String label) =>
      value == null || value.trim().isEmpty ? 'Enter $label' : null;

  void _showLanguageSelector() {
    final languages = ['English', 'Español', 'Français', 'Deutsch', '中文', 'العربية'];
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: _loginCardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Language',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              ...languages.map(
                (lang) => ListTile(
                  title: Text(
                    lang,
                    style: TextStyle(
                      color: _selectedLanguage == lang ? Colors.white : _loginLabelMuted,
                      fontWeight: _selectedLanguage == lang ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  trailing: _selectedLanguage == lang
                      ? const Icon(LucideIcons.check, color: Colors.white, size: 18)
                      : null,
                  onTap: () {
                    setState(() => _selectedLanguage = lang);
                    Navigator.pop(sheetContext);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showHelpModal() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: _loginCardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Text(
              'Need help signing in?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Enter your registered email address or account number to reset your password or recover your username.',
              style: TextStyle(color: _loginLabelMuted, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () {
                Navigator.pop(sheetContext);
                showAppMessage('Password reset instructions sent to your registered email.');
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF36393F),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Reset Password via Email', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () {
                Navigator.pop(sheetContext);
                showAppMessage('Support chat will open shortly.');
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFF383B42)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Contact Customer Support'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _loginDarkBg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Container(
                decoration: BoxDecoration(
                  color: _loginCardBg,
                  borderRadius: BorderRadius.circular(38),
                  border: Border.all(color: _loginCardBorder, width: 1.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x66000000),
                      offset: Offset(0, 14),
                      blurRadius: 28,
                    ),
                    BoxShadow(
                      color: Color(0x12FFFFFF),
                      offset: Offset(0, -2),
                      blurRadius: 8,
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 26),
                child: _isSignUp ? _buildSignUpContent() : _buildLoginContent(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left: "UI Series" pill chip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF222428),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF383B41), width: 0.8),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                offset: Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
          child: const Text(
            'UI Series',
            style: TextStyle(
              color: Color(0xFFBAC0CB),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ),

        // Center: "English ⌵"
        InkWell(
          onTap: _showLanguageSelector,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _selectedLanguage,
                  style: const TextStyle(
                    color: Color(0xFFE2E6ED),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.keyboard_arrow_down,
                  color: Color(0xFFE2E6ED),
                  size: 18,
                ),
              ],
            ),
          ),
        ),

        // Right: "Dark Mode" toggle
        InkWell(
          onTap: () {
            setState(() => _darkModeActive = !_darkModeActive);
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.fromLTRB(10, 4, 4, 4),
            decoration: BoxDecoration(
              color: const Color(0xFF202226),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF36393E), width: 0.8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Dark Mode',
                  style: TextStyle(
                    color: Color(0xFF8E939D),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: _darkModeActive
                          ? [Colors.white, const Color(0xFFD8DCE3)]
                          : [const Color(0xFF6B707B), const Color(0xFF4A4E57)],
                    ),
                    boxShadow: _darkModeActive
                        ? const [
                            BoxShadow(
                              color: Color(0x66FFFFFF),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogoEmblem() {
    return Center(
      child: Container(
        width: 116,
        height: 116,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF35383E), Color(0xFF202226)],
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x8A000000),
              offset: Offset(6, 8),
              blurRadius: 16,
            ),
            BoxShadow(
              color: Color(0x14FFFFFF),
              offset: Offset(-3, -3),
              blurRadius: 8,
            ),
          ],
        ),
        padding: const EdgeInsets.all(8),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF1B1C1F),
            border: Border.all(color: const Color(0x40FFFFFF), width: 1.2),
          ),
          child: ClipOval(
            child: CustomPaint(
              size: const Size(100, 100),
              painter: _LabyrinthEmblemPainter(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginContent() {
    return Form(
      key: _loginFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTopBar(),
          const SizedBox(height: 36),
          _buildLogoEmblem(),
          const SizedBox(height: 40),

          // Field 1: Phone number, email or username
          Padding(
            padding: const EdgeInsets.only(left: 6, bottom: 8),
            child: Text(
              'Phone number, email or username',
              style: TextStyle(
                color: _loginLabelMuted,
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          _buildInsetField(
            child: TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              cursorColor: Colors.white,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 22),

          // Field 2: Password
          Padding(
            padding: const EdgeInsets.only(left: 6, bottom: 8),
            child: Text(
              'Password',
              style: TextStyle(
                color: _loginLabelMuted,
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          _buildInsetField(
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _passwordController,
                    obscureText: !_passwordVisible,
                    obscuringCharacter: '•',
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                    cursorColor: Colors.white,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: _passwordVisible ? 0 : 3.0,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: IconButton(
                    onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
                    icon: Icon(
                      _passwordVisible ? LucideIcons.eye : LucideIcons.eyeOff,
                      color: const Color(0xFFE2E6EC),
                      size: 20,
                    ),
                    tooltip: _passwordVisible ? 'Hide password' : 'Show password',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Log in button (Neumorphic raised pill)
          _buildRaisedButton(
            label: 'Log in',
            onPressed: _submit,
          ),
          const SizedBox(height: 24),

          // Forgot details helper link
          Center(
            child: InkWell(
              onTap: _showHelpModal,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text.rich(
                  TextSpan(
                    text: 'Forgot your login details? ',
                    style: TextStyle(
                      color: const Color(0xFF8E939D),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w400,
                    ),
                    children: const [
                      TextSpan(
                        text: 'Get help login in.',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),

          if (_biometricEnabled && !_biometricAvailable) ...[
            const SizedBox(height: 12),
            Center(
              child: Text(
                'Biometric sign-in unavailable. Use your login ID and password.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _loginLabelMuted,
                  fontSize: 11,
                ),
              ),
            ),
          ],

          const SizedBox(height: 28),

          // Biometric Fingerprint button
          Center(
            child: _buildFingerprintButton(),
          ),

          const SizedBox(height: 28),

          // Sign up footer
          Center(
            child: InkWell(
              onTap: () => setState(() => _isSignUp = true),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Text.rich(
                  TextSpan(
                    text: "Don't have an account? ",
                    style: TextStyle(
                      color: const Color(0xFF8E939D),
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                    children: const [
                      TextSpan(
                        text: 'Sign up',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpContent() {
    return Form(
      key: _signUpFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTopBar(),
          const SizedBox(height: 24),
          _buildLogoEmblem(),
          const SizedBox(height: 28),

          const Center(
            child: Text(
              'Create Account',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              'Start your trading journey with VT Index',
              style: TextStyle(color: _loginLabelMuted, fontSize: 13),
            ),
          ),
          const SizedBox(height: 24),

          // Full Name
          Padding(
            padding: const EdgeInsets.only(left: 6, bottom: 8),
            child: Text('Full Name', style: TextStyle(color: _loginLabelMuted, fontSize: 12.5, fontWeight: FontWeight.w500)),
          ),
          _buildInsetField(
            child: TextFormField(
              controller: _nameController,
              cursorColor: Colors.white,
              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
              validator: (v) => _required(v, 'your full name'),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Email Address
          Padding(
            padding: const EdgeInsets.only(left: 6, bottom: 8),
            child: Text('Email Address', style: TextStyle(color: _loginLabelMuted, fontSize: 12.5, fontWeight: FontWeight.w500)),
          ),
          _buildInsetField(
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    cursorColor: Colors.white,
                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                    validator: (v) {
                      final email = v?.trim() ?? '';
                      if (email.isEmpty) return 'Enter your email address';
                      if (!email.contains('@') || !email.contains('.')) return 'Enter a valid email address';
                      return null;
                    },
                    onChanged: (_) {
                      if (_emailVerified) setState(() => _emailVerified = false);
                    },
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: FilledButton(
                    onPressed: () {
                      final email = _emailController.text.trim();
                      if (email.isEmpty || !email.contains('@') || !email.contains('.')) {
                        showAppMessage('Enter a valid email address first.');
                        return;
                      }
                      setState(() => _emailVerified = true);
                      showAppMessage('Email verified.');
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF383B41),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      minimumSize: const Size(0, 36),
                    ),
                    child: Text(_emailVerified ? 'Verified' : 'Verify', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // IB Referral Code (Optional)
          Padding(
            padding: const EdgeInsets.only(left: 6, bottom: 8),
            child: Text('IB Referral Code (Optional)', style: TextStyle(color: _loginLabelMuted, fontSize: 12.5, fontWeight: FontWeight.w500)),
          ),
          _buildInsetField(
            child: TextFormField(
              controller: _referralController,
              cursorColor: Colors.white,
              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Password
          Padding(
            padding: const EdgeInsets.only(left: 6, bottom: 8),
            child: Text('Password', style: TextStyle(color: _loginLabelMuted, fontSize: 12.5, fontWeight: FontWeight.w500)),
          ),
          _buildInsetField(
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _passwordController,
                    obscureText: !_passwordVisible,
                    obscuringCharacter: '•',
                    cursorColor: Colors.white,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: _passwordVisible ? 0 : 3.0,
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Create a password';
                      if (v.length < 8) return 'Use at least 8 characters';
                      return null;
                    },
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: IconButton(
                    onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
                    icon: Icon(
                      _passwordVisible ? LucideIcons.eye : LucideIcons.eyeOff,
                      color: const Color(0xFFE2E6EC),
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Terms Checkbox
          Row(
            children: [
              Checkbox(
                value: _acceptedTerms,
                onChanged: (v) => setState(() => _acceptedTerms = v ?? false),
                activeColor: const Color(0xFF383B41),
                checkColor: Colors.white,
                side: const BorderSide(color: Color(0xFF5A5E68)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    text: 'I agree to the ',
                    style: TextStyle(color: _loginLabelMuted, fontSize: 12.5),
                    children: const [
                      TextSpan(text: 'Terms & Conditions', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      TextSpan(text: ' and '),
                      TextSpan(text: 'Privacy Policy', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          _buildRaisedButton(
            label: 'Create Account',
            onPressed: _submitSignUp,
          ),
          const SizedBox(height: 24),

          Center(
            child: InkWell(
              onTap: () => setState(() => _isSignUp = false),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Text.rich(
                  TextSpan(
                    text: 'Already have an account? ',
                    style: TextStyle(color: const Color(0xFF8E939D), fontSize: 13),
                    children: const [
                      TextSpan(text: 'Log in', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsetField({required Widget child}) {
    return CustomPaint(
      painter: _NeumorphicInsetPainter(radius: 28),
      child: SizedBox(
        height: 56,
        child: Center(child: child),
      ),
    );
  }

  Widget _buildRaisedButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_loginBtnGradTop, _loginBtnGradBottom],
          ),
          border: Border.all(color: const Color(0x2EFFFFFF), width: 1.0),
          boxShadow: const [
            BoxShadow(
              color: Color(0x8A000000),
              offset: Offset(0, 10),
              blurRadius: 18,
            ),
            BoxShadow(
              color: Color(0x1AFFFFFF),
              offset: Offset(0, -1.5),
              blurRadius: 4,
            ),
          ],
        ),
        child: Container(
          height: 58,
          alignment: Alignment.center,
          child: Text(
            label,
            style: const TextStyle(
              color: _loginBtnText,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFingerprintButton() {
    return InkWell(
      onTap: _signInWithBiometrics,
      borderRadius: BorderRadius.circular(44),
      child: Container(
        width: 86,
        height: 86,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF383B41), Color(0xFF26282D)],
          ),
          border: Border.all(color: const Color(0x33FFFFFF), width: 1.2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x73000000),
              offset: Offset(0, 8),
              blurRadius: 18,
            ),
            BoxShadow(
              color: Color(0x1FFFFFFF),
              offset: Offset(0, -2),
              blurRadius: 6,
            ),
          ],
        ),
        padding: const EdgeInsets.all(7),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF202225),
            border: Border.all(color: const Color(0x26FFFFFF), width: 1.0),
          ),
          child: Center(
            child: _biometricBusy
                ? const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                  )
                : CustomPaint(
                    size: const Size(42, 48),
                    painter: _FingerprintGlyphPainter(),
                  ),
          ),
        ),
      ),
    );
  }
}

/// Custom painter for the sunken / recessed neumorphic trough
class _NeumorphicInsetPainter extends CustomPainter {
  final double radius;

  _NeumorphicInsetPainter({
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );

    // 1. Draw base sunken fill
    final fillPaint = Paint()..color = _loginFieldInsetBg;
    canvas.drawRRect(rrect, fillPaint);

    // 2. Draw outer border
    final borderPaint = Paint()
      ..color = _loginFieldBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRRect(rrect, borderPaint);

    // 3. Clip and draw inner shadow gradients
    canvas.save();
    canvas.clipRRect(rrect);

    // Top dark inner shadow
    final topGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xB3000000),
        const Color(0x59000000),
        Colors.transparent,
      ],
      stops: const [0.0, 0.45, 1.0],
    );
    final topPaint = Paint()
      ..shader = topGradient.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height * 0.5),
      );
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height * 0.5), topPaint);

    // Bottom light inner rim highlight
    final bottomGradient = const LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [
        Color(0x1AFFFFFF),
        Colors.transparent,
      ],
    );
    final bottomPaint = Paint()
      ..shader = bottomGradient.createShader(
        Rect.fromLTWH(0, size.height * 0.65, size.width, size.height * 0.35),
      );
    canvas.drawRect(Rect.fromLTWH(0, size.height * 0.65, size.width, size.height * 0.35), bottomPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _NeumorphicInsetPainter oldDelegate) => false;
}

/// Custom painter for the square geometric labyrinth / maze emblem in the circular medallion
class _LabyrinthEmblemPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.square
      ..strokeJoin = StrokeJoin.miter;

    // Center square diamond maze
    final path = Path();

    // Loop 1 (Outer perimeter tracks with labyrinth entry points)
    final w1 = size.width * 0.30;
    final h1 = size.height * 0.30;
    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy), width: w1 * 2, height: h1 * 2),
      const Radius.circular(5),
    ));

    // Concentric labyrinth meanders inside
    final step = w1 / 4.0;
    for (int i = 1; i <= 3; i++) {
      final s = w1 - (i * step);
      if (s > 4) {
        if (i.isOdd) {
          // Track with top/bottom gaps
          path.moveTo(cx - s + step * 0.6, cy - s);
          path.lineTo(cx + s, cy - s);
          path.lineTo(cx + s, cy + s);
          path.lineTo(cx - s, cy + s);
          path.lineTo(cx - s, cy - s + step * 0.6);
        } else {
          // Track with left/right turns
          path.moveTo(cx - s, cy - s);
          path.lineTo(cx + s - step * 0.6, cy - s);
          path.moveTo(cx + s, cy - s + step * 0.6);
          path.lineTo(cx + s, cy + s);
          path.lineTo(cx - s + step * 0.6, cy + s);
          path.lineTo(cx - s + step * 0.6, cy - s + step * 0.8);
        }
      }
    }

    // Center focal square
    final centerCore = Path()
      ..addRect(Rect.fromCenter(center: Offset(cx, cy), width: step * 0.9, height: step * 0.9));

    canvas.drawPath(path, paint);

    final corePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawPath(centerCore, corePaint);
  }

  @override
  bool shouldRepaint(covariant _LabyrinthEmblemPainter oldDelegate) => false;
}

/// Custom painter for the biometric fingerprint glyph matching the image
class _FingerprintGlyphPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    final paint = Paint()
      ..color = const Color(0xFFE8ECF2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    final path = Path();

    // Ridge 1 (Center loop)
    path.moveTo(cx - 3, cy + 8);
    path.cubicTo(cx - 3, cy - 2, cx + 3, cy - 2, cx + 3, cy + 8);

    // Ridge 2 (Inner arch)
    path.moveTo(cx - 7, cy + 12);
    path.cubicTo(cx - 7, cy - 8, cx + 7, cy - 8, cx + 7, cy + 12);

    // Ridge 3 (Mid arch with left leg curving down)
    path.moveTo(cx - 11, cy + 16);
    path.cubicTo(cx - 11, cy - 13, cx + 11, cy - 13, cx + 11, cy + 15);

    // Ridge 4 (Wide arch)
    path.moveTo(cx - 15, cy + 18);
    path.cubicTo(cx - 15, cy - 18, cx + 15, cy - 18, cx + 15, cy + 17);

    // Ridge 5 (Outer contour arch)
    path.moveTo(cx - 19, cy + 16);
    path.cubicTo(cx - 19, cy - 22, cx + 19, cy - 22, cx + 19, cy + 14);

    // Lower whorl lines
    path.moveTo(cx - 7, cy + 17);
    path.cubicTo(cx - 5, cy + 20, cx - 1, cy + 21, cx + 3, cy + 18);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _FingerprintGlyphPainter oldDelegate) => false;
}

/// Standalone entry point for the account registration form.
class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) => const LoginPage(initialSignUp: true);
}
