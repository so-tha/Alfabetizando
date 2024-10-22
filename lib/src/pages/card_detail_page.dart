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
    Key? key,
    required this.title,
    required this.imageUrl,
    required this.soundUrl,
  }) : super(key: key);

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
                    style: const TextStyle(
                      fontSize: 28,
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
                                    'Áudio não disponível para ${widget.title}.'),
                              ),
                            );
                          }
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Áudio não disponível para ${widget.title}.'),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                _splitSyllables(widget.title), 
                style: const TextStyle(
                  fontSize: 22,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _splitSyllables(String word) {
    if (word.toLowerCase() == "gato") {
      return "Ga-to";
    }
    if (word.toLowerCase() == "cachorro") {
      return "Ca-cho-rro";
    }
    if (word.toLowerCase() == "cavalo") {
      return "Ca-va-lo";
    }
    if (word.toLowerCase() == "tartaruga") {
      return "Tar-ta-ru-ga";
    }
    if (word.toLowerCase() == "banana") {
      return "Ba-na-na";
    }
    return word;
  }
}
