part of '../main.dart';

// Light Glassmorphism Theme with Blue, Gold & White
const _loginCardGlassBg = Color(0xD9FFFFFF);
const _loginGoldRim = Color(0xFFECC868);
const _loginGoldBorder = Color(0x99D4AF37);
const _loginRoyalBlue = Color(0xFF1E70E8);
const _loginDarkBlueText = Color(0xFF0D1B3E);
const _loginMutedBlueText = Color(0xFF5A718F);
const _loginPlaceholderText = Color(0xFF7E92A8);
const _loginErrorColor = Color(0xFFE53935);

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    this.onLogin,
    this.initialSignUp = false,
    this.biometricSignIn,
    @visibleForTesting this.credentialLogin,
  });

  final VoidCallback? onLogin;
  final bool initialSignUp;
  final BiometricSignIn? biometricSignIn;
  final Future<Map<String, dynamic>> Function({
    required String identifier,
    required String password,
    required bool rememberMe,
  })? credentialLogin;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _referralController = TextEditingController();
  final _passwordController = TextEditingController();

  late bool _isSignUp = widget.initialSignUp;
  bool _emailVerified = false;
  bool _passwordVisible = false;
  bool _acceptedTerms = false;
  bool _rememberMe = true;

  // Inline validation error messages
  String? _loginEmailError;
  String? _loginPasswordError;
  String? _signUpNameError;
  String? _signUpEmailError;
  String? _signUpPasswordError;
  String? _signUpTermsError;

  bool _biometricEnabled = false;
  bool _biometricAvailable = false;
  bool _biometricBusy = false;
  bool _loginBusy = false;

  BiometricSignIn get _biometricService =>
      widget.biometricSignIn ?? BiometricSignIn.instance;

  @override
  void initState() {
    super.initState();
    unawaited(_restoreSessionThenBiometrics());
    unawaited(_loadRememberedLogin());
    unawaited(
      AuthApi.instance.getCaptchaConfig().catchError(
        (_) => <String, dynamic>{},
      ),
    );
  }

  Future<void> _restoreSessionThenBiometrics() async {
    if (await AuthApi.instance.tryCookieAutoLogin()) {
      if (mounted) widget.onLogin?.call();
      return;
    }
    if (mounted) await _loadBiometricSignIn();
  }

  Future<void> _loadRememberedLogin() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final remembered = preferences.getBool('vtindex_remember_login') ?? true;
      final identifier =
          preferences.getString('vtindex_login_identifier') ?? '';
      if (!mounted) return;
      setState(() {
        _rememberMe = remembered;
        if (remembered && identifier.isNotEmpty) {
          _emailController.text = identifier;
        }
      });
    } catch (_) {}
  }

  Future<void> _saveRememberedLogin() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setBool('vtindex_remember_login', _rememberMe);
      if (_rememberMe) {
        await preferences.setString(
          'vtindex_login_identifier',
          _emailController.text.trim(),
        );
      } else {
        await preferences.remove('vtindex_login_identifier');
      }
    } catch (_) {}
  }

  Future<void> _loadBiometricSignIn() async {
    var enabled = false;
    try {
      enabled = await _biometricService.isEnabled();
      if (!mounted) return;
      final available =
          enabled &&
          await _biometricService.isAvailable(
            platform: Theme.of(context).platform,
          );
      final hasStoredCredentials =
          available &&
          (AuthApi.instance.hasToken ||
              await _biometricService.hasStoredCredentials());
      if (!mounted) return;
      setState(() {
        _biometricEnabled = enabled;
        _biometricAvailable = available;
      });
      if (enabled && available && hasStoredCredentials) {
        await _signInWithBiometrics();
      }
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
    if (_biometricBusy || _loginBusy) return;
    HapticFeedback.mediumImpact();

    if (!_biometricEnabled || !_biometricAvailable) {
      if (!_biometricEnabled) {
        showAppMessage(
          'Biometric sign-in is not enabled. Sign in with your password and enable it in Security Center.',
        );
      } else {
        showAppMessage('Biometric sensor is not available on this device.');
      }
      return;
    }

    final credentials = await _biometricService.readCredentials();
    if (!mounted) return;
    final hasActiveToken = AuthApi.instance.hasToken;
    if (!hasActiveToken && credentials == null) {
      showAppMessage(
        'Please sign in once with your email and password to enable biometric re-login.',
      );
      return;
    }

    setState(() => _biometricBusy = true);
    try {
      final authenticated = await _biometricService.authenticate(
        localizedReason: 'Sign in to your VTIndex account',
      );
      if (!mounted) return;
      if (!authenticated) {
        showAppMessage(
          'Biometric sign-in was canceled. Use your login ID and password instead.',
        );
        return;
      }

      if (hasActiveToken) {
        try {
          await AuthApi.instance.restoreSession();
          await AuthApi.instance.getProfile();
          if (!mounted) return;
          HapticFeedback.selectionClick();
          widget.onLogin?.call();
          return;
        } on AuthApiException catch (e) {
          if (credentials == null) {
            showAppMessage('Session expired: ${e.message}. Please log in again.');
            return;
          }
          // Fall through to re-authenticate using stored biometric credentials.
        } catch (_) {
          if (AuthApi.instance.hasToken) {
            HapticFeedback.selectionClick();
            widget.onLogin?.call();
            return;
          }
          if (credentials == null) {
            showAppMessage('Session expired. Please log in with your credentials.');
            return;
          }
        }
      }

      await _authenticateWithCredentials(
        identifier: credentials!.identifier,
        password: credentials.password,
        fromBiometric: true,
      );
    } on PlatformException {
      if (mounted) {
        showAppMessage(
          'Biometric sign-in failed. Use your login ID and password instead.',
        );
      }
    } on MissingPluginException {
      if (mounted) {
        showAppMessage(
          'Biometric sign-in is unavailable. Use your login ID and password instead.',
        );
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
    if (_loginBusy) return;
    FocusScope.of(context).unfocus();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    String? emailErr;
    String? passErr;
    if (email.isEmpty) {
      emailErr = 'Please enter your username or email.';
    }
    if (password.isEmpty) {
      passErr = 'Please enter your password.';
    }

    if (emailErr != null || passErr != null) {
      setState(() {
        _loginEmailError = emailErr;
        _loginPasswordError = passErr;
      });
      return;
    }

    setState(() {
      _loginEmailError = null;
      _loginPasswordError = null;
    });

    HapticFeedback.selectionClick();
    unawaited(_saveRememberedLogin());
    setState(() => _loginBusy = true);
    try {
      await _authenticateWithCredentials(
        identifier: email,
        password: password,
        fromBiometric: false,
      );
    } finally {
      if (mounted) setState(() => _loginBusy = false);
    }
  }

  Future<void> _authenticateWithCredentials({
    required String identifier,
    required String password,
    required bool fromBiometric,
  }) async {
    try {
      // Fetch the public GeeTest configuration before login. The backend only
      // exposes the public site ID here; secret validation remains server-side.
      var response = widget.credentialLogin != null
          ? await widget.credentialLogin!(
              identifier: identifier,
              password: password,
              rememberMe: _rememberMe,
            )
          : await AuthApi.instance.login(
              identifier: identifier,
              password: password,
              rememberMe: _rememberMe,
            );
      if (_requiresLoginOtp(response)) {
        final otp = await _requestLoginOtp(identifier);
        if (otp == null || !mounted) return;
        response = await AuthApi.instance.verifyOtp(email: identifier, otp: otp);
      }
      if (_requiresLoginOtp(response)) {
        throw const AuthApiException(
          'The server still requires a login verification code.',
        );
      }
      if (response['captcha_required'] == true) {
        throw AuthApiException(
          response['message'] as String? ??
              'CAPTCHA verification is required. Please verify via the web portal or disable Login CAPTCHA in Security Settings.',
        );
      }
      if (response['success'] == false || response['authenticated'] == false) {
        throw AuthApiException(_apiResponseMessage(response));
      }
      final hasToken = response['access'] != null ||
          response['access_token'] != null ||
          response['token'] != null ||
          AuthApi.instance.hasToken;
      final skipRemoteStatusCheck =
          widget.credentialLogin != null &&
          response['authenticated'] == true &&
          hasToken;
      if (!skipRemoteStatusCheck && !await AuthApi.instance.isAuthenticated()) {
        if (!hasToken) {
          throw const AuthApiException(
            'The server did not confirm an authenticated session.',
          );
        }
      }
      unawaited(
        _biometricService.rememberSessionCredentials(
          identifier: identifier,
          password: password,
        ),
      );
      if (!mounted) return;
      HapticFeedback.selectionClick();
      widget.onLogin?.call();
    } on AuthApiException catch (error) {
      if (fromBiometric &&
          (error.statusCode == 400 || error.statusCode == 401)) {
        // Stored password is no longer accepted by the server; clear it so the
        // user can sign in once with their updated credentials.
        await _biometricService.clearCredentials();
        if (mounted && _emailController.text.trim().isEmpty) {
          _emailController.text = identifier;
        }
      }
      if (mounted) showAppMessage(error.message);
    } catch (error) {
      if (mounted) {
        showAppMessage(
          'Could not connect to the login server. Check the API host and try again.',
        );
      }
    }
  }

  bool _requiresLoginOtp(Map<String, dynamic> response) {
    for (final key in const [
      'verification_required',
      'requires_verification',
      'otp_required',
      'requires_otp',
      'email_verification_required',
      'otp',
    ]) {
      if (response[key] == true) return true;
    }
    final status = (response['status'] ?? response['state'] ?? '')
        .toString()
        .toLowerCase();
    if (status.contains('otp') || status.contains('verification_required')) {
      return true;
    }
    final message = (response['message'] ?? '').toString().toLowerCase();
    return message.contains('verification code') ||
        message.contains('verify to continue');
  }

  String _apiResponseMessage(Map<String, dynamic> response) {
    for (final key in const ['message', 'error', 'detail']) {
      final value = response[key];
      if (value is String && value.isNotEmpty) return value;
    }
    return 'Login could not be completed. Please try again.';
  }

  Future<String?> _requestLoginOtp(String email) async {
    final otpController = TextEditingController();
    try {
      unawaited(
        AuthApi.instance
            .loginOtpStatus(email)
            .catchError((_) => <String, dynamic>{}),
      );
      if (!mounted) return null;
      return await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Verify your login'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'A verification code was sent to $email. Please enter it below to continue.',
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: otpController,
                autofocus: true,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Email verification code',
                  hintText: 'Enter 6-digit code',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                try {
                  await AuthApi.instance.resendLoginOtp({'email': email});
                  if (dialogContext.mounted) {
                    showAppMessage('A new verification code was sent.');
                  }
                } on AuthApiException catch (error) {
                  if (dialogContext.mounted) showAppMessage(error.message);
                } catch (_) {
                  if (dialogContext.mounted) {
                    showAppMessage('Could not resend the verification code.');
                  }
                }
              },
              child: const Text('Resend code'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final code = otpController.text.trim();
                if (code.isNotEmpty) Navigator.pop(dialogContext, code);
              },
              child: const Text('Verify'),
            ),
          ],
        ),
      );
    } finally {
      otpController.dispose();
    }
  }

  void _submitSignUp() {
    FocusScope.of(context).unfocus();
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    String? nameErr;
    String? emailErr;
    String? passErr;
    String? termsErr;

    if (name.isEmpty) {
      nameErr = 'Please enter your full name.';
    }
    if (email.isEmpty) {
      emailErr = 'Please enter your email address.';
    } else if (!email.contains('@') || !email.contains('.')) {
      emailErr = 'Please enter a valid email address.';
    }
    if (password.isEmpty) {
      passErr = 'Please create a password.';
    } else if (password.length < 8) {
      passErr = 'Password must be at least 8 characters long.';
    }
    if (!_acceptedTerms) {
      termsErr = 'Please accept the Terms & Conditions and Privacy Policy.';
    }

    if (!_emailVerified) {
      emailErr = 'Please verify your email address to continue.';
    }

    if (nameErr != null ||
        emailErr != null ||
        passErr != null ||
        termsErr != null) {
      setState(() {
        _signUpNameError = nameErr;
        _signUpEmailError = emailErr;
        _signUpPasswordError = passErr;
        _signUpTermsError = termsErr;
      });
      if (emailErr != null &&
          nameErr == null &&
          passErr == null &&
          termsErr == null &&
          !_emailVerified) {
        _showSignUpEmailVerificationModal(
          isDark: Theme.of(context).brightness == Brightness.dark,
        );
      }
      return;
    }

    setState(() {
      _signUpNameError = null;
      _signUpEmailError = null;
      _signUpPasswordError = null;
      _signUpTermsError = null;
    });

    unawaited(_createAccount(name, email, password));
  }

  Future<void> _createAccount(
    String name,
    String email,
    String password,
  ) async {
    try {
      final encryptedPassword = await AuthApi.instance
          .encryptPasswordForPasswordFlow(password);
      await AuthApi.instance.signup({
        'name': name,
        'email': email,
        'password': encryptedPassword,
        'referral_code': _referralController.text.trim(),
        ...await AuthApi.instance.getDeviceInfo(),
      });
      if (mounted) {
        showAppMessage('Your account request was submitted successfully.');
      }
    } on AuthApiException catch (error) {
      if (mounted) showAppMessage(error.message);
    } catch (_) {
      if (mounted) {
        showAppMessage(
          'Could not connect to the signup server. Please try again.',
        );
      }
    }
  }

  void _showSignUpEmailVerificationModal({required bool isDark}) {
    FocusScope.of(context).unfocus();
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@') || !email.contains('.')) {
      setState(
        () => _signUpEmailError = 'Please enter a valid email address first.',
      );
      return;
    }
    setState(() => _signUpEmailError = null);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (sheetContext) => _SignUpEmailVerificationModal(
        email: email,
        isDark: isDark,
        onVerified: () {
          setState(() {
            _emailVerified = true;
            _signUpEmailError = null;
          });
        },
      ),
    );
  }

  void _showHelpModal() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _ForgotPasswordFlowModal(
        initialEmail: _emailController.text.trim(),
        isDark: isDark,
        onPasswordResetCompleted: (newEmail, newPassword) {
          setState(() {
            _emailController.text = newEmail;
            _passwordController.text = newPassword;
            _loginEmailError = null;
            _loginPasswordError = null;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: isDark
          ? const Color(0xFF18191E)
          : const Color(0xFFEAF1FB),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            // 1. Full-screen decorative background graphic painter
            Positioned.fill(
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: _LoginBackgroundPainter(isDark: isDark),
                ),
              ),
            ),

            // 2. Main floating glass card (stays anchored without jumping up on keyboard open)
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(38),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF25262D)
                                    : _loginCardGlassBg,
                                borderRadius: BorderRadius.circular(38),
                                border: Border.all(
                                  color: isDark
                                      ? const Color(0x33FFFFFF)
                                      : _loginGoldBorder,
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
                              padding: const EdgeInsets.fromLTRB(
                                22,
                                28,
                                22,
                                28,
                              ),
                              child: _isSignUp
                                  ? _buildSignUpContent(isDark: isDark)
                                  : _buildLoginContent(isDark: isDark),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Slogan outside the card
                        Text(
                          'PLAY  •  COMPETE  •  GROW TOGETHER',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isDark
                                ? const Color(0xFF888F9F)
                                : const Color(0xFF4B5E7D),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
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
              : const RadialGradient(colors: [Colors.white, Color(0xFFF3F7FD)]),
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
                cacheWidth: 144,
                cacheHeight: 144,
                errorBuilder: (context, error, stackTrace) => Image.asset(
                  'assets/images/vtindex_logo_img.png',
                  fit: BoxFit.contain,
                  cacheWidth: 144,
                  cacheHeight: 144,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldFeedback({required String? errorText}) {
    if (errorText == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(left: 18, top: 6, bottom: 2),
      child: Row(
        children: [
          const Icon(
            LucideIcons.alertCircle,
            size: 13,
            color: _loginErrorColor,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              errorText,
              style: const TextStyle(
                color: _loginErrorColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginContent({required bool isDark}) {
    final titleColor = isDark ? Colors.white : _loginDarkBlueText;
    final subtitleColor = isDark
        ? const Color(0xFF9CA2B2)
        : _loginMutedBlueText;
    final dividerColor = isDark
        ? const Color(0xFF383B47)
        : const Color(0xFFD4E2F2);
    final inputBg = isDark ? const Color(0xFF1C1D23) : const Color(0xFFF4F8FD);
    final inputBorder = isDark ? const Color(0x2EFFFFFF) : _loginGoldBorder;
    final inputTextColor = isDark ? Colors.white : _loginDarkBlueText;
    final placeholderColor = isDark
        ? const Color(0xFF757989)
        : _loginPlaceholderText;
    final prefixIconColor = isDark ? const Color(0xFF8A90A2) : _loginRoyalBlue;

    return Column(
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
          height: 58,
          decoration: BoxDecoration(
            color: inputBg,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: _loginEmailError != null ? _loginErrorColor : inputBorder,
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? const Color(0x40000000)
                    : const Color(0x0F0D47A1),
                offset: const Offset(0, 3),
                blurRadius: 8,
              ),
            ],
          ),
          child: Center(
            child: TextFormField(
              controller: _emailController,
              textAlignVertical: TextAlignVertical.center,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              cursorColor: isDark ? const Color(0xFF6DA2F5) : _loginRoyalBlue,
              style: TextStyle(
                color: inputTextColor,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                height: 1.25,
              ),
              onChanged: (_) {
                if (_loginEmailError != null) {
                  setState(() => _loginEmailError = null);
                }
              },
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                hintText: 'Username or Email',
                hintStyle: TextStyle(
                  color: placeholderColor,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0,
                  height: 1.25,
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 18, right: 12),
                  child: Icon(
                    LucideIcons.user,
                    color: _loginEmailError != null
                        ? _loginErrorColor
                        : prefixIconColor,
                    size: 21,
                  ),
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 50,
                  minHeight: 24,
                ),
                contentPadding: const EdgeInsets.only(right: 20),
              ),
            ),
          ),
        ),
        _buildFieldFeedback(errorText: _loginEmailError),
        const SizedBox(height: 14),

        // Field 2: Password
        Container(
          height: 58,
          decoration: BoxDecoration(
            color: inputBg,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: _loginPasswordError != null
                  ? _loginErrorColor
                  : inputBorder,
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? const Color(0x40000000)
                    : const Color(0x0F0D47A1),
                offset: const Offset(0, 3),
                blurRadius: 8,
              ),
            ],
          ),
          child: Center(
            child: TextFormField(
              controller: _passwordController,
              textAlignVertical: TextAlignVertical.center,
              obscureText: !_passwordVisible,
              obscuringCharacter: '•',
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
              cursorColor: isDark ? const Color(0xFF6DA2F5) : _loginRoyalBlue,
              style: TextStyle(
                color: inputTextColor,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing:
                    (_passwordVisible || _passwordController.text.isEmpty)
                    ? 0
                    : 2.5,
                height: 1.25,
              ),
              onChanged: (_) {
                if (_loginPasswordError != null) {
                  setState(() => _loginPasswordError = null);
                }
              },
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                hintText: 'Password',
                hintStyle: TextStyle(
                  color: placeholderColor,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0,
                  height: 1.25,
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 18, right: 12),
                  child: Icon(
                    LucideIcons.lock,
                    color: _loginPasswordError != null
                        ? _loginErrorColor
                        : prefixIconColor,
                    size: 21,
                  ),
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 50,
                  minHeight: 24,
                ),
                suffixIconConstraints: const BoxConstraints(
                  minWidth: 44,
                  minHeight: 24,
                ),
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: GestureDetector(
                    onTap: () =>
                        setState(() => _passwordVisible = !_passwordVisible),
                    behavior: HitTestBehavior.opaque,
                    child: Icon(
                      _passwordVisible ? LucideIcons.eye : LucideIcons.eyeOff,
                      color: placeholderColor,
                      size: 20,
                    ),
                  ),
                ),
                contentPadding: const EdgeInsets.only(right: 8),
              ),
            ),
          ),
        ),
        _buildFieldFeedback(errorText: _loginPasswordError),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 2,
                    vertical: 4,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: _rememberMe
                              ? (isDark
                                    ? const Color(0xFF2575FC)
                                    : _loginRoyalBlue)
                              : (isDark
                                    ? const Color(0xFF1E1F24)
                                    : Colors.white),
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: _rememberMe
                                ? (isDark
                                      ? const Color(0xFF2575FC)
                                      : _loginRoyalBlue)
                                : (isDark
                                      ? const Color(0xFF454958)
                                      : const Color(0xFFBACADB)),
                            width: 1.5,
                          ),
                          boxShadow: [
                            if (_rememberMe)
                              BoxShadow(
                                color:
                                    (isDark
                                            ? const Color(0xFF2575FC)
                                            : const Color(0xFF1E70E8))
                                        .withValues(alpha: 0.35),
                                offset: const Offset(0, 2),
                                blurRadius: 4,
                              ),
                          ],
                        ),
                        child: _rememberMe
                            ? const Icon(
                                Icons.check,
                                size: 13,
                                color: Colors.white,
                              )
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
                    color: isDark
                        ? const Color(0xFF6DA2F5)
                        : const Color(0xFF134282),
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
          label: _loginBusy ? 'Connecting…' : 'Login',
          onPressed: _submit,
          isDark: isDark,
          busy: _loginBusy,
        ),
        const SizedBox(height: 28),

        // Sign up link
        Center(
          child: InkWell(
            onTap: () => setState(() {
              _isSignUp = true;
              _loginEmailError = null;
              _loginPasswordError = null;
            }),
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
                        color: isDark
                            ? const Color(0xFF6DA2F5)
                            : _loginRoyalBlue,
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
              style: TextStyle(color: subtitleColor, fontSize: 11),
            ),
          ),
        ],

        if (_biometricEnabled && _biometricAvailable) ...[
          const SizedBox(height: 24),
          Center(child: _buildFingerprintButton(isDark: isDark)),
        ],
      ],
    );
  }

  Widget _buildSignUpContent({required bool isDark}) {
    final titleColor = isDark ? Colors.white : _loginDarkBlueText;
    final subtitleColor = isDark
        ? const Color(0xFF9CA2B2)
        : _loginMutedBlueText;
    final inputBg = isDark ? const Color(0xFF1C1D23) : const Color(0xFFF4F8FD);
    final inputBorder = isDark ? const Color(0x2EFFFFFF) : _loginGoldBorder;
    final inputTextColor = isDark ? Colors.white : _loginDarkBlueText;
    final placeholderColor = isDark
        ? const Color(0xFF757989)
        : _loginPlaceholderText;
    final prefixIconColor = isDark ? const Color(0xFF8A90A2) : _loginRoyalBlue;

    return Column(
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
            border: Border.all(
              color: _signUpNameError != null ? _loginErrorColor : inputBorder,
              width: 1.2,
            ),
          ),
          child: Center(
            child: TextFormField(
              controller: _nameController,
              textAlignVertical: TextAlignVertical.center,
              cursorColor: isDark ? const Color(0xFF6DA2F5) : _loginRoyalBlue,
              style: TextStyle(
                color: inputTextColor,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                height: 1.25,
              ),
              onChanged: (_) {
                if (_signUpNameError != null) {
                  setState(() => _signUpNameError = null);
                }
              },
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                hintText: 'Full Name',
                hintStyle: TextStyle(
                  color: placeholderColor,
                  fontSize: 14.5,
                  height: 1.25,
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 18, right: 12),
                  child: Icon(
                    LucideIcons.user,
                    color: _signUpNameError != null
                        ? _loginErrorColor
                        : prefixIconColor,
                    size: 20,
                  ),
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 50,
                  minHeight: 24,
                ),
                contentPadding: const EdgeInsets.only(right: 20),
              ),
            ),
          ),
        ),
        _buildFieldFeedback(errorText: _signUpNameError),
        const SizedBox(height: 14),

        // Email Address
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: inputBg,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: _signUpEmailError != null ? _loginErrorColor : inputBorder,
              width: 1.2,
            ),
          ),
          child: Center(
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _emailController,
                    textAlignVertical: TextAlignVertical.center,
                    keyboardType: TextInputType.emailAddress,
                    cursorColor: isDark
                        ? const Color(0xFF6DA2F5)
                        : _loginRoyalBlue,
                    style: TextStyle(
                      color: inputTextColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                    ),
                    onChanged: (_) {
                      if (_emailVerified) {
                        setState(() => _emailVerified = false);
                      }
                      if (_signUpEmailError != null) {
                        setState(() => _signUpEmailError = null);
                      }
                    },
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      hintText: 'Email Address',
                      hintStyle: TextStyle(
                        color: placeholderColor,
                        fontSize: 14.5,
                        height: 1.25,
                      ),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(left: 18, right: 12),
                        child: Icon(
                          LucideIcons.mail,
                          color: _signUpEmailError != null
                              ? _loginErrorColor
                              : prefixIconColor,
                          size: 20,
                        ),
                      ),
                      prefixIconConstraints: const BoxConstraints(
                        minWidth: 50,
                        minHeight: 24,
                      ),
                      contentPadding: const EdgeInsets.only(right: 12),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: FilledButton(
                    onPressed: _emailVerified
                        ? null
                        : () =>
                              _showSignUpEmailVerificationModal(isDark: isDark),
                    style: FilledButton.styleFrom(
                      backgroundColor: _emailVerified
                          ? const Color(0xFF2E7D32)
                          : _loginRoyalBlue,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFF2E7D32),
                      disabledForegroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      minimumSize: const Size(0, 36),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_emailVerified) ...[
                          const Icon(
                            Icons.check_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          _emailVerified ? 'Verified' : 'Verify',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        _buildFieldFeedback(errorText: _signUpEmailError),
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
              textAlignVertical: TextAlignVertical.center,
              cursorColor: isDark ? const Color(0xFF6DA2F5) : _loginRoyalBlue,
              style: TextStyle(
                color: inputTextColor,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                height: 1.25,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                hintText: 'IB Referral Code (Optional)',
                hintStyle: TextStyle(
                  color: placeholderColor,
                  fontSize: 14.5,
                  height: 1.25,
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 18, right: 12),
                  child: Icon(
                    LucideIcons.tag,
                    color: prefixIconColor,
                    size: 20,
                  ),
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 50,
                  minHeight: 24,
                ),
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
            border: Border.all(
              color: _signUpPasswordError != null
                  ? _loginErrorColor
                  : inputBorder,
              width: 1.2,
            ),
          ),
          child: Center(
            child: TextFormField(
              controller: _passwordController,
              textAlignVertical: TextAlignVertical.center,
              obscureText: !_passwordVisible,
              obscuringCharacter: '•',
              cursorColor: isDark ? const Color(0xFF6DA2F5) : _loginRoyalBlue,
              style: TextStyle(
                color: inputTextColor,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing:
                    (_passwordVisible || _passwordController.text.isEmpty)
                    ? 0
                    : 2.5,
                height: 1.25,
              ),
              onChanged: (_) {
                if (_signUpPasswordError != null) {
                  setState(() => _signUpPasswordError = null);
                }
              },
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                hintText: 'Password (min. 8 characters)',
                hintStyle: TextStyle(
                  color: placeholderColor,
                  fontSize: 14.5,
                  letterSpacing: 0,
                  height: 1.25,
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 18, right: 12),
                  child: Icon(
                    LucideIcons.lock,
                    color: _signUpPasswordError != null
                        ? _loginErrorColor
                        : prefixIconColor,
                    size: 20,
                  ),
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 50,
                  minHeight: 24,
                ),
                suffixIconConstraints: const BoxConstraints(
                  minWidth: 44,
                  minHeight: 24,
                ),
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: GestureDetector(
                    onTap: () =>
                        setState(() => _passwordVisible = !_passwordVisible),
                    behavior: HitTestBehavior.opaque,
                    child: Icon(
                      _passwordVisible ? LucideIcons.eye : LucideIcons.eyeOff,
                      color: placeholderColor,
                      size: 20,
                    ),
                  ),
                ),
                contentPadding: const EdgeInsets.only(right: 8),
              ),
            ),
          ),
        ),
        _buildFieldFeedback(errorText: _signUpPasswordError),
        const SizedBox(height: 16),

        // Terms Checkbox
        Row(
          children: [
            Checkbox(
              value: _acceptedTerms,
              onChanged: (v) => setState(() {
                _acceptedTerms = v ?? false;
                if (_signUpTermsError != null) _signUpTermsError = null;
              }),
              activeColor: isDark ? const Color(0xFF2575FC) : _loginRoyalBlue,
              checkColor: Colors.white,
              side: BorderSide(
                color: _signUpTermsError != null
                    ? _loginErrorColor
                    : (isDark
                          ? const Color(0xFF454958)
                          : const Color(0xFFBACADB)),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() {
                  _acceptedTerms = !_acceptedTerms;
                  if (_signUpTermsError != null) _signUpTermsError = null;
                }),
                child: Text.rich(
                  TextSpan(
                    text: 'I agree to the ',
                    style: TextStyle(color: subtitleColor, fontSize: 12.5),
                    children: [
                      TextSpan(
                        text: 'Terms & Conditions',
                        style: TextStyle(
                          color: isDark
                              ? const Color(0xFF6DA2F5)
                              : _loginRoyalBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(
                          color: isDark
                              ? const Color(0xFF6DA2F5)
                              : _loginRoyalBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        _buildFieldFeedback(errorText: _signUpTermsError),
        const SizedBox(height: 22),

        _buildRaisedButton(
          label: 'Create Account',
          onPressed: _submitSignUp,
          isDark: isDark,
        ),
        const SizedBox(height: 22),

        Center(
          child: InkWell(
            onTap: () => setState(() {
              _isSignUp = false;
              _signUpNameError = null;
              _signUpEmailError = null;
              _signUpPasswordError = null;
              _signUpTermsError = null;
            }),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Text.rich(
                TextSpan(
                  text: 'Already have an account? ',
                  style: TextStyle(color: subtitleColor, fontSize: 13),
                  children: [
                    TextSpan(
                      text: 'Login',
                      style: TextStyle(
                        color: isDark
                            ? const Color(0xFF6DA2F5)
                            : _loginRoyalBlue,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRaisedButton({
    required String label,
    required VoidCallback? onPressed,
    required bool isDark,
    bool busy = false,
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
              if (busy)
                const Positioned(
                  right: 14,
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                )
              else
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
                color: isDark
                    ? const Color(0x22FFFFFF)
                    : const Color(0x66D4AF37),
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

  static final TextPainter _moreThanAGamePainter = TextPainter(
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
  )..layout();

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
      ..shader =
          const RadialGradient(
            center: Alignment.topLeft,
            radius: 1.0,
            colors: [Color(0x333A3C46), Color(0x003A3C46)],
          ).createShader(
            Rect.fromCircle(center: const Offset(40, 70), radius: 210),
          );
    canvas.drawCircle(const Offset(40, 70), 210, topOrbPaint);

    // 3. Subtle bottom-left 4x4 matrix of dark dots
    final dotPaint = Paint()..color = const Color(0x337A7E8D);
    for (int r = 0; r < 4; r++) {
      for (int c = 0; c < 4; c++) {
        canvas.drawCircle(
          Offset(28.0 + (c * 13.0), size.height - 110.0 + (r * 13.0)),
          2.2,
          dotPaint,
        );
      }
    }
  }

  void _paintLight(Canvas canvas, Size size) {
    // 1. Soft atmospheric base gradient matching reference
    final baseGradient = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFEFF5FD), Color(0xFFF8FAFE), Color(0xFFE2EDFC)],
    ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, Paint()..shader = baseGradient);

    // 2. Top-left ambient royal blue sphere with golden boundary curve
    final blueOrbPaint = Paint()
      ..shader =
          const RadialGradient(
            center: Alignment.topLeft,
            radius: 1.0,
            colors: [Color(0xFF2575FC), Color(0xFF0F52BA), Color(0x000F52BA)],
            stops: [0.0, 0.65, 1.0],
          ).createShader(
            Rect.fromCircle(center: const Offset(40, 70), radius: 210),
          );
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
      ..shader =
          const RadialGradient(colors: [Color(0x7386B8F7), Color(0x0086B8F7)])
              .createShader(
                Rect.fromCircle(
                  center: Offset(size.width + 10, size.height * 0.28),
                  radius: 150,
                ),
              );
    canvas.drawCircle(
      Offset(size.width + 10, size.height * 0.28),
      150,
      rightOrbPaint,
    );

    // 4. Bottom-right sweeping fluid royal curves with gold edge
    final bottomBlueGrad =
        const RadialGradient(
          center: Alignment.bottomRight,
          radius: 1.15,
          colors: [Color(0xFF0B46A8), Color(0xFF1565C0), Color(0x001976D2)],
          stops: [0.0, 0.7, 1.0],
        ).createShader(
          Rect.fromCircle(
            center: Offset(size.width, size.height),
            radius: size.width * 0.85,
          ),
        );

    final bottomPath = Path();
    bottomPath.moveTo(size.width * 0.28, size.height);
    bottomPath.cubicTo(
      size.width * 0.48,
      size.height * 0.88,
      size.width * 0.74,
      size.height * 0.82,
      size.width,
      size.height * 0.77,
    );
    bottomPath.lineTo(size.width, size.height);
    bottomPath.close();
    canvas.drawPath(bottomPath, Paint()..shader = bottomBlueGrad);

    final goldBottomPath = Path();
    goldBottomPath.moveTo(size.width * 0.28, size.height);
    goldBottomPath.cubicTo(
      size.width * 0.48,
      size.height * 0.88,
      size.width * 0.74,
      size.height * 0.82,
      size.width,
      size.height * 0.77,
    );
    canvas.drawPath(goldBottomPath, goldRibbonPaint);

    // 5. Bottom-left 4x4 matrix of subtle light blue dots
    final dotPaint = Paint()..color = const Color(0x999EBCE8);
    for (int r = 0; r < 4; r++) {
      for (int c = 0; c < 4; c++) {
        canvas.drawCircle(
          Offset(28.0 + (c * 13.0), size.height - 110.0 + (r * 13.0)),
          2.2,
          dotPaint,
        );
      }
    }

    // 6. Bottom-right text: "MORE THAN A GAME" with gold horizontal line
    final textPainter = _moreThanAGamePainter;
    final textX = size.width - textPainter.width - 24;
    final textY = size.height - textPainter.height - 30;
    if (textX > 0 && textY > 0) {
      textPainter.paint(canvas, Offset(textX, textY));
      final barPaint = Paint()
        ..color = const Color(0xFFECC868)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            textX + (textPainter.width - 22) / 2,
            textY + textPainter.height + 6,
            22,
            2.5,
          ),
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

/// 5-Step interactive Forgot Password bottom modal flow
class _ForgotPasswordFlowModal extends StatefulWidget {
  const _ForgotPasswordFlowModal({
    required this.initialEmail,
    required this.isDark,
    required this.onPasswordResetCompleted,
  });

  final String initialEmail;
  final bool isDark;
  final void Function(String email, String newPassword)
  onPasswordResetCompleted;

  @override
  State<_ForgotPasswordFlowModal> createState() =>
      _ForgotPasswordFlowModalState();
}

class _ForgotPasswordFlowModalState extends State<_ForgotPasswordFlowModal> {
  int _currentStep =
      1; // 1: Email, 2: OTP, 3: New & Confirm Password, 4: Success

  late final TextEditingController _emailController;
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _otpFocusNode = FocusNode();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _newPasswordVisible = false;
  bool _confirmPasswordVisible = false;

  String? _stepError;
  String? _resetToken;
  int _resendCountdown = 45;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail);
    _otpFocusNode.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _emailController.dispose();
    _otpController.dispose();
    _otpFocusNode.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _countdownTimer?.cancel();
    setState(() => _resendCountdown = 45);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_resendCountdown > 1) {
        setState(() => _resendCountdown--);
      } else {
        timer.cancel();
        setState(() => _resendCountdown = 0);
      }
    });
  }

  Future<void> _resendResetOtp() async {
    try {
      await AuthApi.instance.sendResetOtp(_emailController.text.trim());
      if (mounted) _startTimer();
    } on AuthApiException catch (error) {
      if (mounted) setState(() => _stepError = error.message);
    } catch (_) {
      if (mounted) {
        setState(() => _stepError = 'Could not resend the reset code.');
      }
    }
  }

  // --- Step 1: Send OTP to Email ---
  Future<void> _submitStep1() async {
    FocusScope.of(context).unfocus();
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(
        () => _stepError = 'Please enter your registered email address.',
      );
      return;
    }
    if (!email.contains('@') || !email.contains('.')) {
      setState(() => _stepError = 'Please enter a valid email address.');
      return;
    }
    try {
      await AuthApi.instance.sendResetOtp(email);
      if (!mounted) return;
      setState(() {
        _stepError = null;
        _currentStep = 2;
      });
      _startTimer();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _otpFocusNode.requestFocus();
      });
    } on AuthApiException catch (error) {
      if (mounted) setState(() => _stepError = error.message);
    } catch (_) {
      if (mounted) {
        setState(() => _stepError = 'Could not send the reset code.');
      }
    }
  }

  // --- Step 2: Verify OTP ---
  Future<void> _submitStep2() async {
    FocusScope.of(context).unfocus();
    final otp = _otpController.text.trim();
    if (otp.isEmpty) {
      setState(() => _stepError = 'Please enter the verification code.');
      return;
    }
    if (otp.length < 4) {
      setState(
        () => _stepError = 'Please enter the complete verification code.',
      );
      return;
    }
    try {
      final result = await AuthApi.instance.verifyOtp(
        email: _emailController.text.trim(),
        otp: otp,
      );
      final nested = result['data'];
      final resetToken =
          result['reset_token'] ??
          (nested is Map ? nested['reset_token'] : null);
      if (resetToken is! String || resetToken.isEmpty) {
        throw const AuthApiException(
          'The server did not return a password reset token.',
        );
      }
      if (!mounted) return;
      setState(() {
        _stepError = null;
        _resetToken = resetToken;
        _currentStep = 3;
      });
    } on AuthApiException catch (error) {
      if (mounted) setState(() => _stepError = error.message);
    } catch (_) {
      if (mounted) {
        setState(() => _stepError = 'Could not verify the reset code.');
      }
    }
  }

  // --- Step 3: Set New Password & Confirm Password (in same window one by one) ---
  Future<void> _submitStep3() async {
    FocusScope.of(context).unfocus();
    final pass = _newPasswordController.text;
    final confirm = _confirmPasswordController.text;
    if (pass.isEmpty) {
      setState(() => _stepError = 'Please enter your new password.');
      return;
    }
    if (pass.length < 8) {
      setState(
        () => _stepError = 'Password must be at least 8 characters long.',
      );
      return;
    }
    if (confirm.isEmpty) {
      setState(() => _stepError = 'Please confirm your new password.');
      return;
    }
    if (confirm != pass) {
      setState(() => _stepError = 'Passwords do not match. Please re-enter.');
      return;
    }
    try {
      final encryptedPassword = await AuthApi.instance
          .encryptPasswordForPasswordFlow(_newPasswordController.text);
      await AuthApi.instance.confirmPasswordReset({
        'email': _emailController.text.trim(),
        'new_password': encryptedPassword,
        'reset_token': _resetToken,
      });
      if (!mounted) return;
      setState(() {
        _stepError = null;
        _currentStep = 4;
      });
      widget.onPasswordResetCompleted(
        _emailController.text.trim(),
        _newPasswordController.text,
      );
    } on AuthApiException catch (error) {
      if (mounted) setState(() => _stepError = error.message);
    } catch (_) {
      if (mounted) {
        setState(() => _stepError = 'Could not reset your password.');
      }
    }
  }

  // --- Step 4: Finish & Back to Login ---
  void _submitStep4() {
    Navigator.pop(context);
  }

  Widget _buildStepErrorFeedback() {
    if (_stepError == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 8, bottom: 2),
      child: Row(
        children: [
          const Icon(
            LucideIcons.alertCircle,
            size: 14,
            color: _loginErrorColor,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              _stepError!,
              style: const TextStyle(
                color: _loginErrorColor,
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required VoidCallback onPressed,
    IconData icon = Icons.arrow_forward_rounded,
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
              color: Color(0x4D1E70E8),
              offset: Offset(0, 6),
              blurRadius: 14,
            ),
          ],
        ),
        child: SizedBox(
          height: 54,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Center(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              Positioned(
                right: 8,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.22),
                  ),
                  child: Icon(icon, color: Colors.white, size: 19),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- View: Step 1 Content ---
  Widget _buildStep1Content(
    Color titleColor,
    Color subtitleColor,
    Color inputBg,
    Color inputBorder,
    Color inputTextColor,
    Color placeholderColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Confirm Email Address',
          style: TextStyle(
            color: titleColor,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Enter your registered email address to receive a one-time verification code (OTP).',
          style: TextStyle(color: subtitleColor, fontSize: 13.5, height: 1.4),
        ),
        const SizedBox(height: 22),
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: inputBg,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: _stepError != null ? _loginErrorColor : inputBorder,
              width: 1.2,
            ),
          ),
          child: Center(
            child: TextFormField(
              controller: _emailController,
              textAlignVertical: TextAlignVertical.center,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submitStep1(),
              cursorColor: _loginRoyalBlue,
              style: TextStyle(
                color: inputTextColor,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                height: 1.25,
              ),
              onChanged: (_) {
                if (_stepError != null) setState(() => _stepError = null);
              },
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                hintText: 'Email Address',
                hintStyle: TextStyle(
                  color: placeholderColor,
                  fontSize: 14.5,
                  height: 1.25,
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 18, right: 12),
                  child: Icon(
                    LucideIcons.mail,
                    color: _loginRoyalBlue,
                    size: 20,
                  ),
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 50,
                  minHeight: 24,
                ),
                contentPadding: const EdgeInsets.only(right: 20),
              ),
            ),
          ),
        ),
        _buildStepErrorFeedback(),
        const SizedBox(height: 24),
        _buildActionButton(label: 'Send OTP', onPressed: _submitStep1),
      ],
    );
  }

  // --- View: Step 2 Content (Modern 6-Cell OTP Input with Superior UX) ---
  Widget _buildStep2Content(
    Color titleColor,
    Color subtitleColor,
    Color inputBg,
    Color inputBorder,
    Color inputTextColor,
    Color placeholderColor,
  ) {
    final otpText = _otpController.text;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Enter Verification Code',
                style: TextStyle(
                  color: titleColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            InkWell(
              onTap: () {
                setState(() {
                  _stepError = null;
                  _currentStep = 1;
                });
              },
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Text(
                  'Change',
                  style: TextStyle(
                    color: widget.isDark
                        ? const Color(0xFF6DA2F5)
                        : _loginRoyalBlue,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text.rich(
          TextSpan(
            text: 'We sent a 6-digit code to ',
            style: TextStyle(color: subtitleColor, fontSize: 13.5, height: 1.4),
            children: [
              TextSpan(
                text: _emailController.text.trim(),
                style: TextStyle(
                  color: widget.isDark ? Colors.white : _loginDarkBlueText,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // 6-digit PIN Box interactive input
        SizedBox(
          height: 62,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Hidden real text field backing the UX
              Opacity(
                opacity: 0.0,
                child: TextField(
                  controller: _otpController,
                  focusNode: _otpFocusNode,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  autofocus: true,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  onChanged: (val) {
                    if (_stepError != null) setState(() => _stepError = null);
                    setState(() {});
                    if (val.length == 6) {
                      _submitStep2();
                    }
                  },
                  onSubmitted: (_) => _submitStep2(),
                ),
              ),

              // Visual 6 individual cells
              GestureDetector(
                onTap: () => _otpFocusNode.requestFocus(),
                behavior: HitTestBehavior.opaque,
                child: Row(
                  children: List.generate(6, (index) {
                    final hasChar = index < otpText.length;
                    final char = hasChar ? otpText[index] : '';
                    final isFocusedCell =
                        _otpFocusNode.hasFocus &&
                        (index == otpText.length ||
                            (index == 5 && otpText.length == 6));
                    final hasError = _stepError != null;

                    Color cellBorder;
                    double borderWidth;
                    List<BoxShadow> cellShadow;

                    if (hasError) {
                      cellBorder = _loginErrorColor;
                      borderWidth = 1.5;
                      cellShadow = const [
                        BoxShadow(
                          color: Color(0x26E53935),
                          offset: Offset(0, 3),
                          blurRadius: 8,
                        ),
                      ];
                    } else if (isFocusedCell) {
                      cellBorder = _loginRoyalBlue;
                      borderWidth = 2.0;
                      cellShadow = [
                        BoxShadow(
                          color: _loginRoyalBlue.withValues(alpha: 0.28),
                          offset: const Offset(0, 4),
                          blurRadius: 10,
                        ),
                      ];
                    } else if (hasChar) {
                      cellBorder = widget.isDark
                          ? const Color(0xFF4C7FD8)
                          : _loginRoyalBlue.withValues(alpha: 0.65);
                      borderWidth = 1.5;
                      cellShadow = const [
                        BoxShadow(
                          color: Color(0x141E70E8),
                          offset: Offset(0, 2),
                          blurRadius: 6,
                        ),
                      ];
                    } else {
                      cellBorder = inputBorder;
                      borderWidth = 1.2;
                      cellShadow = [];
                    }

                    return Expanded(
                      child: Container(
                        height: 60,
                        margin: EdgeInsets.only(
                          left: index == 0 ? 0 : 4,
                          right: index == 5 ? 0 : 4,
                        ),
                        decoration: BoxDecoration(
                          color: inputBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: cellBorder,
                            width: borderWidth,
                          ),
                          boxShadow: cellShadow,
                        ),
                        child: Center(
                          child: hasChar
                              ? Text(
                                  char,
                                  style: TextStyle(
                                    color: inputTextColor,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                  ),
                                )
                              : isFocusedCell
                              ? Container(
                                  width: 2.2,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    color: _loginRoyalBlue,
                                    borderRadius: BorderRadius.circular(1),
                                  ),
                                )
                              : Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: placeholderColor.withValues(
                                      alpha: 0.35,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),

        _buildStepErrorFeedback(),

        const SizedBox(height: 14),

        // Helper row: Quick paste & Clear action
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: () async {
                final data = await Clipboard.getData('text/plain');
                if (data?.text != null) {
                  final digits = data!.text!.replaceAll(RegExp(r'\D'), '');
                  if (digits.isNotEmpty) {
                    final code = digits.substring(
                      0,
                      math.min(6, digits.length),
                    );
                    setState(() {
                      _otpController.text = code;
                      if (_stepError != null) _stepError = null;
                    });
                    if (code.length == 6) {
                      _submitStep2();
                    }
                  }
                }
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      LucideIcons.clipboardPaste,
                      size: 14,
                      color: widget.isDark
                          ? const Color(0xFF7E8B9F)
                          : _loginMutedBlueText,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Paste code',
                      style: TextStyle(
                        color: widget.isDark
                            ? const Color(0xFF7E8B9F)
                            : _loginMutedBlueText,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (otpText.isNotEmpty)
              InkWell(
                onTap: () {
                  setState(() {
                    _otpController.clear();
                    if (_stepError != null) _stepError = null;
                  });
                  _otpFocusNode.requestFocus();
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  child: Text(
                    'Clear',
                    style: TextStyle(
                      color: widget.isDark
                          ? const Color(0xFF7E8B9F)
                          : _loginMutedBlueText,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 12),

        // Resend code countdown timer pill / active button
        Center(
          child: _resendCountdown > 0
              ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: widget.isDark
                        ? const Color(0xFF1E2028)
                        : const Color(0xFFF0F5FD),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: widget.isDark
                          ? const Color(0x22FFFFFF)
                          : const Color(0x331E70E8),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.clock, size: 14, color: subtitleColor),
                      const SizedBox(width: 6),
                      Text(
                        'Resend code in 00:${_resendCountdown.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          color: subtitleColor,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
              : TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _otpController.clear();
                      if (_stepError != null) _stepError = null;
                    });
                    unawaited(_resendResetOtp());
                    _otpFocusNode.requestFocus();
                  },
                  icon: const Icon(
                    LucideIcons.rotateCcw,
                    size: 14,
                    color: _loginRoyalBlue,
                  ),
                  label: const Text(
                    'Resend OTP Code',
                    style: TextStyle(
                      color: _loginRoyalBlue,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
        ),

        const SizedBox(height: 20),

        _buildActionButton(label: 'Verify OTP', onPressed: _submitStep2),
      ],
    );
  }

  // --- View: Step 3 Content (New Password & Confirm Password in same window one by one) ---
  Widget _buildStep3Content(
    Color titleColor,
    Color subtitleColor,
    Color inputBg,
    Color inputBorder,
    Color inputTextColor,
    Color placeholderColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Create New Password',
          style: TextStyle(
            color: titleColor,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Choose a strong password and confirm it below.',
          style: TextStyle(color: subtitleColor, fontSize: 13.5, height: 1.4),
        ),
        const SizedBox(height: 20),

        // New Password Field
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: inputBg,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: _stepError != null ? _loginErrorColor : inputBorder,
              width: 1.2,
            ),
          ),
          child: Center(
            child: TextFormField(
              controller: _newPasswordController,
              textAlignVertical: TextAlignVertical.center,
              obscureText: !_newPasswordVisible,
              obscuringCharacter: '•',
              textInputAction: TextInputAction.next,
              cursorColor: _loginRoyalBlue,
              style: TextStyle(
                color: inputTextColor,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing:
                    (_newPasswordVisible || _newPasswordController.text.isEmpty)
                    ? 0
                    : 2.5,
                height: 1.25,
              ),
              onChanged: (_) {
                if (_stepError != null) setState(() => _stepError = null);
              },
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                hintText: 'New Password (min. 8 characters)',
                hintStyle: TextStyle(
                  color: placeholderColor,
                  fontSize: 14.5,
                  letterSpacing: 0,
                  height: 1.25,
                ),
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(left: 18, right: 12),
                  child: Icon(
                    LucideIcons.lock,
                    color: _loginRoyalBlue,
                    size: 20,
                  ),
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 50,
                  minHeight: 24,
                ),
                suffixIconConstraints: const BoxConstraints(
                  minWidth: 44,
                  minHeight: 24,
                ),
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: GestureDetector(
                    onTap: () => setState(
                      () => _newPasswordVisible = !_newPasswordVisible,
                    ),
                    behavior: HitTestBehavior.opaque,
                    child: Icon(
                      _newPasswordVisible
                          ? LucideIcons.eye
                          : LucideIcons.eyeOff,
                      color: placeholderColor,
                      size: 20,
                    ),
                  ),
                ),
                contentPadding: const EdgeInsets.only(right: 8),
              ),
            ),
          ),
        ),

        const SizedBox(height: 14),

        // Confirm Password Field (one by one in the same window)
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: inputBg,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: _stepError != null ? _loginErrorColor : inputBorder,
              width: 1.2,
            ),
          ),
          child: Center(
            child: TextFormField(
              controller: _confirmPasswordController,
              textAlignVertical: TextAlignVertical.center,
              obscureText: !_confirmPasswordVisible,
              obscuringCharacter: '•',
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submitStep3(),
              cursorColor: _loginRoyalBlue,
              style: TextStyle(
                color: inputTextColor,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing:
                    (_confirmPasswordVisible ||
                        _confirmPasswordController.text.isEmpty)
                    ? 0
                    : 2.5,
                height: 1.25,
              ),
              onChanged: (_) {
                if (_stepError != null) setState(() => _stepError = null);
              },
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                hintText: 'Confirm New Password',
                hintStyle: TextStyle(
                  color: placeholderColor,
                  fontSize: 14.5,
                  letterSpacing: 0,
                  height: 1.25,
                ),
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(left: 18, right: 12),
                  child: Icon(
                    LucideIcons.lock,
                    color: _loginRoyalBlue,
                    size: 20,
                  ),
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 50,
                  minHeight: 24,
                ),
                suffixIconConstraints: const BoxConstraints(
                  minWidth: 44,
                  minHeight: 24,
                ),
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: GestureDetector(
                    onTap: () => setState(
                      () => _confirmPasswordVisible = !_confirmPasswordVisible,
                    ),
                    behavior: HitTestBehavior.opaque,
                    child: Icon(
                      _confirmPasswordVisible
                          ? LucideIcons.eye
                          : LucideIcons.eyeOff,
                      color: placeholderColor,
                      size: 20,
                    ),
                  ),
                ),
                contentPadding: const EdgeInsets.only(right: 8),
              ),
            ),
          ),
        ),

        _buildStepErrorFeedback(),
        const SizedBox(height: 22),
        _buildActionButton(
          label: 'Reset Password',
          onPressed: _submitStep3,
          icon: Icons.check_rounded,
        ),
      ],
    );
  }

  // --- View: Step 4 Content (Success Done) ---
  Widget _buildStep4Content(Color titleColor, Color subtitleColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 10),
        Center(
          child: Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFE8F5E9),
              border: Border.all(color: const Color(0xFF2E7D32), width: 2.2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x332E7D32),
                  offset: Offset(0, 6),
                  blurRadius: 16,
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.check_rounded,
                color: Color(0xFF2E7D32),
                size: 46,
              ),
            ),
          ),
        ),
        const SizedBox(height: 22),
        Text(
          'Password Reset Done!',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: titleColor,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Your password has been successfully updated. You can now use your new password to sign in.',
          textAlign: TextAlign.center,
          style: TextStyle(color: subtitleColor, fontSize: 13.5, height: 1.4),
        ),
        const SizedBox(height: 28),
        _buildActionButton(
          label: 'Back to Login',
          onPressed: _submitStep4,
          icon: Icons.login_rounded,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final titleColor = widget.isDark ? Colors.white : _loginDarkBlueText;
    final subtitleColor = widget.isDark
        ? const Color(0xFF9EA3B0)
        : _loginMutedBlueText;
    final inputBg = widget.isDark
        ? const Color(0xFF191A20)
        : const Color(0xFFF4F8FD);
    final inputBorder = widget.isDark
        ? const Color(0x33FFFFFF)
        : _loginGoldBorder;
    final inputTextColor = widget.isDark ? Colors.white : _loginDarkBlueText;
    final placeholderColor = widget.isDark
        ? const Color(0xFF757885)
        : _loginPlaceholderText;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: widget.isDark ? const Color(0xFF22232A) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(
            color: widget.isDark
                ? const Color(0x33FFFFFF)
                : const Color(0x66ECC868),
            width: 1.2,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x40000000),
              offset: Offset(0, -6),
              blurRadius: 24,
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top handle & close row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 32),
                    Container(
                      width: 42,
                      height: 4.5,
                      decoration: BoxDecoration(
                        color: widget.isDark
                            ? const Color(0xFF454854)
                            : const Color(0x80ECC868),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        LucideIcons.x,
                        color: widget.isDark
                            ? const Color(0xFF888F9F)
                            : _loginPlaceholderText,
                        size: 20,
                      ),
                      tooltip: 'Close',
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Dynamic step content
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: switch (_currentStep) {
                    1 => _buildStep1Content(
                      titleColor,
                      subtitleColor,
                      inputBg,
                      inputBorder,
                      inputTextColor,
                      placeholderColor,
                    ),
                    2 => _buildStep2Content(
                      titleColor,
                      subtitleColor,
                      inputBg,
                      inputBorder,
                      inputTextColor,
                      placeholderColor,
                    ),
                    3 => _buildStep3Content(
                      titleColor,
                      subtitleColor,
                      inputBg,
                      inputBorder,
                      inputTextColor,
                      placeholderColor,
                    ),
                    _ => _buildStep4Content(titleColor, subtitleColor),
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Bottom popup modal for Sign-Up email OTP verification
class _SignUpEmailVerificationModal extends StatefulWidget {
  const _SignUpEmailVerificationModal({
    required this.email,
    required this.isDark,
    required this.onVerified,
  });

  final String email;
  final bool isDark;
  final VoidCallback onVerified;

  @override
  State<_SignUpEmailVerificationModal> createState() =>
      _SignUpEmailVerificationModalState();
}

class _SignUpEmailVerificationModalState
    extends State<_SignUpEmailVerificationModal> {
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _otpFocusNode = FocusNode();
  String? _error;
  int _countdown = 45;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    unawaited(_sendSignupOtp());
    _otpFocusNode.addListener(() {
      if (mounted) setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _otpFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    _otpFocusNode.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _countdown = 45);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_countdown > 1) {
        setState(() => _countdown--);
      } else {
        timer.cancel();
        setState(() => _countdown = 0);
      }
    });
  }

  Future<void> _sendSignupOtp() async {
    try {
      await AuthApi.instance.sendSignupOtp(widget.email);
      if (mounted) _startTimer();
    } on AuthApiException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Could not send the verification code.');
      }
    }
  }

  Future<void> _verifyOtp() async {
    FocusScope.of(context).unfocus();
    final otp = _otpController.text.trim();
    if (otp.isEmpty) {
      setState(() => _error = 'Please enter the verification code.');
      return;
    }
    if (otp.length < 4) {
      setState(() => _error = 'Please enter the complete verification code.');
      return;
    }
    try {
      await AuthApi.instance.verifySignupOtp(email: widget.email, otp: otp);
      if (!mounted) return;
      widget.onVerified();
      Navigator.pop(context);
    } on AuthApiException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (_) {
      if (mounted) setState(() => _error = 'Could not verify the code.');
    }
  }

  Widget _buildActionButton() {
    return FilledButton(
      onPressed: _verifyOtp,
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
              color: Color(0x4D1E70E8),
              offset: Offset(0, 6),
              blurRadius: 14,
            ),
          ],
        ),
        child: SizedBox(
          height: 54,
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Center(
                child: Text(
                  'Verify Email',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              Positioned(
                right: 8,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.22),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
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

  @override
  Widget build(BuildContext context) {
    final titleColor = widget.isDark ? Colors.white : _loginDarkBlueText;
    final subtitleColor = widget.isDark
        ? const Color(0xFF9EA3B0)
        : _loginMutedBlueText;
    final inputBg = widget.isDark
        ? const Color(0xFF191A20)
        : const Color(0xFFF4F8FD);
    final inputBorder = widget.isDark
        ? const Color(0x33FFFFFF)
        : _loginGoldBorder;
    final inputTextColor = widget.isDark ? Colors.white : _loginDarkBlueText;
    final placeholderColor = widget.isDark
        ? const Color(0xFF757885)
        : _loginPlaceholderText;
    final otpText = _otpController.text;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: widget.isDark ? const Color(0xFF22232A) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(
            color: widget.isDark
                ? const Color(0x33FFFFFF)
                : const Color(0x66ECC868),
            width: 1.2,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x40000000),
              offset: Offset(0, -6),
              blurRadius: 24,
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top handle & close row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 32),
                    Container(
                      width: 42,
                      height: 4.5,
                      decoration: BoxDecoration(
                        color: widget.isDark
                            ? const Color(0xFF454854)
                            : const Color(0x80ECC868),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        LucideIcons.x,
                        color: widget.isDark
                            ? const Color(0xFF888F9F)
                            : _loginPlaceholderText,
                        size: 20,
                      ),
                      tooltip: 'Close',
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Text(
                  'Verify Email Address',
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text.rich(
                  TextSpan(
                    text: 'We sent a 6-digit verification code to\n',
                    style: TextStyle(
                      color: subtitleColor,
                      fontSize: 13.5,
                      height: 1.4,
                    ),
                    children: [
                      TextSpan(
                        text: widget.email,
                        style: TextStyle(
                          color: widget.isDark
                              ? Colors.white
                              : _loginDarkBlueText,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 6-digit PIN Box interactive input
                SizedBox(
                  height: 62,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Opacity(
                        opacity: 0.0,
                        child: TextField(
                          controller: _otpController,
                          focusNode: _otpFocusNode,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          autofocus: true,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(6),
                          ],
                          onChanged: (val) {
                            if (_error != null) setState(() => _error = null);
                            setState(() {});
                            if (val.length == 6) {
                              _verifyOtp();
                            }
                          },
                          onSubmitted: (_) => _verifyOtp(),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _otpFocusNode.requestFocus(),
                        behavior: HitTestBehavior.opaque,
                        child: Row(
                          children: List.generate(6, (index) {
                            final hasChar = index < otpText.length;
                            final char = hasChar ? otpText[index] : '';
                            final isFocusedCell =
                                _otpFocusNode.hasFocus &&
                                (index == otpText.length ||
                                    (index == 5 && otpText.length == 6));
                            final hasError = _error != null;

                            Color cellBorder;
                            double borderWidth;
                            List<BoxShadow> cellShadow;

                            if (hasError) {
                              cellBorder = _loginErrorColor;
                              borderWidth = 1.5;
                              cellShadow = const [
                                BoxShadow(
                                  color: Color(0x26E53935),
                                  offset: Offset(0, 3),
                                  blurRadius: 8,
                                ),
                              ];
                            } else if (isFocusedCell) {
                              cellBorder = _loginRoyalBlue;
                              borderWidth = 2.0;
                              cellShadow = [
                                BoxShadow(
                                  color: _loginRoyalBlue.withValues(
                                    alpha: 0.28,
                                  ),
                                  offset: const Offset(0, 4),
                                  blurRadius: 10,
                                ),
                              ];
                            } else if (hasChar) {
                              cellBorder = widget.isDark
                                  ? const Color(0xFF4C7FD8)
                                  : _loginRoyalBlue.withValues(alpha: 0.65);
                              borderWidth = 1.5;
                              cellShadow = const [
                                BoxShadow(
                                  color: Color(0x141E70E8),
                                  offset: Offset(0, 2),
                                  blurRadius: 6,
                                ),
                              ];
                            } else {
                              cellBorder = inputBorder;
                              borderWidth = 1.2;
                              cellShadow = [];
                            }

                            return Expanded(
                              child: Container(
                                height: 60,
                                margin: EdgeInsets.only(
                                  left: index == 0 ? 0 : 4,
                                  right: index == 5 ? 0 : 4,
                                ),
                                decoration: BoxDecoration(
                                  color: inputBg,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: cellBorder,
                                    width: borderWidth,
                                  ),
                                  boxShadow: cellShadow,
                                ),
                                child: Center(
                                  child: hasChar
                                      ? Text(
                                          char,
                                          style: TextStyle(
                                            color: inputTextColor,
                                            fontSize: 22,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        )
                                      : isFocusedCell
                                      ? Container(
                                          width: 2.2,
                                          height: 22,
                                          decoration: BoxDecoration(
                                            color: _loginRoyalBlue,
                                            borderRadius: BorderRadius.circular(
                                              1,
                                            ),
                                          ),
                                        )
                                      : Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: placeholderColor.withValues(
                                              alpha: 0.35,
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),

                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, top: 8, bottom: 2),
                    child: Row(
                      children: [
                        const Icon(
                          LucideIcons.alertCircle,
                          size: 14,
                          color: _loginErrorColor,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _error!,
                            style: const TextStyle(
                              color: _loginErrorColor,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 14),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () async {
                        final data = await Clipboard.getData('text/plain');
                        if (data?.text != null) {
                          final digits = data!.text!.replaceAll(
                            RegExp(r'\D'),
                            '',
                          );
                          if (digits.isNotEmpty) {
                            final code = digits.substring(
                              0,
                              math.min(6, digits.length),
                            );
                            setState(() {
                              _otpController.text = code;
                              if (_error != null) _error = null;
                            });
                            if (code.length == 6) {
                              _verifyOtp();
                            }
                          }
                        }
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 4,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              LucideIcons.clipboardPaste,
                              size: 14,
                              color: widget.isDark
                                  ? const Color(0xFF7E8B9F)
                                  : _loginMutedBlueText,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Paste code',
                              style: TextStyle(
                                color: widget.isDark
                                    ? const Color(0xFF7E8B9F)
                                    : _loginMutedBlueText,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (otpText.isNotEmpty)
                      InkWell(
                        onTap: () {
                          setState(() {
                            _otpController.clear();
                            if (_error != null) _error = null;
                          });
                          _otpFocusNode.requestFocus();
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 4,
                          ),
                          child: Text(
                            'Clear',
                            style: TextStyle(
                              color: widget.isDark
                                  ? const Color(0xFF7E8B9F)
                                  : _loginMutedBlueText,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 12),

                Center(
                  child: _countdown > 0
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: widget.isDark
                                ? const Color(0xFF1E2028)
                                : const Color(0xFFF0F5FD),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: widget.isDark
                                  ? const Color(0x22FFFFFF)
                                  : const Color(0x331E70E8),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                LucideIcons.clock,
                                size: 14,
                                color: subtitleColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Resend code in 00:${_countdown.toString().padLeft(2, '0')}',
                                style: TextStyle(
                                  color: subtitleColor,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        )
                      : TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _otpController.clear();
                              if (_error != null) _error = null;
                            });
                            unawaited(_sendSignupOtp());
                            _otpFocusNode.requestFocus();
                          },
                          icon: const Icon(
                            LucideIcons.rotateCcw,
                            size: 14,
                            color: _loginRoyalBlue,
                          ),
                          label: const Text(
                            'Resend OTP Code',
                            style: TextStyle(
                              color: _loginRoyalBlue,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                ),

                const SizedBox(height: 20),

                _buildActionButton(),
              ],
            ),
          ),
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
