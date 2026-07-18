import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/api_client.dart';
import '../../../core/services/connectivity_service.dart';
import '../data/default_hazard_videos.dart';
import '../models/hazard_video.dart';

final hazardVideosProvider = FutureProvider<List<HazardVideo>>((ref) async {
  final connectivity = ref.watch(connectivityProvider);
  if (connectivity == ConnectivityStatus.isDisconnected) {
    return defaultHazardVideos;
  }

  try {
    final api = ref.watch(apiClientProvider);
    final response = await api.get('/content/hazard-videos');
    final data = response.data;
    List<dynamic> list;
    if (data is List) {
      list = data;
    } else if (data is Map) {
      list = data['data'] ?? data['items'] ?? [];
    } else {
      return defaultHazardVideos;
    }
    if (list.isEmpty) return defaultHazardVideos;
    return list
        .map((e) => HazardVideo.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  } catch (_) {
    return defaultHazardVideos;
  }
});
