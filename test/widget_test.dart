import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:th3_fashion/firebase_options.dart';
import 'package:th3_fashion/main.dart';

void main() {
  setUpAll(() async {
    setupFirebaseCoreMocks();
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } on FirebaseException catch (e) {
      if (e.code != 'duplicate-app') {
        rethrow;
      }
    }
  });

  testWidgets('App builds smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const FashionStoreApp());
    await tester.pump();

    expect(find.byType(FashionStoreApp), findsOneWidget);
  });
}
