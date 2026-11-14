{{flutter_js}}
{{flutter_build_config}}

// No service worker: Flutter's SW is deprecated and kept serving stale/broken
// cached builds after deploys. index.html also unregisters any old one.
_flutter.loader.load();
