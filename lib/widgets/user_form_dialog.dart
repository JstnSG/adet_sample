import 'package:flutter/material.dart';
import '../models/user_model.dart';

class UserFormDialog extends StatefulWidget {
  final UserModel? existing;
  const UserFormDialog({super.key, this.existing});

  @override
  State<UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<UserFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullnameCtrl;
  late TextEditingController _usernameCtrl;
  late TextEditingController _passwordCtrl;
  bool _obscure = true;

  bool get _isEdit => widget.existing != null;

  static const _bg = Color(0xFF1C2128);
  static const _surface = Color(0xFF161B22);
  static const _card = Color(0xFF0D1117);
  static const _border = Color(0xFF30363D);
  static const _teal = Color(0xFF00B4D8);
  static const _orange = Color(0xFFD29922);
  static const _white = Color(0xFFE6EDF3);
  static const _textMid = Color(0xFF8B949E);
  static const _red = Color(0xFFF85149);

  @override
  void initState() {
    super.initState();
    _fullnameCtrl = TextEditingController(
      text: widget.existing?.fullname ?? '',
    );
    _usernameCtrl = TextEditingController(
      text: widget.existing?.username ?? '',
    );
    _passwordCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _fullnameCtrl.dispose();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      UserModel(
        id: widget.existing?.id,
        fullname: _fullnameCtrl.text.trim(),
        username: _usernameCtrl.text.trim(),
        password: _passwordCtrl.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = _isEdit ? _orange : _teal;
    return Dialog(
      backgroundColor: _bg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: _border),
      ),
      child: Container(
        width: 420,
        padding: const EdgeInsets.all(28),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: accent.withValues(alpha: 0.25)),
                    ),
                    child: Icon(
                      _isEdit ? Icons.edit_rounded : Icons.person_add_rounded,
                      color: accent,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isEdit ? 'Update User' : 'Add New User',
                        style: const TextStyle(
                          color: _white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        _isEdit
                            ? 'Edit user information'
                            : 'Create a new account',
                        style: const TextStyle(color: _textMid, fontSize: 11),
                      ),
                    ],
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: _surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _border),
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: _textMid,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              const Divider(height: 1, color: _border),
              const SizedBox(height: 20),

              // Full Name
              _fieldLabel('Full Name'),
              const SizedBox(height: 7),
              _formField(
                controller: _fullnameCtrl,
                hint: 'e.g. Juan dela Cruz',
                icon: Icons.person_outline_rounded,
                accent: accent,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Full name is required' : null,
              ),
              const SizedBox(height: 16),

              // Username
              _fieldLabel('Username'),
              const SizedBox(height: 7),
              _formField(
                controller: _usernameCtrl,
                hint: 'e.g. juandc',
                icon: Icons.alternate_email_rounded,
                accent: accent,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Username is required' : null,
              ),
              const SizedBox(height: 16),

              // Password
              _fieldLabel(_isEdit ? 'New Password' : 'Password'),
              const SizedBox(height: 7),
              TextFormField(
                controller: _passwordCtrl,
                obscureText: _obscure,
                style: const TextStyle(color: _white, fontSize: 14),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Password is required' : null,
                decoration: InputDecoration(
                  hintText: _isEdit ? 'Enter new password' : 'Enter password',
                  hintStyle: TextStyle(
                    color: _textMid.withValues(alpha: 0.5),
                    fontSize: 13,
                  ),
                  prefixIcon: const Icon(
                    Icons.lock_outline_rounded,
                    size: 16,
                    color: _textMid,
                  ),
                  suffixIcon: GestureDetector(
                    onTap: () => setState(() => _obscure = !_obscure),
                    child: Icon(
                      _obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 16,
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
                    borderSide: BorderSide(color: accent, width: 1.5),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: _red),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: _red, width: 1.5),
                  ),
                  errorStyle: const TextStyle(color: _red, fontSize: 11),
                ),
              ),
              const SizedBox(height: 26),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _textMid,
                        side: const BorderSide(color: _border),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        _isEdit ? 'Save Changes' : 'Create User',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) => Text(
    text,
    style: const TextStyle(
      color: _white,
      fontSize: 12,
      fontWeight: FontWeight.w600,
    ),
  );

  Widget _formField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required Color accent,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      style: const TextStyle(color: _white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: _textMid.withValues(alpha: 0.5),
          fontSize: 13,
        ),
        prefixIcon: Icon(icon, size: 16, color: _textMid),
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
          borderSide: BorderSide(color: accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _red, width: 1.5),
        ),
        errorStyle: const TextStyle(color: _red, fontSize: 11),
      ),
    );
  }
}
