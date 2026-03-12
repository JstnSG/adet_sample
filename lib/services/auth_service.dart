import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthResult {
  final bool success;
  final String? errorMessage;
  const AuthResult({required this.success, this.errorMessage});
}

class AuthService {
  static const String _baseUrl = 'https://sangabriel-p10-p11-3wy5.vercel.app';

  // ✅ From app.js: app.use('/api/auth', authRoutes)
  static const String _loginUrl = '$_baseUrl/api/auth/login';
  static const String _registerUrl = '$_baseUrl/api/auth/register';

  static http.Client _getClient() {
    final httpClient = HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
    return IOClient(httpClient);
  }

  // ── LOGIN ──
  static Future<AuthResult> login(String username, String password) async {
    final client = _getClient();
    try {
      final res = await client.post(
        Uri.parse(_loginUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'username': username, 'password': password}),
      );

      final body = res.body.trim();
      if (body.isEmpty || body.startsWith('<')) {
        return const AuthResult(
          success: false,
          errorMessage: 'Server error. Check your connection.',
        );
      }

      final data = json.decode(body);

      if (res.statusCode == 200) {
        // Save token — check common token field names
        final token =
            data['token'] ?? data['accessToken'] ?? data['access_token'];
        if (token != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token);
          ApiService.setAuthToken(token); // share token with ApiService
        }
        return const AuthResult(success: true);
      }

      return AuthResult(
        success: false,
        errorMessage: data['message'] ?? 'Invalid username or password.',
      );
    } catch (e) {
      return AuthResult(success: false, errorMessage: e.toString());
    } finally {
      client.close();
    }
  }

  // ── REGISTER ──
  static Future<AuthResult> register(
    String fullName,
    String username,
    String password,
  ) async {
    final client = _getClient();
    try {
      final res = await client.post(
        Uri.parse(_registerUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'full_name': fullName,
          'username': username,
          'password': password,
        }),
      );

      final body = res.body.trim();
      if (body.isEmpty || body.startsWith('<')) {
        return const AuthResult(success: false, errorMessage: 'Server error.');
      }

      final data = json.decode(body);
      if (res.statusCode == 200 || res.statusCode == 201) {
        return const AuthResult(success: true);
      }
      return AuthResult(
        success: false,
        errorMessage: data['message'] ?? 'Registration failed.',
      );
    } catch (e) {
      return AuthResult(success: false, errorMessage: e.toString());
    } finally {
      client.close();
    }
  }

  // ── CHECK IF LOGGED IN ──
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null) ApiService.setAuthToken(token);
    return token != null && token.isNotEmpty;
  }

  // ── LOGOUT ──
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }
}
