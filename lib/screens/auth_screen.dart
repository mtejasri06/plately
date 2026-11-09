import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/dish_photo.dart';

/// Login + sign-up in one screen. [gated] = shown in place of a protected page.
class AuthScreen extends StatefulWidget {
  final bool signup;
  final bool gated;
  const AuthScreen({super.key, this.signup = false, this.gated = false});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _key = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  late bool _signup = widget.signup;
  bool _hide = true;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_key.currentState!.validate()) return;
    final a = context.read<AuthProvider>();
    final err = _signup ? a.signUp(_name.text, _email.text, _pass.text) : a.logIn(_email.text, _pass.text);
    if (err != null) {
      setState(() => _error = err);
    } else if (!widget.gated) {
      Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: BackButton(onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false))),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _key,
              child: Column(children: [
                const Icon(Icons.ramen_dining, size: 64, color: AppTheme.spinach),
                const SizedBox(height: 12),
                Text(_signup ? 'Join the table' : 'Welcome back',
                    style: const TextStyle(fontFamily: 'Georgia', fontSize: 30, color: AppTheme.spinach)),
                const SizedBox(height: 6),
                Text(widget.gated ? 'Log in to post a recipe' : 'Post recipes and join the conversation',
                    style: const TextStyle(color: Colors.black54)),
                const SizedBox(height: 20),
                if (_signup) ...[
                  TextFormField(
                      controller: _name,
                      decoration: const InputDecoration(labelText: 'Display name', prefixIcon: Icon(Icons.person_outline)),
                      validator: (v) => (v == null || v.trim().length < 2) ? 'Enter your name' : null),
                  const SizedBox(height: 14),
                ],
                TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.mail_outline)),
                    validator: (v) => RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch((v ?? '').trim()) ? null : 'Enter a valid email'),
                const SizedBox(height: 14),
                TextFormField(
                    controller: _pass,
                    obscureText: _hide,
                    onFieldSubmitted: (_) => _submit(),
                    decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                            icon: Icon(_hide ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setState(() => _hide = !_hide))),
                    validator: (v) => (v ?? '').length < 6 ? 'At least 6 characters' : null),
                if (_error != null)
                  Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(_error!, style: const TextStyle(color: AppTheme.chili))),
                const SizedBox(height: 20),
                SizedBox(width: double.infinity, child: FilledButton(onPressed: _submit, child: Text(_signup ? 'Create account' : 'Log in'))),
                TextButton(
                    onPressed: () => setState(() {
                          _signup = !_signup;
                          _error = null;
                        }),
                    child: Text(_signup ? 'Already have an account? Log in' : 'New here? Sign up')),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
