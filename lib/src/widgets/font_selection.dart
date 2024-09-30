import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FontSelection {
  static Future<String?> pickFont() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['ttf', 'otf'],
    );

    if (result != null && result.files.single.path != null) {
      String? fontPath = result.files.single.path;

      if (fontPath != null) {
        await _saveFont(fontPath);
        return fontPath;
      }
    }
    return null;
  }

  static Future<void> _saveFont(String fontPath) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedFontPath', fontPath);
  }

  static Future<String?> loadFont() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('selectedFontPath');
  }
}
