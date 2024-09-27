import 'package:flutter/material.dart';
import 'dart:math';

class MathPopup extends StatefulWidget {
  final Function(bool) onCorrectAnswer;

  const MathPopup({required this.onCorrectAnswer});

  @override
  _MathPopupState createState() => _MathPopupState();
}

class _MathPopupState extends State<MathPopup> {
  late int num1;
  late int num2;
  final TextEditingController _answerController = TextEditingController();
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _generateMathProblem();
  }

  void _generateMathProblem() {
    final random = Random();
    num1 = random.nextInt(20) + 1;
    num2 = random.nextInt(20) + 1;
  }

  void _checkAnswer() {
    int correctAnswer = num1 * num2;
    if (int.tryParse(_answerController.text) == correctAnswer) {
      widget.onCorrectAnswer(true);
    } else {
      setState(() {
        _errorMessage = 'Resposta incorreta. Tente novamente!';
      });
      _generateMathProblem(); // Gera outra conta se errar
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Resolva a seguinte operação:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              'Quanto é $num1 x $num2?',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _answerController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Sua resposta',
                errorText: _errorMessage,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _checkAnswer,
              child: const Text('Entrar'),
            ),
          ],
        ),
      ),
    );
  }
}
