import 'dart:async';

import 'package:flutter/widgets.dart';

import '../actions/app_button.dart';
import '../../foundation/app_shadcn_scope.dart';
import 'app_display_components.dart';

typedef AppAsyncDataBuilder<T> = Widget Function(BuildContext context, T data);
typedef AppAsyncErrorBuilder =
    Widget Function(BuildContext context, Object error, VoidCallback retry);

/// A low-boilerplate async state view with built-in retry and stale-result
/// protection. Domain data stays formatted before it reaches this widget.
class AppAsyncView<T> extends StatefulWidget {
  const AppAsyncView({
    super.key,
    required this.load,
    required this.builder,
    this.initialData,
    this.loadingBuilder,
    this.errorBuilder,
    this.emptyBuilder,
    this.isEmpty,
    this.reloadKey,
  });

  final FutureOr<T> Function() load;
  final AppAsyncDataBuilder<T> builder;
  final T? initialData;
  final WidgetBuilder? loadingBuilder;
  final AppAsyncErrorBuilder? errorBuilder;
  final WidgetBuilder? emptyBuilder;
  final bool Function(T data)? isEmpty;
  final Object? reloadKey;

  @override
  State<AppAsyncView<T>> createState() => AppAsyncViewState<T>();
}

class AppAsyncViewState<T> extends State<AppAsyncView<T>> {
  T? _data;
  Object? _error;
  StackTrace? _stackTrace;
  bool _loading = true;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    _data = widget.initialData;
    reload();
  }

  @override
  void didUpdateWidget(covariant AppAsyncView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reloadKey != widget.reloadKey) reload();
  }

  Future<void> reload() async {
    final generation = ++_generation;
    setState(() {
      _loading = true;
      _error = null;
      _stackTrace = null;
    });
    try {
      final value = await widget.load();
      if (!mounted || generation != _generation) return;
      setState(() {
        _data = value;
        _loading = false;
      });
    } catch (error, stackTrace) {
      if (!mounted || generation != _generation) return;
      setState(() {
        _error = error;
        _stackTrace = stackTrace;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = _data;
    if (_loading && data == null) {
      return widget.loadingBuilder?.call(context) ??
          const Center(child: AppCircularProgressIndicator());
    }
    final error = _error;
    if (error != null) {
      return widget.errorBuilder?.call(context, error, reload) ??
          _AppAsyncError(error: error, stackTrace: _stackTrace, retry: reload);
    }
    if (data == null) {
      return widget.emptyBuilder?.call(context) ?? const SizedBox.shrink();
    }
    if (widget.isEmpty?.call(data) ?? false) {
      return widget.emptyBuilder?.call(context) ?? const SizedBox.shrink();
    }
    return widget.builder(context, data);
  }
}

class _AppAsyncError extends StatelessWidget {
  const _AppAsyncError({
    required this.error,
    required this.retry,
    this.stackTrace,
  });

  final Object error;
  final StackTrace? stackTrace;
  final VoidCallback retry;

  @override
  Widget build(BuildContext context) {
    final message =
        AppTheme.maybeOf(context)?.errorPresenter?.call(error, stackTrace) ??
        error.toString();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(message, textAlign: TextAlign.center),
        const SizedBox(height: 8),
        AppButton.outline(onPressed: retry, child: const Text('Retry')),
      ],
    );
  }
}
