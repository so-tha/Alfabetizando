import 'package:flutter/material.dart';

class DeleteRecord extends StatelessWidget {
  const DeleteRecord({super.key});

  void _showDeleteConfirmation(BuildContext context, String recordingName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Apagar Gravação'),
          content: Text('Você tem certeza que deseja apagar "$recordingName"?'),
          actions: [
            TextButton.icon(
              icon: Icon(Icons.close, color: Colors.red),
              label: const Text('Não'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton.icon(
              icon: Icon(Icons.check, color: Colors.green),
              label: const Text('Sim'),
              onPressed: () {
              
                Navigator.of(context).pop(); 
                
                
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Áudio e Voz'),
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
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Apagar Gravação',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Selecione a gravação que deseja deletar',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        title: const Text('Voz da Mamãe'),
                        onTap: () {
                          _showDeleteConfirmation(context, 'Voz da Mamãe');
                        },
                      ),
                      ListTile(
                        title: const Text('Voz padrão masculina'),
                        onTap: () {
                          _showDeleteConfirmation(context, 'Voz padrão masculina');
                        },
                      ),
                      ListTile(
                        title: const Text('Voz padrão feminina'),
                        onTap: () {
                          _showDeleteConfirmation(context, 'Voz padrão feminina');
                        },
                      ),
                      const Spacer(),
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
