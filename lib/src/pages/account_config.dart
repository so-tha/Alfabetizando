// ignore_for_file: unused_field
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../models/user_preferences.dart';
import '../ui/custom_textField.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import '../services/font_manager.dart';

class AccountConfigPage extends StatefulWidget {
  const AccountConfigPage({super.key});

  @override
  _AccountConfigPageState createState() => _AccountConfigPageState();
}

class _AccountConfigPageState extends State<AccountConfigPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late UserPreferences _userPreferences;
  File? _profileImage;
  late UserProvider _userProvider;
  String? _selectedFontId;
  double? _selectedFontSize;
  String? _customFontPath;
  String? _customFontName;
  late FontManager _fontManager;

  final List<double> _fontSizeOptions = [12, 14, 16, 18, 20,22];

  final bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _fontManager = FontManager();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _userProvider = Provider.of<UserProvider>(context, listen: false);
    _userPreferences = _userProvider.userPreferences;
    
    _nameController.text = _userProvider.user?.name ?? '';
    _emailController.text = _userProvider.user?.email ?? '';
    _selectedFontSize = _userPreferences.fontSize;
    _selectedFontId = _userPreferences.defaultFontId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _selectProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickCustomFont() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['ttf', 'otf'],
    );

    if (result != null) {
      final file = result.files.single;
      final fontId = await _fontManager.addCustomFont(file.path!, file.name);
      setState(() {
        _customFontPath = file.path;
        _customFontName = file.name;
        _selectedFontId = fontId;
      });
    }
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      _userProvider.updateUser(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text.isNotEmpty ? _passwordController.text : null,
        photoUrl: '',
      );

      _userProvider.updateUserPreferences(
        UserPreferences(
          fontSize: _selectedFontSize!,
          defaultFontId: _selectedFontId ?? 'helvetica',
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alterações salvas com sucesso!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuração da Conta'),
        backgroundColor: Colors.orange.shade200,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),
              CustomTextField(
                controller: _nameController,
                labelText: 'Nome',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira seu nome.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _emailController,
                labelText: 'Email',
                inputType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira seu email.';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Por favor, insira um email válido.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _passwordController,
                labelText: 'Nova Senha',
                obscureText: true,
                validator: (value) {
                  if (value != null && value.isNotEmpty && value.length < 6) {
                    return 'A senha deve ter pelo menos 6 caracteres.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedFontId,
                      decoration: InputDecoration(
                        labelText: 'Fonte Padrão',
                        filled: true,
                        fillColor: Colors.orange.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'helvetica',
                          child: Text('Helvetica', style: GoogleFonts.roboto()),
                        ),
                        DropdownMenuItem(
                          value: 'arial',
                          child: Text('Arial', style: GoogleFonts.openSans()),
                        ),
                        ..._fontManager.customFonts.map((font) => DropdownMenuItem(
                          value: font.id,
                          child: Text(font.name),
                        )),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedFontId = value;
                          });
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, selecione uma fonte padrão.';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _pickCustomFont,
                    child: const Text('Importar Fonte'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<double>(
                value: _selectedFontSize,
                decoration: InputDecoration(
                  labelText: 'Tamanho da Fonte',
                  filled: true,
                  fillColor: Colors.orange.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: _fontSizeOptions.map((size) {
                  return DropdownMenuItem<double>(
                    value: size,
                    child: Text('$size'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedFontSize = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Por favor, selecione um tamanho de fonte.';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveChanges,
                child: const Text('Salvar Alterações'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _userProvider.deleteUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text('Excluir Conta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
