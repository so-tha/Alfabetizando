import 'package:alfabetizando_tcc/src/services/card_service.dart';
import 'package:alfabetizando_tcc/src/widgets/alter_card.dart';
import 'package:alfabetizando_tcc/src/widgets/add_card.dart';
import 'package:alfabetizando_tcc/src/widgets/delete_card.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';


class CardconfigScreen extends StatelessWidget {
  const CardconfigScreen({super.key});

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
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AddCardWithAudio(cardService: CardService())),
                          );
                        },
                      ),
                      ListTile(
                        title: Text('Alterar cartão'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AlterCard()),
                          );
                        },
                      ),
                      ListTile(
                        title: Text('Excluir cartão'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DeleteCard(
                                  box: Hive.box('MyCacheBox'),
                                ),
                          ));
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
