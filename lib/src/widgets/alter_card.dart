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
import '../services/card_service.dart'; 

class AlterCard extends StatefulWidget {
  @override
  _AlterCardState createState() => _AlterCardState();
}

class _AlterCardState extends State<AlterCard> {
  final SupabaseClient supabase = Supabase.instance.client;
  String? _selectedCategory;
  String? _selectedWord;
  final TextEditingController _palavraNovaController = TextEditingController();

  File? _selectedImage;
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool isRecording = false;
  String? _audioPath;

  bool _isLoading = false;

  late CardService cardService;

  List<String> _categories = [];
  List<String> _words = [];

  @override
  void initState() {
    super.initState();
    cardService = CardService();
    _initializeRecorder();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final response = await supabase
        .from('cards')
        .select('title')
        .order('title');
    
    setState(() {
      _categories = (response as List).map((item) => item['title'] as String).toList();
    });
  }

  Future<void> _loadWords() async {
    if (_selectedCategory == null) return;

    final categoryResponse = await supabase
        .from('cards')
        .select('id')
        .eq('title', _selectedCategory as Object)
        .single();

    if (categoryResponse != null) {
      final int categoryId = categoryResponse['id'];
      final wordsResponse = await supabase
          .from('cards_internos')
          .select('name')
          .eq('category_id', categoryId)
          .order('name');

      setState(() {
        _words = (wordsResponse as List).map((item) => item['name'] as String).toList();
        _selectedWord = null;
      });
    }
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
    if (_selectedCategory == null || _selectedWord == null || _palavraNovaController.text.trim().isEmpty) {
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
          .eq('title', _selectedCategory as Object)
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
        'name': _palavraNovaController.text.trim(),
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
          .eq('name', _selectedWord as Object);

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
              const Text('Selecione a categoria'),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                    _selectedWord = null;
                  });
                  _loadWords();
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.orange.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: TextStyle(fontSize: fontProvider.fontSize.toDouble()),
              ),
              const SizedBox(height: 20),
              const Text('Selecione a palavra que deseja alterar'),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedWord,
                items: _words.map((String word) {
                  return DropdownMenuItem<String>(
                    value: word,
                    child: Text(word),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedWord = newValue;
                  });
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.orange.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
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
