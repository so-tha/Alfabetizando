// ignore_for_file: depend_on_referenced_packages

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive/hive.dart';

part 'categories.g.dart';

@HiveType(typeId: 0)
class Category {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String imageUrl;

  @HiveField(3)
  final String? soundUrl;

  Category({required this.id, required this.title, required this.imageUrl, this.soundUrl});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int,
      title: json['title'] as String,
      imageUrl: json['image_url'] as String,
      soundUrl: json['sound_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'image_url': imageUrl,
      'sound_url': soundUrl,
    };
  }
}

String capitalize(String s) {
  if (s.isEmpty) return ''; 
  return s[0].toUpperCase() + s.substring(1);
}

String capitalizeWords(String s) => s
    .split(' ')
    .map((word) => capitalize(word))
    .join(' ');

    
Future<List<Category>> fetchCategories() async {
  try {
    final response = await Supabase.instance.client
        .from('cards')
        .select();

    if (response.isEmpty) {
      throw Exception('Nenhuma categoria encontrada.');
    }

    final List<dynamic> data = response as List<dynamic>;
 

    return data.map((json) {
      try {
        return Category.fromJson(json as Map<String, dynamic>);
      } catch (e) {
        rethrow;
      }
    }).toList();

  } catch (e) {
    throw Exception('Falha ao carregar categorias: $e');
  }
}

Future<void> addCategory(Category category) async {
  final response =
      await Supabase.instance.client.from('cards').insert(category.toJson());

  if (response.error != null) {
    throw Exception('Erro ao adicionar categoria: ${response.error!.message}');
  }
  final box = await Hive.openBox<Category>('categories');
  box.add(category);
}

Future<void> updateCategory(Category category) async {
  final response = await Supabase.instance.client
      .from('cards')
      .update(category.toJson())
      .eq('id', category.id);

  if (response.error != null) {
    throw Exception('Erro ao atualizar categoria: ${response.error!.message}');
  }
  final box = await Hive.openBox<Category>('categories');
  final existingCategory = box.get(category.id);

  if (existingCategory != null) {
    await box.put(category.id, category);
  } else {
    throw Exception('Categoria não encontrada no Hive para atualização');
  }
}



Future<void> deleteCategory(String id) async {
  final response =
      await Supabase.instance.client.from('cards').delete().eq('id', id);

  if (response.error != null) {
    throw Exception('Erro ao remover categoria: ${response.error!.message}');
  }
  final box = await Hive.openBox<Category>('categories');
  final category = box.get(id);
  if (category != null) {
    await box.delete(id);
  }
}
