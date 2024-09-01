import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_page.dart';

class AuthScreen extends StatefulWidget {
  bool isLogin;
  AuthScreen({this.isLogin = true, super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late bool _isLogin;

  @override
  void initState() {
    super.initState();
    _isLogin = widget.isLogin;
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

//como o meu sistema é pequeno isso pode não ser necessario, pois não existirar duas pessoas tentando fazer login ao mesmo tempo
  Future<void> _signUp(String email, String password) async {
    final response = await Supabase.instance.client.auth.signUp(
      email: email,
      password: password,
    );

    if (response.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível realizar o registro')),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const HomePage (),
        ),
      );
    }
  }

  Future<void> _signIn(String email, String password) async {
    final response = await Supabase.instance.client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.session == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível realizar o login')),
      );
    } else {
            Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const HomePage (),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? 'Login' : 'Criar Conta'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!_isLogin)
                TextFormField(
                  controller: _nameController,
                  decoration: _buildInputDecoration('Nome'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira seu nome.';
                    }
                    return null;
                  },
                ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _buildInputDecoration('Email'),
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
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24.0),
              FilledButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    if (_isLogin) {
                      _signIn(_emailController.text, _passwordController.text);
                    } else {
                      _signUp(_emailController.text, _passwordController.text);
                    }
                  }
                },
                style: _buildButtonStyle(),
                child: Text(_isLogin ? 'Login' : 'Registrar-se'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isLogin = !_isLogin; // Alterna entre login e registro
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
            ],
          ),
        ),
      ),
    );
  }
}
