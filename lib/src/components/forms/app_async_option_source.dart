import 'dart:async';

import 'app_option.dart';

typedef AppAsyncOptionLoader<V> =
    Future<List<AppOption<V>>> Function(String query);

typedef AppAsyncOptionPageLoader<V> =
    Future<AppOptionPage<V>> Function(String query, Object? cursor);

class AppOptionPage<V> {
  const AppOptionPage({required this.options, this.nextCursor});

  final List<AppOption<V>> options;
  final Object? nextCursor;
  bool get hasMore => nextCursor != null;
}

/// Cursor-based source whose loader still returns product-formatted options.
/// HTTP requests, response parsing, and page-number conventions remain outside
/// the component package; [nextCursor] is deliberately opaque.
class AppAsyncPagedOptionSource<V> {
  AppAsyncPagedOptionSource({
    required this.loader,
    this.cacheDuration = const Duration(minutes: 5),
    this.maxCacheEntries = 64,
  }) : assert(maxCacheEntries > 0);

  final AppAsyncOptionPageLoader<V> loader;
  final Duration cacheDuration;
  final int maxCacheEntries;
  final Map<_AppPageKey, _AppPageCacheEntry<V>> _cache = {};
  final Map<_AppPageKey, Future<AppOptionPage<V>>> _inFlight = {};
  final Map<_AppPageKey, int> _generations = {};

  Future<AppOptionPage<V>> load(
    String query, {
    Object? cursor,
    bool forceRefresh = false,
  }) {
    final key = _AppPageKey(query.trim(), cursor);
    final cached = _cache[key];
    if (!forceRefresh &&
        cached != null &&
        DateTime.now().difference(cached.createdAt) < cacheDuration) {
      _touch(key, cached);
      return Future.value(cached.page);
    }
    final pending = _inFlight[key];
    if (!forceRefresh && pending != null) return pending;

    final generation = (_generations[key] ?? 0) + 1;
    _generations[key] = generation;
    final request = loader(key.query, cursor).then((page) {
      final immutable = AppOptionPage<V>(
        options: List<AppOption<V>>.unmodifiable(page.options),
        nextCursor: page.nextCursor,
      );
      if (_generations[key] == generation) {
        _cache[key] = _AppPageCacheEntry(immutable, DateTime.now());
        _trimCache();
      }
      return immutable;
    });
    _inFlight[key] = request;
    unawaited(
      request.then<void>(
        (_) {
          if (identical(_inFlight[key], request)) _inFlight.remove(key);
        },
        onError: (Object _, StackTrace _) {
          if (identical(_inFlight[key], request)) _inFlight.remove(key);
        },
      ),
    );
    return request;
  }

  Future<AppOptionPage<V>> retry(String query, {Object? cursor}) =>
      load(query, cursor: cursor, forceRefresh: true);

  void invalidate([String? query]) {
    final normalized = query?.trim();
    final keys = <_AppPageKey>{
      ..._cache.keys,
      ..._inFlight.keys,
      ..._generations.keys,
    }.where((key) => normalized == null || key.query == normalized);
    for (final key in keys.toList()) {
      _cache.remove(key);
      _inFlight.remove(key);
      _generations[key] = (_generations[key] ?? 0) + 1;
    }
  }

  void _touch(_AppPageKey key, _AppPageCacheEntry<V> entry) {
    _cache
      ..remove(key)
      ..[key] = entry;
  }

  void _trimCache() {
    while (_cache.length > maxCacheEntries) {
      _cache.remove(_cache.keys.first);
    }
  }
}

class _AppPageKey {
  const _AppPageKey(this.query, this.cursor);
  final String query;
  final Object? cursor;

  @override
  bool operator ==(Object other) =>
      other is _AppPageKey && other.query == query && other.cursor == cursor;

  @override
  int get hashCode => Object.hash(query, cursor);
}

class _AppPageCacheEntry<V> {
  const _AppPageCacheEntry(this.page, this.createdAt);
  final AppOptionPage<V> page;
  final DateTime createdAt;
}

/// Loads already-formatted options and owns request-independent concerns such
/// as caching and coalescing. API response parsing and pagination stay in the
/// caller-provided loader.
class AppAsyncOptionSource<V> {
  AppAsyncOptionSource({
    required this.loader,
    this.cacheDuration = const Duration(minutes: 5),
    this.maxCacheEntries = 32,
  }) : assert(maxCacheEntries > 0);

  factory AppAsyncOptionSource.single({
    required Future<List<AppOption<V>>> Function() loader,
    Duration cacheDuration = const Duration(minutes: 5),
  }) {
    return AppAsyncOptionSource<V>(
      loader: (_) => loader(),
      cacheDuration: cacheDuration,
      maxCacheEntries: 1,
    );
  }

  final AppAsyncOptionLoader<V> loader;
  final Duration cacheDuration;
  final int maxCacheEntries;
  final Map<String, _AppOptionCacheEntry<V>> _cache = {};
  final Map<String, Future<List<AppOption<V>>>> _inFlight = {};
  final Map<String, int> _generations = {};

  Future<List<AppOption<V>>> load(String query, {bool forceRefresh = false}) {
    final key = query.trim();
    final now = DateTime.now();
    final cached = _cache[key];
    if (!forceRefresh &&
        cached != null &&
        now.difference(cached.createdAt) < cacheDuration) {
      _touch(key, cached);
      return Future.value(cached.options);
    }

    if (!forceRefresh) {
      final pending = _inFlight[key];
      if (pending != null) return pending;
    }

    final generation = (_generations[key] ?? 0) + 1;
    _generations[key] = generation;
    final request = loader(key).then((options) {
      final immutable = List<AppOption<V>>.unmodifiable(options);
      if (_generations[key] == generation) {
        _cache[key] = _AppOptionCacheEntry(immutable, DateTime.now());
        _trimCache();
      }
      return immutable;
    });
    _inFlight[key] = request;
    unawaited(
      request.then<void>(
        (_) {
          if (identical(_inFlight[key], request)) _inFlight.remove(key);
        },
        onError: (Object _, StackTrace _) {
          if (identical(_inFlight[key], request)) _inFlight.remove(key);
        },
      ),
    );
    return request;
  }

  Future<List<AppOption<V>>> retry(String query) {
    return load(query, forceRefresh: true);
  }

  void invalidate([String? query]) {
    if (query == null) {
      final keys = <String>{
        ..._cache.keys,
        ..._inFlight.keys,
        ..._generations.keys,
      };
      for (final key in keys) {
        _generations[key] = (_generations[key] ?? 0) + 1;
      }
      _cache.clear();
      _inFlight.clear();
    } else {
      final key = query.trim();
      _cache.remove(key);
      _inFlight.remove(key);
      _generations[key] = (_generations[key] ?? 0) + 1;
    }
  }

  void _touch(String key, _AppOptionCacheEntry<V> entry) {
    _cache
      ..remove(key)
      ..[key] = entry;
  }

  void _trimCache() {
    while (_cache.length > maxCacheEntries) {
      _cache.remove(_cache.keys.first);
    }
  }
}

class _AppOptionCacheEntry<V> {
  const _AppOptionCacheEntry(this.options, this.createdAt);

  final List<AppOption<V>> options;
  final DateTime createdAt;
}
