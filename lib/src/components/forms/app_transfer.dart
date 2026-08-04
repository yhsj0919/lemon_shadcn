import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../actions/app_button.dart';
import '../display/app_empty.dart';
import '../display/app_item.dart';
import 'app_field.dart';
import 'app_checkbox.dart';
import 'app_form.dart';
import 'app_option.dart';
import 'app_text_form_field.dart';

/// A controlled dual-list selector for assigning options to a target list.
class AppTransfer<V> extends StatefulWidget {
  const AppTransfer({
    super.key,
    required this.options,
    this.value = const [],
    this.onChanged,
    this.optionConfig = const AppOptionConfig(),
    this.sourceTitle = '可选项',
    this.targetTitle = '已选择',
    this.emptyText = '暂无数据',
    this.searchable = true,
    this.enabled = true,
    this.height = 300,
    this.breakpoint = 620,
  });

  final List<AppOption<V>> options;
  final List<V> value;
  final ValueChanged<List<V>>? onChanged;
  final AppOptionConfig<V> optionConfig;
  final String sourceTitle;
  final String targetTitle;
  final String emptyText;
  final bool searchable;
  final bool enabled;
  final double height;
  final double breakpoint;

  @override
  State<AppTransfer<V>> createState() => _AppTransferState<V>();
}

class _AppTransferState<V> extends State<AppTransfer<V>> {
  final _sourceSelection = <V>[];
  final _targetSelection = <V>[];
  String _sourceQuery = '';
  String _targetQuery = '';

  bool _equals(V left, V right) => widget.optionConfig.isEqual(left, right);

  bool _contains(Iterable<V> values, V value) =>
      values.any((candidate) => _equals(candidate, value));

  List<AppOption<V>> get _sourceOptions => widget.options
      .where((option) => !_contains(widget.value, option.value))
      .toList(growable: false);

  List<AppOption<V>> get _targetOptions => widget.value
      .map((value) {
        for (final option in widget.options) {
          if (_equals(option.value, value)) return option;
        }
        return AppOption<V>(value: value, label: value.toString());
      })
      .toList(growable: false);

  List<AppOption<V>> _filter(List<AppOption<V>> options, String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return options;
    return options
        .where(
          (option) => widget.optionConfig
              .searchableText(option)
              .toLowerCase()
              .contains(normalized),
        )
        .toList(growable: false);
  }

  void _toggle(List<V> selection, V value) {
    setState(() {
      final index = selection.indexWhere((item) => _equals(item, value));
      if (index < 0) {
        selection.add(value);
      } else {
        selection.removeAt(index);
      }
    });
  }

  void _moveToTarget() {
    if (_sourceSelection.isEmpty) return;
    final next = <V>[...widget.value];
    for (final option in widget.options) {
      if (_contains(_sourceSelection, option.value) &&
          !_contains(next, option.value)) {
        next.add(option.value);
      }
    }
    setState(_sourceSelection.clear);
    widget.onChanged?.call(next);
  }

  void _moveToSource() {
    if (_targetSelection.isEmpty) return;
    final next = widget.value
        .where((value) => !_contains(_targetSelection, value))
        .toList(growable: false);
    setState(_targetSelection.clear);
    widget.onChanged?.call(next);
  }

