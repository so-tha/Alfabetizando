import 'package:alfabetizando_tcc/src/models/intern.dart';
import 'package:alfabetizando_tcc/src/ui/custom_category_card.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';


class CardsInternosPage extends StatefulWidget {
  final Box box;
  final int categoryId;
  late final String categoryName;

  CardsInternosPage({
    super.key,
    required this.box,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<CardsInternosPage> createState() => _CardsInternosPageState();
}

class _CardsInternosPageState extends State<CardsInternosPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  late Future<List<CardsInternos>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = fetchCardsInternos(widget.categoryId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CardsInternos>>(
      future: _categoriesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Carregando...'),
              backgroundColor: Colors.orangeAccent,
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Erro'),
              backgroundColor: Colors.orangeAccent,
            ),
            body: Center(child: Text('Erro: ${snapshot.error}')),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Sem Dados'),
              backgroundColor: Colors.orangeAccent,
            ),
            body: Center(
              child: Text('Nenhuma categoria foi encontrada.'),
            ),
          );
        } else {
          final categories = snapshot.data!;
          
          if (categories.isNotEmpty) {
           widget.categoryName;
          } else {
            widget.categoryName = 'Sem Nome';
          }
          return Scaffold(
            appBar: AppBar(
              title: Text(
                widget.categoryName,
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              backgroundColor: Colors.orange.shade200,
            ),
            body: GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.5,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return CategoryCard(
                  title: category.name,
                  imageUrl: category.imageUrl,
                  categoryId: category.id,
                  categoryName: category.name,
                );
              },
            ),
          );
        }
      },
    );
  }
}
