import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static const String projectId = 'mausam-499db';
  static const String projectNumber = '1038194487991';

  static const Map<String, dynamic> web = {
    'apiKey': 'AIzaSyA_D8EhxYsPbZMKJ6HJ_I5qdwBVVkwrgpY',
    'appId': '1:1038194487991:web:2ee477a61b5b2d5ec19332',
    'messagingSenderId': '1038194487991',
    'projectId': 'mausam-499db',
    'authDomain': 'mausam-499db.firebaseapp.com',
    'storageBucket': 'mausam-499db.firebasestorage.app',
    'measurementId': 'G-ZP3ZJM4N9H',
  };

  static const Map<String, dynamic> android = {
    'apiKey': 'AIzaSyDvaeUSQJx6yfvHlSDr9_5mrCntgRKgCyY',
    'appId': '1:1038194487991:android:fc7cf78ab84112afc19332',
    'messagingSenderId': '1038194487991',
    'projectId': 'mausam-499db',
    'storageBucket': 'mausam-499db.firebasestorage.app',
  };
}
