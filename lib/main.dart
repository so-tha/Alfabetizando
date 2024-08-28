import 'package:alfabetizando_tcc/screens/welcome_screen%20.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env"); // Carrega as variáveis de ambiente do arquivo .env
  String supabaseUrl = dotenv.get('URL');
  String supabaseAnonKey = dotenv.get('anonKey');

 await Supabase.initialize(
       url: supabaseUrl,
       anonKey: supabaseAnonKey,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: 
      const WelcomeScreen(),
    );
  }
}
