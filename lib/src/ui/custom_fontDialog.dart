// lib/widgets/font_size_dialog.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/font_provider.dart';

class FontSizeDialog extends StatefulWidget {
  const FontSizeDialog({super.key});

  @override
  _FontSizeDialogState createState() => _FontSizeDialogState();
}

class _FontSizeDialogState extends State<FontSizeDialog> {
  String? _selectedFontId;

  @override
  Widget build(BuildContext context) {
    final fontProvider = Provider.of<FontProvider>(context);
    final fonts = fontProvider.fonts;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: fonts.isEmpty
            ? const SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator()),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Ajustar tamanho padrão da fonte',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 300, // Ajuste conforme necessário
                    child: ListView.builder(
                      itemCount: fonts.length,
                      itemBuilder: (context, index) {
                        final font = fonts[index];
                        return RadioListTile<String>(
                          title: Text('${font.size} px'),
                          value: font.id,
                          groupValue: _selectedFontId ?? fontProvider.selectedFontId,
                          onChanged: (value) {
                            setState(() {
                              _selectedFontId = value;
                            });
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    icon: const Icon(Icons.check, color: Colors.green),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    label: const Text('Salvar'),
                    onPressed: () async {
                      if (_selectedFontId != null) {
                        await fontProvider.updateFont(_selectedFontId!);
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Por favor, selecione um tamanho de fonte.'),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
      ),
    );
  }
}
