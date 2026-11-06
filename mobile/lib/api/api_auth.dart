import '../models/session.dart';
import 'services.dart';

class AuthResult {
  const AuthResult._(this.success, this.message);

  factory AuthResult.ok(String message) => AuthResult._(true, message);

  factory AuthResult.failure(String message) => AuthResult._(false, message);

  final bool success;
  final String message;
}

class ApiAuth {
  ApiAuth._();

  static Future<AuthResult> login(String email, String password) async {
    try {
      final response = await ApiService.post('/auth/login', {
        'email': email,
        'password': password,
      });

      if (response is! Map) {
        return AuthResult.failure('Respons login tidak valid.');
      }

      final user = response['user'];
      final token = response['token'];
      final userId = user is Map ? user['id'] : null;

      if (token is! String || token.isEmpty || userId is! num) {
        return AuthResult.failure('Respons login tidak valid.');
      }

      await Session.saveLogin(
        newToken: token,
        newUserId: userId.toInt(),
        newEmail: (user['email'] ?? email).toString(),
      );

      return AuthResult.ok(
        (response['message'] ?? 'Login berhasil').toString(),
      );
    } on ApiException catch (error) {
      return AuthResult.failure(error.message);
    } catch (_) {
      return AuthResult.failure(
        'Terjadi kesalahan saat masuk. Silakan coba lagi.',
      );
    }
  }

  static Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await ApiService.post('/auth/register', {
        'name': name,
        'email': email,
        'password': password,
      });

      await Session.rememberRegisteredAccount(
        accountEmail: email,
        accountName: name,
      );

      final message = response is Map
          ? (response['message'] ?? 'Registrasi berhasil').toString()
          : 'Registrasi berhasil';
      return AuthResult.ok(message);
    } on ApiException catch (error) {
      return AuthResult.failure(error.message);
    } catch (_) {
      return AuthResult.failure(
        'Terjadi kesalahan saat mendaftar. Silakan coba lagi.',
      );
    }
  }

  static Future<void> logout() => Session.clear();
}
