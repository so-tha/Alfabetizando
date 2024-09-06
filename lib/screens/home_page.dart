import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../data/cards.dart';
import 'package:hive/hive.dart';

class HomePage extends StatefulWidget {
  final Box box;
  const HomePage({required this.box});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? userName;
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool _isDrawerOpen = false;
  bool _isLoading = false;
  late Future<List<Category>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadUserData();
    _categoriesFuture = fetchCategories();
  }

  void _loadData() async {
    var cachedCategories = widget.box.get('categories');

    if(cachedCategories != null){
      setState(() {
        _categoriesFuture = Future.value(cachedCategories);
      });
    } else{
      _categoriesFuture = fetchCategories().then((categories){
        widget.box.put('categories', categories);
        return categories;
      });
    }

  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    final session = Supabase.instance.client.auth.currentSession;

    if (session != null) {
      final user = session.user;
      final userMetadata = user.userMetadata;

      setState(() {
        userName = userMetadata?['child_name'];
      });
  
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao selecionar a imagem.')),
      );
    }
  }

  void _toggleDrawer() {
    setState(() {
      _isDrawerOpen = !_isDrawerOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); 
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: _toggleDrawer,
          ),
        ],
      ),
      body: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(60.0), 
            child: Container(
              decoration: const BoxDecoration(
                color: Color.fromRGBO(255, 246, 244, 1.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              GestureDetector(
                                onTap: _pickImage,
                                child: CircleAvatar(
                                  radius: 20,
                                  backgroundImage: _image != null
                                      ? FileImage(_image!)
                                      : const AssetImage('lib/assets/images/icon.jpg')
                                          as ImageProvider,
                                  child: _image == null
                                      ? const Icon(Icons.add_a_photo, size: 20)
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Text('Olá, ${userName ?? 'Otávio'}',
                                  style: GoogleFonts.nunito(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  )),
                            ],
                          ),
                          Text(
                            'Vamos Aprender?',
                            style: GoogleFonts.nunito(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Escolha uma categoria',
                            style: GoogleFonts.nunito(
                              fontSize: 16,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          Expanded(
                            child: FutureBuilder<List<Category>>(
                              future: _categoriesFuture, 
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                } else if (snapshot.hasError) {
                                  return Center(
                                      child: Text('Erro: ${snapshot.error}'));
                                } else if (!snapshot.hasData ||
                                    snapshot.data!.isEmpty) {
                                  return const Center(
                                      child: Text('Nenhuma categoria encontrada.'));
                                } else {
                                  final categories = snapshot.data!;
                                  return GridView.builder(
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 16,
                                      mainAxisSpacing: 16,
                                      childAspectRatio: 1.0,
                                    ),
                                    itemCount: categories.length,
                                    itemBuilder: (context, index) {
                                      final category = categories[index];
                                      return CategoryCard(
                                        title: category.title,
                                        imageUrl: category.imageUrl,
                                      );
                                    },
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
          if (_isDrawerOpen)
            GestureDetector(
              onTap: _toggleDrawer,
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(),
                ),
              ),
            ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            right: _isDrawerOpen ? 0 : -300, 
            top: 0,
            bottom: 0,
            child: Material(
              elevation: 5,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(60.0),
                bottomLeft: Radius.circular(60.0),
              ),
              child: Container(
                width: 300,
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      color: Colors.orange,
                      padding: const EdgeInsets.all(16.0),
                      child: const Text(
                        'Configurações',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text('Áudio e voz'),
                      onTap: () {
                       
                      },
                    ),
                    ListTile(
                      title: const Text('Fontes'),
                      onTap: () {
                        
                      },
                    ),
                    ListTile(
                      title: const Text('Cartões'),
                      onTap: () {
                        
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final String title;
  final String imageUrl;

  const CategoryCard({
    super.key,
    required this.title,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
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
          height: 100,
          width: double.infinity,
        ),
        const SizedBox(height: 8), 
        Text(
          title,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
