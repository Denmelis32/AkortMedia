// providers/user_provider.dart
import 'package:flutter/foundation.dart';

class UserProvider with ChangeNotifier {
  String _userName = '';
  String _userEmail = '';
  String _userId = '';

  String get userName => _userName;
  String get userEmail => _userEmail;
  String get userId => _userId; // Добавляем геттер для userId

  void setUserData(String name, String email, {String userId = ''}) {
    _userName = name;
    _userEmail = email;
    _userId = userId.isNotEmpty ? userId : 'user_${DateTime.now().millisecondsSinceEpoch}';
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