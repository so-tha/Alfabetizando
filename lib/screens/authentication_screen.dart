import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_page.dart';

class AuthScreen extends StatefulWidget {
  final bool isLogin;
  final Box box;
  const AuthScreen({this.isLogin = true, required this.box, super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  // ignore: unused_field
  String? _userId;
  late bool _isLogin;
  bool _isLoading = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _isLogin = widget.isLogin;
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      setState(() {
        _userId = data.session?.user.id;
      });
    });
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color(0xFFFFCB7C),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFFFCB7C)),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }

  ButtonStyle _buildButtonStyle() {
    return FilledButton.styleFrom(
      backgroundColor: const Color.fromRGBO(47, 61, 218, 1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      padding: const EdgeInsets.all(16.0),
    );
  }

  Future<void> _signUp(String email, String password, String name) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        final userId = response.user!.id;
        await Supabase.instance.client.from('users').insert({
          'id': userId,
          'email': email,
          'child_name': name,
        });
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => HomePage(box: widget.box),
          ),
        );
      } else {
        _handleError('Não foi possível realizar o registro');
      }
    } on AuthException catch (e) {
      _handleError(e.message);
    } catch (e) {
      _handleError('Ocorreu um erro inesperado');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signIn(String email, String password) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.session != null) {
        final userId = response.user!.id;
        final name = _nameController.text;

        final userQuery = await Supabase.instance.client
            .from('users')
            .select()
            .eq('id', userId)
            .single()
            .maybeSingle();

        if (userQuery != null) {
          await Supabase.instance.client.from('users').update({
            'email': email,
            'child_name': name,
          }).eq('id', userId);
        }

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => HomePage(box: widget.box),
          ),
        );
      } else {
        _handleError('Não foi possível realizar o login');
      }
    } on AuthException catch (e) {
      _handleError(e.message);
    } catch (e) {
      print(e);
      _handleError('Ocorreu um erro inesperado');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleError(String message) {
    setState(() {
      errorMessage = message;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? 'Login' : 'Criar Conta'),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Color.fromRGBO(255, 246, 244, 1.0),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!_isLogin)
                            TextFormField(
                              controller: _nameController,
                              decoration:
                                  _buildInputDecoration('Nome da Criança'),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor, insira o nome da criança.';
                                }
                                return null;
                              },
                            ),
                          const SizedBox(height: 16.0),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration:
                                _buildInputDecoration('Email do Responsável'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, insira seu email.';
                              } else if (!RegExp(
                                      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+\.[a-zA-Z]+")
                                  .hasMatch(value)) {
                                return 'Por favor, insira um email válido.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16.0),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: _buildInputDecoration('Senha'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, insira sua senha.';
                              } else if (value.length < 6) {
                                return 'A senha deve ter pelo menos 6 caracteres.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24.0),
                          FilledButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                if (_isLogin) {
                                  _signIn(_emailController.text,
                                      _passwordController.text);
                                } else {
                                  _signUp(
                                    _emailController.text,
                                    _passwordController.text,
                                    _nameController.text,
                                  );
                                }
                              }
                            },
                            style: _buildButtonStyle(),
                            child: Text(_isLogin ? 'Login' : 'Registrar-se'),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isLogin = !_isLogin;
                              });
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                            ),
                            child: Text(
                              _isLogin
                                  ? 'Não tem uma conta? Registre-se'
                                  : 'Já tem uma conta? Faça login',
                              style: const TextStyle(
                                color: Color(0xFF4F4F4F),
                                fontSize: 14,
                                fontFamily: 'Nunito',
                                height: 1.2,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          if (errorMessage.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                errorMessage,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
