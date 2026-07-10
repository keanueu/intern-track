import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../main.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();
  bool _isLoading = false;
  String? _error;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    _passwordCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  bool _hasMinLength(String p) => p.length >= 8;
  bool _hasUpper(String p) => RegExp(r'[A-Z]').hasMatch(p);
  bool _hasLower(String p) => RegExp(r'[a-z]').hasMatch(p);
  bool _hasDigit(String p) => RegExp(r'\d').hasMatch(p);

  bool _isEmailValid(String e) =>
      RegExp(r'^[\w\-.]+@([\w\-]+\.)+[\w\-]{2,}$').hasMatch(e);

  double _passwordScore(String p) {
    if (p.isEmpty) return 0.0;
    int score = 0;
    if (_hasMinLength(p)) score++;
    if (_hasUpper(p)) score++;
    if (_hasLower(p)) score++;
    if (_hasDigit(p)) score++;
    return score / 4.0;
  }

  Future<void> _handleRegister() async {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    final confirm = _confirmCtrl.text;

    if (name.isEmpty) {
      setState(() => _error = 'Please enter your full name.');
      _nameFocus.requestFocus();
      return;
    }
    if (email.isEmpty) {
      setState(() => _error = 'Please enter your email address.');
      _emailFocus.requestFocus();
      return;
    }
    if (!_isEmailValid(email)) {
      setState(() => _error = 'Please enter a valid email address.');
      _emailFocus.requestFocus();
      return;
    }
    if (password.isEmpty) {
      setState(() => _error = 'Please enter a password.');
      _passwordFocus.requestFocus();
      return;
    }
    if (!_isPasswordValid(password)) {
      setState(() => _error =
          'Password must be at least 8 characters with uppercase, lowercase, and a number.');
      _passwordFocus.requestFocus();
      return;
    }
    if (password != confirm) {
      setState(() => _error = 'Passwords do not match.');
      _confirmFocus.requestFocus();
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final appState = context.read<AppState>();
    try {
      await appState.register(name, email, password);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Something went wrong. Please try again.';
      });
      return;
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (appState.isLoggedIn) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainContainer()),
        (route) => false,
      );
    } else {
      setState(() => _error = 'Registration failed. This email may already be in use.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = ThemeColors.of(context);
    final ts = Theme.of(context).textTheme;
    final password = _passwordCtrl.text;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(AppIcons.chevronLeft, color: c.textPrimary),
          tooltip: 'Go back',
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.translucent,
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),

                FadeSlideIn(
                  index: 0,
                  child: Center(
                    child: Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: c.surface,
                        borderRadius: kRadiusCard,
                        border: Border.all(color: c.border),
                        boxShadow: kCardShadowFrom(c),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset('assets/images/logo.png',
                            fit: BoxFit.contain, semanticLabel: 'App logo'),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                FadeSlideIn(
                  index: 1,
                  child: Column(
                    children: [
                      Text('Create Account',
                          textAlign: TextAlign.center,
                          style: ts.headlineMedium?.copyWith(letterSpacing: 0.3)),
                      const SizedBox(height: 8),
                      Text('Start tracking your OJT hours and progress',
                          textAlign: TextAlign.center,
                          style: ts.bodyMedium),
                    ],
                  ),
                ),

                const SizedBox(height: 36),

                _buildField('Full Name', ts, c,
                    index: 2,
                    ctrl: _nameCtrl,
                    focus: _nameFocus,
                    hint: 'Juan dela Cruz',
                    icon: AppIcons.profileOutline,
                    keyboard: TextInputType.name,
                    action: TextInputAction.next,
                    capitalization: TextCapitalization.words,
                    onNext: () => _emailFocus.requestFocus()),

                const SizedBox(height: 18),

                _buildField('Email', ts, c,
                    index: 3,
                    ctrl: _emailCtrl,
                    focus: _emailFocus,
                    hint: 'you@company.com',
                    icon: AppIcons.email,
                    keyboard: TextInputType.emailAddress,
                    action: TextInputAction.next,
                    autocorrect: false,
                    onNext: () => _passwordFocus.requestFocus()),

                const SizedBox(height: 18),

                FadeSlideIn(
                  index: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Password', style: ts.labelSmall),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _passwordCtrl,
                        focusNode: _passwordFocus,
                        style: ts.bodyLarge,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.next,
                        autocorrect: false,
                        enableSuggestions: false,
                        textCapitalization: TextCapitalization.none,
                        onChanged: (_) {
                          if (_error != null) setState(() => _error = null);
                        },
                        onSubmitted: (_) => _confirmFocus.requestFocus(),
                        decoration: InputDecoration(
                          hintText: 'Create a strong password',
                          prefixIcon: Icon(AppIcons.lock, size: 18, color: c.accent),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 18,
                              color: c.textSecondary,
                            ),
                            tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                            onPressed: () =>
                                setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: kRadiusInput,
                              borderSide: BorderSide(color: c.accent, width: 1.5)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      AnimatedGradientBar(
                          value: _passwordScore(password), height: 6),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          _passwordReq('8+ characters', _hasMinLength(password), c),
                          _passwordReq('Uppercase', _hasUpper(password), c),
                          _passwordReq('Lowercase', _hasLower(password), c),
                          _passwordReq('Number', _hasDigit(password), c),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                FadeSlideIn(
                  index: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Confirm Password', style: ts.labelSmall),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _confirmCtrl,
                        focusNode: _confirmFocus,
                        style: ts.bodyLarge,
                        obscureText: _obscureConfirm,
                        textInputAction: TextInputAction.done,
                        autocorrect: false,
                        enableSuggestions: false,
                        textCapitalization: TextCapitalization.none,
                        onChanged: (_) {
                          if (_error != null) setState(() => _error = null);
                        },
                        onSubmitted: (_) => _handleRegister(),
                        decoration: InputDecoration(
                          hintText: 'Re-enter your password',
                          prefixIcon: Icon(AppIcons.lock, size: 18, color: c.accent),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirm
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 18,
                              color: c.textSecondary,
                            ),
                            tooltip: _obscureConfirm ? 'Show password' : 'Hide password',
                            onPressed: () =>
                                setState(() => _obscureConfirm = !_obscureConfirm),
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: kRadiusInput,
                              borderSide: BorderSide(color: c.accent, width: 1.5)),
                        ),
                      ),
                    ],
                  ),
                ),

                if (_error != null)
                  FadeSlideIn(
                    index: 6,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: c.errorLight,
                          borderRadius: kRadiusBtn,
                          border: Border.all(color: c.error.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(AppIcons.warning, size: 16, color: c.error),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(_error!,
                                  style: ts.bodyMedium?.copyWith(color: c.error)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                if (_error != null) const SizedBox(height: 24) else const SizedBox(height: 28),

                FadeSlideIn(
                  index: 7,
                  child: TapScale(
                    onTap: _isLoading ? null : _handleRegister,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: _isLoading ? null : kGreenGradient,
                        color: _isLoading ? c.surface2 : null,
                        borderRadius: kRadiusBtn,
                        border: _isLoading ? Border.all(color: c.border) : null,
                      ),
                      child: Center(
                        child: _isLoading
                            ? SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                    color: c.textMuted, strokeWidth: 2.5),
                              )
                            : Text('Create Account',
                                style: ts.labelLarge?.copyWith(
                                    color: c.onAccent, letterSpacing: 0.3)),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                FadeSlideIn(
                  index: 8,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Already have an account?  ', style: ts.bodyMedium),
                      GestureDetector(
                        onTap: () => Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (_) => const LoginScreen())),
                        child: Text('Sign in',
                            style: ts.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w700, color: c.accent)),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                FadeSlideIn(
                  index: 9,
                  child: Text(
                    'By creating an account, you agree to the Terms of Service and Privacy Policy.',
                    textAlign: TextAlign.center,
                    style: ts.labelSmall,
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _isPasswordValid(String p) =>
      RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$').hasMatch(p);

  Widget _buildField(String label, TextTheme ts, ThemeColors c,
      {required int index,
      required TextEditingController ctrl,
      required FocusNode focus,
      required String hint,
      required IconData icon,
      TextInputType? keyboard,
      TextInputAction? action,
      TextCapitalization? capitalization,
      bool autocorrect = true,
      VoidCallback? onNext}) {
    return FadeSlideIn(
      index: index,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: ts.labelSmall),
          const SizedBox(height: 6),
          TextField(
            controller: ctrl,
            focusNode: focus,
            style: ts.bodyLarge,
            keyboardType: keyboard,
            textInputAction: action,
            textCapitalization: capitalization ?? TextCapitalization.none,
            autocorrect: autocorrect,
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
            onSubmitted: (_) => onNext?.call(),
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(icon, size: 18, color: c.accent),
              focusedBorder: OutlineInputBorder(
                  borderRadius: kRadiusInput,
                  borderSide: BorderSide(color: c.accent, width: 1.5)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _passwordReq(String label, bool met, ThemeColors c) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: met ? c.accentLight : c.surface2,
        borderRadius: kRadiusTag,
        border: Border.all(color: met ? c.accent : c.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            met ? Icons.check_circle : Icons.circle_outlined,
            size: 12,
            color: met ? c.accent : c.textMuted,
          ),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  color: met ? c.accent : c.textMuted,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
