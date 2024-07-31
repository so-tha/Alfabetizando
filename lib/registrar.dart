import 'package:flutter/material.dart';

class RegisterUser extends StatefulWidget {
  const RegisterUser({super.key});

  @override
  State<RegisterUser> createState() => _RegisterUserState();
}

class _RegisterUserState extends State<RegisterUser> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController(); 
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey, 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nome',
            ),
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
            decoration: const InputDecoration(
              labelText: 'Email',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, insira seu email.';
              } else if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+\.[a-zA-Z]+").hasMatch(value)) {
                return 'Por favor, insira um email válido.';
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),
          TextFormField(
            controller: _passwordController,
            obscureText: true, 
            decoration: const InputDecoration(
              labelText: 'Senha',
            ),
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
                // Handle form submission logic here
                // Access form data using controllers
                String name = _nameController.text;
                String email = _emailController.text;
                String password = _passwordController.text;

              
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text('Registrando...')));
              }
            },
            child: const Text('Registra-se'),
          ),
        ],
      ),
    );
  }
}
