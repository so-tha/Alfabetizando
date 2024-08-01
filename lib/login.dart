import 'package:flutter/material.dart';
import 'package:alfabetizando_tcc/registrar.dart';

class loginUser extends StatefulWidget {
  const loginUser({super.key});

  @override
  State<loginUser> createState() => _loginUserState();
}

class _loginUserState extends State<loginUser> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(); 
  final _passwordController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey, 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                String email = _emailController.text;
                String password = _passwordController.text;
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text('Efetuando Login...')));
              }
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }
}