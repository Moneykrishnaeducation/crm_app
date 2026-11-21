part of '../main.dart';

// Light Glassmorphism Theme with Blue, Gold & White
const _loginCardGlassBg = Color(0xD9FFFFFF);
const _loginGoldRim = Color(0xFFECC868);
const _loginGoldBorder = Color(0x99D4AF37);
const _loginRoyalBlue = Color(0xFF1E70E8);
const _loginDarkBlueText = Color(0xFF0D1B3E);
const _loginMutedBlueText = Color(0xFF5A718F);
const _loginPlaceholderText = Color(0xFF687D9B);

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
  bool _rememberMe = true;

  bool _biometricEnabled = false;
  bool _biometricAvailable = false;
  bool _biometricBusy = false;
  bool _isSubmitting = false;

  BiometricSignIn get _biometricService =>
      widget.biometricSignIn ?? BiometricSignIn.instance;

  @override
  void initState() {
    super.initState();
    unawaited(_loadBiometricSignIn());
    unawaited(_loadRememberedLogin());
  }

  Future<void> _loadRememberedLogin() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final remembered = preferences.getBool('vtindex_remember_login') ?? true;
      final identifier = preferences.getString('vtindex_login_identifier') ?? '';
      if (!mounted) return;
      setState(() {
        _rememberMe = remembered;
        if (remembered) _emailController.text = identifier;
      });
    } catch (_) {}
  }

  Future<void> _saveRememberedLogin() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setBool('vtindex_remember_login', _rememberMe);
      if (_rememberMe) {
        await preferences.setString('vtindex_login_identifier', _emailController.text.trim());
      } else {
        await preferences.remove('vtindex_login_identifier');
      }
    } catch (_) {
      if (mounted) showAppMessage('Could not save the Remember Me preference on this device.');
    }
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
    } catch (_) {
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
        HapticFeedback.selectionClick();
        widget.onLogin?.call();
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

  Future<void> _submit() async {
    if (_isSubmitting || _biometricBusy) return;
    FocusScope.of(context).unfocus();
    final form = _loginFormKey.currentState;
    if (form == null || !form.validate()) {
      showAppMessage('Check the highlighted fields and try again.');
      return;
    }
    setState(() => _isSubmitting = true);
    HapticFeedback.selectionClick();
    await _saveRememberedLogin();
    if (!mounted) return;
    try {
      // Demo-mode navigation. Connect a real authentication service before production use.
      if (widget.onLogin != null) {
        widget.onLogin!.call();
      } else {
        showAppMessage('Sign-in is not connected. Please contact the administrator.');
      }
    } catch (_) {
      if (mounted) showAppMessage('Unable to sign in right now. Please try again.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _submitSignUp() {
    final form = _signUpFormKey.currentState;
    if (form == null || !form.validate()) return;
    if (!_acceptedTerms) {
      showAppMessage('Please accept the Terms & Conditions and Privacy Policy.');
      return;
    }
    showAppMessage('Account creation is not connected yet.');
  }

  String? _required(String? value, String label) =>
      value == null || value.trim().isEmpty ? 'Enter $label' : null;

  void _showHelpModal() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
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
                  color: const Color(0x66D4AF37),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Text(
              'Need help signing in?',
              style: TextStyle(
                color: _loginDarkBlueText,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Enter your registered email address or account number to reset your password or recover your username.',
              style: TextStyle(color: _loginMutedBlueText, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () {
                Navigator.pop(sheetContext);
                showAppMessage('Password recovery is not connected yet. Please contact customer support.');
              },
              style: FilledButton.styleFrom(
                backgroundColor: _loginRoyalBlue,
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
                showAppMessage('Support chat is not available in this demo. Please use your broker support channel.');
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: _loginDarkBlueText,
                side: const BorderSide(color: Color(0x66D4AF37)),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF18191E) : const Color(0xFFEAF1FB),
      body: Stack(
        children: [
          // 1. Decorative background graphic painter (supports light & dark themes)
          Positioned.fill(
            child: CustomPaint(
              painter: _LoginBackgroundPainter(isDark: isDark),
            ),
          ),

          // 2. Main floating glass card
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(38),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF25262D) : _loginCardGlassBg,
                          borderRadius: BorderRadius.circular(38),
                          border: Border.all(
                            color: isDark ? const Color(0x33FFFFFF) : _loginGoldBorder,
                            width: 1.5,
                          ),
                          boxShadow: [
                            if (isDark) ...[
                              const BoxShadow(
                                color: Color(0x990A0B0E),
                                offset: Offset(0, 18),
                                blurRadius: 36,
                              ),
                              const BoxShadow(
                                color: Color(0x1AFFFFFF),
                                offset: Offset(0, -1),
                                blurRadius: 6,
                              ),
                            ] else ...[
                              const BoxShadow(
                                color: Color(0x261E70E8),
                                offset: Offset(0, 16),
                                blurRadius: 36,
                              ),
                              const BoxShadow(
                                color: Color(0x33D4AF37),
                                offset: Offset(0, 0),
                                blurRadius: 10,
                              ),
                            ],
                          ],
                        ),
                        padding: const EdgeInsets.fromLTRB(22, 28, 22, 28),
                        child: _isSignUp ? _buildSignUpContent(isDark: isDark) : _buildLoginContent(isDark: isDark),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoEmblem({required bool isDark}) {
    return Center(
      child: Container(
        width: 122,
        height: 122,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: isDark
              ? const RadialGradient(
                  colors: [Color(0xFF33353E), Color(0xFF222329)],
                )
              : const RadialGradient(
                  colors: [Colors.white, Color(0xFFF3F7FD)],
                ),
          border: Border.all(
            color: isDark ? const Color(0x44FFFFFF) : _loginGoldRim,
            width: 2.8,
          ),
          boxShadow: [
            if (isDark)
              const BoxShadow(
                color: Color(0x800A0B0E),
                offset: Offset(0, 10),
                blurRadius: 20,
              )
            else ...[
              const BoxShadow(
                color: Color(0x2E1E70E8),
                offset: Offset(0, 10),
                blurRadius: 22,
              ),
              const BoxShadow(
                color: Color(0x4DECC868),
                offset: Offset(0, 0),
                blurRadius: 10,
              ),
            ],
          ],
        ),
        padding: const EdgeInsets.all(6),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: isDark
                ? const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF2A2B33), Color(0xFF1B1C22)],
                  )
                : const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.white, Color(0xFFE8F1FC)],
                  ),
            border: Border.all(
              color: isDark ? const Color(0x22FFFFFF) : const Color(0x66D4AF37),
              width: 1.0,
            ),
          ),
          child: ClipOval(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Image.asset(
                'assets/images/vtindex_app_icon_source.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Image.asset(
                  'assets/images/vtindex_logo_img.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginContent({required bool isDark}) {
    final titleColor = isDark ? Colors.white : _loginDarkBlueText;
    final subtitleColor = isDark ? const Color(0xFF9CA2B2) : _loginMutedBlueText;
    final dividerColor = isDark ? const Color(0xFF383B47) : const Color(0xFFD4E2F2);
    final inputBg = isDark ? const Color(0xFF1C1D23) : const Color(0xFFF4F8FD);
    final inputBorder = isDark ? const Color(0x2EFFFFFF) : _loginGoldBorder;
    final inputTextColor = isDark ? Colors.white : _loginDarkBlueText;
    final placeholderColor = isDark ? const Color(0xFFADB4C3) : _loginPlaceholderText;
    final prefixIconColor = isDark ? const Color(0xFF8A90A2) : _loginRoyalBlue;

    return Form(
      key: _loginFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildLogoEmblem(isDark: isDark),
          const SizedBox(height: 20),

          // "Welcome Back"
          Text(
            'Welcome Back',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: titleColor,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 8),

          // "— Sign in to continue —"
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 1,
                  color: dividerColor,
                  margin: const EdgeInsets.only(left: 14, right: 12),
                ),
              ),
              Text(
                'Sign in to continue',
                style: TextStyle(
                  color: subtitleColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
              Expanded(
                child: Container(
                  height: 1,
                  color: dividerColor,
                  margin: const EdgeInsets.only(left: 12, right: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Field 1: Username or Email
          Container(
            decoration: BoxDecoration(
              color: inputBg,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: inputBorder, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: isDark ? const Color(0x40000000) : const Color(0x0F0D47A1),
                  offset: const Offset(0, 3),
                  blurRadius: 8,
                ),
              ],
            ),
            child: TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textCapitalization: TextCapitalization.none,
                autocorrect: false,
                textInputAction: TextInputAction.next,
                validator: (value) => _required(value, 'your username or email'),
                cursorColor: isDark ? const Color(0xFF6DA2F5) : _loginRoyalBlue,
                style: TextStyle(
                  color: inputTextColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  hintText: 'Enter username or email',
                  hintStyle: TextStyle(
                    color: placeholderColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.05,
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 18, right: 12),
                    child: Icon(
                      LucideIcons.user,
                      color: prefixIconColor,
                      size: 21,
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 50, minHeight: 24),
                  contentPadding: const EdgeInsets.symmetric(vertical: 18).copyWith(right: 20),
                  errorMaxLines: 2,
                ),
              ),
          ),
          const SizedBox(height: 16),

          // Field 2: Password
          Container(
            decoration: BoxDecoration(
              color: inputBg,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: inputBorder, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: isDark ? const Color(0x40000000) : const Color(0x0F0D47A1),
                  offset: const Offset(0, 3),
                  blurRadius: 8,
                ),
              ],
            ),
            child: TextFormField(
                controller: _passwordController,
                validator: (value) => _required(value, 'your password'),
                obscureText: !_passwordVisible,
                obscuringCharacter: '•',
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
                cursorColor: isDark ? const Color(0xFF6DA2F5) : _loginRoyalBlue,
                style: TextStyle(
                  color: inputTextColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: _passwordVisible ? 0 : 2.5,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  hintText: 'Enter your password',
                  hintStyle: TextStyle(
                    color: placeholderColor,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0,
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 18, right: 12),
                    child: Icon(
                      LucideIcons.lock,
                      color: prefixIconColor,
                      size: 21,
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 50, minHeight: 24),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: IconButton(
                      onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
                      icon: Icon(
                        _passwordVisible ? LucideIcons.eye : LucideIcons.eyeOff,
                        color: placeholderColor,
                        size: 20,
                      ),
                      tooltip: _passwordVisible ? 'Hide password' : 'Show password',
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 18).copyWith(right: 8),
                  errorMaxLines: 2,
                ),
              ),
          ),
          const SizedBox(height: 14),

          // Remember Me & Forgot Password? row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: InkWell(
                  onTap: () {
                setState(() => _rememberMe = !_rememberMe);
                unawaited(_saveRememberedLogin());
              },
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: _rememberMe
                                ? (isDark ? const Color(0xFF2575FC) : _loginRoyalBlue)
                                : (isDark ? const Color(0xFF1E1F24) : Colors.white),
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: _rememberMe
                                  ? (isDark ? const Color(0xFF2575FC) : _loginRoyalBlue)
                                  : (isDark ? const Color(0xFF454958) : const Color(0xFFBACADB)),
                              width: 1.5,
                            ),
                            boxShadow: [
                              if (_rememberMe)
                                BoxShadow(
                                  color: (isDark ? const Color(0xFF2575FC) : const Color(0xFF1E70E8)).withValues(alpha: 0.35),
                                  offset: const Offset(0, 2),
                                  blurRadius: 4,
                                ),
                            ],
                          ),
                          child: _rememberMe
                              ? const Icon(Icons.check, size: 13, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Remember Me',
                          style: TextStyle(
                            color: titleColor,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: _showHelpModal,
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: isDark ? const Color(0xFF6DA2F5) : const Color(0xFF134282),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),

          // Login button (Royal blue gradient pill with gold rim & arrow)
          _buildRaisedButton(
            label: _isSubmitting ? 'Signing in...' : 'Login',
            onPressed: _isSubmitting ? () {} : _submit,
            isDark: isDark,
            isLoading: _isSubmitting,
          ),
          const SizedBox(height: 28),

          // Sign up link
          Center(
            child: InkWell(
              onTap: () => setState(() => _isSignUp = true),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text.rich(
                  TextSpan(
                    text: "Don't have an account? ",
                    style: TextStyle(
                      color: subtitleColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    children: [
                      TextSpan(
                        text: 'Sign up',
                        style: TextStyle(
                          color: isDark ? const Color(0xFF6DA2F5) : _loginRoyalBlue,
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
                  color: subtitleColor,
                  fontSize: 11,
                ),
              ),
            ),
          ],

          if (_biometricEnabled && _biometricAvailable) ...[
            const SizedBox(height: 24),
            Center(
              child: _buildFingerprintButton(isDark: isDark),
            ),
          ],

          const SizedBox(height: 20),

          // Forgot your login details helper
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
                      color: subtitleColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    children: [
                      TextSpan(
                        text: 'Get help login in.',
                        style: TextStyle(
                          color: isDark ? const Color(0xFF6DA2F5) : const Color(0xFF134282),
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

  Widget _buildSignUpContent({required bool isDark}) {
    final titleColor = isDark ? Colors.white : _loginDarkBlueText;
    final subtitleColor = isDark ? const Color(0xFF9CA2B2) : _loginMutedBlueText;
    final inputBg = isDark ? const Color(0xFF1C1D23) : const Color(0xFFF4F8FD);
    final inputBorder = isDark ? const Color(0x2EFFFFFF) : _loginGoldBorder;
    final inputTextColor = isDark ? Colors.white : _loginDarkBlueText;
    final placeholderColor = isDark ? const Color(0xFF757989) : _loginPlaceholderText;
    final prefixIconColor = isDark ? const Color(0xFF8A90A2) : _loginRoyalBlue;

    return Form(
      key: _signUpFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildLogoEmblem(isDark: isDark),
          const SizedBox(height: 20),

          Center(
            child: Text(
              'Create Account',
              style: TextStyle(
                color: titleColor,
                fontSize: 26,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              'Start your trading journey with VT Index',
              style: TextStyle(color: subtitleColor, fontSize: 13),
            ),
          ),
          const SizedBox(height: 24),

          // Full Name
          Container(
            height: 56,
            decoration: BoxDecoration(
              color: inputBg,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: inputBorder, width: 1.2),
            ),
            child: Center(
              child: TextFormField(
                controller: _nameController,
                cursorColor: isDark ? const Color(0xFF6DA2F5) : _loginRoyalBlue,
                style: TextStyle(color: inputTextColor, fontSize: 15, fontWeight: FontWeight.w600),
                validator: (v) => _required(v, 'your full name'),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  hintText: 'Enter your full name',
                  hintStyle: TextStyle(color: placeholderColor, fontSize: 14.5),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 18, right: 12),
                    child: Icon(LucideIcons.user, color: prefixIconColor, size: 20),
                  ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 50, minHeight: 24),
                  contentPadding: const EdgeInsets.only(right: 20),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Email Address
          Container(
            height: 56,
            decoration: BoxDecoration(
              color: inputBg,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: inputBorder, width: 1.2),
            ),
            child: Center(
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      cursorColor: isDark ? const Color(0xFF6DA2F5) : _loginRoyalBlue,
                      style: TextStyle(color: inputTextColor, fontSize: 15, fontWeight: FontWeight.w600),
                      validator: (v) {
                        final email = v?.trim() ?? '';
                        if (email.isEmpty) return 'Enter your email address';
                        if (!email.contains('@') || !email.contains('.')) return 'Enter a valid email address';
                        return null;
                      },
                      onChanged: (_) {
                        if (_emailVerified) setState(() => _emailVerified = false);
                      },
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        hintText: 'Enter your email address',
                        hintStyle: TextStyle(color: placeholderColor, fontSize: 14.5),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(left: 18, right: 12),
                          child: Icon(LucideIcons.mail, color: prefixIconColor, size: 20),
                        ),
                        prefixIconConstraints: const BoxConstraints(minWidth: 50, minHeight: 24),
                        contentPadding: const EdgeInsets.only(right: 12),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
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
                        backgroundColor: _emailVerified ? const Color(0xFF2E7D32) : _loginRoyalBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        minimumSize: const Size(0, 36),
                      ),
                      child: Text(_emailVerified ? 'Verified' : 'Verify', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // IB Referral Code (Optional)
          Container(
            height: 56,
            decoration: BoxDecoration(
              color: inputBg,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: inputBorder, width: 1.2),
            ),
            child: Center(
              child: TextFormField(
                controller: _referralController,
                cursorColor: isDark ? const Color(0xFF6DA2F5) : _loginRoyalBlue,
                style: TextStyle(color: inputTextColor, fontSize: 15, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  hintText: 'Enter referral code (optional)',
                  hintStyle: TextStyle(color: placeholderColor, fontSize: 14.5),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 18, right: 12),
                    child: Icon(LucideIcons.tag, color: prefixIconColor, size: 20),
                  ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 50, minHeight: 24),
                  contentPadding: const EdgeInsets.only(right: 20),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Password
          Container(
            height: 56,
            decoration: BoxDecoration(
              color: inputBg,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: inputBorder, width: 1.2),
            ),
            child: Center(
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: !_passwordVisible,
                      obscuringCharacter: '•',
                      cursorColor: isDark ? const Color(0xFF6DA2F5) : _loginRoyalBlue,
                      style: TextStyle(
                        color: inputTextColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: _passwordVisible ? 0 : 2.5,
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Create a password';
                        if (v.length < 8) return 'Use at least 8 characters';
                        return null;
                      },
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        hintText: 'Password',
                        hintStyle: TextStyle(color: placeholderColor, fontSize: 14.5, letterSpacing: 0),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(left: 18, right: 12),
                          child: Icon(LucideIcons.lock, color: prefixIconColor, size: 20),
                        ),
                        prefixIconConstraints: const BoxConstraints(minWidth: 50, minHeight: 24),
                        contentPadding: const EdgeInsets.only(right: 8),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: IconButton(
                      onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
                      icon: Icon(
                        _passwordVisible ? LucideIcons.eye : LucideIcons.eyeOff,
                        color: placeholderColor,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Terms Checkbox
          Row(
            children: [
              Checkbox(
                value: _acceptedTerms,
                onChanged: (v) => setState(() => _acceptedTerms = v ?? false),
                activeColor: isDark ? const Color(0xFF2575FC) : _loginRoyalBlue,
                checkColor: Colors.white,
                side: BorderSide(color: isDark ? const Color(0xFF454958) : const Color(0xFFBACADB)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    text: 'I agree to the ',
                    style: TextStyle(color: subtitleColor, fontSize: 12.5),
                    children: [
                      TextSpan(text: 'Terms & Conditions', style: TextStyle(color: isDark ? const Color(0xFF6DA2F5) : _loginRoyalBlue, fontWeight: FontWeight.w600)),
                      const TextSpan(text: ' and '),
                      TextSpan(text: 'Privacy Policy', style: TextStyle(color: isDark ? const Color(0xFF6DA2F5) : _loginRoyalBlue, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),

          _buildRaisedButton(
            label: 'Create Account',
            onPressed: _submitSignUp,
            isDark: isDark,
          ),
          const SizedBox(height: 22),

          Center(
            child: InkWell(
              onTap: () => setState(() => _isSignUp = false),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Text.rich(
                  TextSpan(
                    text: 'Already have an account? ',
                    style: TextStyle(color: subtitleColor, fontSize: 13),
                    children: [
                      TextSpan(text: 'Login', style: TextStyle(color: isDark ? const Color(0xFF6DA2F5) : _loginRoyalBlue, fontWeight: FontWeight.w700)),
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

  Widget _buildRaisedButton({
    required String label,
    required VoidCallback onPressed,
    required bool isDark,
    bool isLoading = false,
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
          gradient: isDark
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF353740), Color(0xFF24252C)],
                )
              : const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF267DFF), Color(0xFF0B52C7)],
                ),
          border: Border.all(
            color: isDark ? const Color(0x44FFFFFF) : _loginGoldRim,
            width: 1.5,
          ),
          boxShadow: [
            if (isDark)
              const BoxShadow(
                color: Color(0x66000000),
                offset: Offset(0, 8),
                blurRadius: 18,
              )
            else
              const BoxShadow(
                color: Color(0x661E70E8),
                offset: Offset(0, 8),
                blurRadius: 18,
              ),
          ],
        ),
        child: SizedBox(
          height: 58,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Center(
                child: isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              if (!isLoading)
                Positioned(
                right: 8,
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.22),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFingerprintButton({required bool isDark}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _signInWithBiometrics,
        borderRadius: BorderRadius.circular(42),
        splashColor: isDark ? const Color(0x33FFFFFF) : const Color(0x331E70E8),
        child: Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark ? const Color(0xFF292A32) : Colors.white,
            border: Border.all(
              color: isDark ? const Color(0x44FFFFFF) : _loginGoldRim,
              width: 2.2,
            ),
            boxShadow: [
              if (isDark)
                const BoxShadow(
                  color: Color(0x80000000),
                  offset: Offset(0, 6),
                  blurRadius: 14,
                )
              else ...[
                const BoxShadow(
                  color: Color(0x261E70E8),
                  offset: Offset(0, 6),
                  blurRadius: 14,
                ),
                const BoxShadow(
                  color: Color(0x40D4AF37),
                  offset: Offset(0, 0),
                  blurRadius: 8,
                ),
              ],
            ],
          ),
          padding: const EdgeInsets.all(5),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? const Color(0xFF202127) : const Color(0xFFF7FAFF),
              border: Border.all(
                color: isDark ? const Color(0x22FFFFFF) : const Color(0x66D4AF37),
                width: 1.0,
              ),
            ),
            child: Center(
              child: _biometricBusy
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: isDark ? Colors.white : _loginRoyalBlue,
                      ),
                    )
                  : Icon(
                      Icons.fingerprint,
                      color: isDark ? Colors.white : _loginRoyalBlue,
                      size: 44,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom painter for the ethereal blue ambient background with fluid ribbons, golden curves, and dot matrix
class _LoginBackgroundPainter extends CustomPainter {
  const _LoginBackgroundPainter({this.isDark = false});

  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    if (isDark) {
      _paintDark(canvas, size);
    } else {
      _paintLight(canvas, size);
    }
  }

  void _paintDark(Canvas canvas, Size size) {
    // 1. Charcoal neumorphic dark background
    final baseGradient = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF1B1C21), Color(0xFF141518)],
    ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, Paint()..shader = baseGradient);

    // 2. Subtle top-left radial glow
    final topOrbPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment.topLeft,
        radius: 1.0,
        colors: [Color(0x333A3C46), Color(0x003A3C46)],
      ).createShader(Rect.fromCircle(center: const Offset(40, 70), radius: 210));
    canvas.drawCircle(const Offset(40, 70), 210, topOrbPaint);

    // 3. Subtle bottom-left 4x4 matrix of dark dots
    final dotPaint = Paint()..color = const Color(0x337A7E8D);
    for (int r = 0; r < 4; r++) {
      for (int c = 0; c < 4; c++) {
        canvas.drawCircle(Offset(28.0 + (c * 13.0), size.height - 110.0 + (r * 13.0)), 2.2, dotPaint);
      }
    }
  }

  void _paintLight(Canvas canvas, Size size) {
    // 1. Soft atmospheric base gradient matching reference
    final baseGradient = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFFEFF5FD),
        Color(0xFFF8FAFE),
        Color(0xFFE2EDFC),
      ],
    ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, Paint()..shader = baseGradient);

    // 2. Top-left ambient royal blue sphere with golden boundary curve
    final blueOrbPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment.topLeft,
        radius: 1.0,
        colors: [Color(0xFF2575FC), Color(0xFF0F52BA), Color(0x000F52BA)],
        stops: [0.0, 0.65, 1.0],
      ).createShader(Rect.fromCircle(center: const Offset(40, 70), radius: 210));
    canvas.drawCircle(const Offset(40, 70), 210, blueOrbPaint);

    final goldRibbonPaint = Paint()
      ..color = const Color(0xFFECC868)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6;

    final pathTop = Path();
    pathTop.moveTo(0, 175);
    pathTop.cubicTo(65, 160, 145, 115, 170, 0);
    canvas.drawPath(pathTop, goldRibbonPaint);

    // 3. Right side floating blurred sphere
    final rightOrbPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0x7386B8F7), Color(0x0086B8F7)],
      ).createShader(Rect.fromCircle(center: Offset(size.width + 10, size.height * 0.28), radius: 150));
    canvas.drawCircle(Offset(size.width + 10, size.height * 0.28), 150, rightOrbPaint);

    // 4. Bottom-right sweeping fluid royal curves with gold edge
    final bottomBlueGrad = const RadialGradient(
      center: Alignment.bottomRight,
      radius: 1.15,
      colors: [Color(0xFF0B46A8), Color(0xFF1565C0), Color(0x001976D2)],
      stops: [0.0, 0.7, 1.0],
    ).createShader(Rect.fromCircle(center: Offset(size.width, size.height), radius: size.width * 0.85));

    final bottomPath = Path();
    bottomPath.moveTo(size.width * 0.28, size.height);
    bottomPath.cubicTo(size.width * 0.48, size.height * 0.88, size.width * 0.74, size.height * 0.82, size.width, size.height * 0.77);
    bottomPath.lineTo(size.width, size.height);
    bottomPath.close();
    canvas.drawPath(bottomPath, Paint()..shader = bottomBlueGrad);

    final goldBottomPath = Path();
    goldBottomPath.moveTo(size.width * 0.28, size.height);
    goldBottomPath.cubicTo(size.width * 0.48, size.height * 0.88, size.width * 0.74, size.height * 0.82, size.width, size.height * 0.77);
    canvas.drawPath(goldBottomPath, goldRibbonPaint);

    // 5. Bottom-left 4x4 matrix of subtle light blue dots
    final dotPaint = Paint()..color = const Color(0x999EBCE8);
    for (int r = 0; r < 4; r++) {
      for (int c = 0; c < 4; c++) {
        canvas.drawCircle(Offset(28.0 + (c * 13.0), size.height - 110.0 + (r * 13.0)), 2.2, dotPaint);
      }
    }

    // 6. Bottom-right text: "MORE THAN A GAME" with gold horizontal line
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'MORE\nTHAN\nA GAME',
        style: TextStyle(
          color: Color(0xFF0F1E36),
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 2.2,
          height: 1.3,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    final textX = size.width - textPainter.width - 24;
    final textY = size.height - textPainter.height - 30;
    if (textX > 0 && textY > 0) {
      textPainter.paint(canvas, Offset(textX, textY));
      final barPaint = Paint()
        ..color = const Color(0xFFECC868)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(textX + (textPainter.width - 22) / 2, textY + textPainter.height + 6, 22, 2.5),
          const Radius.circular(2),
        ),
        barPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _LoginBackgroundPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}

/// Standalone entry point for the account registration form.
class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) => const LoginPage(initialSignUp: true);
}
