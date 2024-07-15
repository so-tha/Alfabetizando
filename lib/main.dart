import 'package:flutter/material.dart';

 main(List<String> args) => runApp(new PerguntaApp());

class PerguntaApp extends StatelessWidget{
  @override //subscrevendo o metodo 
  Widget build(BuildContext context){
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Olá'),
        ),
      ),
    );
  }
}
