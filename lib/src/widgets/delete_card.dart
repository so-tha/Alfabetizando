import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DeleteCard extends StatefulWidget {
  final Box box;
  
  const DeleteCard({
    Key? key,
    required this.box,
  }) : super(key: key);

  @override
  _DeleteCardState createState() => _DeleteCardState();
}

class _DeleteCardState extends State<DeleteCard> {
  String? _selectedCategory;
  String? _selectedCard;
  bool _isLoading = false;
  List<String> _categories = [];
  List<String> _cards = [];
  late Box _box;
  @override
  void initState() {
    super.initState();
    _initHive();
    _loadCategories();
  }

  Future<void> _initHive() async {
    try {
      final appDocumentDirectory = await getApplicationDocumentsDirectory();
      await Hive.initFlutter(appDocumentDirectory.path);
      _box = widget.box;
    } catch (e) {
      if (mounted) {  // Verificar se o widget ainda está montado
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao inicializar o banco de dados: $e')),
        );
      }
    }
  }

  Future<void> _loadCategories() async {
    final cachedCategories = _box.get('categories');
    if (cachedCategories != null) {
      setState(() {
        _categories = List<String>.from(cachedCategories);
      });
      return;
    }

    try {
      final response = await Supabase.instance.client
          .from('cards')
          .select('title')
          .order('title');

      setState(() {
        _categories = (response as List).map((item) => item['title'].toString()).toList();
        _box.put('categories', _categories);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar categorias: $e')),
      );
    }
  }

  Future<void> _loadCards() async {
    if (_selectedCategory == null) return;

    try {
      final cachedCards = _box.get(_selectedCategory);

      if (cachedCards != null) {
        setState(() {
          _cards = List<String>.from(cachedCards);
          _selectedCard = null;
        });
        return;
      }

      final categoryResponse = await Supabase.instance.client
          .from('cards')
          .select('id')
          .eq('title', _selectedCategory!)
          .single();

      final int categoryId = categoryResponse['id'];

      final cardsResponse = await Supabase.instance.client
          .from('cards_internos')
          .select('name')
          .eq('category_id', categoryId)
          .order('name');

      setState(() {
        _cards = (cardsResponse as List).map((item) => item['name'] as String).toList();
        _box.put(_selectedCategory, _cards);
        _selectedCard = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar cartões: $e')),
      );
    }
  }

  Future<void> _deletarCartao() async {
    if (_selectedCategory == null || _selectedCard == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione uma categoria e um cartão.')),
      );
      return;
    }

    try {
      final confirmDelete = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirmar exclusão'),
            content: Text('Você tem certeza de que deseja excluir o cartão "$_selectedCard"?'),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Color.fromRGBO(51, 65, 222, 1),
                  foregroundColor: Colors.white,
                ),
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Sim'),
              ),
            ],
          );
        },
      );

      if (confirmDelete != true) return;

      setState(() {
        _isLoading = true;
      });

      final categoriaResponse = await Supabase.instance.client
          .from('cards')
          .select('id')
          .eq('title', _selectedCategory!)
          .single();

      final int categoriaId = categoriaResponse['id'];

      final deleteResponse = await Supabase.instance.client
          .from('cards_internos')
          .delete()
          .eq('category_id', categoriaId)
          .eq('name', _selectedCard!);

      if (deleteResponse.error != null) {
        throw Exception(deleteResponse.error!.message);
      }

      _cards.remove(_selectedCard);
      _box.put(_selectedCategory, _cards);

      setState(() {
        _selectedCard = null;
        _cards = _cards.where((card) => card != _selectedCard).toList();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cartão deletado com sucesso!')),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ocorreu um erro: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cartões'),
        backgroundColor: Colors.orange.shade200,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Deletar cartão',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              const Text('Selecione a categoria'),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                    _selectedCard = null;
                  });
                  _loadCards();
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.orange.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Selecione o cartão que deseja deletar'),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedCard,
                items: _cards.map((String card) {
                  return DropdownMenuItem<String>(
                    value: card,
                    child: Text(card),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCard = newValue;
                  });
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.orange.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _deletarCartao,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(79, 79, 79, 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 16,
                    ),
                  ),
                  icon: _isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                  label: const Text(
                    'Deletar',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
