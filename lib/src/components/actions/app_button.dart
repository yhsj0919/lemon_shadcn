import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../foundation/app_shadcn_scope.dart';

typedef AppButtonCallback = FutureOr<void> Function();

enum AppButtonVariant { primary, secondary, outline, ghost, destructive }

abstract final class AppButton {
  static Widget primary({
    Key? key,
    required Widget child,
    AppButtonCallback? onPressed,
    bool? loading,
    Widget? leading,
    Widget? trailing,
    String? loadingLabel,
  }) => _AppAsyncButton(
    key: key,
    variant: AppButtonVariant.primary,
    onPressed: onPressed,
    loading: loading,
    leading: leading,
    trailing: trailing,
    loadingLabel: loadingLabel,
    child: child,
  );

  static Widget secondary({
    Key? key,
    required Widget child,
    AppButtonCallback? onPressed,
    bool? loading,
  }) => _AppAsyncButton(
    key: key,
    variant: AppButtonVariant.secondary,
    onPressed: onPressed,
    loading: loading,
    child: child,
  );

  static Widget outline({
    Key? key,
    required Widget child,
    AppButtonCallback? onPressed,
    bool? loading,
  }) => _AppAsyncButton(
    key: key,
    variant: AppButtonVariant.outline,
    onPressed: onPressed,
    loading: loading,
    child: child,
  );

  static Widget ghost({
    Key? key,
    required Widget child,
    AppButtonCallback? onPressed,
    bool? loading,
  }) => _AppAsyncButton(
    key: key,
    variant: AppButtonVariant.ghost,
    onPressed: onPressed,
    loading: loading,
    child: child,
  );

  static Widget destructive({
    Key? key,
    required Widget child,
    AppButtonCallback? onPressed,
    bool? loading,
  }) => _AppAsyncButton(
    key: key,
    variant: AppButtonVariant.destructive,
    onPressed: onPressed,
    loading: loading,
    child: child,
  );
}

class _AppAsyncButton extends StatefulWidget {
  const _AppAsyncButton({
    super.key,
    required this.variant,
    required this.child,
    this.onPressed,
    this.loading,
    this.leading,
    this.trailing,
    this.loadingLabel,
  });

  final AppButtonVariant variant;
  final Widget child;
  final AppButtonCallback? onPressed;
  final bool? loading;
  final Widget? leading;
  final Widget? trailing;
  final String? loadingLabel;

  @override
  State<_AppAsyncButton> createState() => _AppAsyncButtonState();
}

class _AppAsyncButtonState extends State<_AppAsyncButton> {
  bool _loading = false;

  bool get _effectiveLoading => widget.loading ?? _loading;

  Future<void> _press() async {
    if (_effectiveLoading || widget.onPressed == null) return;
    final result = widget.onPressed!();
    if (result is! Future<void>) return;

    final motion = AppTheme.maybeOf(context)?.motion;
    DateTime? loadingStarted;
    final delay = motion?.loadingDelay ?? Duration.zero;
    final timer = Timer(delay, () {
      if (mounted && widget.loading == null) {
        loadingStarted = DateTime.now();
        setState(() => _loading = true);
      }
    });

    try {
      await result;
      if (loadingStarted case final started?) {
        final minimum = motion?.minimumLoadingDuration ?? Duration.zero;
        final remaining = minimum - DateTime.now().difference(started);
        if (remaining > Duration.zero) await Future<void>.delayed(remaining);
      }
    } finally {
      timer.cancel();
      if (mounted && widget.loading == null) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = _effectiveLoading;
    final child = _AppButtonContent(
      loading: loading,
      loadingLabel: widget.loadingLabel,
      child: widget.child,
    );
    final onPressed = widget.onPressed == null || loading ? null : _press;

    return switch (widget.variant) {
      AppButtonVariant.primary => shad.PrimaryButton(
        onPressed: onPressed,
        leading: widget.leading,
        trailing: widget.trailing,
        child: child,
      ),
      AppButtonVariant.secondary => shad.SecondaryButton(
        onPressed: onPressed,
        leading: widget.leading,
        trailing: widget.trailing,
        child: child,
      ),
      AppButtonVariant.outline => shad.OutlineButton(
        onPressed: onPressed,
        leading: widget.leading,
        trailing: widget.trailing,
        child: child,
      ),
      AppButtonVariant.ghost => shad.GhostButton(
        onPressed: onPressed,
        leading: widget.leading,
        trailing: widget.trailing,
        child: child,
      ),
      AppButtonVariant.destructive => shad.DestructiveButton(
        onPressed: onPressed,
        leading: widget.leading,
        trailing: widget.trailing,
        child: child,
      ),
    };
  }
}

class _AppButtonContent extends StatelessWidget {
  const _AppButtonContent({
    required this.loading,
    required this.child,
    this.loadingLabel,
  });

  final bool loading;
  final Widget child;
  final String? loadingLabel;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Opacity(opacity: loading ? 0 : 1, child: child),
        if (loading)
          Positioned.fill(
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox.square(
                      dimension: 16,
                      child: shad.CircularProgressIndicator(),
                    ),
                    if (loadingLabel != null) ...[
                      const shad.Gap(8),
                      Text(loadingLabel!),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
