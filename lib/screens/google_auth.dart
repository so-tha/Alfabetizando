import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuth {
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account != null) {
        final GoogleSignInAuthentication googleAuth = await account.authentication;
        final String? idToken = googleAuth.idToken;
        // Aqui você pode fazer a autenticação com o Supabase usando o idToken
        print("Usuário logado: ${account.displayName}, Email: ${account.email}");
      }
    } catch (error) {
      print('Erro no login com Google: $error');
    }
  }
}
