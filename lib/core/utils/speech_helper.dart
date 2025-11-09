import 'dart:async';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechHelper {
  static final SpeechHelper _instance = SpeechHelper._internal();
  factory SpeechHelper() => _instance;
  SpeechHelper._internal();

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isInitialized = false;

  Future<bool> init() async {
    if (_isInitialized) return true;
    _isInitialized = await _speech.initialize();
    return _isInitialized;
  }

  /// Lắng nghe một lần với UI trực quan.
  /// Khi im 2 giây, popup tự đóng và trả về keyword đã nói.
  Future<String?> listenOnceWithUI(BuildContext context) async {
    final available = await init();
    if (!available) return null;

    String? recognizedText;
    final isListening = ValueNotifier<bool>(true);
    final currentText = ValueNotifier<String>('');

    Timer? autoStopTimer;
    void resetAutoStopTimer() {
      autoStopTimer?.cancel();
      autoStopTimer = Timer(const Duration(seconds: 2), () async {
        if (isListening.value) {
          isListening.value = false;
          await _speech.stop();
          if (context.mounted) Navigator.of(context).pop();
        }
      });
    }

    await showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.black87,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        // Bắt đầu nghe
        _speech.listen(
          onResult: (res) async {
            currentText.value = res.recognizedWords;
            recognizedText = res.recognizedWords;

            // reset lại 2s mỗi lần user nói thêm
            resetAutoStopTimer();

            if (res.finalResult) {
              isListening.value = false;
              autoStopTimer?.cancel();
              await _speech.stop();
              if (ctx.mounted) Navigator.of(ctx).pop();
            }
          },
          localeId: 'vi_VN',
          listenMode: stt.ListenMode.confirmation,
        );

        // fallback: dừng sau 7s nếu không có input
        Future.delayed(const Duration(seconds: 7), () async {
          if (isListening.value) {
            isListening.value = false;
            autoStopTimer?.cancel();
            await _speech.stop();
            if (ctx.mounted) Navigator.of(ctx).pop();
          }
        });

        return ValueListenableBuilder<bool>(
          valueListenable: isListening,
          builder: (_, listening, __) {
            return SizedBox(
              height: 250,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: listening ? 80 : 60,
                      height: listening ? 80 : 60,
                      decoration: BoxDecoration(
                        color: listening ? Colors.redAccent : Colors.green,
                        shape: BoxShape.circle,
                        boxShadow: [
                          if (listening)
                            BoxShadow(
                              color: Colors.redAccent.withOpacity(0.5),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                        ],
                      ),
                      child: const Icon(
                        Icons.mic,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      listening ? "Đang nghe..." : "Hoàn tất",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ValueListenableBuilder<String>(
                      valueListenable: currentText,
                      builder: (_, text, __) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            text.isNotEmpty
                                ? text
                                : 'Hãy nói từ khóa tìm kiếm...',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontStyle: text.isEmpty
                                  ? FontStyle.italic
                                  : FontStyle.normal,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    if (listening)
                      TextButton(
                        onPressed: () async {
                          isListening.value = false;
                          autoStopTimer?.cancel();
                          await _speech.stop();
                          if (ctx.mounted) Navigator.of(ctx).pop();
                        },
                        child: const Text(
                          'Hủy',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    autoStopTimer?.cancel();
    return recognizedText?.trim().isEmpty ?? true ? null : recognizedText;
  }

  void stop() => _speech.stop();
}
