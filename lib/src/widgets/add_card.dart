import 'package:alfabetizando_tcc/src/services/card_service.dart';
import 'package:alfabetizando_tcc/src/ui/custom_fontDialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/intern.dart';
import 'package:provider/provider.dart';
import '../providers/font_provider.dart';

class AddCardWithAudio extends StatefulWidget {
  final CardService cardService;

  const AddCardWithAudio({super.key, required this.cardService});

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
    print('Gravação salva em: $path');
  }

  int _generateUniqueId() {
    return DateTime.now().millisecondsSinceEpoch;
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

        String imageUrl = await widget.cardService.uploadFile(_selectedImage!, 'images');

        File audioFile = File(_audioPath!);
        String soundUrl = await widget.cardService.uploadFile(audioFile, 'audios');

        int newId = _generateUniqueId();

        CardsInternos card = CardsInternos(
          id: newId,
          name: _wordController.text,
          imageUrl: imageUrl,
          soundUrl: soundUrl,
          categoryId: int.parse(_categoryController.text),
        );
        await widget.cardService.addCardsInternos(card);

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

  void _openFontSizeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const FontSizeDialog();
      },
    );
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
    final fontProvider = Provider.of<FontProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar novo cartão'),
        backgroundColor: Colors.orange.shade200,
        actions: [
          IconButton(
            icon: const Icon(Icons.font_download),
            onPressed: _openFontSizeDialog,
            tooltip: 'Ajustar Tamanho da Fonte',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Adicionar novo cartão',
                style: TextStyle(
                  fontSize: fontProvider.fontSize.toDouble(),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Grave o áudio associado ao cartão',
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
              const SizedBox(height: 10),
              if (_audioPath != null)
                Text(
                  'Áudio salvo: ${_audioPath!.split('/').last}',
                  style: TextStyle(color: Colors.green, fontSize: fontProvider.fontSize.toDouble()),
                ),
              const SizedBox(height: 20),
              Text(
                'Selecione a foto do cartão',
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
              Text(
                'Informe a categoria',
                style: TextStyle(fontSize: fontProvider.fontSize.toDouble()),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _categoryController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.orange.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  hintText: 'ID da categoria',
                ),
                style: TextStyle(fontSize: fontProvider.fontSize.toDouble()),
              ),
              const SizedBox(height: 20),
              Text(
                'Informe a palavra',
                style: TextStyle(fontSize: fontProvider.fontSize.toDouble()),
              ),
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
                  hintText: 'Palavra',
                ),
                style: TextStyle(fontSize: fontProvider.fontSize.toDouble()),
              ),
              const SizedBox(height: 40),
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
