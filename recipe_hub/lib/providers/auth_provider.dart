import 'package:flutter/foundation.dart';

class Comment {
  final String author;
  final String text;
  final DateTime at;
  const Comment(this.author, this.text, this.at);
}

class _Account {
  final String name;
  final String password;
  const _Account(this.name, this.password);
}

/// In-memory auth (demo): accounts live until the page is refreshed.
/// Swap for Firebase/your API for real persistence.
class AuthProvider extends ChangeNotifier {
  final Map<String, _Account> _users = {};
  String? _email;
  String? _name;

  bool get loggedIn => _email != null;
  String get name => _name ?? 'Guest';

  /// Returns an error message, or null on success.
  String? signUp(String name, String email, String password) {
    final e = email.trim().toLowerCase();
    if (_users.containsKey(e)) return 'An account with this email already exists';
    _users[e] = _Account(name.trim(), password);
    _email = e;
    _name = name.trim();
    notifyListeners();
    return null;
  }

  String? logIn(String email, String password) {
    final e = email.trim().toLowerCase();
    final u = _users[e];
    if (u == null || u.password != password) return 'Incorrect email or password';
    _email = e;
    _name = u.name;
    notifyListeners();
    return null;
  }

  void logOut() {
    _email = null;
    _name = null;
    notifyListeners();
  }
}
