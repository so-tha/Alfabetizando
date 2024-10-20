import 'dart:io';

import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

class CustomFont {
  final String id;
  final String name;
  final String path;

  CustomFont({required this.id, required this.name, required this.path});
}

class FontManager {
  final List<CustomFont> _customFonts = [];

  List<CustomFont> get customFonts => List.unmodifiable(_customFonts);

  Future<String> addCustomFont(String path, String name) async {
    final fontId = const Uuid().v4();
    final customFont = CustomFont(id: fontId, name: name, path: path);
    _customFonts.add(customFont);

    final fontLoader = FontLoader(fontId);
    fontLoader.addFont(Future.value(ByteData.view(await File(path).readAsBytes().then((bytes) => bytes.buffer))));
    await fontLoader.load();

    return fontId;
  }

  FontWeight? getFontWeight(String fontId) {
    return FontWeight.normal;
  }
}
