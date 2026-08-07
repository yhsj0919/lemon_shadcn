import 'dart:async';

import 'package:cross_file/cross_file.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../foundation/app_interactive_style.dart';
import '../actions/app_button.dart';
import '../display/app_empty.dart';
import '../display/app_item.dart';
import '../overlay/app_overlay_components.dart';
import 'app_field.dart';
import 'app_form.dart';
import 'app_input_group.dart';

@immutable
class AppFileSelection {
  const AppFileSelection({
    required this.name,
    this.path,
    this.size,
    this.extension,
    this.data,
  });

  final String name;
  final String? path;
  final int? size;
  final String? extension;

  /// The underlying [XFile] for built-in selection and dropping. Custom
  /// pickers may store their own source object here.
  final Object? data;
}

typedef AppFilePickCallback = FutureOr<List<AppFileSelection>> Function();
typedef AppFileRejectedCallback = void Function(String message);
typedef AppFileTrailingBuilder =
    Widget? Function(BuildContext context, AppFileSelection file, int index);

enum AppFilePickerVariant { dropzone, simple }

/// Native file selection and file-drop surface.
///
/// [pick] is optional and only needed to replace the built-in system picker.
/// Selection and dropping share extension, size and count validation.
class AppFilePicker extends StatefulWidget {
  const AppFilePicker({
    super.key,
    required this.files,
    required this.onChanged,
    this.pick,
    this.variant = AppFilePickerVariant.dropzone,
    this.multiple = true,
    this.enabled = true,
    this.enableDrop = true,
    this.allowRemove = true,
    this.allowedExtensions,
    this.maxFileSize,
    this.maxFiles,
    this.dialogTitle,
    this.onRejected,
    this.trailingBuilder,
    this.emptyTitle = '点击选择或拖放文件到这里',
    this.dropTitle = '拖放文件到这里',
    this.pickLabel = '选择文件',
    this.hintText = '未选择文件',
  });

  final List<AppFileSelection> files;
  final ValueChanged<List<AppFileSelection>> onChanged;
  final AppFilePickCallback? pick;
  final AppFilePickerVariant variant;
  final bool multiple;
  final bool enabled;
  final bool enableDrop;
  final bool allowRemove;
  final List<String>? allowedExtensions;
  final int? maxFileSize;
  final int? maxFiles;
  final String? dialogTitle;
  final AppFileRejectedCallback? onRejected;
  final AppFileTrailingBuilder? trailingBuilder;
  final String emptyTitle;
  final String dropTitle;
  final String pickLabel;
  final String hintText;

  @override
  State<AppFilePicker> createState() => _AppFilePickerState();
}

class _AppFilePickerState extends State<AppFilePicker> {
  bool _dragging = false;
  String? _rejectionMessage;

  Set<String>? get _normalizedExtensions {
    final extensions = widget.allowedExtensions;
    if (extensions == null || extensions.isEmpty) return null;
    return extensions
        .map((value) => value.replaceFirst('.', '').toLowerCase())
        .toSet();
  }

  Future<void> _pick() async {
    try {
      final customPick = widget.pick;
      final selected = customPick == null
          ? await _pickNativeFiles()
          : await customPick();
      if (!mounted) return;
      _accept(selected);
    } catch (_) {
      if (mounted) _reject('无法选择文件，请重试');
    }
  }

  Future<List<AppFileSelection>> _pickNativeFiles() async {
    final extensions = _normalizedExtensions;
    final result = await FilePicker.pickFiles(
      allowMultiple: widget.multiple,
      allowedExtensions: extensions?.toList(),
      dialogTitle: widget.dialogTitle,
      type: extensions == null ? FileType.any : FileType.custom,
    );
    if (result == null) return const [];
    return [for (final file in result.files) _fromPlatformFile(file)];
  }

