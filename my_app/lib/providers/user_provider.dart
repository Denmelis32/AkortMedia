// providers/user_provider.dart
import 'package:flutter/foundation.dart';

class UserProvider with ChangeNotifier {
  String _userName = '';
  String _userEmail = '';

  String get userName => _userName;
  String get userEmail => _userEmail;

  void setUserData(String name, String email) {
    _userName = name;
    _userEmail = email;
    notifyListeners();
  }

  void clearUserData() {
    _userName = '';
    _userEmail = '';
    notifyListeners();
  }

  bool get isLoggedIn => _userName.isNotEmpty;
}