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
                  '/home/thaithai/Documents/alfabetizando/lib/assets/images/background_image.jpg'),
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
                      color: const Color.fromRGBO(248, 111, 3, 100),
                    )),
                const SizedBox(
                  height: 20,
                ),
                FilledButton(
                  style: ButtonStyle(
                    backgroundColor: const WidgetStatePropertyAll<Color>(
                        Color.fromRGBO(255, 209, 139, 1)),
                    padding:
                        WidgetStateProperty.all<EdgeInsets>(const EdgeInsets.all(20)),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AuthScreen()),
                    );
                  },
                  child: const Text('Login'),
                ),
                const SizedBox(
                  height: 20,
                ),
                OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AuthScreen(isLogin: false,)),
                    );
                  },
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
