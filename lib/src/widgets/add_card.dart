import 'dart:io';

import 'package:alfabetizando_tcc/src/models/intern.dart';
import 'package:alfabetizando_tcc/src/ui/custom_textField.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'audio_record.dart';
import 'image_picker.dart';

class AddCardWithAudio extends StatefulWidget {
  const AddCardWithAudio({super.key});

  @override
  _AddCardWithAudioState createState() => _AddCardWithAudioState();
}

class _AddCardWithAudioState extends State<AddCardWithAudio> {
  File? _selectedImage;
  String? _audioPath;
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _wordController = TextEditingController();

  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String> _uploadFile(File file, String folder) async {
    try {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';

      await _supabase.storage.from(folder).upload(fileName, file);

      final publicUrl = _supabase.storage.from(folder).getPublicUrl(fileName);

      if (publicUrl.isEmpty) {
        throw Exception('Não foi possível gerar a URL pública para o arquivo.');
      }

      return publicUrl;
    } catch (e) {
      if (kDebugMode) {
        print('Erro no upload do arquivo: $e');
      }
      throw Exception('Falha no upload do arquivo: $e');
    }
  }

  Future<void> _saveCard() async {
    if (_selectedImage != null &&
        _categoryController.text.isNotEmpty &&
        _wordController.text.isNotEmpty &&
        _audioPath != null) {
      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(child: CircularProgressIndicator()),
        );
        String imageUrl = await _uploadFile(_selectedImage!, 'images');
        File audioFile = File(_audioPath!);
        String soundUrl = await _uploadFile(audioFile, 'audios');
        int newId = _generateUniqueId();
        CardsInternos card = CardsInternos(
          id: newId,
          name: _wordController.text,
          imageUrl: imageUrl,
          soundUrl: soundUrl,
          categoryId: int.parse(_categoryController.text),
        );

        await addCardsInternos(card);
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cartão salvo com sucesso!')),
        );
        _categoryController.clear();
        _wordController.clear();
        setState(() {
          _selectedImage = null;
          _audioPath = null;
        });
      } catch (e) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar cartão: $e')),
        );
        if (kDebugMode) {
          print('Erro ao salvar cartão: $e');
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Por favor, preencha todos os campos e adicione áudio.')),
      );
      if (kDebugMode) {
        print('Por favor, preencha todos os campos e adicione áudio.');
      }
    }
  }

  int _generateUniqueId() {
    return DateTime.now().millisecondsSinceEpoch;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar novo cartão'),
        backgroundColor: Colors.orange.shade200,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Adicionar novo cartão',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              const Text('Grave o áudio associado ao cartão'),
              const SizedBox(height: 10),
              AudioRecorder(onAudioRecorded: (path) {
                setState(() {
                  _audioPath = path;
                });
              }),
              const SizedBox(height: 10),
              if (_audioPath != null)
                Text('Áudio salvo: ${_audioPath!.split('/').last}',
                    style: const TextStyle(color: Colors.green)),
              const SizedBox(height: 20),
              const Text('Selecione a foto do cartão'),
              const SizedBox(height: 10),
              ImagePickerWidget(onImagePicked: (file) {
                setState(() {
                  _selectedImage = file;
                });
              }),
              const SizedBox(height: 20),
              const Text('Informe a categoria'),
              const SizedBox(height: 10),
              CustomTextField(
                hintText: 'ID da categoria',
                controller: _categoryController,
                inputType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              const Text('Informe a palavra'),
              const SizedBox(height: 10),
              CustomTextField(
                hintText: 'Palavra',
                controller: _wordController,
              ),
              const SizedBox(height: 40),
              Center(
                child: ElevatedButton.icon(
                  onPressed: _saveCard,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 16),
                  ),
                  icon: const Icon(Icons.check, color: Colors.green),
                  label: const Text('Salvar',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
