import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../main.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  bool _isLoading = false;
  String? _error;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();

    if (email.isEmpty) {
      setState(() => _error = 'Please enter your email address.');
      _emailFocus.requestFocus();
      return;
    }
    if (password.isEmpty) {
      setState(() => _error = 'Please enter your password.');
      _passwordFocus.requestFocus();
      return;
    }

    setState(() { _isLoading = true; _error = null; });

    final appState = context.read<AppState>();
    await appState.login(email, password);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (appState.isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainContainer()),
      );
    } else {
      setState(() => _error = 'Invalid email or password. Please try again.');
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
                    Text('Welcome Back',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: c.textPrimary,
                            letterSpacing: 0.3)),
                    const SizedBox(height: 8),
                    Text('Sign in to continue tracking your progress',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: c.textSecondary)),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Email field
              FadeSlideIn(
                index: 2,
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

              // Password field
              FadeSlideIn(
                index: 3,
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
                      onSubmitted: (_) => _handleLogin(),
                      decoration: InputDecoration(
                        hintText: 'Enter your password',
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
                  ],
                ),
              ),

              // Error
              if (_error != null)
                FadeSlideIn(
                  index: 4,
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

              // Sign In button
              FadeSlideIn(
                index: 5,
                child: TapScale(
                  onTap: _isLoading ? null : _handleLogin,
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
                          : Text('Sign In',
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

              // Register link
              FadeSlideIn(
                index: 6,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account?  ",
                        style: TextStyle(fontSize: 13, color: c.textSecondary)),
                    GestureDetector(
                      onTap: () => Navigator.push(
                          context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                      child: Text('Sign up',
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
                index: 7,
                child: Text(
                  'By continuing, you agree to the Terms of Service and Privacy Policy.',
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
}
