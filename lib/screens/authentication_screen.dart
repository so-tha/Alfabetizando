import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthScreen extends StatefulWidget {
  bool isLogin;
  AuthScreen({this.isLogin = true, super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
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
      fillColor: Color(0xFFFFCB7C),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Color(0xFFFFCB7C)),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.red),
      ),
    );
  }

  ButtonStyle _buildButtonStyle() {
    return FilledButton.styleFrom(
      backgroundColor: Color.fromRGBO(47, 61, 218, 1), // Cor do botão
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      padding: EdgeInsets.all(16.0),
    );
  }

  Future<void> _signUp(String email, String password) async {
    final response = await Supabase.instance.client.auth.signUp(
      email: email,
      password: password,
    );

    if (response.user == null) {
      // Mostra um erro se a resposta não contiver um usuário
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possivel realizar o login')),
      );
    } else {
      // Sucesso - usuário registrado
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registro bem-sucedido!')),
      );
    }
  }

  Future<void> _signIn(String email, String password) async {
    final response = await Supabase.instance.client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.session == null) {
      // Mostra um erro se a resposta não contiver uma sessão válida
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possivel realizar o login')),
      );
    } else {
      // Sucesso - usuário logado
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login bem-sucedido!')),
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
                    FilledButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _signUp(
                              _emailController.text, _passwordController.text);
                        }
                      },
                      child: Text('Registrar-se'),
                    );
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
                  padding:
                      EdgeInsets.zero, // Padding personalizado, se necessário
                ),
                child: Text(
                  _isLogin
                      ? 'Não tem uma conta? Registre-se'
                      : 'Já tem uma conta? Faça login',
                  style: TextStyle(
                    color: Color(0xFF4F4F4F),
                    fontSize: 14,
                    fontFamily: 'Nunito',
                    height: 1.2, // Ajuste de altura da linha
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
