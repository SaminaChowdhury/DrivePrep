import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/hive_service.dart';
import '../../../core/services/offline_sync_service.dart';

class HighwayCodeEntry {
  final String id;
  final String section;
  final String title;
  final String content;
  final int order;

  const HighwayCodeEntry({
    required this.id,
    required this.section,
    required this.title,
    required this.content,
    required this.order,
  });

  factory HighwayCodeEntry.fromJson(Map<String, dynamic> json) {
    return HighwayCodeEntry(
      id: json['id'] as String,
      section: json['section'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      order: json['order'] as int? ?? 0,
    );
  }
}

final highwayCodeProvider = FutureProvider<List<HighwayCodeEntry>>((ref) async {
  final hive = ref.watch(hiveServiceProvider);
  final sync = ref.watch(offlineSyncServiceProvider);

  if (!hive.isHighwayCodeSeeded()) {
    await sync.syncHighwayCode();
  }

  final raw = await hive.getAllHighwayCodeEntries();
  return raw.map(HighwayCodeEntry.fromJson).toList();
});
