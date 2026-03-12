import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class Register extends StatefulWidget {
  const Register({super.key});
  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register>
    with SingleTickerProviderStateMixin {
  final _fullnameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure1 = true;
  bool _obscure2 = true;
  String _msg = '';
  bool _isError = false;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  static const _bg = Color(0xFF0D1117);
  static const _surface = Color(0xFF161B22);
  static const _card = Color(0xFF1C2128);
  static const _border = Color(0xFF30363D);
  static const _teal = Color(0xFF00B4D8);
  static const _white = Color(0xFFE6EDF3);
  static const _textMid = Color(0xFF8B949E);
  static const _red = Color(0xFFF85149);
  static const _green = Color(0xFF3FB950);

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _fullnameCtrl.dispose();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_fullnameCtrl.text.isEmpty ||
        _usernameCtrl.text.isEmpty ||
        _passwordCtrl.text.isEmpty ||
        _confirmCtrl.text.isEmpty) {
      setState(() {
        _msg = 'Please fill in all fields.';
        _isError = true;
      });
      return;
    }
    if (_passwordCtrl.text != _confirmCtrl.text) {
      setState(() {
        _msg = 'Passwords do not match.';
        _isError = true;
      });
      return;
    }
    setState(() {
      _loading = true;
      _msg = '';
    });
    final result = await AuthService.register(
      _fullnameCtrl.text.trim(),
      _usernameCtrl.text.trim(),
      _passwordCtrl.text,
    );
    setState(() => _loading = false);
    if (result.success) {
      setState(() {
        _msg = 'Account created successfully!';
        _isError = false;
      });
      await Future.delayed(const Duration(milliseconds: 900));
      if (!mounted) return;
      Navigator.pop(context);
    } else {
      setState(() {
        _msg = result.errorMessage ?? 'Registration failed.';
        _isError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            // Back button row
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: _textMid,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 8,
                  ),
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Logo
                            Center(
                              child: Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [_teal, Color(0xFF0077B6)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _teal.withValues(alpha: 0.25),
                                      blurRadius: 16,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.person_add_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                            const SizedBox(height: 22),
                            const Center(
                              child: Text(
                                'Create Account',
                                style: TextStyle(
                                  color: _white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.4,
                                ),
                              ),
                            ),
                            const SizedBox(height: 5),
                            const Center(
                              child: Text(
                                'Fill in the details to get started',
                                style: TextStyle(color: _textMid, fontSize: 13),
                              ),
                            ),
                            const SizedBox(height: 28),

                            // Form card
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
                                  _label('Full Name'),
                                  const SizedBox(height: 8),
                                  _field(
                                    controller: _fullnameCtrl,
                                    hint: 'e.g. Juan dela Cruz',
                                    icon: Icons.badge_outlined,
                                  ),
                                  const SizedBox(height: 16),
                                  _label('Username'),
                                  const SizedBox(height: 8),
                                  _field(
                                    controller: _usernameCtrl,
                                    hint: 'e.g. juandc',
                                    icon: Icons.alternate_email_rounded,
                                  ),
                                  const SizedBox(height: 16),
                                  _label('Password'),
                                  const SizedBox(height: 8),
                                  _passField(
                                    controller: _passwordCtrl,
                                    hint: 'Enter password',
                                    obscure: _obscure1,
                                    toggle: () =>
                                        setState(() => _obscure1 = !_obscure1),
                                  ),
                                  const SizedBox(height: 16),
                                  _label('Confirm Password'),
                                  const SizedBox(height: 8),
                                  _passField(
                                    controller: _confirmCtrl,
                                    hint: 'Re-enter password',
                                    obscure: _obscure2,
                                    toggle: () =>
                                        setState(() => _obscure2 = !_obscure2),
                                  ),
                                  if (_msg.isNotEmpty) ...[
                                    const SizedBox(height: 14),
                                    _msgBox(_msg, _isError),
                                  ],
                                  const SizedBox(height: 22),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 48,
                                    child: ElevatedButton(
                                      onPressed: _loading ? null : _register,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _teal,
                                        foregroundColor: Colors.white,
                                        disabledBackgroundColor: _teal
                                            .withValues(alpha: 0.4),
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
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
                                              'Create Account',
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
                            const SizedBox(height: 20),
                            Center(
                              child: GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: RichText(
                                  text: TextSpan(
                                    text: 'Already have an account?  ',
                                    style: const TextStyle(
                                      color: _textMid,
                                      fontSize: 13,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'Sign In',
                                        style: TextStyle(
                                          color: _teal,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
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

  Widget _label(String t) => Text(
    t,
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
        prefixIcon: Icon(icon, size: 17, color: _textMid),
        filled: true,
        fillColor: _card,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 13,
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

  Widget _passField({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback toggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: _white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: _textMid.withValues(alpha: 0.6),
          fontSize: 13,
        ),
        prefixIcon: const Icon(
          Icons.lock_outline_rounded,
          size: 17,
          color: _textMid,
        ),
        suffixIcon: GestureDetector(
          onTap: toggle,
          child: Icon(
            obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            size: 17,
            color: _textMid,
          ),
        ),
        filled: true,
        fillColor: _card,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 13,
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

  Widget _msgBox(String msg, bool isError) {
    final color = isError ? _red : _green;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            isError
                ? Icons.error_outline_rounded
                : Icons.check_circle_outline_rounded,
            size: 15,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(msg, style: TextStyle(color: color, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
