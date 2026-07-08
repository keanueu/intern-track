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
  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  bool _isLoading = false;
  String? _error;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  bool _isPasswordValid(String p) =>
      RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$').hasMatch(p);

  bool _isEmailValid(String e) =>
      RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(e);

  Future<void> _handleRegister() async {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;

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

    setState(() { _isLoading = true; _error = null; });

    final appState = context.read<AppState>();
    await appState.register(name, email, password);

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
    final canPop = ModalRoute.of(context)?.canPop ?? false;

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: canPop
            ? IconButton(
                icon: Icon(AppIcons.chevronLeft, color: c.textPrimary),
                onPressed: () => Navigator.pop(context),
              )
            : null,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),

              // Logo
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
                      child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Title
              FadeSlideIn(
                index: 1,
                child: Column(
                  children: [
                    Text('Create Account',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: c.textPrimary,
                            letterSpacing: 0.3)),
                    const SizedBox(height: 8),
                    Text('Start tracking your OJT hours and progress',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: c.textSecondary)),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              // Full Name
              FadeSlideIn(
                index: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Full Name',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: c.textSecondary)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _nameCtrl,
                      focusNode: _nameFocus,
                      style: TextStyle(color: c.textPrimary, fontSize: 15),
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      autocorrect: false,
                      onSubmitted: (_) => _emailFocus.requestFocus(),
                      decoration: InputDecoration(
                        hintText: 'Juan dela Cruz',
                        prefixIcon: Icon(AppIcons.profileOutline, size: 18, color: kGreen),
                        filled: true,
                        fillColor: c.surface2,
                        border: OutlineInputBorder(
                            borderRadius: kRadiusInput, borderSide: BorderSide.none),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: kRadiusInput,
                            borderSide: BorderSide(color: c.border)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: kRadiusInput,
                            borderSide: const BorderSide(color: kGreen, width: 1.5)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Email
              FadeSlideIn(
                index: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Email',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: c.textSecondary)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _emailCtrl,
                      focusNode: _emailFocus,
                      style: TextStyle(color: c.textPrimary, fontSize: 15),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autocorrect: false,
                      onSubmitted: (_) => _passwordFocus.requestFocus(),
                      decoration: InputDecoration(
                        hintText: 'you@company.com',
                        prefixIcon: Icon(AppIcons.email, size: 18, color: kGreen),
                        filled: true,
                        fillColor: c.surface2,
                        border: OutlineInputBorder(
                            borderRadius: kRadiusInput, borderSide: BorderSide.none),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: kRadiusInput,
                            borderSide: BorderSide(color: c.border)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: kRadiusInput,
                            borderSide: const BorderSide(color: kGreen, width: 1.5)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Password
              FadeSlideIn(
                index: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Password',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: c.textSecondary)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _passwordCtrl,
                      focusNode: _passwordFocus,
                      style: TextStyle(color: c.textPrimary, fontSize: 15),
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _handleRegister(),
                      decoration: InputDecoration(
                        hintText: 'Create a strong password',
                        prefixIcon: Icon(AppIcons.lock, size: 18, color: kGreen),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            size: 18,
                            color: c.textSecondary,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        filled: true,
                        fillColor: c.surface2,
                        border: OutlineInputBorder(
                            borderRadius: kRadiusInput, borderSide: BorderSide.none),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: kRadiusInput,
                            borderSide: BorderSide(color: c.border)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: kRadiusInput,
                            borderSide: const BorderSide(color: kGreen, width: 1.5)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _passwordReq('8+ characters'),
                        _passwordReq('Uppercase'),
                        _passwordReq('Lowercase'),
                        _passwordReq('Number'),
                      ],
                    ),
                  ],
                ),
              ),

              // Error
              if (_error != null)
                FadeSlideIn(
                  index: 5,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: kRed.withValues(alpha: 0.1),
                        borderRadius: kRadiusBtn,
                        border: Border.all(color: kRed.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(AppIcons.warning, size: 16, color: kRed),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(_error!,
                                style: TextStyle(color: kRed, fontSize: 13)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              if (_error != null) const SizedBox(height: 24) else const SizedBox(height: 28),

              // Create Account button
              FadeSlideIn(
                index: 6,
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
                              style: TextStyle(
                                  color: c.onAccent,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  letterSpacing: 0.3)),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Login link
              FadeSlideIn(
                index: 7,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already have an account?  ',
                        style: TextStyle(fontSize: 13, color: c.textSecondary)),
                    GestureDetector(
                      onTap: () => Navigator.pushReplacement(
                          context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                      child: Text('Sign in',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: kGreen)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Legal
              FadeSlideIn(
                index: 8,
                child: Text(
                  'By creating an account, you agree to the Terms of Service and Privacy Policy.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: c.textMuted),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _passwordReq(String label) {
    final c = ThemeColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: c.surface2,
        borderRadius: kRadiusTag,
        border: Border.all(color: c.border),
      ),
      child: Text(label,
          style: TextStyle(fontSize: 10, color: c.textMuted, fontWeight: FontWeight.w500)),
    );
  }
}
