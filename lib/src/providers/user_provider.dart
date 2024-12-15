import 'dart:io';
import 'package:alfabetizando_tcc/src/models/user_preferences.dart';
import 'package:flutter/foundation.dart';
import '../models/user.dart' as AppUser;
import 'package:supabase_flutter/supabase_flutter.dart';


class UserProvider extends ChangeNotifier {
  AppUser.User? _user;
  UserPreferences _userPreferences = UserPreferences(fontSize: 16.0, defaultFontId: 'Roboto');
  final SupabaseClient supabase = Supabase.instance.client;

  UserProvider(this._user, this._userPreferences);
  AppUser.User? get user => _user;
  UserPreferences get userPreferences => _userPreferences;

  Future<void> setUser(AppUser.User user) async {
    _user = user;
    notifyListeners();
  }

  Future<void> clearUser() async {
    _user = null;
    _userPreferences = UserPreferences(fontSize: 16.0, defaultFontId: 'Roboto');
    notifyListeners();
  }

  Future<void> updateUser({
    String? name,
    String? email,
    String? password,
    UserPreferences? userPreferences,
    File? profileImage, required String photoUrl,
  }) async {
    try {
      if (name != null || email != null) {
        final updates = <String, dynamic>{};
        if (name != null) updates['data'] = {'name': name};
        if (email != null) updates['email'] = email;

        final authResponse = await supabase.auth.updateUser(
          UserAttributes(
            email: email,
            data: updates['data'],
          ),
        );

        if (authResponse.user != null) {
          _user = AppUser.User(
            id: authResponse.user!.id,
            email: authResponse.user!.email ?? '',
            name: authResponse.user!.userMetadata?['name'] ?? '',
            photoUrl: authResponse.user!.userMetadata?['photo_url'] ?? '',
          );
          notifyListeners();
        }
      }

      if (password != null) {
         final passwordResponse = await supabase.auth.updateUser(
          UserAttributes(password: password),
        );
        try {
        } catch (e) {
          throw Exception('Failed to update password: $e');
        }
      }

      if (userPreferences != null) {
        final prefResponse = await supabase
            .from('userpreferences') 
            .update(userPreferences.toJson())
            .eq('user_id', _user!.id!);
        if (prefResponse.error != null) {
          throw prefResponse.error!;
        }

        _userPreferences = userPreferences;
      }

      if (profileImage != null) {
        final fileName = 'profile_${_user!.id}_${DateTime.now().millisecondsSinceEpoch}.png';
        final uploadResponse = await supabase.storage
            .from('https://bqdmmkkmjblovfvefazq.supabase.co/storage/v1/s3')
            .upload(fileName, profileImage);

        // ignore: unnecessary_null_comparison
        if (uploadResponse == null) {
          throw Exception('Failed to upload profile image');
        }

        final publicUrlResponse = supabase.storage.from('https://bqdmmkkmjblovfvefazq.supabase.co/storage/v1/s3').getPublicUrl(fileName);

        final imageUrl = publicUrlResponse;

        final dbResponse = await supabase
            .from('users') 
            .update({'photo_url': imageUrl})
            .eq('id', _user!.id!);

        if (dbResponse.error != null) {
          throw dbResponse.error!;
        }

        final updatedUserResponse = await supabase.auth.getUser();
        if (updatedUserResponse.user != null) {
          _user = AppUser.User(
            id: updatedUserResponse.user!.id,
            email: updatedUserResponse.user!.email ?? '',
            name: updatedUserResponse.user!.userMetadata?['name'] ?? '',
            photoUrl: updatedUserResponse.user!.userMetadata?['avatar_url'] ?? '',
          );
          notifyListeners();
        }
      }

      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao atualizar usuário: $e');
      }
      rethrow;
    }
  }
  
  Future<void> deleteUser() async {
    try {
      await Supabase.instance.client.auth.admin.deleteUser(_user!.id!);
      await Supabase.instance.client.auth.signOut();
      await clearUser();
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  void updateUserPreferences(UserPreferences preferences) {
    _userPreferences = preferences;
    notifyListeners();
  }
}
