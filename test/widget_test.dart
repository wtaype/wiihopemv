import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:wiihope/firebase_options.dart';
import 'package:wiihope/main.dart';

const _defaultAppName = '[DEFAULT]';

void setupFirebaseCoreMocks() {
  const channel = MethodChannel('plugins.flutter.io/firebase_core');
  TestWidgetsFlutterBinding.ensureInitialized();

  channel.setMockMethodCallHandler((call) async {
    switch (call.method) {
      case 'Firebase#initializeCore':
        return [
          {
            'name': _defaultAppName,
            'options': {
              'apiKey': 'test',
              'appId': '1:123:web:abc',
              'messagingSenderId': '123',
              'projectId': 'test-project',
              'storageBucket': 'test-bucket',
              'databaseURL': null,
              'measurementId': null,
            },
            'pluginConstants': {},
          },
        ];
      case 'Firebase#initializeApp':
        final args = call.arguments as Map<dynamic, dynamic>;
        return {
          'name': args['appName'],
          'options': args['options'],
          'pluginConstants': {},
        };
      default:
        return null;
    }
  });
}

void main() {
  setupFirebaseCoreMocks();

  setUpAll(() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  });

  testWidgets('App arranca sin excepciones', (tester) async {
    await tester.pumpWidget(const MiApp());
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
