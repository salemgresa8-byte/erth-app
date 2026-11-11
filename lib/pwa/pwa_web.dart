import 'dart:js_interop';

@JS('erthCanInstall')
external bool _canInstall();
@JS('erthIsStandalone')
external bool _isStandalone();
@JS('erthIsIOS')
external bool _isIOS();
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
