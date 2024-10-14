// lib/models/font.dart

import 'package:hive/hive.dart';

part 'font.g.dart';

@HiveType(typeId: 1)
class Font {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final int size;

  Font({
    required this.id,
    required this.size,
  });

  factory Font.fromJson(Map<String, dynamic> json) {
    return Font(
      id: json['default_font_id'] as String,
      size: json['size'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'default_font_id': id,
      'size': size,
    };
  }
}
