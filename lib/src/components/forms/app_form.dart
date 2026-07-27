import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../foundation/app_async_action.dart';
import '../../foundation/app_shadcn_scope.dart';

typedef AppAsyncFieldValidator<T> = Future<String?> Function(T? value);
typedef AppCrossFieldValidator =
    FutureOr<Map<String, String>> Function(Map<String, Object?> values);
typedef AppFormSubmitHandler =
    FutureOr<void> Function(Map<String, Object?> values);

/// Coordinates named App fields while retaining Flutter's native [Form]
/// validation, save, and reset lifecycle.
class AppFormController extends ChangeNotifier {
  AppFormController({this.crossValidators = const []});

  final List<AppCrossFieldValidator> crossValidators;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final Map<String, _AppFormFieldRegistration<dynamic>> _fields = {};
  final Map<String, Object?> _cleanValues = {};
  bool _validating = false;
  bool _notifyScheduled = false;
  bool _disposed = false;
  Object? _submitError;
  StackTrace? _submitStackTrace;
  int _validationGeneration = 0;
  int _runningValidationGeneration = 0;

  bool get isValidating => _validating;
  Object? get submitError => _submitError;
  StackTrace? get submitStackTrace => _submitStackTrace;

  Map<String, Object?> get values => Map.unmodifiable({
    for (final entry in _fields.entries) entry.key: entry.value.value,
  });

  T? value<T>(String name) => _fields[name]?.value as T?;

  Set<String> get dirtyFields => {
    for (final entry in _fields.entries)
      if (!_appFormValueEquals(_cleanValues[entry.key], entry.value.value))
        entry.key,
  };

  bool get isDirty => dirtyFields.isNotEmpty;

  /// Uses current formatted values as the new dirty-comparison baseline.
  void markClean() {
    _cleanValues
      ..clear()
      ..addAll({
        for (final entry in _fields.entries)
          entry.key: _appFormValueSnapshot(entry.value.value),
      });
    notifyListeners();
  }

  bool validateSync() => formKey.currentState?.validate() ?? false;

  Future<bool> validate() async {
    _clearCrossErrors();
    final generation = ++_validationGeneration;
    _runningValidationGeneration = generation;
    final syncValid = validateSync();
    final fields = List<_AppFormFieldRegistration<dynamic>>.of(_fields.values);
    _validating = true;
    notifyListeners();
    try {
      final results = await Future.wait([
        for (final field in fields) field.validateAsync(),
      ]);
      var crossValid = true;
      for (final validator in crossValidators) {
        final errors = await validator(values);
        if (generation != _validationGeneration) return false;
        for (final entry in errors.entries) {
          final field = _fields[entry.key];
          if (field == null) {
            throw FlutterError(
              'Cross-field validator returned an error for unknown field '
              '"${entry.key}".',
            );
          }
          field.setExternalError(entry.value);
          crossValid = false;
        }
      }
      return syncValid && results.every((error) => error == null) && crossValid;
    } finally {
      if (generation == _runningValidationGeneration) {
        _validating = false;
        notifyListeners();
      }
    }
  }

  void save() => formKey.currentState?.save();

  /// Validates sync, async and cross-field rules, saves native FormFields, then
  /// passes an immutable formatted-value snapshot to the submit handler.
  Future<bool> submit(AppFormSubmitHandler onValid) async {
    clearSubmitError();
    if (!await validate()) return false;
    save();
    try {
      await onValid(Map.unmodifiable(values));
      return true;
    } catch (error, stackTrace) {
      _submitError = error;
      _submitStackTrace = stackTrace;
      notifyListeners();
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  void clearSubmitError() {
    if (_submitError == null && _submitStackTrace == null) return;
    _submitError = null;
    _submitStackTrace = null;
    notifyListeners();
  }

  /// Creates a shareable action suitable for `AppButton(action: ...)`.
  /// The caller owns and disposes the returned action.
  AppAsyncAction<void> createSubmitAction(
    AppFormSubmitHandler onValid, {
    Duration loadingDelay = Duration.zero,
    Duration minimumLoadingDuration = Duration.zero,
  }) {
    return AppAsyncAction<void>(
      loadingDelay: loadingDelay,
      minimumLoadingDuration: minimumLoadingDuration,
      operation: () async {
        await submit(onValid);
      },
    );
  }

  void reset() {
    formKey.currentState?.reset();
    for (final field in _fields.values) {
      field.clearError();
    }
    clearSubmitError();
  }

  void _clearCrossErrors() {
    _validationGeneration++;
    for (final field in _fields.values) {
      field.setExternalError(null);
    }
  }

  void _register(_AppFormFieldRegistration<dynamic> field) {
    final existing = _fields[field.name];
    if (existing != null && !identical(existing.token, field.token)) {
      throw FlutterError(
        'AppForm contains more than one field named "${field.name}".',
      );
    }
    final previous = _fields[field.name]?.value;
    _fields[field.name] = field;
    _cleanValues.putIfAbsent(
      field.name,
      () => _appFormValueSnapshot(field.value),
    );
    if (!_appFormValueEquals(previous, field.value)) _scheduleNotify();
  }

  void _unregister(String name, Object token) {
    if (identical(_fields[name]?.token, token)) {
      _fields.remove(name);
      _cleanValues.remove(name);
      _scheduleNotify();
    }
  }

  void _scheduleNotify() {
    if (_notifyScheduled || _disposed) return;
    _notifyScheduled = true;
    scheduleMicrotask(() {
      _notifyScheduled = false;
      if (!_disposed) notifyListeners();
    });
  }

  @override
  void dispose() {
    _disposed = true;
    _validationGeneration++;
    super.dispose();
  }
}

Object? _appFormValueSnapshot(Object? value) {
  if (value is List) {
    return List<Object?>.unmodifiable(value.map(_appFormValueSnapshot));
  }
  if (value is Map) {
    return Map<Object?, Object?>.unmodifiable({
      for (final entry in value.entries)
        _appFormValueSnapshot(entry.key): _appFormValueSnapshot(entry.value),
    });
  }
  if (value is Set) {
    return Set<Object?>.unmodifiable(value.map(_appFormValueSnapshot));
  }
  return value;
}

bool _appFormValueEquals(Object? a, Object? b) {
  if (identical(a, b)) return true;
  if (a is List && b is List) {
    if (a.length != b.length) return false;
    for (var index = 0; index < a.length; index++) {
      if (!_appFormValueEquals(a[index], b[index])) return false;
    }
    return true;
  }
  if (a is Map && b is Map) {
    if (a.length != b.length) return false;
    for (final entry in a.entries) {
      if (!b.containsKey(entry.key) ||
          !_appFormValueEquals(entry.value, b[entry.key])) {
        return false;
      }
    }
    return true;
  }
  if (a is Set && b is Set) {
    return a.length == b.length && a.containsAll(b);
  }
  return a == b;
}

class AppForm extends StatelessWidget {
  const AppForm({
    super.key,
    required this.controller,
    required this.child,
    this.autovalidateMode,
    this.onChanged,
    this.canPop,
    this.onPopInvokedWithResult,
  });

  final AppFormController controller;
  final Widget child;
  final AutovalidateMode? autovalidateMode;
  final VoidCallback? onChanged;
  final bool? canPop;
  final PopInvokedWithResultCallback<Object?>? onPopInvokedWithResult;

  static AppFormController? maybeControllerOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_AppFormScope>()
        ?.controller;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.formKey,
      autovalidateMode: autovalidateMode,
      onChanged: () {
        controller._clearCrossErrors();
        controller.clearSubmitError();
        onChanged?.call();
      },
      canPop: canPop,
      onPopInvokedWithResult: onPopInvokedWithResult,
      child: _AppFormScope(controller: controller, child: child),
    );
  }
}

