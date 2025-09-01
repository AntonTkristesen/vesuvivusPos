import 'package:flutter/foundation.dart';
import '../data/repositories/auth_repository.dart';
import '../models/user.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _repo;

  AuthViewModel(this._repo);

  User? currentUser;
  bool busy = false;
  String? error;

  Future<bool> login(String email, String password) async {
    busy = true; error = null; notifyListeners();
    try {
      currentUser = await _repo.login(email, password);
      return true;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      busy = false; notifyListeners();
    }
  }

  Future<bool> register(String name, String email, String password) async {
    busy = true; error = null; notifyListeners();
    try {
      currentUser = await _repo.register(name, email, password);
      return true;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      busy = false; notifyListeners();
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    currentUser = null;
    notifyListeners();
  }
}
