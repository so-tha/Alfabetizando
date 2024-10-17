import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DeleteCard extends StatefulWidget {
  @override
  _DeleteCardState createState() => _DeleteCardState();
}

class _DeleteCardState extends State<DeleteCard> {
  final TextEditingController _categoriaController = TextEditingController();
  final TextEditingController _cartaoController = TextEditingController();
  bool _isLoading = false;

  Future<void> _deletarCartao() async {
    final String categoria = _categoriaController.text.trim();
    final String cartao = _cartaoController.text.trim();

    if (categoria.isEmpty || cartao.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, preencha todos os campos.')),
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
          .eq('title', categoria)
          .single();

      if (categoriaResponse == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Categoria não encontrada.')),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final int categoriaId = categoriaResponse['id'];

      final deleteResponse = await Supabase.instance.client
          .from('cards_internos')
          .delete()
          .eq('category_id', categoriaId)
          .eq('name', cartao);

      if (deleteResponse.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(deleteResponse.error!.message)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cartão deletado com sucesso!')),
        );
        _categoriaController.clear();
        _cartaoController.clear();
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
              const Text('Informe a categoria'),
              const SizedBox(height: 10),
              TextFormField(
                controller: _categoriaController,
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
              const Text('Informe o cartão que deseja deletar'),
              const SizedBox(height: 10),
              TextFormField(
                controller: _cartaoController,
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
                  onPressed: _isLoading
                      ? null
                      : () {
                          _deletarCartao();
                        },
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
