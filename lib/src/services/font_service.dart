import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/font.dart';

class FontService {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<List<Font>> fetchFonts() async {
    try {
      final response = await supabase
          .from('fonts')
          .select()
          .order('size', ascending: true);

      final List<dynamic> data = response as List<dynamic>;
      return data.map((json) => Font.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar fontes: $e');
    }
  }
}
