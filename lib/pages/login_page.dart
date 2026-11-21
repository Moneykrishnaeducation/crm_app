part of '../main.dart';

// Light Glassmorphism Theme with Blue, Gold & White
const _loginCardGlassBg = Color(0xD9FFFFFF);
const _loginGoldRim = Color(0xFFECC868);
const _loginGoldBorder = Color(0x99D4AF37);
const _loginRoyalBlue = Color(0xFF1E70E8);
const _loginDarkBlueText = Color(0xFF0D1B3E);
const _loginMutedBlueText = Color(0xFF5A718F);
const _loginPlaceholderText = Color(0xFF7E92A8);

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
  bool _darkModeActive = false;
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

  void _submit() {
    final form = _loginFormKey.currentState;
    if (form == null || !form.validate()) return;
    widget.onLogin?.call();
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

  void _showLanguageSelector() {
    final languages = ['English', 'Español', 'Français', 'Deutsch', '中文', 'العربية'];
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                  color: _loginDarkBlueText,
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
                      color: _selectedLanguage == lang ? _loginRoyalBlue : _loginMutedBlueText,
                      fontWeight: _selectedLanguage == lang ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  trailing: _selectedLanguage == lang
                      ? const Icon(LucideIcons.check, color: _loginRoyalBlue, size: 18)
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
                showAppMessage('Password reset instructions sent to your registered email.');
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
                showAppMessage('Support chat will open shortly.');
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
    return Scaffold(
      backgroundColor: const Color(0xFFEAF1FB),
      body: Stack(
        children: [
          // 1. Decorative background graphic painter
          Positioned.fill(
            child: CustomPaint(
              painter: _LoginBackgroundPainter(),
            ),
          ),

          // Optional subtle overlay of ribbon background art if available
          Positioned.fill(
            child: Opacity(
              opacity: 0.35,
              child: Image.asset(
                'assets/images/login_light_ribbons.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
              ),
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
                          color: _loginCardGlassBg,
                          borderRadius: BorderRadius.circular(38),
                          border: Border.all(color: _loginGoldBorder, width: 1.5),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x261E70E8),
                              offset: Offset(0, 16),
                              blurRadius: 36,
                            ),
                            BoxShadow(
                              color: Color(0x33D4AF37),
                              offset: Offset(0, 0),
                              blurRadius: 10,
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.center,
      child: SizedBox(
        width: 460,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left: "UI Series ⌵"
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0x66D4AF37), width: 0.9),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    offset: Offset(0, 2),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'UI Series',
                    style: TextStyle(
                      color: Color(0xFF0F1E36),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 3),
                  Icon(Icons.keyboard_arrow_down, size: 15, color: Color(0xFF0F1E36)),
                ],
              ),
            ),

            // Center: "English ⌵"
            InkWell(
              onTap: _showLanguageSelector,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _selectedLanguage,
                      style: const TextStyle(
                        color: Color(0xFF0F1E36),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(Icons.keyboard_arrow_down, size: 15, color: Color(0xFF0F1E36)),
                  ],
                ),
              ),
            ),

            // Right: "Dark Mode"
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Dark Mode',
                  style: TextStyle(
                    color: Color(0xFF5A718F),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                _buildDarkModeSwitch(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDarkModeSwitch() {
    return GestureDetector(
      onTap: () => setState(() => _darkModeActive = !_darkModeActive),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 46,
        height: 25,
        padding: const EdgeInsets.all(2.5),
        decoration: BoxDecoration(
          color: _darkModeActive ? const Color(0xFF1E3A68) : const Color(0xFFD6E3F5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x66D4AF37), width: 0.8),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 250),
          alignment: _darkModeActive ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Color(0x29000000),
                  blurRadius: 3,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Icon(
              _darkModeActive ? Icons.nightlight_round : Icons.wb_sunny_rounded,
              size: 12,
              color: _darkModeActive ? _loginRoyalBlue : const Color(0xFFD8A82E),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoEmblem() {
    return Center(
      child: Container(
        width: 118,
        height: 118,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Color(0xFFF0F5FD)],
          ),
          border: Border.all(color: _loginGoldRim, width: 2.5),
          boxShadow: const [
            BoxShadow(
              color: Color(0x291E70E8),
              offset: Offset(0, 10),
              blurRadius: 22,
            ),
            BoxShadow(
              color: Color(0x40D4AF37),
              offset: Offset(0, 0),
              blurRadius: 10,
            ),
          ],
        ),
        padding: const EdgeInsets.all(6),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white, Color(0xFFE8F1FC)],
            ),
            border: Border.all(color: const Color(0x66D4AF37), width: 1.0),
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

  Widget _buildLoginContent() {
    return Form(
      key: _loginFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTopBar(),
          const SizedBox(height: 20),
          _buildLogoEmblem(),
          const SizedBox(height: 18),

          // "Welcome Back"
          const Text(
            'Welcome Back',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _loginDarkBlueText,
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
                  color: const Color(0xFFD4E2F2),
                  margin: const EdgeInsets.only(left: 14, right: 12),
                ),
              ),
              const Text(
                'Sign in to continue',
                style: TextStyle(
                  color: _loginMutedBlueText,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
              Expanded(
                child: Container(
                  height: 1,
                  color: const Color(0xFFD4E2F2),
                  margin: const EdgeInsets.only(left: 12, right: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),

          // Field 1: Username or Email
          Container(
            height: 58,
            decoration: BoxDecoration(
              color: const Color(0xFFF4F8FD),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: _loginGoldBorder, width: 1.2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0F0D47A1),
                  offset: Offset(0, 3),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Center(
              child: TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                cursorColor: _loginRoyalBlue,
                style: const TextStyle(
                  color: _loginDarkBlueText,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  hintText: 'Username or Email',
                  hintStyle: TextStyle(
                    color: _loginPlaceholderText,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500,
                  ),
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(left: 18, right: 12),
                    child: Icon(
                      LucideIcons.user,
                      color: _loginRoyalBlue,
                      size: 21,
                    ),
                  ),
                  prefixIconConstraints: BoxConstraints(minWidth: 50, minHeight: 24),
                  contentPadding: EdgeInsets.only(right: 20),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Field 2: Password
          Container(
            height: 58,
            decoration: BoxDecoration(
              color: const Color(0xFFF4F8FD),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: _loginGoldBorder, width: 1.2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0F0D47A1),
                  offset: Offset(0, 3),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Center(
              child: TextFormField(
                controller: _passwordController,
                obscureText: !_passwordVisible,
                obscuringCharacter: '•',
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
                cursorColor: _loginRoyalBlue,
                style: TextStyle(
                  color: _loginDarkBlueText,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: _passwordVisible ? 0 : 2.5,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  hintText: 'Password',
                  hintStyle: const TextStyle(
                    color: _loginPlaceholderText,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0,
                  ),
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(left: 18, right: 12),
                    child: Icon(
                      LucideIcons.lock,
                      color: _loginRoyalBlue,
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
                        color: _loginPlaceholderText,
                        size: 20,
                      ),
                      tooltip: _passwordVisible ? 'Hide password' : 'Show password',
                    ),
                  ),
                  contentPadding: const EdgeInsets.only(right: 8),
                ),
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
                  onTap: () => setState(() => _rememberMe = !_rememberMe),
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
                            color: _rememberMe ? _loginRoyalBlue : Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: _rememberMe ? _loginRoyalBlue : const Color(0xFFBACADB),
                              width: 1.5,
                            ),
                            boxShadow: [
                              if (_rememberMe)
                                const BoxShadow(
                                  color: Color(0x331E70E8),
                                  offset: Offset(0, 2),
                                  blurRadius: 4,
                                ),
                            ],
                          ),
                          child: _rememberMe
                              ? const Icon(Icons.check, size: 13, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Remember Me',
                          style: TextStyle(
                            color: _loginDarkBlueText,
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
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: Color(0xFF134282),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),

          // Login button (Royal blue gradient pill with gold rim & arrow)
          _buildRaisedButton(
            label: 'Login',
            onPressed: _submit,
          ),
          const SizedBox(height: 22),

          // "— OR CONTINUE WITH —"
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 1,
                  color: const Color(0xFFD4E2F2),
                  margin: const EdgeInsets.only(left: 14, right: 12),
                ),
              ),
              const Text(
                'OR CONTINUE WITH',
                style: TextStyle(
                  color: Color(0xFF7E92A8),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              Expanded(
                child: Container(
                  height: 1,
                  color: const Color(0xFFD4E2F2),
                  margin: const EdgeInsets.only(left: 12, right: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Social Login Buttons: Google, Discord, Facebook
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSocialButton(
                icon: SvgPicture.asset('assets/icons/google_logo.svg', width: 24, height: 24),
                onTap: () => showAppMessage('Google sign-in coming soon.'),
              ),
              const SizedBox(width: 22),
              _buildSocialButton(
                icon: const _DiscordLogoIcon(),
                onTap: () => showAppMessage('Discord sign-in coming soon.'),
              ),
              const SizedBox(width: 22),
              _buildSocialButton(
                icon: const Icon(Icons.facebook, color: Color(0xFF1877F2), size: 30),
                onTap: () => showAppMessage('Facebook sign-in coming soon.'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Sign up link
          Center(
            child: InkWell(
              onTap: () => setState(() => _isSignUp = true),
              borderRadius: BorderRadius.circular(8),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text.rich(
                  TextSpan(
                    text: "Don't have an account? ",
                    style: TextStyle(
                      color: _loginMutedBlueText,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    children: [
                      TextSpan(
                        text: 'Sign up',
                        style: TextStyle(
                          color: _loginRoyalBlue,
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
            const Center(
              child: Text(
                'Biometric sign-in unavailable. Use your login ID and password.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _loginMutedBlueText,
                  fontSize: 11,
                ),
              ),
            ),
          ],

          if (_biometricEnabled && _biometricAvailable) ...[
            const SizedBox(height: 20),
            Center(
              child: _buildFingerprintButton(),
            ),
          ],

          const SizedBox(height: 16),

          // Forgot your login details helper
          Center(
            child: InkWell(
              onTap: _showHelpModal,
              borderRadius: BorderRadius.circular(8),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text.rich(
                  TextSpan(
                    text: 'Forgot your login details? ',
                    style: TextStyle(
                      color: _loginMutedBlueText,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    children: [
                      TextSpan(
                        text: 'Get help login in.',
                        style: TextStyle(
                          color: Color(0xFF134282),
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
          const SizedBox(height: 20),
          _buildLogoEmblem(),
          const SizedBox(height: 18),

          const Center(
            child: Text(
              'Create Account',
              style: TextStyle(
                color: _loginDarkBlueText,
                fontSize: 26,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Center(
            child: Text(
              'Start your trading journey with VT Index',
              style: TextStyle(color: _loginMutedBlueText, fontSize: 13),
            ),
          ),
          const SizedBox(height: 24),

          // Full Name
          Container(
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFF4F8FD),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: _loginGoldBorder, width: 1.2),
            ),
            child: Center(
              child: TextFormField(
                controller: _nameController,
                cursorColor: _loginRoyalBlue,
                style: const TextStyle(color: _loginDarkBlueText, fontSize: 15, fontWeight: FontWeight.w600),
                validator: (v) => _required(v, 'your full name'),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  hintText: 'Full Name',
                  hintStyle: TextStyle(color: _loginPlaceholderText, fontSize: 14.5),
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(left: 18, right: 12),
                    child: Icon(LucideIcons.user, color: _loginRoyalBlue, size: 20),
                  ),
                  prefixIconConstraints: BoxConstraints(minWidth: 50, minHeight: 24),
                  contentPadding: EdgeInsets.only(right: 20),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Email Address
          Container(
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFF4F8FD),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: _loginGoldBorder, width: 1.2),
            ),
            child: Center(
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      cursorColor: _loginRoyalBlue,
                      style: const TextStyle(color: _loginDarkBlueText, fontSize: 15, fontWeight: FontWeight.w600),
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
                        hintText: 'Email Address',
                        hintStyle: TextStyle(color: _loginPlaceholderText, fontSize: 14.5),
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(left: 18, right: 12),
                          child: Icon(LucideIcons.mail, color: _loginRoyalBlue, size: 20),
                        ),
                        prefixIconConstraints: BoxConstraints(minWidth: 50, minHeight: 24),
                        contentPadding: EdgeInsets.only(right: 12),
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
              color: const Color(0xFFF4F8FD),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: _loginGoldBorder, width: 1.2),
            ),
            child: Center(
              child: TextFormField(
                controller: _referralController,
                cursorColor: _loginRoyalBlue,
                style: const TextStyle(color: _loginDarkBlueText, fontSize: 15, fontWeight: FontWeight.w600),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  hintText: 'IB Referral Code (Optional)',
                  hintStyle: TextStyle(color: _loginPlaceholderText, fontSize: 14.5),
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(left: 18, right: 12),
                    child: Icon(LucideIcons.tag, color: _loginRoyalBlue, size: 20),
                  ),
                  prefixIconConstraints: BoxConstraints(minWidth: 50, minHeight: 24),
                  contentPadding: EdgeInsets.only(right: 20),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Password
          Container(
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFF4F8FD),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: _loginGoldBorder, width: 1.2),
            ),
            child: Center(
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: !_passwordVisible,
                      obscuringCharacter: '•',
                      cursorColor: _loginRoyalBlue,
                      style: TextStyle(
                        color: _loginDarkBlueText,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: _passwordVisible ? 0 : 2.5,
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Create a password';
                        if (v.length < 8) return 'Use at least 8 characters';
                        return null;
                      },
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        hintText: 'Password',
                        hintStyle: TextStyle(color: _loginPlaceholderText, fontSize: 14.5, letterSpacing: 0),
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(left: 18, right: 12),
                          child: Icon(LucideIcons.lock, color: _loginRoyalBlue, size: 20),
                        ),
                        prefixIconConstraints: BoxConstraints(minWidth: 50, minHeight: 24),
                        contentPadding: EdgeInsets.only(right: 8),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: IconButton(
                      onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
                      icon: Icon(
                        _passwordVisible ? LucideIcons.eye : LucideIcons.eyeOff,
                        color: _loginPlaceholderText,
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
                activeColor: _loginRoyalBlue,
                checkColor: Colors.white,
                side: const BorderSide(color: Color(0xFFBACADB)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    text: 'I agree to the ',
                    style: const TextStyle(color: _loginMutedBlueText, fontSize: 12.5),
                    children: const [
                      TextSpan(text: 'Terms & Conditions', style: TextStyle(color: _loginRoyalBlue, fontWeight: FontWeight.w600)),
                      TextSpan(text: ' and '),
                      TextSpan(text: 'Privacy Policy', style: TextStyle(color: _loginRoyalBlue, fontWeight: FontWeight.w600)),
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
          ),
          const SizedBox(height: 22),

          Center(
            child: InkWell(
              onTap: () => setState(() => _isSignUp = false),
              borderRadius: BorderRadius.circular(8),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Text.rich(
                  TextSpan(
                    text: 'Already have an account? ',
                    style: TextStyle(color: _loginMutedBlueText, fontSize: 13),
                    children: [
                      TextSpan(text: 'Login', style: TextStyle(color: _loginRoyalBlue, fontWeight: FontWeight.w700)),
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
            colors: [Color(0xFF267DFF), Color(0xFF0B52C7)],
          ),
          border: Border.all(color: _loginGoldRim, width: 1.5),
          boxShadow: const [
            BoxShadow(
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
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
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

  Widget _buildSocialButton({
    required Widget icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        splashColor: const Color(0x261E70E8),
        child: Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0x40D4AF37), width: 1.2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x140D47A1),
                offset: Offset(0, 4),
                blurRadius: 10,
              ),
            ],
          ),
          child: Center(child: icon),
        ),
      ),
    );
  }

  Widget _buildFingerprintButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _signInWithBiometrics,
        borderRadius: BorderRadius.circular(42),
        splashColor: const Color(0x331E70E8),
        child: Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: _loginGoldRim, width: 2.0),
            boxShadow: const [
              BoxShadow(
                color: Color(0x261E70E8),
                offset: Offset(0, 6),
                blurRadius: 14,
              ),
              BoxShadow(
                color: Color(0x40D4AF37),
                offset: Offset(0, 0),
                blurRadius: 8,
              ),
            ],
          ),
          padding: const EdgeInsets.all(5),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFF7FAFF),
              border: Border.all(color: const Color(0x66D4AF37), width: 1.0),
            ),
            child: Center(
              child: _biometricBusy
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: _loginRoyalBlue),
                    )
                  : const Icon(
                      Icons.fingerprint,
                      color: _loginRoyalBlue,
                      size: 44,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom painter for the Discord gamepad controller logo
class _DiscordLogoIcon extends StatelessWidget {
  const _DiscordLogoIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: const BoxDecoration(
        color: Color(0xFF5865F2),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: CustomPaint(
          size: const Size(20, 16),
          painter: _DiscordPainter(),
        ),
      ),
    );
  }
}

class _DiscordPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width * 0.15, size.height * 0.2);
    path.cubicTo(size.width * 0.35, size.height * 0.05, size.width * 0.65, size.height * 0.05, size.width * 0.85, size.height * 0.2);
    path.cubicTo(size.width * 0.98, size.height * 0.6, size.width * 0.9, size.height * 0.9, size.width * 0.9, size.height * 0.9);
    path.cubicTo(size.width * 0.8, size.height * 0.98, size.width * 0.7, size.height * 0.92, size.width * 0.7, size.height * 0.92);
    path.cubicTo(size.width * 0.65, size.height * 0.85, size.width * 0.6, size.height * 0.8, size.width * 0.6, size.height * 0.8);
    path.cubicTo(size.width * 0.55, size.height * 0.82, size.width * 0.45, size.height * 0.82, size.width * 0.4, size.height * 0.8);
    path.cubicTo(size.width * 0.4, size.height * 0.8, size.width * 0.35, size.height * 0.85, size.width * 0.3, size.height * 0.92);
    path.cubicTo(size.width * 0.3, size.height * 0.92, size.width * 0.2, size.height * 0.98, size.width * 0.1, size.height * 0.9);
    path.cubicTo(size.width * 0.1, size.height * 0.9, size.width * 0.02, size.height * 0.6, size.width * 0.15, size.height * 0.2);
    path.close();

    canvas.drawPath(path, paint);

    final eyePaint = Paint()..color = const Color(0xFF5865F2);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(size.width * 0.36, size.height * 0.52), width: 3.5, height: 4.5),
      eyePaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(size.width * 0.64, size.height * 0.52), width: 3.5, height: 4.5),
      eyePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom painter for the ethereal blue ambient background with fluid ribbons, golden curves, and dot matrix
class _LoginBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. Soft atmospheric base gradient
    final baseGradient = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFFE9F1FC),
        Color(0xFFF6F9FE),
        Color(0xFFDEEAFB),
      ],
    ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, Paint()..shader = baseGradient);

    // 2. Top-left ambient royal blue sphere and golden trim ribbon
    final blueOrbPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFF1E70E8), Color(0x001E70E8)],
      ).createShader(Rect.fromCircle(center: const Offset(40, 80), radius: 180));
    canvas.drawCircle(const Offset(40, 80), 180, blueOrbPaint);

    final goldRibbonPaint = Paint()
      ..color = const Color(0xFFECC868)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4;

    final pathTop = Path();
    pathTop.moveTo(0, 160);
    pathTop.cubicTo(60, 150, 140, 110, 160, 0);
    canvas.drawPath(pathTop, goldRibbonPaint);

    // 3. Right side floating blurred sphere
    final rightOrbPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0x6686B8F7), Color(0x0086B8F7)],
      ).createShader(Rect.fromCircle(center: Offset(size.width + 20, size.height * 0.3), radius: 140));
    canvas.drawCircle(Offset(size.width + 20, size.height * 0.3), 140, rightOrbPaint);

    // 4. Bottom-right sweeping fluid royal curves with gold edge
    final bottomBlueGrad = const RadialGradient(
      center: Alignment.bottomRight,
      radius: 1.2,
      colors: [Color(0xFF0D47A1), Color(0xFF1976D2), Color(0x001E88E5)],
    ).createShader(Rect.fromCircle(center: Offset(size.width, size.height), radius: size.width * 0.8));
    final bottomBluePaint = Paint()..shader = bottomBlueGrad;

    final bottomPath = Path();
    bottomPath.moveTo(size.width * 0.3, size.height);
    bottomPath.cubicTo(size.width * 0.5, size.height * 0.88, size.width * 0.75, size.height * 0.82, size.width, size.height * 0.78);
    bottomPath.lineTo(size.width, size.height);
    bottomPath.close();
    canvas.drawPath(bottomPath, bottomBluePaint);

    final goldBottomPath = Path();
    goldBottomPath.moveTo(size.width * 0.3, size.height);
    goldBottomPath.cubicTo(size.width * 0.5, size.height * 0.88, size.width * 0.75, size.height * 0.82, size.width, size.height * 0.78);
    canvas.drawPath(goldBottomPath, goldRibbonPaint);

    // 5. Bottom-left 4x4 matrix of subtle light blue dots
    final dotPaint = Paint()..color = const Color(0x809EBCE8);
    for (int r = 0; r < 4; r++) {
      for (int c = 0; c < 4; c++) {
        canvas.drawCircle(Offset(32.0 + (c * 13.0), size.height - 110.0 + (r * 13.0)), 2.2, dotPaint);
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
  bool shouldRepaint(covariant _LoginBackgroundPainter oldDelegate) => false;
}

/// Standalone entry point for the account registration form.
class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) => const LoginPage(initialSignUp: true);
}
