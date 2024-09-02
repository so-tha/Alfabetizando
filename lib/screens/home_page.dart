import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? userName;
  String? userPhotoUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final session = Supabase.instance.client.auth.currentSession;

    if (session != null) {
      final user = session.user;
      final userMetadata = user.userMetadata;

      setState(() {
        userName = userMetadata?['full_name'] ?? user.email;
        userPhotoUrl = userMetadata?['avatar_url']; 
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vamos aprender?'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (userPhotoUrl != null)
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(userPhotoUrl!),
                  )
                else
                  const CircleAvatar(
                    radius: 20,
                    child: Icon(Icons.person),
                  ),
                const SizedBox(width: 8),
                Text(
                  'Olá, ${userName ?? 'usuário'}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            // Aqui vai o GridView com as categorias
            Expanded(
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
          ],
        ),
      ),
    );
  }

  final List<String> categories = [
    "Animais",
    "Brinquedos",
    "Escola",
    "Família",

  ];

  final List<String> imageUrls = [
    "assets/animais.png",
    "assets/brinquedos.png",
    "assets/categoria/escola.png",
  ];
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
          image: AssetImage(imageUrl),
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
