import 'package:alfabetizando_tcc/src/models/intern.dart'; 
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CardsInternosCard extends StatelessWidget {
  final CardsInternos cardsInternos; 
  final AudioPlayer _audioPlayer = AudioPlayer();

  CardsInternosCard({required this.cardsInternos});

  void _playSound() async {
    await _audioPlayer.play(AssetSource(cardsInternos.soundUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: _playSound,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.asset(
                  cardsInternos.imageUrl,
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                color: Colors.black54,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(
                    cardsInternos.name,
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        IconButton(
          icon: const Icon(Icons.volume_up),
          onPressed: _playSound,
        ),
      ],
    );
  }
}
