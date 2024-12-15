import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/intern.dart';
import '../services/card_service.dart';
import 'package:provider/provider.dart';
import '../providers/font_provider.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;

class AddCardWithAudio extends StatefulWidget {
  final CardService cardService;

  const AddCardWithAudio({super.key, required this.cardService});

  @override
  _AddCardWithAudioState createState() => _AddCardWithAudioState();
}

class _AddCardWithAudioState extends State<AddCardWithAudio> {
  final SupabaseClient supabase = Supabase.instance.client;
  File? _selectedImage;
  final TextEditingController _wordController = TextEditingController();
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool isRecording = false;
  String? _audioPath;
  String? _selectedCategory;
  List<String> _categories = [];
  late Box _cardsBox;

  final Color primaryColor = Colors.orange.shade200;
  final double buttonPadding = 16.0;

  @override
  void initState() {
    super.initState();
    _initializeRecorder();
    _loadCategories();
    _initHive();
  }
  Future<void> _initHive() async {
      final appDir = await getApplicationDocumentsDirectory();
      Hive.init(appDir.path);
      _cardsBox = await Hive.openBox('cards');
    }

  Future<void> _initializeRecorder() async {
    await _recorder.openRecorder();
    await Permission.microphone.request();
  }

  Future<void> _loadCategories() async {
    final response = await supabase
        .from('cards')
        .select('id, title')
        .order('title');
    
    setState(() {
      _categories = (response as List).map((item) => '${item['id']}:${item['title']}').toList();
    });
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
    setState(() => isRecording = true);
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
  }

  int _generateUniqueId() {
    return DateTime.now().millisecondsSinceEpoch;
  }

