// Non-web fallback: installation is a browser feature, so nothing to do.
bool pwaCanInstall() => false;
bool pwaIsStandalone() => false;
bool pwaIsIOS() => false;
Future<String> pwaInstall() async => 'unavailable';

// Guide voice is web-only (window.erthSpeak).
bool ttsIsSpeaking() => false;
bool ttsSpeak(String text, {required String lang, required String persona}) =>
    false;
void ttsStop() {}
