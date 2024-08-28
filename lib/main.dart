import 'package:alfabetizando_tcc/screens/welcome_screen%20.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

 await Supabase.initialize(
       url: 'https://bqdmmkkmjblovfvefazq.supabase.co',
       anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJxZG1ta2ttamJsb3ZmdmVmYXpxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjQ4NTAyMjYsImV4cCI6MjA0MDQyNjIyNn0.X87eF8w7PxWafWwQUpzSkkTrUK25SZO-b8uBuAEdgZg',
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
