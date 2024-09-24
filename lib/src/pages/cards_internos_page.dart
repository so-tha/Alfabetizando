import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/intern.dart'; // Importar o arquivo onde está o fetchCategories

class CardsInternos {
  final String name;
  final String imageUrl;
  final String soundUrl;

  CardsInternos({
    required this.name,
    required this.imageUrl,
    required this.soundUrl,
  });
}

class CardsInternosPage extends StatefulWidget {
  final int categoryId; 
  final String categoryName;
  CardsInternosPage({super.key, required this.categoryId, required this.categoryName});

  @override
  _CardsInternosPageState createState() => _CardsInternosPageState();
}

class _CardsInternosPageState extends State<CardsInternosPage> {
  late Future<List<CardsInternos>> _cardsInternosFuture;

  @override
  void initState() {
    super.initState();
   
     _cardsInternosFuture = fetchCardsInternos(widget.categoryId).then((categories) {
      return categories.map((category) {
        return CardsInternos(
          name: category.name,
          imageUrl: category.imageUrl, 
          soundUrl: category.soundUrl,
        );
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName), 
      ),
      body: FutureBuilder<List<CardsInternos>>(
        future: _cardsInternosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhum cartão encontrado.'));
          } else {
            final cardsInternos = snapshot.data!;
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.3,
              ),
              itemCount: cardsInternos.length,
              itemBuilder: (context, index) {
                final cardInternos = cardsInternos[index];
                return CardsInternosCard(cardsInternos: cardInternos);
              },
            );
          }
        },
      ),
    );
  }
}

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
