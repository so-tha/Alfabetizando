// lib/services/preference_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';

class PreferenceService {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<void> saveFontPreference(String userId, String fontId) async {
    try {
      await supabase
          .from('userpreferences')
          .upsert({'user_id': userId, 'default_font_id': fontId}, onConflict: 'user_id');
    } catch (e) {
      throw Exception('Erro ao salvar preferência: $e');
    }
  }

  Future<String?> loadFontPreference(String userId) async {
    try {
      final response = await supabase
          .from('userpreferences')
          .select('default_font_id')
          .eq('user_id', userId)
          .single();

      return response['default_font_id'] as String?;
      } catch (e) {
      throw Exception('Erro ao carregar preferência: $e');
    }
  }
}
