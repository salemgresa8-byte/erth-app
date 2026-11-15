import 'dart:js_interop';

@JS('erthCanInstall')
external bool _canInstall();
@JS('erthIsStandalone')
external bool _isStandalone();
@JS('erthIsIOS')
external bool _isIOS();
@JS('erthTtsSupported')
external bool _ttsSupported();
@JS('erthSpeak')
external bool _speak(String text, String lang, double pitch, double rate, bool male);
@JS('erthStopSpeak')
external void _stopSpeak();
@JS('erthIsSpeaking')
external bool _isSpeaking();
@JS('erthInstall')
external JSPromise<JSString> _install();

bool _safe(bool Function() f) {
  try {
    return f();
  } catch (_) {
    return false;
  }
}

bool pwaCanInstall() => _safe(() => _canInstall());
bool pwaIsStandalone() => _safe(() => _isStandalone());
bool pwaIsIOS() => _safe(() => _isIOS());

/// Returns "accepted", "dismissed" or "unavailable".
Future<String> pwaInstall() async {
  try {
    return (await _install().toDart).toDart;
  } catch (_) {
    return 'unavailable';
  }
}

// ── Text-to-speech (Web Speech API) ──
bool ttsSupported() => _safe(() => _ttsSupported());
bool ttsIsSpeaking() => _safe(() => _isSpeaking());
bool ttsSpeak(String text,
        {required String lang,
        required double pitch,
        required double rate,
        required bool male}) =>
    _safe(() => _speak(text, lang, pitch, rate, male));
void ttsStop() {
  try {
    _stopSpeak();
  } catch (_) {}
}
