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

// Função para buscar categorias do banco de dados
Future<List<Category>> fetchCategories() async {
  final response = await Supabase.instance.client.from('cards').select();

  try {
    await response.from('cards').select();
  } on PostgrestException catch (error) {
    error.code; // Contains PostgREST error code
  }

  final List<dynamic> data = response.data as List<dynamic>;
  return data
      .map((json) => Category.fromJson(json as Map<String, dynamic>))
      .toList();
}

// Função para adicionar uma nova categoria
Future<void> addCategory(Category category) async {
  final response =
      await Supabase.instance.client.from('cards').insert(category.toJson());

  if (response.error != null) {
    throw Exception('Erro ao adicionar categoria: ${response.error!.message}');
  }
}

// Função para atualizar uma categoria existente
Future<void> updateCategory(Category category) async {
  final response = await Supabase.instance.client
      .from('cards')
      .update(category.toJson())
      .eq('id', category.id);

  if (response.error != null) {
    throw Exception('Erro ao atualizar categoria: ${response.error!.message}');
  }
}

// Função para remover uma categoria
Future<void> deleteCategory(String id) async {
  final response =
      await Supabase.instance.client.from('cards').delete().eq('id', id);

  if (response.error != null) {
    throw Exception('Erro ao remover categoria: ${response.error!.message}');
  }
}
