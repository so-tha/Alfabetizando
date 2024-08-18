import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'authentication_screen.dart';

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
      body: Stack(
        //permite a sobreposição
        children: [
          Container(
            decoration: const BoxDecoration(
                image: DecorationImage(
              image: AssetImage(
                  '/home/thais/Documents/workspace/alfabetizando/lib/assets/images/background_image.jpg'),
              fit: BoxFit.cover, //toda a pagina
            )),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Alfabetizando',
                    style: GoogleFonts.theGirlNextDoor(
                      fontSize: 32,
                      color: Color.fromRGBO(248, 111, 3, 100),
                    )),
                const SizedBox(
                  height: 20,
                ),
                FilledButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll<Color>(
                        const Color.fromRGBO(255, 209, 139, 1)),
                    padding:
                        WidgetStateProperty.all<EdgeInsets>(EdgeInsets.all(20)),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AuthScreen()),
                    );
                  },
                  child: const Text('Login'),
                ),
                const SizedBox(
                  height: 20,
                ),
                OutlinedButton(
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
