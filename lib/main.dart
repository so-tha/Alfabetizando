import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:alfabetizando_tcc/auth_screen.dart';
=======
import 'package:firebase_core/firebase_core.dart';
import 'autent_user.dart';
import 'firebase_options.dart';
>>>>>>> 4c52b3e84a96f6270ad4c21a45f6b2a8ea21c68f

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
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
<<<<<<< HEAD
      home: const AuthScreen(),
=======
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Autenticação'),
        ),
        body: const SingleChildScrollView(
          padding: EdgeInsets.all(20.0),
          child: LoginRegisterScreen(),
        ),
      ),
>>>>>>> 4c52b3e84a96f6270ad4c21a45f6b2a8ea21c68f
    );
  }
}
