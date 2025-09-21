import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/app_config.dart';
import '../../core/exceptions.dart';

class ApiClient {
    final AppConfig config;
    final http.Client _client = http.Client();
    String? _token;

    ApiClient({required this.config});

    Future<SharedPreferences> _prefs() => SharedPreferences.getInstance();

    Future<void> saveToken(String token) async {
      _token = token;
      final p = await _prefs();
      await p.setString('token', token);
    }

    Future<String?> getToken() async {
        if (_token != null) return _token;
        final p = await _prefs();
        _token = p.getString('token');
        return _token;
    }

    Future<void> clearToken() async {
        _token = null;
        final p = await _prefs();
        await p.remove('token');
    }

    Uri _uri(String path) => Uri.parse('${config.baseUrl}/$path');

    Future<dynamic> get(String path, {Map<String, String>? query}) async {
        final token = await getToken();
        final uri = _uri(path).replace(queryParameters: query);
        final res = await _client.get(uri, headers: {
            'Accept': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
        });
        return _handle(res);
    }

    Future<dynamic> post(String path, Map<String, dynamic> body) async {
        final token = await getToken();
        final res = await _client.post(_uri(path),
            headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
                if (token != null) 'Authorization': 'Bearer $token',
            },
            body: jsonEncode(body));
        return _handle(res);
    }

    Future<dynamic> delete(String path) async {
        print(_uri(path));
        final token = await getToken();
        final res = await _client.delete(_uri(path), headers: {
            'Accept': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
        });
        return _handle(res);
    }

    dynamic _handle(http.Response r) {
        final status = r.statusCode;
        final data = (r.body.isEmpty) ? {} : jsonDecode(r.body);
        if (status >= 200 && status < 300) return data;
        final msg = data is Map && data['message'] is String
            ? data['message']
            : 'HTTP $status';
        throw ApiException(msg, statusCode: status);
    }
}
