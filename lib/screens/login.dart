import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'register.dart';
import 'dashboard.dart';

class Login extends StatefulWidget {
  const Login({super.key});
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with SingleTickerProviderStateMixin {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  String _error = '';

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  // ── Design tokens ──
  static const _bg = Color(0xFF0D1117);
  static const _surface = Color(0xFF161B22);
  static const _card = Color(0xFF1C2128);
  static const _border = Color(0xFF30363D);
  static const _teal = Color(0xFF00B4D8);
  static const _white = Color(0xFFE6EDF3);
  static const _textMid = Color(0xFF8B949E);
  static const _red = Color(0xFFF85149);

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_usernameCtrl.text.isEmpty || _passwordCtrl.text.isEmpty) {
      setState(() => _error = 'Please fill in all fields.');
      return;
    }
    setState(() {
      _loading = true;
      _error = '';
    });
    final result = await AuthService.login(
      _usernameCtrl.text.trim(),
      _passwordCtrl.text,
    );
    setState(() => _loading = false);
    if (result.success) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } else {
      setState(() => _error = result.errorMessage ?? 'Login failed.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Logo ──
                      Center(
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [_teal, Color(0xFF0077B6)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: _teal.withValues(alpha: 0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.lock_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ── Title ──
                      const Center(
                        child: Text(
                          'Welcome back',
                          style: TextStyle(
                            color: _white,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Center(
                        child: Text(
                          'Sign in to your account',
                          style: TextStyle(color: _textMid, fontSize: 14),
                        ),
                      ),
                      const SizedBox(height: 36),

                      // ── Form Card ──
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: _surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: _border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label('Username'),
                            const SizedBox(height: 8),
                            _field(
                              controller: _usernameCtrl,
                              hint: 'Enter your username',
                              icon: Icons.person_outline_rounded,
                            ),
                            const SizedBox(height: 18),
                            _label('Password'),
                            const SizedBox(height: 8),
                            _passwordField(),
                            if (_error.isNotEmpty) ...[
                              const SizedBox(height: 14),
                              _errorBox(_error),
                            ],
                            const SizedBox(height: 22),
                            // Sign In button
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: _loading ? null : _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _teal,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: _teal.withValues(
                                    alpha: 0.4,
                                  ),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: _loading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : const Text(
                                        'Sign In',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Divider ──
                      Row(
                        children: [
                          const Expanded(
                            child: Divider(color: _border, thickness: 1),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: Text(
                              'or',
                              style: TextStyle(
                                color: _textMid.withValues(alpha: 0.6),
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const Expanded(
                            child: Divider(color: _border, thickness: 1),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // ── Register ──
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const Register()),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _white,
                            side: const BorderSide(color: _border),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Create an Account',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: Text(
                          'By signing in, you agree to our Terms & Privacy Policy.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            color: _textMid.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
    text,
    style: const TextStyle(
      color: _white,
      fontSize: 13,
      fontWeight: FontWeight.w600,
    ),
  );

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: _white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: _textMid.withValues(alpha: 0.6),
          fontSize: 13,
        ),
        prefixIcon: Icon(icon, size: 18, color: _textMid),
        filled: true,
        fillColor: _card,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _teal, width: 1.5),
        ),
      ),
    );
  }

  Widget _passwordField() {
    return TextField(
      controller: _passwordCtrl,
      obscureText: _obscure,
      style: const TextStyle(color: _white, fontSize: 14),
      decoration: InputDecoration(
        hintText: 'Enter your password',
        hintStyle: TextStyle(
          color: _textMid.withValues(alpha: 0.6),
          fontSize: 13,
        ),
        prefixIcon: const Icon(
          Icons.lock_outline_rounded,
          size: 18,
          color: _textMid,
        ),
        suffixIcon: GestureDetector(
          onTap: () => setState(() => _obscure = !_obscure),
          child: Icon(
            _obscure
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            size: 18,
            color: _textMid,
          ),
        ),
        filled: true,
        fillColor: _card,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _teal, width: 1.5),
        ),
      ),
    );
  }

  Widget _errorBox(String msg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _red.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, size: 15, color: _red),
          const SizedBox(width: 8),
          Expanded(
            child: Text(msg, style: const TextStyle(color: _red, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
