import 'package:supabase_flutter/supabase_flutter.dart';

class FontService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  Future<List<String>> fetchFonts() async {
    try {
      final response = await _supabaseClient
          .from('fonts')
          .select('name');

      final List<dynamic> data = response as List<dynamic>;
      return data.map((font) => font['name'] as String).toList();
    } catch (e) {
      throw Exception('Erro ao buscar fontes: $e');
    }
  }
}
