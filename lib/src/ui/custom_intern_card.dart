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
    return GestureDetector(
      onTap: _playSound, 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.asset(
                  cardsInternos.imageUrl,
                  height: 120, 
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                bottom: 0,
                child: Container(
                  width: double.infinity,
                  color: Colors.black.withOpacity(0.6),
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          cardsInternos.name,
                          style: GoogleFonts.nunito(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.volume_up,
                          color: Colors.white,
                        ),
                        onPressed: _playSound, 
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
