import 'package:flutter/material.dart';

class CardDetailPage extends StatelessWidget {
  final String title;
  final String imageUrl;

  const CardDetailPage({
    super.key,
    required this.title,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
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
                    image: AssetImage(imageUrl),
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
              Text(
                title,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _splitSyllables(title), 
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
