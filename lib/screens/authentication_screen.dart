import 'package:flutter/material.dart';

class AuthScreen extends StatefulWidget {
  bool isLogin;
  AuthScreen({this.isLogin = true, super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late bool _isLogin;

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? 'Login' : 'Registro'),
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
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(_isLogin
                              ? 'Efetuando Login...'
                              : 'Registrando...')),
                    );
                  }
                },
                child: Text(_isLogin ? 'Login' : 'Registrar-se'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isLogin = !_isLogin; // Alterna entre login e registro
                  });
                },
                child: Text(_isLogin
                    ? 'Não tem uma conta? Registre-se'
                    : 'Já tem uma conta? Faça login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
