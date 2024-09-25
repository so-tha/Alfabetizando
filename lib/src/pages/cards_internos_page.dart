import 'package:alfabetizando_tcc/src/ui/custom_intern_card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/intern.dart';

class CardsInternosPage extends StatefulWidget {
  final int categoryId;
  final String categoryName;
  const CardsInternosPage(
      {super.key, required this.categoryId, required this.categoryName});

  @override
  _CardsInternosPageState createState() => _CardsInternosPageState();
}

class _CardsInternosPageState extends State<CardsInternosPage> {
  late Future<List<CardsInternos>> _cardsInternosFuture;

  @override
  void initState() {
    super.initState();

    _cardsInternosFuture =
        fetchCardsInternos(widget.categoryId).then((categories) {
      return categories.map((category) {
        return CardsInternos(
          name: category.name,
          imageUrl: category.imageUrl,
          soundUrl: category.soundUrl,
          id: category.id,
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
                              'lib/assets/logs/logOpsAlgoDeuErrado-Photoroom.png'), //colocar o caminho
                          const SizedBox(height: 16),
                          Text(
                            'Parece que nenhuma categoria foi encontrada, chame seu responsável!',
                            style: GoogleFonts.nunito(fontSize: 18),
                            textAlign: TextAlign.center,
                          )
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
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    );
                  });
            });
            return const SizedBox.shrink();
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
