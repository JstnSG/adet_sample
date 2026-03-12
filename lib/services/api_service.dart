import 'dart:convert';
import 'dart:io';
import 'dart:developer' as dev;
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class ApiService {
  static const String baseUrl = 'https://sangabriel-p10-p11-3wy5.vercel.app';

  static const String _userBase = '$baseUrl/api/user';
  static const String _authBase = '$baseUrl/api/auth';

  static final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // ── Save token after login ──
  static void setAuthToken(String token) {
    _headers['Authorization'] = 'Bearer $token';
  }

  // ── Load saved token from storage ──
  static Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null) setAuthToken(token);
  }

  // ── SSL bypass for dev ──
  static http.Client _getClient() {
    final httpClient = HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
    return IOClient(httpClient);
  }

  // ── Safe JSON parser ──
  static dynamic _parse(http.Response res, String label) {
    dev.log(
      '[$label] ${res.statusCode} → ${res.body.length > 200 ? res.body.substring(0, 200) : res.body}',
    );
    final body = res.body.trim();
    if (body.isEmpty || body.startsWith('<')) {
      throw Exception(
        'Server error (${res.statusCode}). Check your API endpoint.',
      );
    }
    try {
      return json.decode(body);
    } catch (_) {
      throw Exception('Invalid JSON from server (${res.statusCode})');
    }
  }

  // ════════════════════════════════════════
  //  AUTH — POST /api/auth/login
  // ════════════════════════════════════════
  static Future<bool> login(String username, String password) async {
    final client = _getClient();
    try {
      final res = await client.post(
        Uri.parse('$_authBase/login'),
        headers: _headers,
        body: json.encode({'username': username, 'password': password}),
      );
      final data = _parse(res, 'POST /api/auth/login');
      if (res.statusCode == 200) {
        final token =
            data['token'] ?? data['accessToken'] ?? data['access_token'];
        if (token != null) {
          setAuthToken(token);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token);
        }
        return true;
      }
      throw Exception(data['message'] ?? 'Login failed (${res.statusCode})');
    } finally {
      client.close();
    }
  }

  // ════════════════════════════════════════
  //  READ ALL — GET /api/user
  // ════════════════════════════════════════
  static Future<List<UserModel>> getUsers() async {
    await loadToken(); // ✅ ensure token is loaded
    final client = _getClient();
    try {
      final res = await client.get(Uri.parse(_userBase), headers: _headers);
      final data = _parse(res, 'GET /api/user');
      if (res.statusCode == 200) {
        final list = data is List
            ? data
            : (data['data'] ?? data['users'] ?? data['user'] ?? []);
        return (list as List).map((j) => UserModel.fromJson(j)).toList();
      }
      throw Exception(
        data['message'] ?? 'Failed to load users (${res.statusCode})',
      );
    } finally {
      client.close();
    }
  }

  // ════════════════════════════════════════
  //  READ ONE — GET /api/user/:id
  // ════════════════════════════════════════
  static Future<UserModel> getUserById(int id) async {
    await loadToken(); // ✅ added
    final client = _getClient();
    try {
      final res = await client.get(
        Uri.parse('$_userBase/$id'),
        headers: _headers,
      );
      final data = _parse(res, 'GET /api/user/$id');
      if (res.statusCode == 200) {
        final obj = data is Map ? data : data['data'];
        return UserModel.fromJson(obj as Map<String, dynamic>);
      }
      throw Exception(data['message'] ?? 'User not found');
    } finally {
      client.close();
    }
  }

  // ════════════════════════════════════════
  //  CREATE — POST /api/user
  // ════════════════════════════════════════
  static Future<UserModel> createUser(UserModel user) async {
    await loadToken(); // ✅ added
    final client = _getClient();
    try {
      final res = await client.post(
        Uri.parse(_userBase),
        headers: _headers,
        body: json.encode(user.toJson()),
      );
      final data = _parse(res, 'POST /api/user');
      if (res.statusCode == 200 || res.statusCode == 201) {
        final obj = data is Map ? data : (data['data'] ?? data['user']);
        return UserModel.fromJson(obj as Map<String, dynamic>);
      }
      throw Exception(data['message'] ?? 'Create failed (${res.statusCode})');
    } finally {
      client.close();
    }
  }

  // ════════════════════════════════════════
  //  UPDATE — PUT /api/user/:id
  // ════════════════════════════════════════
  static Future<UserModel> updateUser(int id, UserModel user) async {
    await loadToken(); // ✅ added
    final client = _getClient();
    try {
      final res = await client.put(
        Uri.parse('$_userBase/$id'),
        headers: _headers,
        body: json.encode(user.toJson()),
      );
      final data = _parse(res, 'PUT /api/user/$id');
      if (res.statusCode == 200) {
        final obj = data is Map ? data : (data['data'] ?? data['user']);
        return UserModel.fromJson(obj as Map<String, dynamic>);
      }
      throw Exception(data['message'] ?? 'Update failed (${res.statusCode})');
    } finally {
      client.close();
    }
  }

  // ════════════════════════════════════════
  //  DELETE — DELETE /api/user/:id
  // ════════════════════════════════════════
  static Future<void> deleteUser(int id) async {
    await loadToken(); // ✅ added
    final client = _getClient();
    try {
      final res = await client.delete(
        Uri.parse('$_userBase/$id'),
        headers: _headers,
      );
      dev.log('[DELETE /api/user/$id] ${res.statusCode}');
      if (res.statusCode != 200 && res.statusCode != 204) {
        throw Exception('Delete failed (${res.statusCode})');
      }
    } finally {
      client.close();
    }
  }
}
