import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? _selectedFontPath; 

  @override
  void initState() {
    super.initState();
    _loadSavedFont(); 
  }

  
  Future<void> _loadSavedFont() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedFontPath = prefs.getString('selectedFontPath');
    });
  }

  
  Future<void> _saveFont(String fontPath) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedFontPath', fontPath);
  }

 
  Future<void> _pickFont() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['ttf', 'otf'], 
    );

    if (result != null && result.files.single.path != null) {
      String? fontPath = result.files.single.path;

      if (fontPath != null) {
        setState(() {
          _selectedFontPath = fontPath; 
        });
        _saveFont(fontPath);
      }
    }
  }


  ThemeData _buildTheme() {
    if (_selectedFontPath != null && File(_selectedFontPath!).existsSync()) {
      return ThemeData(
        fontFamily: _selectedFontPath, 
        textTheme: TextTheme(
          bodyLarge: TextStyle(
            fontFamily: _selectedFontPath, 
            fontSize: 16.0,
          ),
        ),
        primarySwatch: Colors.blue, 
      );
    } else {
      return ThemeData(
        textTheme: const TextTheme(
          bodyLarge: TextStyle(
            fontSize: 16.0, // Fonte padrão
          ),
        ),
        primarySwatch: Colors.blue, 
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: _buildTheme(), 
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Selecionar Fonte'),
        ),
        body: ListView(
          children: [
            ListTile(
              title: const Text('Importar Fonte'),
              onTap: _pickFont,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Texto com Fonte Selecionada'),
            ),
          ],
        ),
      ),
    );
  }
}
