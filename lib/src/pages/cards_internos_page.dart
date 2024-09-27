import 'package:alfabetizando_tcc/src/models/intern.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';

class CardsInternosPage extends StatefulWidget {
  final Box box;
  final int categoryId;
  const CardsInternosPage( 
      {super.key, required this.box, required this.categoryId});

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

  void _loadData() async {
    var cachedCategories = widget.box.get(
        'categories_${widget.categoryId}'); 

    if (cachedCategories != null) {
      setState(() {
        _categoriesFuture = Future.value(cachedCategories);
      });
    } else {
      _categoriesFuture =
          fetchCardsInternos(widget.categoryId).then((categories) {
        widget.box.put('categories_${widget.categoryId}',
            categories); 
        return categories;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          flex: 1,
          child: FutureBuilder<List<CardsInternos>>(
            future: _categoriesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Erro: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(
                          'Oops!',
                          style: GoogleFonts.nunito(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'lib/assets/logs/logOpsAlgoDeuErrado-Photoroom.png',
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Parece que nenhuma categoria foi encontrada, chame seu responsável!',
                              style: GoogleFonts.nunito(fontSize: 18),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              'Entendi!',
                              style: GoogleFonts.nunito(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                });
                return const SizedBox.shrink();
              } else {
                final categories = snapshot.data!;
                return GridView.builder(
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
                    return Material(
                      child: InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                             builder: (context) => CardsInternosPage(box: widget.box, categoryId: category.id),
                          ),
                        ),
                        child: Column(
                          children: [
                            Image.asset(
                              category.imageUrl,
                              fit: BoxFit.cover,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              category.name, // Ajuste aqui
                              style: GoogleFonts.nunito(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
            },
          ),
        ),
      ],
    );
  }
}
