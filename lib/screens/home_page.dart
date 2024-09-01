import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
 
  final List<String> categories = [
    "Animais",
    "Brinquedos",
    "Escola",
    "Família",
    "Família",
    "Família",
  ];

  final List<String> imageUrls = [
    "https://via.placeholder.com/138x71", // Placeholder para "Animais"
    "https://via.placeholder.com/138x71", // Placeholder para "Brinquedos"
    "https://via.placeholder.com/138x71", // Placeholder para "Escola"
    "https://via.placeholder.com/138x71", // Placeholder para "Família"
    "https://via.placeholder.com/138x71", // Placeholder para "Família"
    "https://via.placeholder.com/138x71", // Placeholder para "Família"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vamos aprender?'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 2.0,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            return CategoryCard(
              title: categories[index],
              imageUrl: imageUrls[index],
            );
          },
        ),
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final String title;
  final String imageUrl;

  const CategoryCard({
    Key? key,
    required this.title,
    required this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ShapeDecoration(
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0xFFE4E4E4),
            blurRadius: 4,
            offset: Offset(2, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Center(
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                blurRadius: 6.0,
                color: Colors.black,
                offset: Offset(2, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
