import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DeleteCard extends StatefulWidget {
  @override
  _DeleteCardState createState() => _DeleteCardState();
}

class _DeleteCardState extends State<DeleteCard> {
  String? _selectedCategory;
  String? _selectedCard;
  bool _isLoading = false;
  List<String> _categories = [];
  List<String> _cards = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final response = await Supabase.instance.client
        .from('cards')
        .select('title')
        .order('title');
    
    setState(() {
      _categories = (response as List).map((item) => item['title'] as String).toList();
    });
  }

  Future<void> _loadCards() async {
    if (_selectedCategory == null) return;

    final categoryResponse = await Supabase.instance.client
        .from('cards')
        .select('id')
        .eq('title', _selectedCategory as Object)
        .single();

    final int categoryId = categoryResponse['id'];
    final cardsResponse = await Supabase.instance.client
        .from('cards_internos')
        .select('name')
        .eq('category_id', categoryId)
        .order('name');

    setState(() {
      _cards = (cardsResponse as List).map((item) => item['name'] as String).toList();
      _selectedCard = null;
    });
    }

  Future<void> _deletarCartao() async {
    if (_selectedCategory == null || _selectedCard == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, selecione uma categoria e um cartão.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final categoriaResponse = await Supabase.instance.client
          .from('cards')
          .select('id')
          .eq('title', _selectedCategory as Object)
          .single();

      final int categoriaId = categoriaResponse['id'];

      final deleteResponse = await Supabase.instance.client
          .from('cards_internos')
          .delete()
          .eq('category_id', categoriaId)
          .eq('name', _selectedCard as Object);

      if (deleteResponse.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(deleteResponse.error!.message)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cartão deletado com sucesso!')),
        );
        setState(() {
          _selectedCategory = null;
          _selectedCard = null;
        });
        _loadCategories();
      }
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
                    backgroundColor: Colors.blue,
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
                          color: Colors.white,
                        ),
                  label: const Text(
                    'Deletar',
                    style: TextStyle(
                      color: Colors.white,
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
