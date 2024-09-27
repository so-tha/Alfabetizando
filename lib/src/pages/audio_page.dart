import 'package:flutter/material.dart';

class AudioScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Audio e Voz'),
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
                        'Definir voz padrão',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Selecione a gravação que deseja utilizar',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 16),
                      ListTile(
                        title: Text('Voz da Mamãe'),
                        onTap: () {
                          
                        },
                      ),
                      ListTile(
                        title: Text('Voz padrão masculina'),
                        onTap: () {
                          
                        },
                      ),
                      ListTile(
                        title: Text('Voz padrão feminina'),
                        onTap: () {
                          
                        },
                      ),
                      ListTile(
                        title: Text('Adicionar nova voz'),
                        onTap: () {
                          
                        },
                      ),
                      Spacer(),
                      ListTile(
                        title: Text(
                          'Apagar gravação',
                          style: TextStyle(color: Colors.red),
                        ),
                        onTap: () {
                          
                        },
                      ),
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
