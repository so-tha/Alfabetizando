import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';

// Defina a classe de modelo do card
class Category {
  final String id;
  final String title;
  final String imageUrl;

  Category({required this.id, required this.title, required this.imageUrl});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      title: json['title'] as String,
      imageUrl: json['image_url'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'image_url': imageUrl,
    };
  }
}


Future<List<Category>> fetchCategories() async {
  final response = await Supabase.instance.client
      .from('cards')
      .select();

  if (response.isEmpty) {
    throw Exception('Nenhuma categoria encontrada.');
  }

  final List<dynamic> data = response as List<dynamic>;
  return data
      .map((json) => Category.fromJson(json as Map<String, dynamic>))
      .toList();
}


Future<void> addCategory(Category category) async {
  final response =
      await Supabase.instance.client.from('cards').insert(category.toJson());

  if (response.error != null) {
    throw Exception('Erro ao adicionar categoria: ${response.error!.message}');
  }
}



Future<void> updateCategory(Category category) async {
  final response = await Supabase.instance.client
      .from('cards')
      .update(category.toJson())
      .eq('id', category.id);

  if (response.error != null) {
    throw Exception('Erro ao atualizar categoria: ${response.error!.message}');
  }
}


Future<void> deleteCategory(String id) async {
  final response =
      await Supabase.instance.client.from('cards').delete().eq('id', id);

  if (response.error != null) {
    throw Exception('Erro ao remover categoria: ${response.error!.message}');
  }
}
