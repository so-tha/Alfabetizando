import 'package:alfabetizando_tcc/src/models/intern.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart';
import '../providers/font_provider.dart';

class CardDetailPage extends StatefulWidget {
  final String title;
  final String imageUrl;
  final String soundUrl;

  const CardDetailPage({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.soundUrl,
  });

  @override
  _CardDetailPageState createState() => _CardDetailPageState();
}

class _CardDetailPageState extends State<CardDetailPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fontProvider = Provider.of<FontProvider>(context);
    String syllables = splitSyllables(widget.title);
    return Scaffold(
      appBar: AppBar(
        title: Text(capitalizeWords(widget.title)),
        backgroundColor: Colors.orange.shade200,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                decoration: ShapeDecoration(
                  image: DecorationImage(
                    image: AssetImage(widget.imageUrl),
                    fit: BoxFit.cover,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                height: 200,
                width: 200,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    capitalizeWords(widget.title),
                    style: TextStyle(
                      fontSize: fontProvider.fontSize.toDouble(),
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.volume_up),
                    color: Colors.black,
                    iconSize: 24.0,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () async {
                      if (widget.soundUrl.isNotEmpty) {
                        try {
                          final soundUrl =
                              'https://bqdmmkkmjblovfvefazq.supabase.co/storage/v1/object/public/audios/${widget.soundUrl}';
                          await _audioPlayer.setSourceUrl(soundUrl);
                          await _audioPlayer.resume();
                        } catch (e) {
                          try {
                            await _audioPlayer.setSource(AssetSource(
                                'assets/audios/${widget.soundUrl}'));
                            await _audioPlayer.resume();
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Essa não! Parece que não existe nenhum áudio disponível para ${widget.title}.'),
                              ),
                            );
                          }
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Essa não! Parece que não existe nenhum áudio disponível para ${widget.title}.'),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                splitSyllables(widget.title), 
                style: TextStyle(
                  fontSize: fontProvider.fontSize.toDouble(),
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

String splitSyllables(String word) {
  word = word.toLowerCase();
  List<String> syllables = [];

  final digraphs = ['ch', 'lh', 'nh', 'qu', 'gu', 'rr'];
  final vowels = 'aeiouáéíóúãõâêîôûàèìòù';
  final nasalDitongos = ['ão', 'õe', 'ãe'];

  String buffer = '';
  for (int i = 0; i < word.length; i++) {
    buffer += word[i];

    if (i + 1 < word.length && digraphs.contains(word.substring(i, i + 2))) {
      buffer += word[i + 1];
      i++;
    } 
    else if (i + 1 < word.length && nasalDitongos.contains(word.substring(i, i + 2))) {
      buffer += word[i + 1];
      i++;
    }
    else if (vowels.contains(word[i])) {
      syllables.add(buffer);
      buffer = '';
    }
  }

  if (buffer.isNotEmpty) {
    syllables.add(buffer);
  }

  return syllables.join('-');
  }
}
