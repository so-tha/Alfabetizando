import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'font_selection.dart'; 

class FontDefineScreen extends StatefulWidget {
  @override
  _FontDefineScreenState createState() => _FontDefineScreenState();
}

class _FontDefineScreenState extends State<FontDefineScreen> {
   final SupabaseClient supabase = Supabase.instance.client; 
  String? userId;
  String? selectedFontPath;
  @override
  void initState() {
    super.initState();
    _loadFont(); 
  }

  
Future<void> _loadFont() async {
  try {
    final response = await supabase
        .from('userpreferences')
        .select('profile_font')
        .eq('user_id', userId!)
        .single();

    if (response['profile_font'] != null) {
      setState(() {
        selectedFontPath = response['profile_font']['fontPath'];
      });
    }
  } catch (error) {
    if (kDebugMode) {
      print('Error loading font: $error');
    }
  }
}


  
Future<void> _pickFont() async {
    String? fontPath = await FontSelection.pickFont();
    if (fontPath != null) {
      final response = await supabase.from('userpreferences').upsert({
        'user_id': userId,
        'profile_font': {'fontPath': fontPath}
      });

      if (response.error == null) {
        setState(() {
          selectedFontPath = fontPath;
        });
      } else {
        if (kDebugMode) {
          print('Error saving font: ${response.error!.message}');
        }
      }
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
           if (selectedFontPath != null)
            Text('Selected Font: $selectedFontPath'),
        ],
      ),
    );
  }
}
