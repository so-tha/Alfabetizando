import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';

class AddRecord extends StatefulWidget {
  const AddRecord({super.key});

  @override
  _AddRecordState createState() => _AddRecordState();
}

class _AddRecordState extends State<AddRecord> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool isRecording = false;

  @override
  void initState() {
    super.initState();
    _initializeRecorder();
  }

  Future<void> _initializeRecorder() async {
    await _recorder.openRecorder();

    await Permission.microphone.request();
  }

  Future<void> _startRecording() async {
    setState(() {
      isRecording = true;
    });

    await _recorder.startRecorder(
      toFile: 'recording.aac',
    );
  }

  Future<void> _stopRecording() async {
    final path = await _recorder.stopRecorder();
    setState(() {
      isRecording = false;
    });

    _showAddConfirmation(context);
    print('Gravação salva em: $path');
  }

  void _showAddConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const AlertDialog(
          title: Text('Gravação salva com sucesso!!!'),
        );
      },
    );
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    super.dispose();
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
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Adicionar nova voz',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Mantenha pressionado o microfone e diga a palavra que deseja gravar, logo após solte.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Spacer(),
                      Center(
                        child: GestureDetector(
                          onLongPress: _startRecording,
                          onLongPressUp: _stopRecording,
                          child: Container(
                            width: 180,
                            height: 195,
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(255, 164, 27,
                                  1), 
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.mic,
                                color: isRecording ? const Color.fromARGB(255, 17, 17, 17) : Colors.white,
                                size: 48.0, 
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Spacer(),
                      Center(
                        child: TextButton.icon(
                          icon: const Icon(Icons.check, color: Colors.green),
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(
                              const Color.fromARGB(51, 1, 78, 222),
                            ),
                          ),
                          label: const Text('Salvar'),
                          onPressed: () {
                            _showAddConfirmation(context);
                          },
                        ),
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
