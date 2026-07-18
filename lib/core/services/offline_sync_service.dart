import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/default_highway_code.dart';
import '../../features/signs/data/default_signs.dart';
import '../../features/theory/data/default_questions.dart';
import 'api_client.dart';
import 'connectivity_service.dart';
import 'hive_service.dart';

final offlineSyncServiceProvider = Provider<OfflineSyncService>((ref) {
  return OfflineSyncService(
    hiveService: ref.watch(hiveServiceProvider),
    apiClient: ref.watch(apiClientProvider),
    connectivity: ref.watch(connectivityProvider),
  );
});

/// Offline-first content sync: Hive → API → bundled defaults.
class OfflineSyncService {
  final HiveService _hive;
  final ApiClient _api;
  final ConnectivityStatus _connectivity;

  OfflineSyncService({
    required HiveService hiveService,
    required ApiClient apiClient,
    required ConnectivityStatus connectivity,
  })  : _hive = hiveService,
        _api = apiClient,
        _connectivity = connectivity;

  static const String questionsApiPath = '/content/questions';
  static const String roadSignsApiPath = '/content/road-signs';
  static const String highwayCodeApiPath = '/content/highway-code';

  bool get _isOnline => _connectivity == ConnectivityStatus.isConnected;

  /// Sync all content modules. Safe to call on every app launch.
  Future<SyncResult> syncAll() async {
    await _hive.init();

    final questions = await syncQuestions();
    final signs = await syncRoadSigns();
    final highway = await syncHighwayCode();

    if (questions.source != SyncSource.cache ||
        signs.source != SyncSource.cache ||
        highway.source != SyncSource.cache) {
      await _hive.setLastSyncAt(DateTime.now());
    }

    return SyncResult(
      questions: questions,
      roadSigns: signs,
      highwayCode: highway,
    );
  }

  Future<SyncModuleResult> syncQuestions() async {
    return _syncModule(
      boxName: HiveService.questionsBoxName,
      isSeeded: _hive.isQuestionsSeeded,
      markSeeded: _hive.setQuestionsSeeded,
      save: _hive.saveQuestions,
      read: _hive.getAllQuestions,
      apiPath: questionsApiPath,
      fallback: () => defaultTheoryQuestions,
      parseList: _parseListResponse,
    );
  }

  Future<SyncModuleResult> syncRoadSigns() async {
    return _syncModule(
      boxName: HiveService.roadSignsBoxName,
      isSeeded: _hive.isRoadSignsSeeded,
      markSeeded: _hive.setRoadSignsSeeded,
      save: _hive.saveRoadSigns,
      read: _hive.getAllRoadSigns,
      apiPath: roadSignsApiPath,
      fallback: () => defaultRoadSigns.map((s) => s.toJson()).toList(),
      parseList: _parseListResponse,
    );
  }

  Future<SyncModuleResult> syncHighwayCode() async {
    return _syncModule(
      boxName: HiveService.highwayCodeBoxName,
      isSeeded: _hive.isHighwayCodeSeeded,
      markSeeded: _hive.setHighwayCodeSeeded,
      save: _hive.saveHighwayCode,
      read: _hive.getAllHighwayCodeEntries,
      apiPath: highwayCodeApiPath,
      fallback: () => defaultHighwayCode,
      parseList: _parseListResponse,
    );
  }

  Future<SyncModuleResult> _syncModule({
    required String boxName,
    required bool Function() isSeeded,
    required Future<void> Function(bool) markSeeded,
    required Future<void> Function(List<Map<String, dynamic>>) save,
    required Future<List<Map<String, dynamic>>> Function() read,
    required String apiPath,
    required List<Map<String, dynamic>> Function() fallback,
    required List<Map<String, dynamic>> Function(dynamic) parseList,
  }) async {
    if (isSeeded()) {
      final cached = await read();
      if (cached.isNotEmpty) {
        return SyncModuleResult(
          source: SyncSource.cache,
          count: cached.length,
          boxName: boxName,
        );
      }
    }

    if (_isOnline) {
      try {
        final response = await _api.get(apiPath);
        final items = parseList(response.data);
        if (items.isNotEmpty) {
          await save(items);
          await markSeeded(true);
          debugPrint('[OfflineSync] $boxName synced from API (${items.length} items)');
          return SyncModuleResult(
            source: SyncSource.api,
            count: items.length,
            boxName: boxName,
          );
        }
      } catch (e) {
        debugPrint('[OfflineSync] API failed for $boxName: $e');
      }
    }

    final bundled = fallback();
    await save(bundled);
    await markSeeded(true);
    debugPrint('[OfflineSync] $boxName loaded from bundled defaults (${bundled.length} items)');
    return SyncModuleResult(
      source: SyncSource.bundled,
      count: bundled.length,
      boxName: boxName,
    );
  }

  List<Map<String, dynamic>> _parseListResponse(dynamic data) {
    if (data is List) {
      return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    if (data is Map) {
      final list = data['data'] ?? data['results'] ?? data['items'];
      if (list is List) {
        return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
    }
    return [];
  }
}

enum SyncSource { cache, api, bundled }

class SyncModuleResult {
  final SyncSource source;
  final int count;
  final String boxName;

  const SyncModuleResult({
    required this.source,
    required this.count,
    required this.boxName,
  });
}

class SyncResult {
  final SyncModuleResult questions;
  final SyncModuleResult roadSigns;
  final SyncModuleResult highwayCode;

  const SyncResult({
    required this.questions,
    required this.roadSigns,
    required this.highwayCode,
  });

  bool get isFullyOfflineReady =>
      questions.count > 0 && roadSigns.count > 0 && highwayCode.count > 0;
}
