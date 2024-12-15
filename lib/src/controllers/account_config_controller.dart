import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../models/user_preferences.dart';
import '../providers/user_provider.dart';
import '../services/font_manager.dart';
import 'package:google_fonts/google_fonts.dart';

class AccountConfigController {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  
  final UserProvider userProvider;
  final FontManager fontManager;
  
  File? profileImage;
  String? selectedFontId;
  double? selectedFontSize;
  String? customFontPath;
  String? customFontName;
  
  final List<double> fontSizeOptions = [12, 14, 16, 18, 20, 22];
  
  final List<Map<String, dynamic>> availableFonts = [
    {
      'id': 'helvetica',
      'name': 'Helvetica',
      'style': const TextStyle(fontFamily: 'Helvetica'),
    },
    {
      'id': 'arial',
      'name': 'Arial',
      'style': const TextStyle(fontFamily: 'Arial'),
    },
    {'id': 'roboto', 'name': 'Roboto', 'style': GoogleFonts.roboto()},
    {'id': 'openSans', 'name': 'Open Sans', 'style': GoogleFonts.openSans()},
    {'id': 'lato', 'name': 'Lato', 'style': GoogleFonts.lato()},
  ];
  
  List<Map<String, dynamic>> customFonts = [];
  
  void addCustomFont(String id, String name, String path) {
    customFonts.add({
      'id': id,
      'name': name,
      'path': path,
      'style': TextStyle(fontFamily: name),
    });
  }
  
  List<Map<String, dynamic>> get allFonts => [...availableFonts, ...customFonts];
  
  AccountConfigController({
    required this.userProvider,
    FontManager? fontManager,
  }) : fontManager = fontManager ?? FontManager() {
    _initializeData();
  }

  void _initializeData() {
    final userPreferences = userProvider.userPreferences;
    nameController.text = userProvider.user?.name ?? '';
    emailController.text = userProvider.user?.email ?? '';
    selectedFontSize = userPreferences.fontSize;
    
    if (allFonts.any((font) => font['id'] == userPreferences.defaultFontId)) {
      selectedFontId = userPreferences.defaultFontId;
    }
  }

  Future<void> selectProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      profileImage = File(pickedFile.path);
    }
  }

  Future<void> pickCustomFont() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['ttf', 'otf'],
    );

    if (result != null) {
      final file = result.files.single;
      final fontId = await fontManager.addCustomFont(file.path!, file.name);
      customFontPath = file.path;
      customFontName = file.name;
      selectedFontId = fontId;
    }
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira seu email.';
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'Por favor, insira um email válido.';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value != null && value.isNotEmpty && value.length < 6) {
      return 'A senha deve ter pelo menos 6 caracteres.';
    }
    return null;
  }

  String? validateFont(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, selecione uma fonte padrão.';
    }
    return null;
  }

  String? validateFontSize(double? value) {
    if (value == null) {
      return 'Por favor, selecione um tamanho de fonte.';
    }
    return null;
  }

  Future<bool> saveChanges() async {
    if (formKey.currentState!.validate()) {
      try {
        await userProvider.updateUser(
          name: nameController.text,
          email: emailController.text,
          password: passwordController.text.isNotEmpty ? passwordController.text : null,
          photoUrl: '',
        );

        userProvider.updateUserPreferences(
          UserPreferences(
            fontSize: selectedFontSize!,
            defaultFontId: selectedFontId ?? 'roboto',
          ),
        );
        
        return true;
      } catch (e) {
        Exception('Erro ao salvar alterações: $e');
        return false;
      }
    }
    return false;
  }

  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
  }
}
