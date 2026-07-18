// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:drive_prep/core/services/hive_service.dart';
import 'package:drive_prep/main.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final dir = await Directory.systemTemp.createTemp('drive_prep_test');
    Hive.init(dir.path);
    await Hive.openBox<dynamic>(HiveService.settingsBoxName);
    await Hive.openBox<dynamic>(HiveService.questionsBoxName);
    await Hive.openBox<dynamic>(HiveService.roadSignsBoxName);
    await Hive.openBox<dynamic>(HiveService.highwayCodeBoxName);
    await Hive.openBox<dynamic>(HiveService.bookmarksBoxName);
    await Hive.openBox<dynamic>(HiveService.progressBoxName);
  });

  testWidgets('App initialization smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(),
      ),
    );

    expect(find.byType(MyApp), findsOneWidget);

    // Flush splash-screen timers so the test harness shuts down cleanly.
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });
}
