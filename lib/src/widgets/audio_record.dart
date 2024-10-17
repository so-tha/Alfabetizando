import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioRecorder extends StatefulWidget {
  final Function(String) onAudioRecorded;

  const AudioRecorder({super.key, required this.onAudioRecorded});

  @override
  _AudioRecorderState createState() => _AudioRecorderState();
}

class _AudioRecorderState extends State<AudioRecorder> {
  FlutterSoundRecorder? _recorder;
  bool isRecording = false;

  @override
  void initState() {
    super.initState();
    _initializeRecorder();
  }

  Future<void> _initializeRecorder() async {
    _recorder = FlutterSoundRecorder();
    await _recorder!.openRecorder();
    await Permission.microphone.request();
  }

  Future<void> _startRecording() async {
    if (_recorder?.isRecording ?? false) {
      if (kDebugMode) {
        print('Already recording!');
      }
      return;
    }

    try {
      setState(() {
        isRecording = true;
      });
      final tempDir = await Directory.systemTemp.create();
      final filePath = '${tempDir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.aac';
      await _recorder!.startRecorder(toFile: filePath);
    } catch (e) {
      if (kDebugMode) {
        print('Error starting recording: $e');
      }
      setState(() {
        isRecording = false;
      });
    }
  }

  Future<void> _stopRecording() async {
    if (!(_recorder?.isRecording ?? false)) {
      if (kDebugMode) {
        print('Not recording!');
      }
      return;
    }

    try {
      final path = await _recorder!.stopRecorder();
      setState(() {
        isRecording = false;
      });
      if (path != null) {
        widget.onAudioRecorded(path);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error stopping recording: $e');
      }
    }
  }

  @override
  void dispose() {
    _recorder?.closeRecorder();
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
