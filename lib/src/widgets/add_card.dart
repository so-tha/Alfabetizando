import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';

class AddCardWithAudio extends StatefulWidget {
  const AddCardWithAudio({super.key});

  @override
  _AddCardWithAudioState createState() => _AddCardWithAudioState();
}

class _AddCardWithAudioState extends State<AddCardWithAudio> {
  File? _selectedImage;
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _wordController = TextEditingController();

  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool isRecording = false;
  String? _audioPath;

  @override
  void initState() {
    super.initState();
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
    setState(() {
      isRecording = true;
    });
    await _recorder.startRecorder(toFile: 'recording.aac');
    _audioPath = 'recording.aac';
  }

  Future<void> _stopRecording() async {
    final path = await _recorder.stopRecorder();
    setState(() {
      isRecording = false;
      _audioPath = path;
    });
    print('Gravação salva em: $path');
  }

  void _saveCard() {
    if (_selectedImage != null &&
        _categoryController.text.isNotEmpty &&
        _wordController.text.isNotEmpty &&
        _audioPath != null) {
      // Aqui você pode salvar os dados no banco (Supabase)
      print(
          'Salvar cartão com imagem: ${_selectedImage!.path}, categoria: ${_categoryController.text}, palavra: ${_wordController.text}, áudio: $_audioPath');
      // Limpar campos após salvar
      _categoryController.clear();
      _wordController.clear();
      setState(() {
        _selectedImage = null;
        _audioPath = null;
      });
    } else {
      if (kDebugMode) {
        print('Por favor, preencha todos os campos e adicione áudio.');
      }
    }
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _categoryController.dispose();
    _wordController.dispose();
    super.dispose();
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
              const Text(
                'Adicionar novo cartão',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              const Text('Grave o áudio associado ao cartão'),
              const SizedBox(height: 10),
              GestureDetector(
                onLongPress: _startRecording,
                onLongPressUp: _stopRecording,
                child: Container(
                  width: 90,
                  height: 97,
                  decoration: BoxDecoration(
                    color:
                        isRecording ? Colors.redAccent : Colors.orange.shade200,
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
              const Text('Selecione a foto do cartão'),
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
              const Text('Informe a categoria'),
              const SizedBox(height: 10),
              TextFormField(
                controller: _categoryController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.orange.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Informe a palavra'),
              const SizedBox(height: 10),
              TextFormField(
                controller: _wordController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.orange.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton.icon(
                  onPressed: _saveCard,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 16),
                  ),
                  icon: const Icon(Icons.check, color: Colors.green),
                  label: const Text(
                    'Salvar',
                    style: TextStyle(color: Colors.white),
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
