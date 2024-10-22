import 'package:alfabetizando_tcc/src/pages/intern_cards.dart';
import 'package:alfabetizando_tcc/src/providers/font_provider.dart';
import 'package:alfabetizando_tcc/src/widgets/math_poup.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
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
    final fontProvider = Provider.of<FontProvider>(context);

    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final user = userProvider.user;
        final userName = user?.name ?? '';
        final userPhotoUrl = user?.photoUrl;
        final userFont = user?.font ?? 'Nunito';
        return Theme(
          data: Theme.of(context).copyWith(
            textTheme: GoogleFonts.getTextTheme(userFont),
          ),
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                userName.isNotEmpty
                    ? 'Seja Bem-vindo(a), $userName'
                    : 'Seja Bem-vindo(a)',
                style: GoogleFonts.nunito(
                  fontSize: fontProvider.fontSize.toDouble(),
                  fontWeight: FontWeight.bold,
                ),
              ),
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
                      padding: const EdgeInsets.all(14.0),
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Vamos aprender? Escolha uma categoria.',
                                  style: GoogleFonts.nunito(
                                    fontSize: fontProvider.fontSize.toDouble(),
                                    fontWeight: FontWeight.w400,
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
                                                    fontSize: fontProvider.fontSize.toDouble(),
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                content: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Image.asset('lib/assets/logs/logOpsAlgoDeuErrado-Photoroom.png'),
                                                    const SizedBox(height: 16),
                                                    Text(
                                                      'Parece que nenhuma categoria foi encontrada, chame seu responsável ou tente reiniciar a sua internet.',
                                                      style: GoogleFonts.nunito(
                                                        fontSize: fontProvider.fontSize.toDouble(),
                                                        fontWeight: FontWeight.bold,
                                                      ),
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
                                                        fontSize: fontProvider.fontSize.toDouble(),
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
                                                soundUrl: category.soundUrl,
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
}
