import '../api/api_client.dart';
import '../../models/user.dart';

class AuthRepository {
    final ApiClient _api;
    AuthRepository(this._api);

    Future<User> login(String email, String password) async {
        final data = await _api.post('auth/login', {'email': email, 'password': password});
        await _api.saveToken(data['token']);
        return User.fromJson(data['user']);
    }

    Future<User> register(String name, String email, String password) async {
        final data = await _api.post('auth/register', {'name': name, 'email': email, 'password': password});
        await _api.saveToken(data['token']);
        return User.fromJson(data['user']);
    }

    Future<void> logout() => _api.clearToken();

    Future<User?> getCurrentUser() async {
        final data = await _api.get('auth/me');
        if (data['user'] == null) return null;
        return User.fromJson(data['user']);
    }
}
