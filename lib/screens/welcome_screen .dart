import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreen();
}

class _WelcomeScreen extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold( 
      appBar: AppBar(),
      body: Stack(
         //permite a sobreposição
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('alfabetizando/lib/assets/images/background_image.jpg'),
                fit: BoxFit.cover, //toda a pagina
              )
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                 const Text(
                  'Alfabetizando',
                  style: TextStyle(
                    fontSize: 32,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20,),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Login'),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Registre-se'),
                ),
              ],
            ),
          ),
        ],
      ),
       backgroundColor: Colors.transparent,
    );
  }
}