  Widget _buildPanel(
    BuildContext context, {
    required String title,
    required List<AppOption<V>> options,
    required List<V> selection,
    required String query,
    required ValueChanged<String> onQueryChanged,
  }) {
    final theme = shad.Theme.of(context);
    final filtered = _filter(options, query);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.border, width: 1),
        borderRadius: BorderRadius.circular(theme.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Text(
                  '${selection.length}/${options.length}',
                  style: TextStyle(color: theme.colorScheme.mutedForeground),
                ),
              ],
            ),
          ),
          if (widget.searchable)
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: AppTextField(
                value: query,
                hintText: '搜索',
                leading: const Icon(shad.LucideIcons.search, size: 16),
                onChanged: onQueryChanged,
              ),
            ),
          SizedBox(
            height: 1,
            child: ColoredBox(color: theme.colorScheme.border),
          ),
          Expanded(
            child: filtered.isEmpty
                ? AppEmpty(
                    title: Text(widget.emptyText),
                    padding: const EdgeInsets.all(16),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(4),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final option = filtered[index];
                      final selected = _contains(selection, option.value);
                      return AppItem(
                        enabled: widget.enabled && !option.disabled,
                        onPressed: () => _toggle(selection, option.value),
                        leading: AppCheckboxIndicator(
                          state: selected
                              ? shad.CheckboxState.checked
                              : shad.CheckboxState.unchecked,
                          enabled: widget.enabled && !option.disabled,
                          onChanged: (_) => _toggle(selection, option.value),
                        ),
                        title: widget.optionConfig.buildSelected(
                          context,
                          option,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls(Axis layoutDirection) {
    final horizontal = layoutDirection == Axis.horizontal;
    return Flex(
      direction: horizontal ? Axis.vertical : Axis.horizontal,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppIconButton(
          tooltip: '添加所选项',
          config: AppButtonConfig.plain,
          onPressed: widget.enabled && _sourceSelection.isNotEmpty
              ? _moveToTarget
              : null,
          icon: Icon(
            horizontal
                ? shad.LucideIcons.chevronRight
                : shad.LucideIcons.chevronDown,
          ),
        ),
        const SizedBox(width: 8, height: 8),
        AppIconButton(
          tooltip: '移除所选项',
          config: AppButtonConfig.plain,
          onPressed: widget.enabled && _targetSelection.isNotEmpty
              ? _moveToSource
              : null,
          icon: Icon(
            horizontal
                ? shad.LucideIcons.chevronLeft
                : shad.LucideIcons.chevronUp,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontal =
            !constraints.hasBoundedWidth ||
            constraints.maxWidth >= widget.breakpoint;
        final source = _buildPanel(
          context,
          title: widget.sourceTitle,
          options: _sourceOptions,
          selection: _sourceSelection,
          query: _sourceQuery,
          onQueryChanged: (value) => setState(() => _sourceQuery = value),
        );
        final target = _buildPanel(
          context,
          title: widget.targetTitle,
          options: _targetOptions,
          selection: _targetSelection,
          query: _targetQuery,
          onQueryChanged: (value) => setState(() => _targetQuery = value),
        );
        if (horizontal) {
          return SizedBox(
            height: widget.height,
            child: Row(
              children: [
                Expanded(child: source),
                const SizedBox(width: 12),
                _buildControls(Axis.horizontal),
                const SizedBox(width: 12),
                Expanded(child: target),
              ],
            ),
          );
        }
        return SizedBox(
          height: widget.height * 2 + 64,
          child: Column(
            children: [
              Expanded(child: source),
              const SizedBox(height: 8),
              _buildControls(Axis.vertical),
              const SizedBox(height: 8),
              Expanded(child: target),
            ],
          ),
        );
      },
    );
  }
}

class AppTransferFormField<V> extends FormField<List<V>> {
  AppTransferFormField({
    super.key,
    required List<AppOption<V>> options,
    String? name,
    String? label,
    String? description,
    bool required = false,
    double? width,
    AppOptionConfig<V> optionConfig = const AppOptionConfig(),
    String sourceTitle = '可选项',
    String targetTitle = '已选择',
    bool searchable = true,
    double height = 300,
    ValueChanged<List<V>>? onChanged,
    super.initialValue = const [],
    super.onSaved,
    super.validator,
    AppAsyncFieldValidator<List<V>>? asyncValidator,
    super.enabled = true,
    super.autovalidateMode = AutovalidateMode.onUserInteraction,
    super.restorationId,
  }) : super(
         builder: (state) => AppFormFieldBinding<List<V>>(
           name: name,
           value: state.value,
           asyncValidator: asyncValidator,
           builder: (context, asyncError) => AppField(
             label: label,
             description: description,
             required: required,
             width: width,
             errorText: state.errorText ?? asyncError,
             child: AppTransfer<V>(
               options: options,
               value: state.value ?? const [],
               enabled: state.widget.enabled,
               optionConfig: optionConfig,
               sourceTitle: sourceTitle,
               targetTitle: targetTitle,
               searchable: searchable,
               height: height,
               onChanged: (value) {
                 state.didChange(value);
                 onChanged?.call(value);
               },
             ),
           ),
         ),
       );
}
