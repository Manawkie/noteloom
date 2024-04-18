// class for caching retrieved data

import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class CachedData {
  static const key = "note-loom";
  static var cache = CacheManager(Config(key,
      maxNrOfCacheObjects: 10, stalePeriod: const Duration(days: 7)));
  final cachelist = [];

  static Future<Uint8List?> getCachedFile(String filePath) async {
    FileInfo? file = await cache.getFileFromCache(filePath);

    return file?.file.readAsBytes();
  }

  static Future setCachedFile(String filePath, Uint8List bytes) async {
  await cache.putFile(filePath, bytes);

    if (kDebugMode) {
      print("Set Successful: $filePath");
    }
  }
}
