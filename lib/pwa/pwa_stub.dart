// Non-web fallback: installation is a browser feature, so nothing to do.
bool pwaCanInstall() => false;
bool pwaIsStandalone() => false;
bool pwaIsIOS() => false;
Future<String> pwaInstall() async => 'unavailable';
