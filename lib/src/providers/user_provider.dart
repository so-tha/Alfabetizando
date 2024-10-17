import 'dart:io';
import 'package:alfabetizando_tcc/src/models/user_preferences.dart';
import 'package:alfabetizando_tcc/src/services/card_service.dart';
import 'package:flutter/foundation.dart';
import '../models/user.dart' as myUser;
import 'package:supabase_flutter/supabase_flutter.dart';


class UserProvider extends ChangeNotifier {
  myUser.User _user;
  UserPreferences _userPreferences;
  final SupabaseClient supabase = Supabase.instance.client;
  final CardService _cardService = CardService();

  UserProvider(this._user, UserPreferences? userPreferences)
      : _userPreferences = userPreferences ?? UserPreferences.defaultPreferences();

  myUser.User get user => _user;
  UserPreferences get userPreferences => _userPreferences;

  Future<void> updateUser({
    String? name,
    String? email,
    String? password,
    UserPreferences? userPreferences,
    File? profileImage,
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

        if (authResponse.user == null) {
          throw Exception('Failed to update user');
        }
        _user = authResponse.user! as myUser.User;

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
            .eq('user_id', _user.id);

        if (prefResponse.error != null) {
          throw prefResponse.error!;
        }

        _userPreferences = userPreferences;
      }

      if (profileImage != null) {
        final fileName = 'profile_${_user.id}_${DateTime.now().millisecondsSinceEpoch}.png';
        final uploadResponse = await supabase.storage
            .from('https://bqdmmkkmjblovfvefazq.supabase.co/storage/v1/s3')
            .upload(fileName, profileImage);

        if (uploadResponse == null) {
          throw Exception('Failed to upload profile image');
        }

        final publicUrlResponse = supabase.storage.from('https://bqdmmkkmjblovfvefazq.supabase.co/storage/v1/s3').getPublicUrl(fileName);

        final imageUrl = publicUrlResponse;

        final dbResponse = await supabase
            .from('users') 
            .update({'photo_url': imageUrl})
            .eq('id', _user.id);

        if (dbResponse.error != null) {
          throw dbResponse.error!;
        }

        final updatedUserResponse = await supabase.auth.getUser();
        if (updatedUserResponse.user == null) {
          throw Exception('Failed to get updated user data');
        }
        _user = updatedUserResponse.user! as myUser.User;

        notifyListeners();
      }

      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao atualizar usuário: $e');
      }
      rethrow;
    }
  }

  void updateUserPreferences(UserPreferences newPreferences) {
    _userPreferences = newPreferences;
    // You might need to save this to local storage or an API
    notifyListeners();
  }
}
