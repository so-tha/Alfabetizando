import 'package:alfabetizando_tcc/src/models/user_preferences.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'dart:io';

class UpdateProfile extends StatefulWidget {
  const UpdateProfile({super.key});

  @override
  _UpdateProfileState createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  final _formKey = GlobalKey<FormState>();
  String? _name;
  String? _email;
  String? _password;
  File? _profileImage;
  double? _fontSize;

  bool _isLoading = false;

  Future<void> _selectProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateUser() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      await userProvider.updateUser(
        name: _name,
        email: _email,
        password: _password,
        userPreferences: UserPreferences(
          fontSize: _fontSize ?? userProvider.userPreferences.fontSize, defaultFontId: '',
        ),
        profileImage: _profileImage, photoUrl: '',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Perfil atualizado com sucesso!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar perfil: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar exclusão de conta'),
          content: Text('Tem certeza que deseja excluir sua conta? Esta ação não pode ser desfeita.'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text('Excluir'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );
    if (confirmed == true) {
      setState(() {
        _isLoading = true;
      });
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      try {
        await userProvider.deleteUser();
        Navigator.of(context).pushReplacementNamed('/login');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao excluir conta: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Atualizar Perfil'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _selectProfileImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _profileImage != null
                      ? FileImage(_profileImage!)
                      : (userProvider.user?.photoUrl != null
                          ? NetworkImage(userProvider.user!.photoUrl!)
                          : null) as ImageProvider?,
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                initialValue: userProvider.user?.name,
                decoration: InputDecoration(labelText: 'Nome'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira seu nome.';
                  }
                  return null;
                },
                onSaved: (value) => _name = value,
              ),
              TextFormField(
                initialValue: userProvider.user?.email ?? '',
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira seu email.';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Por favor, insira um email válido.';
                  }
                  return null;
                },
                onSaved: (value) => _email = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Nova Senha'),
                obscureText: true,
                onSaved: (value) => _password = value,
              ),
              Slider(
                value: _fontSize ?? userProvider.userPreferences.fontSize,
                min: 12,
                max: 24,
                divisions: 6,
                label: (_fontSize ?? userProvider.userPreferences.fontSize).toString(),
                onChanged: (value) {
                  setState(() {
                    _fontSize = value;
                  });
                },
              ),
              SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator()
                  : Column(
                      children: [
                        ElevatedButton(
                          onPressed: _updateUser,
                          child: Text('Atualizar Perfil'),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
