import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter/foundation.dart';

class VoiceService {
  final SpeechToText _speech = SpeechToText();
  bool _isAvailable = false;

  Future<bool> init() async {
    _isAvailable = await _speech.initialize(
      onStatus: (status) => debugPrint('Voice Status: $status'),
      onError: (error) => debugPrint('Voice Error: $error'),
    );
    return _isAvailable;
  }

  Future<void> startListening(Function(String) onResult) async {
    if (!_isAvailable) await init();
    
    await _speech.listen(
      onResult: (result) {
        if (result.finalResult) {
          onResult(result.recognizedWords);
        }
      },
      localeId: 'ta_IN', // Tamil (India)
    );
  }

  Future<void> stopListening() async {
    await _speech.stop();
  }

  /// Simple command matcher for Tamil
  /// Example: "தக்காளி விலை" (Tomato price)
  String? processCommand(String text) {
    final lowerText = text.toLowerCase();
    
    if (lowerText.contains('தக்காளி') || lowerText.contains('tomato')) {
      return 'tomato_id'; // Placeholder for real ID
    }
    if (lowerText.contains('வெங்காயம்') || lowerText.contains('onion')) {
      return 'onion_id';
    }
    if (lowerText.contains('அரிசி') || lowerText.contains('rice')) {
      return 'rice_id';
    }
    
    return null;
  }
}
