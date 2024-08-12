import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'autent_user.dart';
import 'firebase_options.dart';

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
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Autenticação'),
        ),
        body: const SingleChildScrollView(
          padding: EdgeInsets.all(20.0),
          child: LoginRegisterScreen(),
        ),
      ),
    );
  }
}
