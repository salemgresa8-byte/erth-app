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
external bool _speak(String text, String lang, String persona);
@JS('erthUnlockAudio')
external void _unlockAudio();
@JS('erthChime')
external void _chime(String persona);
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
/// Speaks via the JS 3-layer engine. Call directly from a tap handler so
/// mobile browsers treat it as user-initiated audio.
bool ttsSpeak(String text, {required String lang, required String persona}) =>
    _safe(() => _speak(text, lang, persona));

/// Unlocks speechSynthesis, the <audio> element and AudioContext (tap only).
void ttsUnlock() {
  try {
    _unlockAudio();
  } catch (_) {}
}

/// Short Web Audio lyre chord for the persona.
void ttsChime(String persona) {
  try {
    _chime(persona);
  } catch (_) {}
}

void ttsStop() {
  try {
    _stopSpeak();
  } catch (_) {}
}
