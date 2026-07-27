import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../actions/app_button.dart';

/// Button variants supported by [AppDropdownButton].
enum AppDropdownButtonVariant { primary, secondary, outline, ghost }

/// A product-level button that opens an anchored shadcn dropdown menu.
class AppDropdownButton extends StatefulWidget {
  const AppDropdownButton({
    super.key,
    required this.child,
    required this.items,
    this.variant = AppDropdownButtonVariant.outline,
    this.enabled = true,
    this.leading,
    this.trailing,
    this.config = const AppButtonConfig(),
    this.alignment,
    this.anchorAlignment,
    this.offset,
  });

  final Widget child;
  final List<shad.MenuItem> items;
  final AppDropdownButtonVariant variant;
  final bool enabled;
  final Widget? leading;
  final Widget? trailing;
  final AppButtonConfig config;
  final AlignmentGeometry? alignment;
  final AlignmentGeometry? anchorAlignment;
  final Offset? offset;

  @override
  State<AppDropdownButton> createState() => _AppDropdownButtonState();
}

class _AppDropdownButtonState extends State<AppDropdownButton> {
  final _buttonKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    void open() {
      final buttonContext = _buttonKey.currentContext;
      if (buttonContext == null) return;
      shad.PopoverConfiguration<void>(
        alignment: widget.alignment ?? Alignment.bottomLeft,
        anchorAlignment: widget.anchorAlignment,
        offset: widget.offset,
        builder: (context) => shad.DropdownMenu(children: widget.items),
      ).show(buttonContext);
    }

    final onPressed = widget.enabled ? open : null;
    final button = switch (widget.variant) {
      AppDropdownButtonVariant.primary => AppButton.primary(
        onPressed: onPressed,
        leading: widget.leading,
        trailing: widget.trailing,
        config: widget.config,
        child: widget.child,
      ),
      AppDropdownButtonVariant.secondary => AppButton.secondary(
        onPressed: onPressed,
        leading: widget.leading,
        trailing: widget.trailing,
        config: widget.config,
        child: widget.child,
      ),
      AppDropdownButtonVariant.outline => AppButton.outline(
        onPressed: onPressed,
        leading: widget.leading,
        trailing: widget.trailing,
        config: widget.config,
        child: widget.child,
      ),
      AppDropdownButtonVariant.ghost => AppButton.ghost(
        onPressed: onPressed,
        leading: widget.leading,
        trailing: widget.trailing,
        config: widget.config,
        child: widget.child,
      ),
    };
    return SizedBox(key: _buttonKey, child: button);
  }
}
