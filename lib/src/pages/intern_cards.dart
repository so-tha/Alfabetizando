// ignore_for_file: must_be_immutable
import 'package:alfabetizando_tcc/src/models/intern.dart';
import 'package:alfabetizando_tcc/src/pages/card_detail_page.dart';
import 'package:alfabetizando_tcc/src/providers/font_provider.dart';
import 'package:alfabetizando_tcc/src/services/card_service.dart';
import 'package:alfabetizando_tcc/src/ui/custom_category_card.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';


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
    CardService cv = CardService();
    _categoriesFuture = cv.fetchCardsInternos(widget.categoryId);
    _categoriesFuture.then((cards) {
      print('Cards carregados: ${cards.length}');
      cards.forEach((card) => print('Card: ${card.name}, ID: ${card.id}'));
    }).catchError((error) {
      print('Erro ao carregar cards: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    print('Building CardsInternosPage with categoryId: ${widget.categoryId}');
    final fontProvider = Provider.of<FontProvider>(context);
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
                  fontSize: fontProvider.fontSize.toDouble(),
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
                            soundUrl: category.soundUrl,
                            word: category.name,
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
                          bottom: 8,
                          right: 8,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(width: 4),
                              IconButton(
                                icon: Icon(Icons.volume_up),
                                color: const Color.fromARGB(255, 0, 0, 0),
                                iconSize: 24.0,
                                padding: EdgeInsets.zero,
                                constraints: BoxConstraints(),
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
                            ],
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
