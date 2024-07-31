import 'package:flutter/material.dart';
import 'package:alfabetizando_tcc/registrar.dart';

void main() {
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
        ),
        body: const SingleChildScrollView(
          padding: EdgeInsets.all(20.0),
          child: RegisterUser(),
        ),
      ),
    );
  }
}
