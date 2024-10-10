import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioRecorder extends StatefulWidget {
  final Function(String) onAudioRecorded;

  const AudioRecorder({Key? key, required this.onAudioRecorded}) : super(key: key);

  @override
  _AudioRecorderState createState() => _AudioRecorderState();
}

class _AudioRecorderState extends State<AudioRecorder> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool isRecording = false;
  String? _audioPath;

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
    final tempDir = Directory.systemTemp;
    final filePath = '${tempDir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.aac';
    await _recorder.startRecorder(toFile: filePath);
    _audioPath = filePath;
  }

  Future<void> _stopRecording() async {
    final path = await _recorder.stopRecorder();
    setState(() {
      isRecording = false;
      _audioPath = path;
    });
    widget.onAudioRecorded(path!);  
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: _startRecording,
      onLongPressUp: _stopRecording,
      child: Container(
        width: 90,
        height: 97,
        decoration: BoxDecoration(
          color: isRecording ? Colors.redAccent : Colors.orange.shade200,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Center(
          child: Icon(
            Icons.mic,
            color: isRecording ? Colors.white : Colors.black,
            size: 48.0,
          ),
        ),
      ),
    );
  }
}
