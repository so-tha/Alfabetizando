import 'package:flutter/material.dart';

class CardconfigScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cartões'),
        backgroundColor: Colors.orange.shade200,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.orange.shade200,
            padding: const EdgeInsets.all(16.0),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: Container(
                  color: Colors.pink.shade50,
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 16),
                      ListTile(
                        title: Text('Adicionar novo cartão'),
                        onTap: () {},
                      ),
                      ListTile(
                        title: Text('Alterar cartão'),
                        onTap: () {},
                      ),
                      ListTile(
                        title: Text('Excluir cartão'),
                        onTap: () {},
                      ),
                      Spacer(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
