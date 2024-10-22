import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/authentication_screen.dart';
import 'package:hive/hive.dart';

class WelcomeScreen extends StatefulWidget {
  final Box box;
  const WelcomeScreen({super.key, required this.box});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
                image: DecorationImage(
              image: AssetImage(
                  'lib/assets/images/background_image.jpg'),
              fit: BoxFit.cover,
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
                const SizedBox(height: 20),
                FilledButton(
                  style: ButtonStyle(
                    backgroundColor: const WidgetStatePropertyAll<Color>(
                        Color.fromRGBO(255, 209, 139, 1)),
                    padding: WidgetStateProperty.all<EdgeInsets>(
                        const EdgeInsets.all(20)),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AuthScreen(box: widget.box)),
                    );
                  },
                  child: const Text('Login'),
                ),
                const SizedBox(height: 20),
                OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AuthScreen(
                                isLogin: false, box: widget.box
                              )),
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
