import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

import '../models/categories.dart';

class CategoryCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final int categoryId;
  final String categoryName;
  final String? soundUrl;

  const CategoryCard({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.categoryId,
    required this.categoryName,
    this.soundUrl,
  });

  @override
  Widget build(BuildContext context) {
    final AudioPlayer audioPlayer = AudioPlayer();

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            flex: 1,
            child: Container(
              decoration: ShapeDecoration(
                image: DecorationImage(
                  image: AssetImage(imageUrl),
                  fit: BoxFit.cover,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                shadows: const [
                  BoxShadow(
                    color: Color.fromARGB(255, 226, 226, 226),
                    blurRadius: 2,
                    spreadRadius: 0,
                  ),
                ],
              ),
              height: 140,
              width: double.infinity,
            ),
          ),
          const SizedBox(height: 8),

          Text(
            capitalizeWords(title),
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          if (soundUrl != null)
            IconButton(
              icon: const Icon(Icons.volume_up),
              color: Colors.black,
              iconSize: 24.0,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () async {
      if (soundUrl != null && soundUrl!.isNotEmpty) {
        try {
          final fullSoundUrl =
               'https://bqdmmkkmjblovfvefazq.supabase.co/storage/v1/object/public/audios/$soundUrl';
          await audioPlayer.setSourceUrl(fullSoundUrl);
          await audioPlayer.resume();
        } catch (e) {
          if (kDebugMode) {
            throw Exception('Erro ao carregar áudio do Supabase: $e');
          }
          try {
            await audioPlayer.setSource(AssetSource('assets/audios/$soundUrl'));
            await audioPlayer.resume();
          } catch (e) {
            if (kDebugMode) {
              throw Exception('Erro ao carregar áudio local: $e');
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Áudio não disponível para $title.'),
              ),
            );
          }
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Áudio não disponível para $title.'),
                    ),
                  );
              }
            },
          ),
        ],
      ),
    );
  }
}
