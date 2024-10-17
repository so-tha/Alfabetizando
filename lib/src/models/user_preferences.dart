class UserPreferences {
  final double fontSize;
  final String defaultFontId;

  UserPreferences({
    required this.fontSize,
    required String defaultFontId,
  }) : defaultFontId = _validateFontId(defaultFontId);

  static String _validateFontId(String fontId) {
    if (fontId != 'helvetica' && fontId != 'arial') {
      print('Warning: Invalid defaultFontId "$fontId". Defaulting to "helvetica".');
      return 'helvetica';
    }
    return fontId;
  }

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      fontSize: (json['font_size'] as num).toDouble(),
      defaultFontId: json['default_font_id'] as String, // Obtido do JSON
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'font_size': fontSize,
      'default_font_id': defaultFontId, 
    };
  }

  factory UserPreferences.defaultPreferences() {
    return UserPreferences(
      fontSize: 16.0,
      defaultFontId: 'helvetica',
    );
  }
}
