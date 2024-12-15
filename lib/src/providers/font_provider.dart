// lib/providers/font_provider.dart

import 'package:flutter/foundation.dart';
import '../services/preference_service.dart';
import '../models/font.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FontProvider with ChangeNotifier {
  final PreferenceService _preferenceService = PreferenceService();

  final List<Font> _fonts = [
    Font(id: 'roboto', size: 16),
    Font(id: 'opensans', size: 16),
    Font(id: 'lato', size: 16),
  ];
  
  String? _selectedFontId;
  int _fontSize = 16;

  List<Font> get fonts => _fonts;
  int get fontSize => _fontSize;
  String? get selectedFontId => _selectedFontId;

  FontProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadFontPreference();
  }

  Future<void> _loadFontPreference() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      try {
        final savedFontId = await _preferenceService.loadFontPreference(user.id);
        if (savedFontId != null) {
          _selectedFontId = savedFontId;
          final selectedFont = _fonts.firstWhere(
            (font) => font.id == _selectedFontId,
            orElse: () => _fonts.first,
          );
          _fontSize = selectedFont.size;
          notifyListeners();
        }
      } catch (e) {
        print('Erro ao carregar preferência de fonte: $e');
      }
    }
  }

  void setSelectedFont(String font) {
    _selectedFontId = font;
    notifyListeners();
  }

  void setFontSize(double size) {
    _fontSize = size.toInt();
    notifyListeners();
  }

  Future<void> updateFont(String fontId) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      try {
        _selectedFontId = fontId;
        final selectedFont = _fonts.firstWhere(
          (font) => font.id == _selectedFontId,
          orElse: () => _fonts.first,
        );
        _fontSize = selectedFont.size;
        notifyListeners();
        await _preferenceService.saveFontPreference(user.id, fontId);
      } catch (e) {
        if (kDebugMode) {
          throw Exception('Erro ao salvar preferência de fonte: $e');
        }
      }
    }
  }
}
