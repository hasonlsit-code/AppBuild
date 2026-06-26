import 'package:flutter/material.dart';

class AuthViewModel extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;

  Future<bool> login(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    if (email == 'admin@gmail.com' && password == '123456') {
      isLoading = false;
      notifyListeners();
      return true;
    } else {
      errorMessage = 'Invalid email or password';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void logout() {
    isLoading = false;
    errorMessage = null;
    notifyListeners();
  }
}
