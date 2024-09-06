import 'package:alfabetizando_tcc/main.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<AuthResponse> nativeGoogleSignIn() async {
  const webClientId = '197164761946-dum8pn71f4kv8899c8qnnttv6qm3mtq7.apps.googleusercontent.com';
  final supabase = Supabase.instance.client;
  final GoogleSignIn googleSignIn = GoogleSignIn(
    serverClientId: webClientId,
  );

  final googleUser = await googleSignIn.signIn();
  final googleAuth = await googleUser!.authentication;
  final acessToken = googleAuth.accessToken;
  final idToken = googleAuth.idToken;

  if(acessToken == null){throw 'No Acess Token found';}
  if(idToken == null){throw 'No ID token found';}

  return supabase.auth.signInWithIdToken(provider: OAuthProvider.google,
   idToken: idToken,
   accessToken:  acessToken,
   );

}
