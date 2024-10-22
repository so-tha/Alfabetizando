// lib/models/intern.dart

import 'package:hive/hive.dart';

part 'intern.g.dart';

@HiveType(typeId: 2)
class CardsInternos {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String imageUrl;

  @HiveField(3)
  final String soundUrl;

  @HiveField(4)
  final int categoryId;

  CardsInternos({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.soundUrl,
    required this.categoryId,
  });

  factory CardsInternos.fromJson(Map<String, dynamic> json) {
    return CardsInternos(
      id: json['id'] as int,
      name: json['name'] as String,
      imageUrl: json['image_url'] as String,
      soundUrl: json['sound_url'] as String,
      categoryId: json['category_id'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image_url': imageUrl,
      'sound_url': soundUrl,
      'category_id': categoryId,
    };
  }
}

String capitalize(String s) {
  if (s.isEmpty) return '';
  return s[0].toUpperCase() + s.substring(1);
}

String capitalizeWords(String s) =>
    s.split(' ').map((word) => capitalize(word)).join(' ');

String splitSyllables(String word) {
  word = word.toLowerCase();

  List<String> syllables = [];
  RegExp exp = RegExp(r'[aeiouáéíóúãõâêîôûàèìòù]+[^aeiouáéíóúãõâêîôûàèìòù]*');
  Iterable<Match> matches = exp.allMatches(word);

  for (var match in matches) {
    syllables.add(match.group(0) ?? '');
  }

  return syllables.join('-');
}