  Future<void> _drop(List<XFile> files) async {
    final selected = <AppFileSelection>[];
    String? rejection;
    for (final file in files) {
      try {
        selected.add(
          AppFileSelection(
            name: file.name,
            path: file.path,
            size: await file.length(),
            extension: _extensionOf(file.name),
            data: file,
          ),
        );
      } catch (_) {
        rejection ??= '无法读取文件 ${file.name}';
      }
    }
    if (!mounted) return;
    _accept(selected, rejection: rejection);
  }

  String? _validateFile(AppFileSelection file) {
    final extensions = _normalizedExtensions;
    final extension = (file.extension ?? _extensionOf(file.name))
        ?.toLowerCase();
    if (extensions != null && !extensions.contains(extension)) {
      return '不支持文件 ${file.name} 的格式';
    }
    final maxFileSize = widget.maxFileSize;
    if (maxFileSize != null && file.size != null && file.size! > maxFileSize) {
      return '文件 ${file.name} 超出大小限制';
    }
    return null;
  }

  void _accept(List<AppFileSelection> incoming, {String? rejection}) {
    if (incoming.isEmpty) {
      if (rejection != null) _reject(rejection);
      return;
    }
    final accepted = <AppFileSelection>[];
    for (final file in incoming) {
      final error = _validateFile(file);
      if (error != null) {
        rejection ??= error;
        continue;
      }
      accepted.add(file);
      if (!widget.multiple) break;
    }
    if (accepted.isEmpty) {
      if (rejection != null) _reject(rejection);
      return;
    }
    final next = widget.multiple
        ? <AppFileSelection>[...widget.files, ...accepted]
        : <AppFileSelection>[accepted.first];
    final maxFiles = widget.maxFiles;
    if (maxFiles != null && next.length > maxFiles) {
      _reject('最多只能选择 $maxFiles 个文件');
      return;
    }
    if (rejection != null) {
      _reject(rejection);
    } else {
      _clearRejection();
    }
    widget.onChanged(List.unmodifiable(next));
  }

  void _reject(String message) {
    if (!mounted) return;
    if (_rejectionMessage != message) {
      setState(() => _rejectionMessage = message);
    }
    widget.onRejected?.call(message);
  }

  void _clearRejection() {
    if (_rejectionMessage != null) {
      setState(() => _rejectionMessage = null);
    }
  }

