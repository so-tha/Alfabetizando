import 'package:alfabetizando_tcc/src/ui/custom_fontDialog.dart';
import 'package:flutter/material.dart';

class StandardSize extends StatefulWidget {
  const StandardSize({super.key});

  @override
  _StandardSizeState createState() => _StandardSizeState();
}

class _StandardSizeState extends State<StandardSize> {
  bool _dialogShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showFontDialog(context);
    });
  }

  void _showFontDialog(BuildContext context) {
    if (!_dialogShown) {
      _dialogShown = true;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const FontSizeDialog();
        },
      ).then((_) {
        _dialogShown = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade200,
      body: Center(
        child: Text(
          'Bem-vindo ao Aplicativo!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
