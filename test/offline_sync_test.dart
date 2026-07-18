import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:drive_prep/core/data/default_highway_code.dart';
import 'package:drive_prep/core/services/hive_service.dart';
import 'package:drive_prep/features/signs/data/default_signs.dart';
import 'package:drive_prep/features/theory/data/default_questions.dart';

void main() {
  late HiveService hiveService;

  setUp(() async {
    final dir = await Directory.systemTemp.createTemp('drive_prep_offline_test');
    Hive.init(dir.path);
    hiveService = HiveService();
    await hiveService.init();
    await hiveService.clearBox(HiveService.questionsBoxName);
    await hiveService.clearBox(HiveService.roadSignsBoxName);
    await hiveService.clearBox(HiveService.highwayCodeBoxName);
    await hiveService.clearBox(HiveService.bookmarksBoxName);
    await hiveService.setQuestionsSeeded(false);
    await hiveService.setRoadSignsSeeded(false);
    await hiveService.setHighwayCodeSeeded(false);
  });

  test('questions box stores and retrieves offline data', () async {
    await hiveService.saveQuestions(defaultTheoryQuestions);
    final cached = await hiveService.getAllQuestions();

    expect(hiveService.isQuestionsSeeded(), isTrue);
    expect(cached.length, defaultTheoryQuestions.length);
    expect(cached.first['id'], defaultTheoryQuestions.first['id']);
  });

  test('road signs box stores and retrieves offline data', () async {
    final signs = defaultRoadSigns.map((s) => s.toJson()).toList();
    await hiveService.saveRoadSigns(signs);
    final cached = await hiveService.getAllRoadSigns();

    expect(hiveService.isRoadSignsSeeded(), isTrue);
    expect(cached.length, signs.length);
  });

  test('highway code box stores and retrieves offline data', () async {
    await hiveService.saveHighwayCode(defaultHighwayCode);
    final cached = await hiveService.getAllHighwayCodeEntries();

    expect(hiveService.isHighwayCodeSeeded(), isTrue);
    expect(cached.length, defaultHighwayCode.length);
    expect(cached.first['title'], defaultHighwayCode.first['title']);
  });

  test('bookmarks box is separate from progress box', () async {
    await hiveService.toggleBookmark('q_1');
    await hiveService.toggleBookmark('q_2');

    final bookmarks = await hiveService.getBookmarkedQuestionIds();
    expect(bookmarks, ['q_1', 'q_2']);

    await hiveService.recordAnswer('q_1', true);
    final history = await hiveService.getAnsweredQuestionsHistory();
    expect(history['q_1'], isTrue);
    expect(bookmarks.length, 2);
  });

  test('settings box tracks last sync timestamp', () async {
    final time = DateTime(2026, 6, 8, 12, 0);
    await hiveService.setLastSyncAt(time);
    expect(hiveService.getLastSyncAt(), time);
  });
}
