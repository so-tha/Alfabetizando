import 'package:alfabetizando_tcc/src/pages/font_page.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

class StandardSize extends StatefulWidget {
  const StandardSize({super.key});

  @override
  _StandardSizeState createState() => _StandardSizeState();
}

class _StandardSizeState extends State<StandardSize> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showFontDialog(context);
    });
  }

  void _showFontDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Ajustar tamanho padrão da fonte',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: '16 px',
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {},
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: const BorderSide(color: Colors.purple),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton.icon(
                  icon: const Icon(Icons.check, color: Colors.green),
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(Colors.blue),
                    foregroundColor: WidgetStateProperty.all(Colors.white),
                  ),
                  label: const Text('Salvar'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FontScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade200,
    );
  }
}
