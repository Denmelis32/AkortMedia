// providers/user_provider.dart
import 'package:flutter/foundation.dart';

class UserProvider with ChangeNotifier {
  String _userName = '';
  String _userEmail = '';
  String _userId = '';

  String get userName => _userName;
  String get userEmail => _userEmail;
  String get userId => _userId;

  void setUserData(String name, String email, {String userId = ''}) {
    _userName = name;
    _userEmail = email;

    // Генерируем стабильный ID на основе email или имени
    if (userId.isNotEmpty) {
      _userId = userId;
    } else if (email.isNotEmpty) {
      _userId = 'user_${email.trim().toLowerCase().hashCode.abs()}';
    } else {
      _userId = 'user_${name.hashCode.abs()}_${DateTime.now().millisecondsSinceEpoch}';
    }

    print('🆔 UserProvider: Set user data - Name: $name, ID: $_userId');
    notifyListeners();
  }

  void clearUserData() {
    _userName = '';
    _userEmail = '';
    _userId = '';
    notifyListeners();
  }

  bool get isLoggedIn => _userName.isNotEmpty;
}