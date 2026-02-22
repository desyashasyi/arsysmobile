import 'package:flutter/foundation.dart' show kIsWeb;

String getBaseUrl() {
  if (kIsWeb) {
    // Running on the web (local development)
    return 'http://127.0.0.1:8000/api';
  } else {
    // Running on a mobile device
    return 'http://192.168.100.26:8000/api';
  }
}