class AppFormErrorSummary extends StatelessWidget {
  const AppFormErrorSummary({
    super.key,
    required this.controller,
    this.height = 28,
    this.builder,
  });

  final AppFormController controller;
  final double height;
  final Widget Function(BuildContext context, Object error, String message)?
  builder;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ListenableBuilder(
        listenable: controller,
        builder: (context, child) {
          final error = controller.submitError;
          if (error == null) return const SizedBox.shrink();
          final message =
              AppTheme.maybeOf(
                context,
              )?.errorPresenter?.call(error, controller.submitStackTrace) ??
              error.toString();
          return builder?.call(context, error, message) ??
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  message,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              );
        },
      ),
    );
  }
}

class _AppFormScope extends InheritedWidget {
  const _AppFormScope({required this.controller, required super.child});

  final AppFormController controller;

  @override
  bool updateShouldNotify(_AppFormScope oldWidget) {
    return controller != oldWidget.controller;
  }
}

class AppFormFieldBinding<T> extends StatefulWidget {
  const AppFormFieldBinding({
    super.key,
    required this.value,
    required this.builder,
    this.name,
    this.asyncValidator,
  });

  final String? name;
  final T? value;
  final AppAsyncFieldValidator<T>? asyncValidator;
  final Widget Function(BuildContext context, String? asyncError) builder;

  @override
  State<AppFormFieldBinding<T>> createState() => _AppFormFieldBindingState<T>();
}

class _AppFormFieldBindingState<T> extends State<AppFormFieldBinding<T>> {
  final Object _token = Object();
  AppFormController? _controller;
  String? _registeredName;
  String? _asyncError;
  String? _externalError;
  int _validationGeneration = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncRegistration();
  }

  @override
  void didUpdateWidget(AppFormFieldBinding<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _validationGeneration++;
      _setError(null);
    }
    _syncRegistration();
  }

  void _syncRegistration() {
    final nextController = AppForm.maybeControllerOf(context);
    if (_controller != nextController || _registeredName != widget.name) {
      _unregister();
      _controller = nextController;
    }
    final name = widget.name;
    if (name == null || _controller == null) return;
    _controller!._register(
      _AppFormFieldRegistration<T>(
        token: _token,
        name: name,
        value: widget.value,
        validate: _validate,
        clearError: () => _setError(null),
        setExternalError: _setExternalError,
      ),
    );
    _registeredName = name;
  }

  Future<String?> _validate() async {
    final validator = widget.asyncValidator;
    if (validator == null) {
      _setError(null);
      return null;
    }
    final generation = ++_validationGeneration;
    final error = await validator(widget.value);
    if (!mounted || generation != _validationGeneration) return _asyncError;
    _setError(error);
    return error;
  }

  void _setError(String? error) {
    if (_asyncError == error) return;
    if (mounted) setState(() => _asyncError = error);
  }

  void _setExternalError(String? error) {
    if (_externalError == error) return;
    if (mounted) setState(() => _externalError = error);
  }

  void _unregister() {
    final name = _registeredName;
    if (name != null) _controller?._unregister(name, _token);
    _registeredName = null;
  }

  @override
  void dispose() {
    _validationGeneration++;
    _unregister();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      widget.builder(context, _externalError ?? _asyncError);
}

class _AppFormFieldRegistration<T> {
  const _AppFormFieldRegistration({
    required this.token,
    required this.name,
    required this.value,
    required this.validate,
    required this.clearError,
    required this.setExternalError,
  });

  final Object token;
  final String name;
  final T? value;
  final Future<String?> Function() validate;
  final VoidCallback clearError;
  final ValueChanged<String?> setExternalError;

  Future<String?> validateAsync() => validate();
}