  Future<void> _saveCard() async {
    if (_selectedImage != null &&
        _selectedCategory != null &&
        _wordController.text.isNotEmpty &&
        _audioPath != null) {
      try {
        _showLoadingDialog();
        
        String imageUrl = await widget.cardService.uploadFile(_selectedImage!, 'images');
        File audioFile = File(_audioPath!);
        String soundUrl = await widget.cardService.uploadFile(audioFile, 'audios');
        String? wordDefinition = await getWordDefinition(_wordController.text);
        int? categoryId = int.tryParse(_selectedCategory!);
        if (categoryId == null) {
          throw FormatException('Invalid category ID: $_selectedCategory');
        }

        CardsInternos card = CardsInternos(
          id: _generateUniqueId(),
          name: _wordController.text,
          imageUrl: imageUrl,
          soundUrl: soundUrl,
          categoryId: categoryId,
          wordDefinition: wordDefinition!
        );

        await widget.cardService.addCardsInternos(card);
        await _cardsBox.add(card);

        Navigator.of(context).pop();

        _resetForm();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cartão salvo com sucesso!')),
        );
      } catch (e) {
        Navigator.of(context).pop(); 
        _showErrorSnackBar('Erro ao salvar cartão: $e');
      }
    } else {
      _showErrorSnackBar('Por favor, preencha todos os campos e adicione áudio.');
    }
  }

  void _resetForm() {
    _wordController.clear();
    setState(() {
      _selectedImage = null;
      _audioPath = null;
    });
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _wordController.dispose();
    super.dispose();
    _cardsBox.close();
  }

  @override
  Widget build(BuildContext context) {
    final fontProvider = Provider.of<FontProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar novo cartão'),
        backgroundColor: primaryColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Grave o áudio associado ao cartão. Por favor tente dizer a palavra de forma pausada e respeitando as sílabas.', fontProvider),
              const SizedBox(height: 10),
              _buildAudioRecordButton(),
              const SizedBox(height: 10),
              if (_audioPath != null) _buildAudioSavedMessage(fontProvider),
              const SizedBox(height: 20),
              _buildSectionTitle('Selecione uma foto para o novo cartão:', fontProvider),
              const SizedBox(height: 10),
              _buildImagePicker(),
              const SizedBox(height: 20),
              _buildSectionTitle('Selecione a categoria da qual o cartão irá pertencer:', fontProvider),
              const SizedBox(height: 10),
              _buildCategoryDropdown(fontProvider),
              const SizedBox(height: 10),
              _buildSectionTitle('Informe a nova palavra:', fontProvider),
              const SizedBox(height: 10),
              _buildWordInputField(fontProvider),
              const SizedBox(height: 40),
              Center(child: _buildSaveButton()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String text, FontProvider fontProvider) {
    return Text(
      text,
      style: TextStyle(fontSize: fontProvider.fontSize.toDouble()),
    );
  }

  Widget _buildAudioRecordButton() {
    return GestureDetector(
      onLongPress: _startRecording,
      onLongPressUp: _stopRecording,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: isRecording ? Colors.redAccent : primaryColor,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Center(
          child: Icon(
            Icons.mic,
            color: isRecording ? Colors.white : Colors.black,
            size: 30.0,
          ),
        ),
      ),
    );
  }

  Widget _buildAudioSavedMessage(FontProvider fontProvider) {
    return Text(
      'Áudio salvo: ${_audioPath!.split('/').last}',
      style: TextStyle(color: Colors.green, fontSize: fontProvider.fontSize.toDouble()),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: _selectedImage != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                _selectedImage!,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
              ),
            )
          : Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.camera_alt),
            ),
    );
  }

  Widget _buildCategoryDropdown(FontProvider fontProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButton<String>(
          value: _selectedCategory,
          items: _categories.map((category) {
            final parts = category.split(':');
            final id = parts[0];
            final title = parts.length > 1 ? parts[1] : id;
            return DropdownMenuItem<String>(
              value: id,
              child: Text(
                title,
                style: TextStyle(fontSize: fontProvider.fontSize.toDouble()),
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedCategory = value;
            });
          },
          hint: const Text('Ex: animais'),
          isExpanded: true,
        ),
        if (_categories.isEmpty)
          const Text('Que estranho! Parece que nenhuma categoria está disponível, tente fechar e abrir novamente o aplicativo', style: TextStyle(color: Colors.red)),
      ],
    );
  }

  Widget _buildWordInputField(FontProvider fontProvider) {
    return TextField(
      controller: _wordController,
      decoration: const InputDecoration(hintText: 'Ex: cachorro'),
      style: TextStyle(fontSize: fontProvider.fontSize.toDouble()),
    );
  }

  Widget _buildSaveButton() {
    return Consumer<FontProvider>(
      builder: (context, fontProvider, child) {
        return ElevatedButton(
          onPressed: () async {
            final shouldSave = await showDialog<bool>(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Confirmar alterações'),
                  content: Text('Tem certeza que deseja salvar o cartão?'),
                  actions: <Widget>[
                    TextButton(
                      child: Text('Cancelar'),
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                    TextButton(
                      child: Text('Salvar'),
                      onPressed: () => Navigator.of(context).pop(true),
                    ),
                  ],
                );
              },
            );

            if (shouldSave == true) {
              await _saveCard(); 
            }
          },
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: buttonPadding * 1.2, vertical: buttonPadding * 1.2),
            backgroundColor: primaryColor,
            minimumSize: Size(120, 48),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.save, size: fontProvider.fontSize.toDouble()),
              SizedBox(width: 8),
              Text(
                'Salvar',
                style: TextStyle(fontSize: fontProvider.fontSize.toDouble()),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<String?> getWordDefinition(String word) async {
    try {
      final url = 'https://dicionario.priberam.org/$word';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var document = html_parser.parse(response.body);
        var wordBlock = document.querySelector('span.titpalavra');

        if (wordBlock != null) {
          return wordBlock.text;
        }
      }
      return null;
    } catch (e) {
      debugPrint('Erro ao buscar definição: $e');
      return null;
    }
  }
}
