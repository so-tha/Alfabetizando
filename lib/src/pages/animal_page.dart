import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';

class AnimalPage extends StatelessWidget {
  final List<Animal> animals = [
    Animal(name: 'Gato', imageUrl: 'lib/assets/images/gato.jpg', soundUrl: 'lib/assets/sounds/gato.mp3'),
    Animal(name: 'Cachorro', imageUrl: 'lib/assets/images/cachorro.jpg', soundUrl: 'lib/assets/sounds/cachorro.mp3'),
  ];

   AnimalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); 
          },
        ),
        title: Row(
          children: [
            Text(
              'Animais',
              style: GoogleFonts.nunito(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.volume_up), // Ícone de som
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.3, // Define a proporção dos itens
          ),
          itemCount: animals.length,
          itemBuilder: (context, index) {
            final animal = animals[index];
            return AnimalCard(animal: animal);
          },
        ),
      ),
    );
  }
}

class Animal {
  final String name;
  final String imageUrl;
  final String soundUrl;

  Animal({
    required this.name,
    required this.imageUrl,
    required this.soundUrl,
  });
}

class AnimalCard extends StatelessWidget {
  final Animal animal;
  final AudioPlayer _audioPlayer = AudioPlayer();

  AnimalCard({required this.animal});

  void _playSound() async {
    await _audioPlayer.play(AssetSource(animal.soundUrl)); 
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: _playSound, // Função para tocar o som
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.asset(
                  animal.imageUrl,
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                color: Colors.black54, // Fundo semitransparente para o título
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(
                    animal.name,
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
          onPressed: _playSound, // Botão para tocar o som
        ),
      ],
    );
  }
}
