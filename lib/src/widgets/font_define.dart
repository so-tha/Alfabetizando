import 'package:flutter/material.dart';
import 'font_selection.dart'; 

class FontDefineScreen extends StatefulWidget {
  @override
  _FontDefineScreenState createState() => _FontDefineScreenState();
}

class _FontDefineScreenState extends State<FontDefineScreen> {
  String? _selectedFontPath; 

  @override
  void initState() {
    super.initState();
    _loadFont(); 
  }

  
  Future<void> _loadFont() async {
    String? fontPath = await FontSelection.loadFont();
    setState(() {
      _selectedFontPath = fontPath;
    });
  }

  
  Future<void> _pickFont() async {
    String? fontPath = await FontSelection.pickFont();
    if (fontPath != null) {
      setState(() {
        _selectedFontPath = fontPath;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Definir Fonte'),
        backgroundColor: Colors.orange.shade200,
      ),
      body: ListView(
        children: [
          
          ListTile(
            title: const Text('Fonte Padrão'),
            onTap: () {
              setState(() {
                _selectedFontPath = null;
              });
            },
          ),
          ListTile(
            title: const Text('Importar Fonte'),
            onTap: () async {
              await _pickFont(); 
            },
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              'Texto de Exemplo',
              style: TextStyle(
                fontFamily: _selectedFontPath != null ? _selectedFontPath : null,
                fontSize: 16.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
