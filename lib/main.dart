import 'package:alfabetizando_tcc/screens/authentication_screen.dart';
import 'package:alfabetizando_tcc/screens/welcome_screen%20.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
