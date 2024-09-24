import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/categories.dart';
import 'package:hive/hive.dart';

import '../ui/custom_drawer.dart';

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

    if (cachedCategories != null) {
      setState(() {
        _categoriesFuture = Future.value(cachedCategories);
      });
    } else {
      _categoriesFuture = fetchCategories().then((categories) {
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
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(_isDrawerOpen ? Icons.close : Icons.menu),
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
                                      : const AssetImage(
                                              'lib/assets/images/icon.jpg')
                                          as ImageProvider,
                                  child: _image == null
                                      ? const Icon(Icons.add_a_photo, size: 20)
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Text(
                                  userName != null
                                      ? 'Bem-vindo(a), $userName'
                                      : 'Bem-vindo(a)',
                                  style: GoogleFonts.nunito(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  )),
                            ],
                          ),
                          Text(
                            'Vamos aprender? Escolha uma categoria.',
                            style: GoogleFonts.nunito(
                              fontSize: 20,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          Expanded(
                            child: FutureBuilder<List<Category>>(
                              future: _categoriesFuture,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                } else if (snapshot.hasError) {
                                  return Center(
                                      child: Text('Erro: ${snapshot.error}'));
                                } else if (!snapshot.hasData ||
                                    snapshot.data!.isEmpty) {
                                  WidgetsBinding.instance
                                      .addPostFrameCallback((_) {
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
                                                SizedBox(height: 16),
                                                Text(
                                                  'Parece que nenhuma categoria foi encontrada, chame seu responsável!',
                                                  style: GoogleFonts.nunito(
                                                      fontSize: 18),
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
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              )
                                            ],
                                          );
                                        });
                                  });
                                  return const SizedBox.shrink();
                                } else {
                                  final categories = snapshot.data!;
                                  return GridView.builder(
                                    padding: const EdgeInsets.all(10),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 10,
                                      childAspectRatio: 2,
                                    ),
                                    itemCount: categories.length,
                                    itemBuilder: (context, index) {
                                      final category = categories[index];
                                      return InkWell(
                                        onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const CategoryCard(
                                              title: '',
                                              imageUrl: '',
                                            ),
                                          ),
                                        ),
                                        child: CategoryCard(
                                            title: category.title,
                                            imageUrl: category.imageUrl),
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
          CustomDrawer(isDrawerOpen: _isDrawerOpen, toggleDrawer: _toggleDrawer),
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
          title,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
