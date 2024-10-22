
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive/hive.dart';
import '../models/intern.dart';

class CardService {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<List<CardsInternos>> fetchCardsInternos(int categoryId) async {
    try {
      final response = await supabase
          .from('cards_internos')
          .select()
          .eq('category_id', categoryId);

      final List<dynamic> data = response as List<dynamic>;
      return data
          .map((json) => CardsInternos.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar cards internos: $e');
    }
  }

  Future<void> addCardsInternos(CardsInternos card) async {
    try {
      final response = await supabase
          .from('cards_internos')
          .insert(card.toJson())
          .select()
          .single();

      final insertedCard = CardsInternos.fromJson(response);

      final box = await Hive.openBox<CardsInternos>('cards_internos');
      await box.put(insertedCard.id, insertedCard);
    } catch (e) {
      throw Exception('Erro ao adicionar card: $e');
    }
  }

  Future<void> updateCardsInternos(CardsInternos card) async {
    try {
      await supabase
          .from('cards_internos')
          .update(card.toJson())
          .eq('id', card.id);

      final box = await Hive.openBox<CardsInternos>('cards_internos');
      final existingCard = box.get(card.id);

      if (existingCard != null) {
        await box.put(card.id, card);
      } else {
        throw Exception('Card não encontrado no Hive para atualização.');
      }
    } catch (e) {
      throw Exception('Erro ao atualizar card: $e');
    }
  }
  
  Future<String> uploadFile(file, String folder) async {
    try {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';

      await supabase.storage.from(folder).upload(fileName, file);

      final publicUrl = supabase.storage
          .from(folder)
          .getPublicUrl(fileName);

      if (publicUrl.isEmpty) {
        throw Exception('Não foi possível gerar a URL pública para o arquivo.');
      }

      return publicUrl;
    } catch (e) {
      if (kDebugMode) {
        print('Erro no upload do arquivo: $e');
      }
      throw Exception('Falha no upload do arquivo: $e');
    }
  }

  Future<void> deleteCardsInternos(int id) async {
    try {
      await supabase
          .from('cards_internos')
          .delete()
          .eq('id', id);

      final box = await Hive.openBox<CardsInternos>('cards_internos');
      await box.delete(id);
    } catch (e) {
      throw Exception('Erro ao remover card: $e');
    }
  }
    Future<int> addNewCategory(String name) async {
      try {
        final response = await supabase
            .from('cards') 
            .insert({
              'name': name, 
            })
            .select()
            .single();

        final int categoryId = response['id'];
        final box = await Hive.openBox('categories');
        await box.put(categoryId, name);

        return categoryId;
      } catch (e) {
        throw Exception('Erro ao adicionar nova categoria: $e');
      }
  }
    Future<List<String>> fetchCategories() async {
      try {
        final response = await supabase
            .from('cards') 
            .select();

        final List<dynamic> data = response as List<dynamic>;

        return data.map((json) => json['name'] as String).toList();
      } catch (e) {
        throw Exception('Erro ao buscar categorias: $e');
      }
    }
}
