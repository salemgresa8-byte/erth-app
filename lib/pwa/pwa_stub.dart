// Non-web fallback: installation is a browser feature, so nothing to do.
bool pwaCanInstall() => false;
bool pwaIsStandalone() => false;
bool pwaIsIOS() => false;
Future<String> pwaInstall() async => 'unavailable';

// Text-to-speech is provided by the browser's Web Speech API only.
bool ttsSupported() => false;
bool ttsIsSpeaking() => false;
bool ttsSpeak(String text,
        {required String lang,
        required double pitch,
        required double rate,
        required bool male}) =>
    false;
void ttsStop() {}
