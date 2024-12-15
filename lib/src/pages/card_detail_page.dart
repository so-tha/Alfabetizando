import 'package:alfabetizando_tcc/src/models/intern.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart';
import '../providers/font_provider.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:supabase_flutter/supabase_flutter.dart';

class CardDetailPage extends StatefulWidget {
  final String title;
  final String imageUrl;
  final String soundUrl;
  final String word;

  const CardDetailPage({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.soundUrl,
    required this.word,
  });

  @override
  _CardDetailPageState createState() => _CardDetailPageState();
}

class _CardDetailPageState extends State<CardDetailPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final _supabase = Supabase.instance.client;

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<String?> fetchWordDefinition(String word) async {
    final url = 'https://dicionario.priberam.org/$word';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var document = html_parser.parse(response.body);

      var wordBlock = document.querySelector('span.titpalavra');

      if (wordBlock != null) {
        return wordBlock.text;
      } else {
        throw Exception('Bloco de palavra não encontrado.');
      }
    } else {
      throw Exception('Falha ao carregar a página: ${response.statusCode}');
    }
  }

  Future<String?> getWordDefinition(String word) async {
    // Verifica se já existe definição no card
    final response = await _supabase
        .from('cards_internos')
        .select('word_definition')
        .eq('word', word)
        .single();

    if (response['word_definition'] != null) {
      return response['word_definition'];
    }
    // Se não encontrou, busca online e atualiza o card
    try {
      final definition = await fetchWordDefinition(word);
      if (definition != null) {
        // Atualiza o card com a definição
        await _supabase
            .from('cards_internos')
            .update({'word_definition': definition})
            .eq('word', word);
        return definition;
      }
    } catch (e) {
      debugPrint('Erro ao buscar definição: $e');
    }
    return null;
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
              FutureBuilder<String?>(
                future: getWordDefinition(widget.word),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData) {
                    return Text(
                      '${snapshot.data}',
                      style: TextStyle(
                        fontSize: fontProvider.fontSize.toDouble(),
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    );
                  } else {
                    return Text(
                      'Nenhuma definição encontrada.',
                      style: TextStyle(
                        fontSize: fontProvider.fontSize.toDouble(),
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
