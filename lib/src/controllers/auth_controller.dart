import 'package:supabase_flutter/supabase_flutter.dart';

class AuthController {
  final SupabaseClient _client = Supabase.instance.client;

  Future<void> signUp(String email, String password, String name) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
    );

    if (response.user != null) {
      final userId = response.user!.id;
      await _client.from('users').insert({
        'id': userId,
        'email': email,
        'child_name': name,
      });
    } else {
      throw AuthException('Não foi possível realizar o registro');
    }
  }

  Future<void> signIn(String email, String password) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.session == null) {
      throw AuthException('Não foi possível realizar o login');
    }
  }
}



class AuthException implements Exception {
  final String message;
  AuthException(this.message);
}