  Widget _buildRejection(shad.ThemeData theme) => Semantics(
    liveRegion: true,
    child: Text(
      _rejectionMessage!,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 13, color: theme.colorScheme.destructive),
    ),
  );

  void _remove(int index) {
    final next = List<AppFileSelection>.of(widget.files)..removeAt(index);
    _clearRejection();
    widget.onChanged(List.unmodifiable(next));
  }

  Widget? _buildTrailing(BuildContext context, int index) {
    final custom = widget.trailingBuilder?.call(
      context,
      widget.files[index],
      index,
    );
    final remove = !widget.allowRemove
        ? null
        : widget.variant == AppFilePickerVariant.simple
        ? AppTooltip(
            tooltip: (context) => const Text('移除文件'),
            child: Semantics(
              button: true,
              label: '移除文件',
              child: shad.IconButton.text(
                density: shad.ButtonDensity.compact,
                enabled: widget.enabled,
                onPressed: widget.enabled ? () => _remove(index) : null,
                icon: Icon(
                  shad.LucideIcons.x,
                  color: shad.Theme.of(context).colorScheme.foreground,
                ),
              ),
            ),
          )
        : AppIconButton(
            tooltip: '移除文件',
            variant: AppButtonVariant.ghost,
            config: AppButtonConfig.plain,
            onPressed: widget.enabled ? () => _remove(index) : null,
            icon: const Icon(shad.LucideIcons.x),
          );
    if (custom == null) return remove;
    if (remove == null) return custom;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [custom, const SizedBox(width: 6), remove],
    );
  }

  Widget _buildSimple(BuildContext context, shad.ThemeData theme) {
    final selected = widget.files.isNotEmpty;
    final fileName = selected
        ? widget.multiple && widget.files.length > 1
              ? '${widget.files.first.name} 等 ${widget.files.length} 个文件'
              : widget.files.first.name
        : widget.hintText;
    final control = AppInputGroup(
      enabled: widget.enabled,
      backgroundColor: !widget.enabled
          ? null
          : _dragging
          ? theme.colorScheme.muted
          : theme.colorScheme.background,
      borderColor: _dragging ? theme.colorScheme.primary : null,
      leading: AppInkWell(
        enabled: widget.enabled,
        onPressed: _pick,
        hoverOpacity: 0,
        pressedOpacity: 0,
        child: Text(
          widget.pickLabel,
          style: TextStyle(
            color: theme.colorScheme.foreground,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      trailing: selected ? _buildTrailing(context, 0) : null,
      child: Text(
        fileName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: selected
              ? theme.colorScheme.foreground
              : theme.colorScheme.mutedForeground,
        ),
      ),
    );
    if (_rejectionMessage == null) return control;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        control,
        const SizedBox(height: 4),
        Align(alignment: Alignment.centerLeft, child: _buildRejection(theme)),
      ],
    );
  }

  Widget _buildDropzone(BuildContext context, shad.ThemeData theme) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: !widget.enabled
            ? theme.colorScheme.muted.withValues(alpha: 0.55)
            : _dragging
            ? theme.colorScheme.muted
            : null,
        border: Border.all(
          color: _dragging
              ? theme.colorScheme.primary
              : theme.colorScheme.border,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(theme.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.files.isEmpty)
            AppEmpty(
              icon: const Icon(shad.LucideIcons.paperclip),
              title: Text(_dragging ? widget.dropTitle : widget.emptyTitle),
              description: _rejectionMessage == null
                  ? null
                  : _buildRejection(theme),
              action: AppButton.outline(
                onPressed: widget.enabled ? _pick : null,
                child: Text(widget.pickLabel),
              ),
            )
          else ...[
            AppItemGroup(
              bordered: false,
              children: [
                for (var index = 0; index < widget.files.length; index++)
                  AppItem(
                    leading: const Icon(shad.LucideIcons.file),
                    title: Text(widget.files[index].name),
                    description: widget.files[index].size == null
                        ? null
                        : Text(_formatBytes(widget.files[index].size!)),
                    trailing: _buildTrailing(context, index),
                  ),
              ],
            ),
            if (_rejectionMessage != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 6, 10, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _buildRejection(theme),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: AppButton.outline(
                  onPressed: widget.enabled ? _pick : null,
                  child: Text(widget.pickLabel),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final picker = switch (widget.variant) {
      AppFilePickerVariant.dropzone => _buildDropzone(context, theme),
      AppFilePickerVariant.simple => _buildSimple(context, theme),
    };
    if (!widget.enabled || !widget.enableDrop) return picker;
    return DropTarget(
      onDragEntered: (_) => setState(() => _dragging = true),
      onDragExited: (_) => setState(() => _dragging = false),
      onDragDone: (details) {
        setState(() => _dragging = false);
        unawaited(_drop(details.files));
      },
      child: picker,
    );
  }
}

class AppFilePickerFormField extends FormField<List<AppFileSelection>> {
  AppFilePickerFormField({
    super.key,
    this.pick,
    this.variant = AppFilePickerVariant.dropzone,
    this.name,
    this.label,
    this.description,
    this.required = false,
    this.width,
    this.multiple = true,
    this.allowRemove = true,
    this.enableDrop = true,
    this.allowedExtensions,
    this.maxFileSize,
    this.maxFiles,
    this.dialogTitle,
    this.onRejected,
    this.trailingBuilder,
    this.emptyTitle = '点击选择或拖放文件到这里',
    this.dropTitle = '拖放文件到这里',
    this.pickLabel = '选择文件',
    this.hintText = '未选择文件',
    this.onChanged,
    super.initialValue = const [],
    super.onSaved,
    super.validator,
    super.enabled = true,
    super.autovalidateMode = AutovalidateMode.onUserInteraction,
  }) : super(
         builder: (state) {
           final field = state.widget as AppFilePickerFormField;
           return AppFormFieldBinding<List<AppFileSelection>>(
             name: field.name,
             value: state.value ?? const [],
             builder: (context, asyncError) => AppField(
               label: field.label,
               description: field.description,
               errorText: state.errorText ?? asyncError,
               required: field.required,
               width: field.width,
               child: AppFilePicker(
                 files: state.value ?? const [],
                 pick: field.pick,
                 variant: field.variant,
                 multiple: field.multiple,
                 enabled: field.enabled,
                 allowRemove: field.allowRemove,
                 enableDrop: field.enableDrop,
                 allowedExtensions: field.allowedExtensions,
                 maxFileSize: field.maxFileSize,
                 maxFiles: field.maxFiles,
                 dialogTitle: field.dialogTitle,
                 onRejected: field.onRejected,
                 trailingBuilder: field.trailingBuilder,
                 emptyTitle: field.emptyTitle,
                 dropTitle: field.dropTitle,
                 pickLabel: field.pickLabel,
                 hintText: field.hintText,
                 onChanged: (value) {
                   state.didChange(value);
                   field.onChanged?.call(value);
                 },
               ),
             ),
           );
         },
       );

  final AppFilePickCallback? pick;
  final AppFilePickerVariant variant;
  final String? name;
  final String? label;
  final String? description;
  final bool required;
  final double? width;
  final bool multiple;
  final bool allowRemove;
  final bool enableDrop;
  final List<String>? allowedExtensions;
  final int? maxFileSize;
  final int? maxFiles;
  final String? dialogTitle;
  final AppFileRejectedCallback? onRejected;
  final AppFileTrailingBuilder? trailingBuilder;
  final String emptyTitle;
  final String dropTitle;
  final String pickLabel;
  final String hintText;
  final ValueChanged<List<AppFileSelection>>? onChanged;
}

/// Image-focused preset of [AppFilePicker]. The picker remains injectable so
/// the component does not own platform permissions, uploads, or request data.
class AppImageInput extends AppFilePicker {
  const AppImageInput({
    super.key,
    required super.files,
    required super.onChanged,
    super.pick,
    super.variant,
    super.multiple = true,
    super.enabled,
    super.enableDrop,
    super.allowRemove,
    super.allowedExtensions = const <String>['png', 'jpg', 'jpeg', 'webp'],
    super.maxFileSize,
    super.maxFiles,
    super.dialogTitle = '选择图片',
    super.onRejected,
    super.trailingBuilder,
    super.emptyTitle = '点击选择或拖放图片到这里',
    super.dropTitle = '拖放图片到这里',
    super.pickLabel = '选择图片',
    super.hintText = '未选择图片',
  });
}

/// Form-compatible image preset sharing validation and layout with file input.
class AppImageInputFormField extends AppFilePickerFormField {
  AppImageInputFormField({
    super.key,
    super.pick,
    super.variant,
    super.name,
    super.label,
    super.description,
    super.required,
    super.width,
    super.multiple = true,
    super.allowRemove,
    super.enableDrop,
    super.allowedExtensions = const <String>['png', 'jpg', 'jpeg', 'webp'],
    super.maxFileSize,
    super.maxFiles,
    super.dialogTitle = '选择图片',
    super.onRejected,
    super.trailingBuilder,
    super.emptyTitle = '点击选择或拖放图片到这里',
    super.dropTitle = '拖放图片到这里',
    super.pickLabel = '选择图片',
    super.hintText = '未选择图片',
    super.onChanged,
    super.initialValue,
    super.onSaved,
    super.validator,
    super.enabled,
    super.autovalidateMode,
  });
}

AppFileSelection _fromPlatformFile(PlatformFile file) => AppFileSelection(
  name: file.name,
  path: file.path,
  size: file.size,
  extension: file.extension,
  data: file.xFile,
);

String? _extensionOf(String name) {
  final separator = name.lastIndexOf('.');
  if (separator < 0 || separator == name.length - 1) return null;
  return name.substring(separator + 1);
}

String _formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}
