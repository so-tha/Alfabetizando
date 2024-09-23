// ignore_for_file: depend_on_referenced_packages

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive/hive.dart';

part 'intern.g.dart';


@HiveType(typeId: 0)
class CardsInternos {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String imageUrl;

  @HiveField(3)
  final String soundUrl;

  CardsInternos({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.soundUrl,
  });

  factory CardsInternos.fromJson(Map<String, dynamic> json) {
    return CardsInternos(
      id: json['id'] as int,
      name: json['name'] as String,
      imageUrl: json['image_url'] as String,
      soundUrl: json['sound_url'] as String,
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image_url': imageUrl,
      'sound_url': soundUrl,
    };
  }
}

Future<List<CardsInternos>> fetchCardsInternos(int categoryId) async {
  final response = await Supabase.instance.client
      .from('cards_internos')
      .select()
      .eq('category_id', categoryId);

  if (response.isEmpty) {
    throw Exception('Nenhum card encontrado.');
  }

  final List<dynamic> data = response as List<dynamic>;
  return data
      .map((json) => CardsInternos.fromJson(json as Map<String, dynamic>))
      .toList();
}

Future<void> addCardsInternos(CardsInternos card) async {
  final response = await Supabase.instance.client
      .from('cards_internos')
      .insert(card.toJson());

  if (response.error != null) {
    throw Exception('Erro ao adicionar card: ${response.error!.message}');
  }
  final box = await Hive.openBox<CardsInternos>('cards_internos');
  box.add(card);
}

Future<void> updateCardsInternos(CardsInternos card) async {
  final response = await Supabase.instance.client
      .from('cards_internos')
      .update(card.toJson())
      .eq('id', card.id);

  if (response.error != null) {
    throw Exception('Erro ao atualizar card: ${response.error!.message}');
  }
  final box = await Hive.openBox<CardsInternos>('cards_internos');
  final existingCard = box.get(card.id);

  if (existingCard != null) {
    await box.put(card.id, card);
  } else {
    throw Exception('Card não encontrado no Hive para atualização');
  }
}

Future<void> deleteCardsInternos(int id) async {
  final response = await Supabase.instance.client
      .from('cards_internos')
      .delete()
      .eq('id', id);

  if (response.error != null) {
    throw Exception('Erro ao remover card: ${response.error!.message}');
  }
  final box = await Hive.openBox<CardsInternos>('cards_internos');
  await box.delete(id);
}
