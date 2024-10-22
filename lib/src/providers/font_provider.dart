// lib/providers/font_provider.dart

import 'package:flutter/foundation.dart';
import '../services/preference_service.dart';
import '../services/font_service.dart';
import '../models/font.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FontProvider with ChangeNotifier {
  final PreferenceService _preferenceService = PreferenceService();
  final FontService _fontService = FontService();

  List<Font> _fonts = [];
  String? _selectedFontId;
  int _fontSize = 16; // Valor padrão

  List<Font> get fonts => _fonts;
  int get fontSize => _fontSize;
  
  String? get selectedFontId => _selectedFontId;

  FontProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    await _fetchFonts();
    await _loadFontPreference();
  }

  Future<void> _fetchFonts() async {
    _fonts = await _fontService.fetchFonts();
    notifyListeners();
  }

Future<void> _loadFontPreference() async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user != null) {
    try {
      final savedFontId = await _preferenceService.loadFontPreference(user.id);
      if (savedFontId != null && _fonts.isNotEmpty) {
        _selectedFontId = savedFontId;
        final selectedFont = _fonts.firstWhere(
          (font) => font.id == _selectedFontId,
          orElse: () => _fonts.first, 
          );
        _fontSize = selectedFont.size;
        notifyListeners();
      } else {
        print('Nenhuma fonte salva ou lista de fontes está vazia.');
      }
    } catch (e) {
      throw Exception('Erro ao carregar preferência de fonte: $e');
    }
  }
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
