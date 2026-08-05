import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../foundation/app_shadcn_scope.dart';
import '../../foundation/app_theme_aliases.dart';
import '../display/app_async_view.dart';
import '../layout/app_layout_components.dart';

class AppChartCard extends StatelessWidget {
  const AppChartCard({
    super.key,
    required this.title,
    required this.child,
    this.description,
    this.action,
    this.padding = const EdgeInsets.all(20),
  });

  final Widget title;
  final Widget child;
  final Widget? description;
  final Widget? action;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = ShadcnTheme.of(context);
    return AppCard(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    DefaultTextStyle(
                      style: theme.typography.large.copyWith(
                        color: theme.colorScheme.foreground,
                        fontWeight: FontWeight.w600,
                      ),
                      child: title,
                    ),
                    if (description != null) ...<Widget>[
                      const SizedBox(height: 4),
                      DefaultTextStyle(
                        style: theme.typography.small.copyWith(
                          color: theme.colorScheme.mutedForeground,
                        ),
                        child: description!,
                      ),
                    ],
                  ],
                ),
              ),
              if (action != null) ...<Widget>[
                const SizedBox(width: 12),
                action!,
              ],
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}

/// Keeps loading, error, empty and chart content in the same chart slot.
/// The loader receives already-formatted domain data and owns no request
/// protocol or JSON parsing behavior.
class AppAsyncChart<T> extends StatelessWidget {
  const AppAsyncChart({
    super.key,
    required this.load,
    required this.builder,
    this.initialData,
    this.loadingBuilder,
    this.errorBuilder,
    this.emptyBuilder,
    this.isEmpty,
    this.reloadKey,
    this.height,
  });

  final FutureOr<T> Function() load;
  final AppAsyncDataBuilder<T> builder;
  final T? initialData;
  final WidgetBuilder? loadingBuilder;
  final AppAsyncErrorBuilder? errorBuilder;
  final WidgetBuilder? emptyBuilder;
  final bool Function(T data)? isEmpty;
  final Object? reloadKey;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final slotHeight = height ?? AppTheme.of(context).chart.height;
    return SizedBox(
      height: slotHeight,
      child: AppAsyncView<T>(
        load: load,
        builder: builder,
        initialData: initialData,
        loadingBuilder: loadingBuilder,
        errorBuilder: errorBuilder,
        emptyBuilder: emptyBuilder,
        isEmpty: isEmpty,
        reloadKey: reloadKey,
      ),
    );
  }
}
