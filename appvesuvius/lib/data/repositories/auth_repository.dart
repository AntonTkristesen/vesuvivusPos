import '../api/api_client.dart';
import '../../models/user.dart';

class AuthRepository {
  final ApiClient _api;
  AuthRepository(this._api);

  Future<User> login(String email, String password) async {
    final data = await _api.post('login.php', {'email': email, 'password': password});
    await _api.saveToken(data['token']);
    return User.fromJson(data['user']);
  }

  Future<User> register(String name, String email, String password) async {
    final data = await _api.post('register.php', {'name': name, 'email': email, 'password': password});
    await _api.saveToken(data['token']);
    return User.fromJson(data['user']);
  }

  Future<void> logout() => _api.clearToken();
}
