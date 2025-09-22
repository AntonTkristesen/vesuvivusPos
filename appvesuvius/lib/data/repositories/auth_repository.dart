import '../api/api_client.dart';
import '../../models/user.dart';
import '../../services/realtime_service.dart';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class AuthRepository {
    final ApiClient _api;
    AuthRepository(this._api);

    Future<User> login(String email, String password) async {
        var oneSignalUser = await OneSignal.User;
        var onesignalId = await oneSignalUser.getOnesignalId();
        final data = await _api.post('auth/login', {'email': email, 'password': password, 'onesignal_id': onesignalId});
        await _api.saveToken(data['token']);
        final user = User.fromJson(data['user']);
        await RealtimeService().init();

        return user;
    }

    Future<User> register(String name, String email, String password) async {
        try {
            var oneSignalUser = await OneSignal.User;
            var onesignalId = await oneSignalUser.getOnesignalId();
            final data = await _api.post('auth/register', {'name': name, 'email': email, 'password': password, 'onesignal_id': onesignalId});
            await _api.saveToken(data['token']);
            final user = User.fromJson(data['user']);
            await RealtimeService().init();

            return user;
        } catch (e) {
            await _api.clearToken();
            RealtimeService().disconnect();
            rethrow;
        }
    }

    Future<void> logout() async {
        RealtimeService().disconnect();
        await _api.clearToken();
    }

    Future<User?> getCurrentUser() async {
        try {
            final data = await _api.get('auth/me');
            if (data['user'] == null) return null;
            return User.fromJson(data['user']);
        } catch (e) {
            await _api.clearToken();
            RealtimeService().disconnect();
            return null;
        }
    }

    Future<bool> isAuthenticated() async {
        try {
            final user = await getCurrentUser();
            return user != null;
        } catch (e) {
            return false;
        }
    }

    Future<void> initializeRealtimeIfAuthenticated() async {
        try {
            final user = await getCurrentUser();
            if (user != null) {
                await RealtimeService().init();
            }
        } catch (e) {
            debugPrint('Failed to initialize realtime service: $e');
        }
    }
}
