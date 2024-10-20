import 'package:alfabetizando_tcc/src/pages/intern_cards.dart';
import 'package:alfabetizando_tcc/src/widgets/math_poup.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../models/categories.dart';
import 'package:hive/hive.dart';
import '../ui/custom_category_card.dart';
import '../providers/user_provider.dart';
import '../ui/custom_drawer.dart';

class HomePage extends StatefulWidget {
  final Box box;
  const HomePage({super.key, required this.box});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final bool _isLoading = false;
  late Future<List<Category>> _categoriesFuture;
  bool _isDrawerOpen = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadData();
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

  void _showMathPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return MathPopup(
          onCorrectAnswer: (isCorrect) {
            if (isCorrect) {
              Navigator.of(context).pop();
              _toggleDrawer();
            } else {
              // Exibir mensagem de erro no popup
            }
          },
        );
      },
    );
  }

  void _toggleDrawer() {
    setState(() {
      _isDrawerOpen = !_isDrawerOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final user = userProvider.user;
        final userName = user.name ?? '';
        final userPhotoUrl = user.photoUrl;
        final userFont = user.font ?? 'Nunito';

        return Theme(
          data: Theme.of(context).copyWith(
            textTheme: GoogleFonts.getTextTheme(userFont),
          ),
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: Icon(_isDrawerOpen ? Icons.close : Icons.menu),
                  onPressed: _showMathPopup,
                ),
              ],
              backgroundColor: const Color.fromRGBO(255, 203, 124, 1),
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
                                        backgroundImage: userPhotoUrl != null
                                            ? CachedNetworkImageProvider(userPhotoUrl)
                                            : const AssetImage('lib/assets/images/icon.jpg') as ImageProvider,
                                        child: userPhotoUrl != null
                                            ? const Icon(Icons.add_a_photo, size: 20)
                                            : null,
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    Text(
                                      userName.isNotEmpty
                                          ? 'Bem-vindo(a), $userName'
                                          : 'Bem-vindo(a)',
                                      style: GoogleFonts.nunito(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
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
                                                    Image.asset('lib/assets/logs/logOpsAlgoDeuErrado-Photoroom.png'),
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
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        });
                                        return const SizedBox.shrink();
                                      } else {
                                        final categories = snapshot.data!;
                                        return GridView.builder(
                                          padding: const EdgeInsets.all(10),
                                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2,
                                            crossAxisSpacing: 10,
                                            mainAxisSpacing: 10,
                                            childAspectRatio: 1.5,
                                          ),
                                          itemCount: categories.length,
                                          itemBuilder: (context, index) {
                                            final category = categories[index];
                                            return InkWell(
                                              onTap: () => Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => CardsInternosPage(
                                                    box: widget.box,
                                                    categoryId: category.id,
                                                    categoryName: category.title,
                                                  ),
                                                ),
                                              ),
                                              child: CategoryCard(
                                                title: category.title,
                                                imageUrl: category.imageUrl,
                                                categoryId: category.id,
                                                categoryName: category.title,
                                              ),
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
                  CustomDrawer(
                    isDrawerOpen: _isDrawerOpen,
                    toggleDrawer: _toggleDrawer,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        final fileExt = pickedFile.path.split('.').last;
        final fileName = '${DateTime.now().toIso8601String()}.$fileExt';
        final filePath = fileName;

        await Supabase.instance.client.storage.from('avatars').uploadBinary(
          filePath,
          bytes,
          fileOptions: FileOptions(contentType: pickedFile.mimeType),
        );

        final imageUrl = Supabase.instance.client.storage.from('avatars').getPublicUrl(filePath);

        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await userProvider.updateUser(photoUrl: imageUrl);

        setState(() {});
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao selecionar a imagem.')),
      );
    }
  }
}
