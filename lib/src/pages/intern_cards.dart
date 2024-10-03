// ignore_for_file: must_be_immutable
import 'package:alfabetizando_tcc/src/models/intern.dart';
import 'package:alfabetizando_tcc/src/pages/card_detail_page.dart';
import 'package:alfabetizando_tcc/src/ui/custom_category_card.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';

class CardsInternosPage extends StatefulWidget {
  final Box box;
  final int categoryId;
  String categoryName;

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
              itemBuilder: (context, index) {
                if (index < categories.length) {
                  final category = categories[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CardDetailPage(
                            title: category.name,
                            imageUrl: category.imageUrl,
                          ),
                        ),
                      );
                    },
                    child: Stack(
                      children: [
                        CategoryCard(
                          title: category.name,
                          imageUrl: category.imageUrl,
                          categoryId: category.id,
                          categoryName: category.name,
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: IconButton(
                            icon: Icon(Icons.volume_up),
                            color: Colors.black,
                            iconSize: 24.0,
                            onPressed: () async {
                              if (category.soundUrl.isNotEmpty) {
                                try {
                                  final soundUrl =
                                      'https://bqdmmkkmjblovfvefazq.supabase.co/storage/v1/object/public/audios/${category.soundUrl}';
                                  await _audioPlayer.setSourceUrl(soundUrl);
                                  await _audioPlayer.resume();
                                } catch (e) {
                                  try {
                                    await _audioPlayer.setSource(AssetSource(
                                        'assets/audios/${category.soundUrl}'));
                                    await _audioPlayer.resume();
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Áudio não disponível para ${category.name}.'),
                                      ),
                                    );
                                  }
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Áudio não disponível para ${category.name}.'),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return SizedBox();
                }
              },
            ),
          );
        }
      },
    );
  }
}
