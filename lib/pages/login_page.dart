part of '../main.dart';

const _loginGold = Color(0xFFFFD45C);
const _loginBlue = Color(0xFF087BFF);

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
  bool _rememberMe = true;
  bool _acceptedTerms = true;
  bool _biometricEnabled = false;
  bool _biometricAvailable = false;
  bool _biometricBusy = false;
  bool _biometricAttempted = false;

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
    if (!_biometricEnabled || !_biometricAvailable || _biometricBusy) return;
    setState(() => _biometricBusy = true);
    try {
      final authenticated = await _biometricService.authenticate(
        localizedReason: 'Sign in to your VTIndex account',
      );
      if (!mounted) return;
      if (authenticated) {
        _submit();
      } else {
        setState(() => _biometricAttempted = true);
        showAppMessage('Biometric sign-in was canceled. Use your login ID and password instead.');
      }
    } on PlatformException {
      if (mounted) {
        setState(() => _biometricAttempted = true);
        showAppMessage('Biometric sign-in failed. Use your login ID and password instead.');
      }
    } on MissingPluginException {
      if (mounted) {
        setState(() => _biometricAttempted = true);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF031642),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/login_light_ribbons.png',
              fit: BoxFit.cover,
              cacheWidth: 1080,
              gaplessPlayback: true,
            ),
          ),
          const Positioned.fill(
            child: ColoredBox(color: Color(0x22020A20)),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 600;
                return Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(compact ? 20 : 48, 4, compact ? 20 : 48, 22),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: (constraints.maxHeight - 26).clamp(0, double.infinity).toDouble(),
                          ),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 860),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(height: compact ? 12 : 20),
                                  Image.asset(
                                    'assets/images/vtindex_logo.png',
                                    width: compact ? 230 : 300,
                                    height: compact ? 76 : 98,
                                    fit: BoxFit.contain,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _isSignUp
                                        ? 'Start your trading journey with VT Index.'
                                        : 'Sign in to your trading account',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: const Color(0xFFE5ECFF),
                                      fontSize: compact ? 17 : 25,
                                    ),
                                  ),
                                  SizedBox(height: compact ? 28 : 38),
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(maxWidth: 520),
                                    child: _isSignUp
                                        ? _buildSignUpCard(compact)
                                        : _buildLoginCard(compact),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginCard(bool compact) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(compact ? 16 : 36, compact ? 18 : 32, compact ? 16 : 36, compact ? 18 : 26),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color.fromARGB(41, 22, 26, 38), Color.fromARGB(66, 9, 13, 24), Color.fromARGB(61, 27, 26, 37)],
        ),
        borderRadius: BorderRadius.circular(compact ? 24 : 32),
        border: Border.all(color: const Color(0x66F1EAF8), width: 1),
        boxShadow: const [
          BoxShadow(color: Color(0x88000000), blurRadius: 35, offset: Offset(0, 18)),
          BoxShadow(color: Color(0x2297A7D9), blurRadius: 26, spreadRadius: -10),
        ],
      ),
      child: Form(
        key: _loginFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildModeTabs(compact),
            SizedBox(height: compact ? 18 : 30),
            _buildTextField(
              controller: _emailController,
              hint: 'Email or Login ID',
              icon: LucideIcons.userRound,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
            ),
            SizedBox(height: compact ? 12 : 20),
            _buildTextField(
              controller: _passwordController,
              hint: 'Password',
              icon: LucideIcons.lockKeyhole,
              obscureText: !_passwordVisible,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              suffix: IconButton(
                tooltip: _passwordVisible ? 'Hide password' : 'Show password',
                onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
                icon: Icon(
                  _passwordVisible ? LucideIcons.eye : LucideIcons.eyeOff,
                  color: const Color(0xFFE0E9FF),
                  size: compact ? 24 : 30,
                ),
              ),
            ),
            SizedBox(height: compact ? 12 : 22),
            Row(
              children: [
                Checkbox(
                  value: _rememberMe,
                  onChanged: (value) => setState(() => _rememberMe = value ?? false),
                  activeColor: _loginBlue,
                  checkColor: Colors.white,
                  side: const BorderSide(color: Color(0xFF9BB6E5)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                Text(
                  'Remember me',
                  style: TextStyle(color: Colors.white, fontSize: compact ? 12 : 14),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFE6E2EC),
                    padding: EdgeInsets.symmetric(horizontal: compact ? 4 : 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text('Forgot Password?', style: TextStyle(fontSize: compact ? 11 : 13)),
                ),
              ],
            ),
            SizedBox(height: compact ? 14 : 24),
            SizedBox(
              height: compact ? 54 : 66,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: const Color(0x14FFFFFF),
                  border: Border.all(color: const Color(0xBBDDD9E7), width: 1),
                ),
                child: FilledButton(
                  onPressed: _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Login', style: TextStyle(fontSize: compact ? 16 : 20, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ),
            if (_biometricEnabled) ...[
              SizedBox(height: compact ? 10 : 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_biometricBusy)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    const Icon(
                      LucideIcons.fingerprint,
                      size: 18,
                      color: Color(0xFFE0E9FF),
                    ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      _biometricBusy
                          ? 'Waiting for biometric verification...'
                          : !_biometricAvailable
                              ? 'Biometric sign-in unavailable. Use your login ID and password.'
                              : _biometricAttempted
                                  ? 'Biometric sign-in was not completed. Use your login ID and password.'
                                  : 'Biometric sign-in starts automatically.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFFE0E9FF),
                        fontSize: compact ? 11 : 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            SizedBox(height: compact ? 16 : 26),
            _buildSocialDivider(compact),
            SizedBox(height: compact ? 16 : 26),
            _buildGoogleButton(compact, label: 'Continue with Google', isSignUp: false),
          ],
        ),
      ),
    );
  }

  Widget _buildSignUpCard(bool compact) {
    final fieldGap = compact ? 14.0 : 18.0;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(compact ? 16 : 36, compact ? 18 : 30, compact ? 16 : 36, compact ? 18 : 26),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xB8161A26), Color(0x90090D18), Color(0xA61B1A25)],
        ),
        borderRadius: BorderRadius.circular(compact ? 24 : 32),
        border: Border.all(color: const Color(0x66F1EAF8), width: 1),
        boxShadow: const [
          BoxShadow(color: Color(0x88000000), blurRadius: 35, offset: Offset(0, 18)),
          BoxShadow(color: Color(0x2297A7D9), blurRadius: 26, spreadRadius: -10),
        ],
      ),
      child: Form(
        key: _signUpFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildModeTabs(compact),
            SizedBox(height: compact ? 20 : 28),
            _buildTextField(
              controller: _nameController,
              hint: 'Full Name',
              icon: LucideIcons.userRound,
              textInputAction: TextInputAction.next,
              validator: (value) => _required(value, 'your full name'),
            ),
            SizedBox(height: fieldGap),
            _buildTextField(
              controller: _emailController,
              hint: 'Email Address',
              icon: LucideIcons.mail,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: (value) {
                final email = value?.trim() ?? '';
                if (email.isEmpty) return 'Enter your email address';
                if (!email.contains('@') || !email.contains('.')) return 'Enter a valid email address';
                return null;
              },
              onChanged: (_) {
                if (_emailVerified) setState(() => _emailVerified = false);
              },
              suffix: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: FilledButton(
                        onPressed: () {
                          final email = _emailController.text.trim();
                          if (email.isEmpty || !email.contains('@') || !email.contains('.')) {
                            showAppMessage('Enter a valid email address first.');
                            return;
                          }
                          setState(() => _emailVerified = true);
                          showAppMessage('Email verified. You can now create a password.');
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF2384F4),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          minimumSize: const Size(0, 40),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                        child: const Text('Verify'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(LucideIcons.mail, color: Color(0xFFE7E9F2), size: 20),
                  ],
                ),
              ),
            ),
            SizedBox(height: fieldGap),
            _buildTextField(
              controller: _referralController,
              hint: 'IB Referral Code (Optional)',
              icon: LucideIcons.tag,
              textInputAction: TextInputAction.next,
            ),
            if (_emailVerified) ...[
              SizedBox(height: fieldGap),
              _buildTextField(
                controller: _passwordController,
                hint: 'Password',
                icon: LucideIcons.lockKeyhole,
                obscureText: !_passwordVisible,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submitSignUp(),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Create a password';
                  if (value.length < 8) return 'Use at least 8 characters';
                  return null;
                },
                suffix: IconButton(
                  tooltip: _passwordVisible ? 'Hide password' : 'Show password',
                  onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
                  icon: Icon(_passwordVisible ? LucideIcons.eye : LucideIcons.eyeOff, color: Colors.white),
                ),
              ),
            ],
            SizedBox(height: compact ? 10 : 16),
            Row(
              children: [
                Checkbox(
                  value: _acceptedTerms,
                  onChanged: (value) => setState(() => _acceptedTerms = value ?? false),
                  activeColor: _loginBlue,
                  checkColor: Colors.white,
                  side: const BorderSide(color: Color(0xFF9BB6E5)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                ),
                Expanded(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text('I agree to the ', style: TextStyle(color: Colors.white, fontSize: compact ? 12 : 16)),
                      _termsLink('Terms & Conditions'),
                      Text(' and ', style: TextStyle(color: Colors.white, fontSize: compact ? 12 : 16)),
                      _termsLink('Privacy Policy'),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: compact ? 14 : 20),
            _buildGoldButton(
              compact: compact,
              label: 'Create Account',
              onPressed: _submitSignUp,
            ),
            SizedBox(height: compact ? 18 : 24),
            _buildSocialDivider(compact, label: 'or sign up with'),
            SizedBox(height: compact ? 14 : 20),
            _buildGoogleButton(compact, label: 'Sign up with Google', isSignUp: true),
          ],
        ),
      ),
    );
  }

  Widget _termsLink(String label) => GestureDetector(
        onTap: () {},
        child: Text(
          label,
          style: TextStyle(
            color: _loginGold,
            fontSize: MediaQuery.sizeOf(context).width < 600 ? 12 : 16,
            decoration: TextDecoration.underline,
            decorationColor: _loginGold,
          ),
        ),
      );

  Widget _buildGoldButton({required bool compact, required String label, required VoidCallback onPressed}) {
    return SizedBox(
      height: compact ? 54 : 64,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: const Color(0x14FFFFFF),
          border: Border.all(color: const Color(0xBBDDD9E7), width: 1),
        ),
        child: FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label, style: TextStyle(fontSize: compact ? 16 : 20, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeTabs(bool compact) {
    return Container(
      height: compact ? 44 : 54,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0x1AFFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x55F1EAF8)),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => setState(() => _isSignUp = false),
              borderRadius: BorderRadius.circular(13),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _isSignUp ? const Color.fromARGB(0, 0, 0, 0) : const Color.fromARGB(118, 3, 79, 179),
                  borderRadius: BorderRadius.circular(13),
                  boxShadow: _isSignUp
                      ? null
                      : const [BoxShadow(color: Color(0x33212D49), blurRadius: 9, offset: Offset(0, 3))],
                ),
                child: Text(
                  'Login',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: compact ? 14 : 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () => setState(() => _isSignUp = true),
              borderRadius: BorderRadius.circular(13),
              child: Center(
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _isSignUp ? const Color.fromARGB(125, 1, 87, 185) : Colors.transparent,
                    borderRadius: BorderRadius.circular(13),
                    boxShadow: _isSignUp
                        ? const [BoxShadow(color: Color(0x33212D49), blurRadius: 9, offset: Offset(0, 3))]
                        : null,
                  ),
                  child: Text(
                    'Sign Up',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: compact ? 14 : 16,
                      fontWeight: FontWeight.w600,
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    bool obscureText = false,
    Widget? suffix,
    ValueChanged<String>? onSubmitted,
    String? Function(String?)? validator,
    ValueChanged<String>? onChanged,
  }) {
    final compact = MediaQuery.sizeOf(context).width < 600;
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: compact ? 48 : 60),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        obscureText: obscureText,
        onFieldSubmitted: onSubmitted,
        validator: validator,
        onChanged: onChanged,
        style: TextStyle(color: Colors.white, fontSize: compact ? 14 : 17),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: const Color(0x99E0E4F0), fontSize: compact ? 14 : 17),
          suffixIcon: suffix ?? Icon(icon, color: const Color(0xFFE7E9F2), size: compact ? 23 : 27),
          suffixIconConstraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          filled: true,
          fillColor: const Color(0x120A1025),
          contentPadding: EdgeInsets.symmetric(horizontal: compact ? 17 : 22, vertical: compact ? 12 : 16),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(17),
            borderSide: const BorderSide(color: Color(0x99D8D5E7), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(17),
            borderSide: const BorderSide(color: Color(0xFFE3D8F3), width: 1.4),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(17),
            borderSide: const BorderSide(color: Color(0xFFFF9393)),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(17),
            borderSide: const BorderSide(color: Color(0xFFFF9393), width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialDivider(bool compact, {String label = 'or continue with'}) {
    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0xFF8EA4CC))),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 24),
          child: Text(label, style: TextStyle(color: Colors.white, fontSize: compact ? 12 : 18)),
        ),
        const Expanded(child: Divider(color: Color(0xFF8EA4CC))),
      ],
    );
  }

  Widget _buildGoogleButton(bool compact, {required String label, required bool isSignUp}) {
    return SizedBox(
      height: compact ? 52 : 60,
      child: OutlinedButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isSignUp
                    ? 'Google sign-up is not connected yet.'
                    : 'Google sign-in is not connected yet.',
              ),
            ),
          );
        },
        style: OutlinedButton.styleFrom(
          backgroundColor: const Color(0x14FFFFFF),
          side: const BorderSide(color: Color(0x66E5DFEB), width: 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: SvgPicture.asset(
                'assets/icons/google_logo.svg',
                semanticsLabel: 'Google',
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: compact ? 14 : 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Standalone entry point for the account registration form.
class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) => const LoginPage(initialSignUp: true);
}


