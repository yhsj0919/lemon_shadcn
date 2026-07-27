import 'dart:async';

import 'package:flutter/foundation.dart';

enum AppAsyncStatus { idle, loading, success, error }

typedef AppAsyncOperation<T> = FutureOr<T> Function();

/// Shareable async operation state for buttons, form submission, refresh and
/// other actions. Repeated execution joins the current request by default.
class AppAsyncAction<T> extends ChangeNotifier {
  AppAsyncAction({
    required this.operation,
    this.loadingDelay = Duration.zero,
    this.minimumLoadingDuration = Duration.zero,
  });

  final AppAsyncOperation<T> operation;
  final Duration loadingDelay;
  final Duration minimumLoadingDuration;

  AppAsyncStatus _status = AppAsyncStatus.idle;
  T? _value;
  Object? _error;
  StackTrace? _stackTrace;
  Future<T>? _inFlight;
  int _generation = 0;
  bool _disposed = false;

  AppAsyncStatus get status => _status;
  T? get value => _value;
  Object? get error => _error;
  StackTrace? get stackTrace => _stackTrace;
  bool get isRunning => _inFlight != null;
  bool get isLoading => _status == AppAsyncStatus.loading;
  bool get hasError => _status == AppAsyncStatus.error;

  Future<T> execute({bool force = false}) {
    final current = _inFlight;
    if (!force && current != null) return current;
    final generation = ++_generation;
    final future = _run(generation);
    _inFlight = future;
    _notify();
    return future;
  }

  Future<T> retry() => execute(force: true);

  void reset() {
    _generation++;
    _inFlight = null;
    _status = AppAsyncStatus.idle;
    _value = null;
    _error = null;
    _stackTrace = null;
    _notify();
  }

  Future<T> _run(int generation) async {
    DateTime? loadingStarted;
    Timer? loadingTimer;
    _error = null;
    _stackTrace = null;

    if (loadingDelay == Duration.zero) {
      _status = AppAsyncStatus.loading;
      loadingStarted = DateTime.now();
    } else {
      _status = AppAsyncStatus.idle;
      loadingTimer = Timer(loadingDelay, () {
        if (_disposed || generation != _generation) return;
        loadingStarted = DateTime.now();
        _status = AppAsyncStatus.loading;
        _notify();
      });
    }

    try {
      final result = await operation();
      loadingTimer?.cancel();
      if (loadingStarted case final started?) {
        final remaining =
            minimumLoadingDuration - DateTime.now().difference(started);
        if (remaining > Duration.zero) await Future<void>.delayed(remaining);
      }
      if (generation == _generation) {
        _value = result;
        _status = AppAsyncStatus.success;
      }
      return result;
    } catch (error, stackTrace) {
      loadingTimer?.cancel();
      if (generation == _generation) {
        _error = error;
        _stackTrace = stackTrace;
        _status = AppAsyncStatus.error;
      }
      Error.throwWithStackTrace(error, stackTrace);
    } finally {
      if (generation == _generation) {
        _inFlight = null;
        _notify();
      }
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _generation++;
    _inFlight = null;
    super.dispose();
  }
}
