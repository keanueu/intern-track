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
    final password = _passwordCtrl.text;

    if (email.isEmpty) {
      setState(() => _error = 'Please enter your email address.');
      _emailFocus.requestFocus();
      return;
    }
    final emailRegex = RegExp(r'^[\w\-.]+@([\w\-]+\.)+[\w\-]{2,}$');
    if (!emailRegex.hasMatch(email)) {
      setState(() => _error = 'Please enter a valid email address.');
      _emailFocus.requestFocus();
      return;
    }
    if (password.isEmpty) {
      setState(() => _error = 'Please enter your password.');
      _passwordFocus.requestFocus();
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final appState = context.read<AppState>();
    try {
      await appState.login(email, password);
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
    final ts = Theme.of(context).textTheme;
    final canPop = ModalRoute.of(context)?.canPop ?? false;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: canPop
            ? IconButton(
                icon: Icon(AppIcons.chevronLeft, color: c.textPrimary),
                tooltip: 'Go back',
                onPressed: () => Navigator.pop(context),
              )
            : null,
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
                const SizedBox(height: 16),

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
                            fit: BoxFit.contain,
                            semanticLabel: 'App logo'),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                FadeSlideIn(
                  index: 1,
                  child: Column(
                    children: [
                      Text('Welcome Back',
                          textAlign: TextAlign.center,
                          style: ts.headlineMedium?.copyWith(letterSpacing: 0.3)),
                      const SizedBox(height: 8),
                      Text('Sign in to continue tracking your progress',
                          textAlign: TextAlign.center,
                          style: ts.bodyMedium),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                FadeSlideIn(
                  index: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Email', style: ts.labelSmall),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _emailCtrl,
                        focusNode: _emailFocus,
                        style: ts.bodyLarge,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autocorrect: false,
                        onChanged: (_) {
                          if (_error != null) setState(() => _error = null);
                        },
                        onSubmitted: (_) => _passwordFocus.requestFocus(),
                        decoration: InputDecoration(
                          hintText: 'you@company.com',
                          prefixIcon: Icon(AppIcons.email, size: 18, color: c.accent),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: kRadiusInput,
                              borderSide: BorderSide(color: c.accent, width: 1.5)),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                FadeSlideIn(
                  index: 3,
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
                        textInputAction: TextInputAction.done,
                        onChanged: (_) {
                          if (_error != null) setState(() => _error = null);
                        },
                        onSubmitted: (_) => _handleLogin(),
                        decoration: InputDecoration(
                          hintText: 'Enter your password',
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
                    ],
                  ),
                ),

                if (_error != null)
                  FadeSlideIn(
                    index: 4,
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
                                style: ts.labelLarge?.copyWith(
                                    color: c.onAccent, letterSpacing: 0.3)),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                FadeSlideIn(
                  index: 6,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have an account?  ", style: ts.bodyMedium),
                      GestureDetector(
                        onTap: _isLoading
                            ? null
                            : () => Navigator.push(context,
                                MaterialPageRoute(builder: (_) => const RegisterScreen())),
                        child: Text('Sign up',
                            style: ts.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w700, color: c.accent)),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                FadeSlideIn(
                  index: 7,
                  child: Text(
                    'By continuing, you agree to the Terms of Service and Privacy Policy.',
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
}
