import 'package:flutter/material.dart';

class FontDefineScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fonte'),
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
                      const Text(
                        'Reedefinir nova fonte',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Selecione ou adicione a fonte que deseja utilizar',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      //isso aqui vai vir da tabela de users preferences
                      SizedBox(height: 16),
                      ListTile(
                        title: Text('Fonte 1'),
                        onTap: () {},
                      ),
                      ListTile(
                        title: Text('Fonte 2'),
                        onTap: () {},
                      ),
                      ListTile(
                        title: Text('Fonte 3'),
                        onTap: () {},
                      ),
                      ListTile(
                        title: Text('Importar Fonte', style: TextStyle(color: const Color.fromARGB(255, 2, 2, 2)),),
                        onTap: () {

                        },
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
