// lib/widgets/alter_card.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../models/intern.dart';
import '../providers/font_provider.dart';
import '../services/card_service.dart'; // Certifique-se de ter esse serviço implementado

class AlterCard extends StatefulWidget {
  @override
  _AlterCardState createState() => _AlterCardState();
}

class _AlterCardState extends State<AlterCard> {
  final SupabaseClient supabase = Supabase.instance.client;
  final TextEditingController _categoriaController = TextEditingController();
  final TextEditingController _palavraAntigaController = TextEditingController();
  final TextEditingController _palavraNovaController = TextEditingController();

  File? _selectedImage;
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool isRecording = false;
  String? _audioPath;

  bool _isLoading = false;

  late CardService cardService;

  @override
  void initState() {
    super.initState();
    cardService = CardService(); 
    _initializeRecorder();
  }

  Future<void> _initializeRecorder() async {
    await _recorder.openRecorder();
    await Permission.microphone.request();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _startRecording() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      status = await Permission.microphone.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Permissão de microfone negada')),
        );
        return;
      }
    }

    setState(() {
      isRecording = true;
    });

    final tempDir = Directory.systemTemp;
    final filePath =
        '${tempDir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.aac';
    await _recorder.startRecorder(toFile: filePath);
    _audioPath = filePath;
  }

  Future<void> _stopRecording() async {
    final path = await _recorder.stopRecorder();
    setState(() {
      isRecording = false;
      _audioPath = path;
    });
    if (kDebugMode) {
      print('Gravação salva em: $path');
    }
  }

  Future<void> _alterarCard() async {
    final String categoria = _categoriaController.text.trim();
    final String palavraAntiga = _palavraAntigaController.text.trim();
    final String palavraNova = _palavraNovaController.text.trim();

    if (categoria.isEmpty || palavraAntiga.isEmpty || palavraNova.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, preencha todos os campos.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final categoriaResponse = await supabase
          .from('cards')
          .select('id')
          .eq('title', categoria)
          .single();

      final int categoriaId = categoriaResponse['id'];
      if (kDebugMode) {
        print('Categoria ID: $categoriaId');
      }

      String? imageUrl;
      String? soundUrl;

      if (_selectedImage != null) {
        imageUrl = await cardService.uploadFile(_selectedImage!, 'images');
      }

      if (_audioPath != null) {
        File audioFile = File(_audioPath!);
        soundUrl = await cardService.uploadFile(audioFile, 'audios');
      }

      Map<String, dynamic> updateData = {
        'name': palavraNova,
        'updatedAt': DateTime.now().toUtc().toIso8601String(),
      };

      if (imageUrl != null) {
        updateData['image_url'] = imageUrl;
      }

      if (soundUrl != null) {
        updateData['sound_url'] = soundUrl;
      }

      final updateResponse = await supabase
          .from('cards_internos')
          .update(updateData)
          .eq('category_id', categoriaId)
          .eq('name', palavraAntiga);

      if (updateResponse.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(updateResponse.error!.message)),
        );
      } else {
        final affectedRows = updateResponse.data;
        if (affectedRows != null && affectedRows.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Card alterado com sucesso!')),
          );

          _categoriaController.clear();
          _palavraAntigaController.clear();
          _palavraNovaController.clear();
          setState(() {
            _selectedImage = null;
            _audioPath = null;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Nenhum card foi encontrado para alterar.')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ocorreu um erro: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _categoriaController.dispose();
    _palavraAntigaController.dispose();
    _palavraNovaController.dispose();
    _recorder.closeRecorder();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fontProvider = Provider.of<FontProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cartões'),
        backgroundColor: Colors.orange.shade200,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Alterar cartão',
                style: TextStyle(
                  fontSize: fontProvider.fontSize.toDouble(),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              const Text('Informe a categoria'),
              const SizedBox(height: 10),
              TextFormField(
                controller: _categoriaController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.orange.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  hintText: 'Categoria',
                ),
                style: TextStyle(fontSize: fontProvider.fontSize.toDouble()),
              ),
              const SizedBox(height: 20),
              const Text('Informe a palavra que deseja alterar'),
              const SizedBox(height: 10),
              TextFormField(
                controller: _palavraAntigaController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.orange.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  hintText: 'Palavra Atual',
                ),
                style: TextStyle(fontSize: fontProvider.fontSize.toDouble()),
              ),
              const SizedBox(height: 20),
              // Gravação de áudio
              Text(
                'Grave novo áudio associado ao cartão',
                style: TextStyle(fontSize: fontProvider.fontSize.toDouble()),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onLongPress: _startRecording,
                onLongPressUp: _stopRecording,
                child: Container(
                  width: 90,
                  height: 97,
                  decoration: BoxDecoration(
                    color: isRecording ? Colors.redAccent : Colors.orange.shade200,
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.mic,
                      color: isRecording ? Colors.white : Colors.black,
                      size: 48.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              if (_audioPath != null)
                Text(
                  'Áudio salvo: ${_audioPath!.split('/').last}',
                  style: TextStyle(color: Colors.green, fontSize: fontProvider.fontSize.toDouble()),
                ),
              const SizedBox(height: 20),
              // Seleção de imagem
              Text(
                'Selecione a nova foto do cartão',
                style: TextStyle(fontSize: fontProvider.fontSize.toDouble()),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _pickImage,
                child: _selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _selectedImage!,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.add_a_photo,
                          size: 50,
                          color: Colors.grey,
                        ),
                      ),
              ),
              const SizedBox(height: 20),
              const Text('Informe a nova palavra'),
              const SizedBox(height: 10),
              TextFormField(
                controller: _palavraNovaController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.orange.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  hintText: 'Nova Palavra',
                ),
                style: TextStyle(fontSize: fontProvider.fontSize.toDouble()),
              ),
              const SizedBox(height: 20),

              // Botão Alterar
              Center(
                child: _isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton.icon(
                        onPressed: _alterarCard,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 16,
                          ),
                        ),
                        icon: const Icon(
                          Icons.check,
                          color: Colors.green,
                        ),
                        label: const Text(
                          'Alterar',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
