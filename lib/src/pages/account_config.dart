// lib/ui/account_config_prt

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../models/user_preferences.dart';
import '../ui/custom_textField.dart';
import '../widgets/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';

class AccountConfigPage extends StatefulWidget {
  const AccountConfigPage({Key? key}) : super(key: key);

  @override
  _AccountConfigPageState createState() => _AccountConfigPageState();
}

class _AccountConfigPageState extends State<AccountConfigPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _fontSizeController;
  late UserPreferences _userPreferences;
  File? _profileImage;
  late UserProvider _userProvider;
  String? _selectedFontId;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _fontSizeController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _userProvider = Provider.of<UserProvider>(context, listen: false);
    _userPreferences = _userProvider.userPreferences;
    
    _nameController.text = _userProvider.user.name ?? '';
    _emailController.text = _userProvider.user.email ?? '';
    _fontSizeController.text = _userPreferences.fontSize.toString();
    _selectedFontId = _userPreferences.defaultFontId;
    if (_selectedFontId != 'helvetica' && _selectedFontId != 'arial') {
      _selectedFontId = 'helvetica';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _fontSizeController.dispose(); 
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

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      // Update user information
      _userProvider.updateUser(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text.isNotEmpty ? _passwordController.text : null,
      );

      _userProvider.updateUserPreferences(
        UserPreferences(
          fontSize: double.parse(_fontSizeController.text),
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
              Center(
                child: ImagePickerWidget(
                  onImagePicked: (File image) {
                    setState(() {
                      _profileImage = image;
                    });
                  },
                ),
              ),
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
              DropdownButtonFormField<String>(
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
              const SizedBox(height: 16),
              CustomTextField(
                controller: _fontSizeController,
                labelText: 'Tamanho da Fonte',
                inputType: TextInputType.number,
                onChanged: (value) {
                  final size = double.tryParse(value);
                  if (size != null) {
                    _userProvider.updateUserPreferences(UserPreferences(fontSize: size, defaultFontId: _userPreferences.defaultFontId));
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o tamanho da fonte.';
                  }
                  final size = double.tryParse(value);
                  if (size == null || size < 8 || size > 72) {
                    return 'O tamanho da fonte deve estar entre 8 e 72.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveChanges,
                child: const Text('Salvar Alterações'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
