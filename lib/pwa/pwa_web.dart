import 'dart:js_interop';

@JS('erthCanInstall')
external bool _canInstall();
@JS('erthIsStandalone')
external bool _isStandalone();
@JS('erthIsIOS')
external bool _isIOS();
@JS('erthSpeak')
external bool _speak(String text, String lang, String persona);
@JS('erthStopAudio')
external void _stopAudio();
@JS('erthPreloadVoices')
external void _preloadVoices();
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

// ── Guide voice (window.erthSpeak; silent stub until ElevenLabs) ──
bool ttsIsSpeaking() => _safe(() => _isSpeaking());

/// Returns true when the JS backend started playback. Call from a tap
/// handler so mobile browsers treat the audio as user-initiated.
bool ttsSpeak(String text, {required String lang, required String persona}) =>
    _safe(() => _speak(text, lang, persona));

void ttsStop() {
  try {
    _stopAudio();
  } catch (_) {}
}

/// Warms the welcome MP3s into memory (idle time) before the first tap.
void ttsPreload() {
  try {
    _preloadVoices();
  } catch (_) {}
}
