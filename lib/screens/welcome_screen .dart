import 'package:flutter/material.dart';

class WelcomeScreen  extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreen();
}

class _WelcomeScreen extends State<WelcomeScreen> with SingleTickerProviderStateMixin{
  @override
Widget build(BuildContext context){
  return Scaffold(
    appBar: AppBar(
      title: Text('Alfabetizando'),
    ),
  );
}
}
