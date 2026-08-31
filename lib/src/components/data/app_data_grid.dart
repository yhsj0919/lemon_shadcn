import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import 'package:trina_grid/trina_grid.dart';

import '../../foundation/app_shadcn_scope.dart';
import '../../foundation/app_theme_config.dart';
import '../../foundation/app_control_box.dart';
import '../../motion/app_page_transition.dart';
import '../actions/app_button.dart';
import '../display/app_empty.dart';
import '../forms/app_checkbox.dart';
import '../forms/app_collection_inputs.dart';
import '../forms/app_option.dart';
import '../forms/app_select.dart';
import '../forms/app_text_form_field.dart';
import '../navigation/app_menu_components.dart';
import '../navigation/app_navigation_components.dart';
import '../overlay/app_overlay_components.dart';

enum AppDataGridColumnType { text, number, boolean, date, time, dateTime }

enum AppDataGridColumnPin { none, start, end }

enum AppDataGridColumnWidthMode { fixed, content, fill }

enum AppDataGridSelectionMode { none, single, multiple }

enum AppDataGridColumnMenuMode { contextMenu, icon }

enum AppDataGridSortDirection { ascending, descending }

typedef AppDataGridCellBuilder<T> =
    Widget Function(BuildContext context, T row, Object? value);

typedef AppDataGridLoader<T> =
    Future<AppDataGridPage<T>> Function(AppDataGridQuery query);

typedef AppDataGridReorderCallback<T> =
    FutureOr<void> Function(List<Object> orderedKeys, List<T> orderedRows);

typedef AppDataGridCellChanged<T> =
    void Function(T row, String field, Object? value, Object? oldValue);

typedef AppDataGridRowColor<T> = Color? Function(T row);

typedef AppDataGridTreeRowColor<T> =
    Color? Function(T row, int depth, bool isParent);

typedef AppDataGridRowContextMenuBuilder<T> =
    List<shad.MenuItem> Function(BuildContext context, T row, int rowIndex);

typedef AppDataGridChildrenBuilder<T> = List<T> Function(T row);
typedef AppDataGridHasChildren<T> = bool Function(T row);
typedef AppDataGridChildrenLoader<T> = Future<List<T>> Function(T row);

class AppDataGridColumn<T> {
  const AppDataGridColumn({
    required this.id,
    required this.title,
    required this.value,
    this.type = AppDataGridColumnType.text,
    this.cellBuilder,
    this.width = 160,
    this.minWidth = 80,
    this.widthMode,
    this.flex = 1,
    this.pin = AppDataGridColumnPin.none,
    this.sortable = true,
    this.filterable = true,
    this.resizable = true,
    this.reorderable = true,
    this.editable = false,
    this.hidden = false,
    this.alignment = Alignment.center,
    this.titleAlignment,
  }) : assert(width > 0),
       assert(minWidth > 0),
       assert(flex > 0);

  final String id;
  final String title;
  final Object? Function(T row) value;
  final AppDataGridColumnType type;
  final AppDataGridCellBuilder<T>? cellBuilder;
  final double width;
  final double minWidth;

  /// Overrides the grid-wide column width mode for this column.
  final AppDataGridColumnWidthMode? widthMode;

  /// Relative width used when the resolved [widthMode] is
  /// [AppDataGridColumnWidthMode.fill].
  final double flex;
  final AppDataGridColumnPin pin;
  final bool sortable;
  final bool filterable;
  final bool resizable;
  final bool reorderable;
  final bool editable;
  final bool hidden;
  final Alignment alignment;
  final Alignment? titleAlignment;
}

class AppDataGridSort {
  const AppDataGridSort({required this.field, required this.direction});

  final String field;
  final AppDataGridSortDirection direction;
}

class AppDataGridFilter {
  const AppDataGridFilter({
    required this.field,
    required this.operator,
    required this.value,
  });

  final String field;
  final String operator;
  final Object? value;
}

class AppDataGridQuery {
  const AppDataGridQuery({
    this.page = 1,
    this.pageSize = 20,
    this.cursor,
    this.sorts = const [],
    this.filters = const [],
  });

  final int page;
  final int pageSize;
  final String? cursor;
  final List<AppDataGridSort> sorts;
  final List<AppDataGridFilter> filters;
}

class AppDataGridPage<T> {
  const AppDataGridPage({
    required this.items,
    this.total,
    this.nextCursor,
    this.hasMore = false,
  });

  final List<T> items;
  final int? total;
  final String? nextCursor;
  final bool hasMore;
}

class AppDataGridController {
  VoidCallback? _refresh;
  VoidCallback? _reload;
  void Function(int page)? _goToPage;

  void refresh() => _refresh?.call();

  void reload() => _reload?.call();

  void goToPage(int page) => _goToPage?.call(page);

  void _attach({
    required VoidCallback refresh,
    required VoidCallback reload,
    required void Function(int page) goToPage,
  }) {
    _refresh = refresh;
    _reload = reload;
    _goToPage = goToPage;
  }

  void _detach() {
    _refresh = null;
    _reload = null;
    _goToPage = null;
  }
}

enum _AppDataGridMode { local, paginated, infinite }

const _appDataGridSelectionField = '__app_selection__';
const _appDataGridDragField = '__app_drag__';
const _appDataGridTreeField = '__app_tree__';

class AppDataGrid<T> extends StatefulWidget {
  const AppDataGrid.local({
    super.key,
    required this.columns,
    required this.rows,
    required this.rowKey,
    this.controller,
    this.height = 420,
    this.shrinkWrap = false,
    this.selectionMode = AppDataGridSelectionMode.none,
    this.selectedKeys = const {},
    this.autoSelectFirstRow = false,
    this.onSelectionChanged,
    this.onRowDoubleTap,
    this.onCellChanged,
    this.sortable = false,
    this.reorderableRows = false,
    this.onRowsReordered,
    this.reorderableColumns = false,
    this.columnMenuMode = AppDataGridColumnMenuMode.contextMenu,
    this.showFilters = false,
    this.columnWidthMode = AppDataGridColumnWidthMode.fixed,
    this.showBorder = true,
    this.showInternalDividers = true,
    this.textStyle,
    this.headerTextStyle,
    this.cellTextStyle,
    this.headerBackgroundColor,
    this.headerForegroundColor,
    this.cellBackgroundColor,
    this.cellForegroundColor,
    this.striped = true,
    this.stripeColor,
    this.highlightHoveredRow = true,
    this.selectedRowColor,
    this.rowContextMenuBuilder,
    this.rowBackgroundColor,
    this.empty,
    this.buildChildren,
    this.hasChildren,
    this.childrenLoader,
    this.treeColumnId,
    this.defaultExpandedDepth = 0,
    this.expandedKeys,
    this.onExpandedKeysChanged,
    this.treeIndent = 0,
    this.treeRowBackgroundColor,
  }) : assert(height == null || height > 0),
       _mode = _AppDataGridMode.local,
       loader = null,
       pageSize = 20,
       pageSizeOptions = const [10, 20, 50, 100];

  const AppDataGrid.paginated({
    super.key,
    required this.columns,
    required this.loader,
    required this.rowKey,
    this.controller,
    this.height = 480,
    this.shrinkWrap = false,
    this.pageSize = 20,
    this.pageSizeOptions = const [10, 20, 50, 100],
    this.selectionMode = AppDataGridSelectionMode.none,
    this.selectedKeys = const {},
    this.autoSelectFirstRow = false,
    this.onSelectionChanged,
    this.onRowDoubleTap,
    this.onCellChanged,
    this.sortable = false,
    this.reorderableRows = false,
    this.onRowsReordered,
    this.reorderableColumns = false,
    this.columnMenuMode = AppDataGridColumnMenuMode.contextMenu,
    this.showFilters = false,
    this.columnWidthMode = AppDataGridColumnWidthMode.fixed,
    this.showBorder = true,
    this.showInternalDividers = true,
    this.textStyle,
    this.headerTextStyle,
    this.cellTextStyle,
    this.headerBackgroundColor,
    this.headerForegroundColor,
    this.cellBackgroundColor,
    this.cellForegroundColor,
    this.striped = true,
    this.stripeColor,
    this.highlightHoveredRow = true,
    this.selectedRowColor,
    this.rowContextMenuBuilder,
    this.rowBackgroundColor,
    this.empty,
    this.buildChildren,
    this.hasChildren,
    this.childrenLoader,
    this.treeColumnId,
    this.defaultExpandedDepth = 0,
    this.expandedKeys,
    this.onExpandedKeysChanged,
    this.treeIndent = 0,
    this.treeRowBackgroundColor,
  }) : assert(height == null || height > 0),
       _mode = _AppDataGridMode.paginated,
       rows = const [];

  const AppDataGrid.infinite({
    super.key,
    required this.columns,
    required this.loader,
    required this.rowKey,
    this.controller,
    this.height = 480,
    this.shrinkWrap = false,
    this.pageSize = 30,
    this.selectionMode = AppDataGridSelectionMode.none,
    this.selectedKeys = const {},
    this.autoSelectFirstRow = false,
    this.onSelectionChanged,
    this.onRowDoubleTap,
    this.onCellChanged,
    this.sortable = false,
    this.reorderableRows = false,
    this.onRowsReordered,
    this.reorderableColumns = false,
    this.columnMenuMode = AppDataGridColumnMenuMode.contextMenu,
    this.showFilters = false,
    this.columnWidthMode = AppDataGridColumnWidthMode.fixed,
    this.showBorder = true,
    this.showInternalDividers = true,
    this.textStyle,
    this.headerTextStyle,
    this.cellTextStyle,
    this.headerBackgroundColor,
    this.headerForegroundColor,
    this.cellBackgroundColor,
    this.cellForegroundColor,
    this.striped = true,
    this.stripeColor,
    this.highlightHoveredRow = true,
    this.selectedRowColor,
    this.rowContextMenuBuilder,
    this.rowBackgroundColor,
    this.empty,
    this.buildChildren,
    this.hasChildren,
    this.childrenLoader,
    this.treeColumnId,
    this.defaultExpandedDepth = 0,
    this.expandedKeys,
    this.onExpandedKeysChanged,
    this.treeIndent = 0,
    this.treeRowBackgroundColor,
  }) : assert(height == null || height > 0),
       _mode = _AppDataGridMode.infinite,
       rows = const [],
       pageSizeOptions = const [];

  final List<AppDataGridColumn<T>> columns;
  final List<T> rows;
  final AppDataGridLoader<T>? loader;
  final Object Function(T row) rowKey;
  final AppDataGridController? controller;

  /// Fixed grid height. Set to null to fill the bounded parent height.
  final double? height;

  /// Sizes the grid from its header, optional filter/footer, and loaded rows.
  /// When true this takes precedence over [height].
  final bool shrinkWrap;
  final int pageSize;
  final List<int> pageSizeOptions;
  final AppDataGridSelectionMode selectionMode;
  final Set<Object> selectedKeys;

  /// When true and [selectionMode] is [AppDataGridSelectionMode.single],
  /// select the first row on load and notify [onSelectionChanged].
  /// Ignored when [selectedKeys] is non-empty.
  final bool autoSelectFirstRow;
  final ValueChanged<List<T>>? onSelectionChanged;

  /// Called when a business row is double-clicked or double-tapped.
  final ValueChanged<T>? onRowDoubleTap;

  final AppDataGridCellChanged<T>? onCellChanged;

  /// Enables column sorting. Per-column [AppDataGridColumn.sortable] still
  /// applies when this is true.
  final bool sortable;
  final bool reorderableRows;
  final AppDataGridReorderCallback<T>? onRowsReordered;
  final bool reorderableColumns;
  final AppDataGridColumnMenuMode columnMenuMode;
  final bool showFilters;

  /// Default width strategy for columns that do not provide their own
  /// [AppDataGridColumn.widthMode].
  final AppDataGridColumnWidthMode columnWidthMode;

  /// Whether the grid draws its outer border.
  final bool showBorder;

  /// Whether horizontal and vertical separators are drawn inside the grid.
  /// The outer grid border is unaffected.
  final bool showInternalDividers;

  /// Shared typography applied to both the header and body cells.
  final TextStyle? textStyle;

  /// Typography merged over [textStyle] for column titles.
  final TextStyle? headerTextStyle;

  /// Typography merged over [textStyle] for body cells.
  final TextStyle? cellTextStyle;

  final Color? headerBackgroundColor;
  final Color? headerForegroundColor;
  final Color? cellBackgroundColor;
  final Color? cellForegroundColor;

  /// Whether alternating business rows use a secondary background color.
  final bool striped;

  /// Background used by every second business row when [striped] is true.
  /// Defaults to the current theme's muted color.
  final Color? stripeColor;

  /// Whether a row scales slightly in place with a rounded surface and shadow
  /// while hovered.
  ///
  /// Disable this to keep rows visually stationary under the pointer.
  final bool highlightHoveredRow;

  /// Background for the active single-selection row and checked
  /// multiple-selection rows. Defaults to a semantic blue surface so it
  /// remains distinguishable even when the theme primary color is neutral.
  final Color? selectedRowColor;

  /// Builds a context menu for a business row. Return an empty list to leave
  /// the platform's default secondary-click behavior untouched.
  final AppDataGridRowContextMenuBuilder<T>? rowContextMenuBuilder;

  /// Resolves a background for each business row independently. Returning
  /// null falls back to the configured stripe and then the cell background.
  final AppDataGridRowColor<T>? rowBackgroundColor;
  final Widget? empty;

  /// Returns children that are already available in memory.
  final AppDataGridChildrenBuilder<T>? buildChildren;

  /// Reports whether a row can have children. Required with
  /// [childrenLoader] so an unloaded parent can be distinguished from a leaf.
  final AppDataGridHasChildren<T>? hasChildren;

  /// Loads a parent's children the first time that parent is expanded.
  final AppDataGridChildrenLoader<T>? childrenLoader;

  /// Column that displays tree indentation and the disclosure control.
  /// Defaults to the first data column when tree rows are enabled.
  final String? treeColumnId;

  /// Number of levels expanded initially in uncontrolled mode. Zero keeps all
  /// parents collapsed; one expands root parents.
  final int defaultExpandedDepth;

  /// Controlled expanded row keys. When null the grid owns expansion state.
  final Set<Object>? expandedKeys;
  final ValueChanged<Set<Object>>? onExpandedKeysChanged;

  /// Horizontal indentation per tree level. Defaults to zero so parent and
  /// child values stay aligned; set to a positive value for classic nesting.
  final double treeIndent;

  /// Resolves a tree row background with access to its depth and parent state.
  /// Returning null falls back to [rowBackgroundColor], stripes, then the base
  /// cell background.
  final AppDataGridTreeRowColor<T>? treeRowBackgroundColor;
  final _AppDataGridMode _mode;

  @override
  State<AppDataGrid<T>> createState() => _AppDataGridState<T>();
}

class _AppDataGridState<T> extends State<AppDataGrid<T>> {
  final _paginationKey = GlobalKey<TrinaLazyPaginationState>();
  TrinaGridStateManager? _stateManager;
  Object? _loadError;
  String? _nextCursor;
  int _infinitePage = 0;
  int _generation = 0;
  var _wasEditing = false;
  var _allDataColumnsHidden = false;
  var _loadedRowCount = 0;
  final _rowMenuController = shad.OverlayController();
  final Set<Object> _expandedKeys = {};
  final Map<Object, List<T>> _loadedChildren = {};
  final Set<Object> _loadingChildren = {};
  final Set<Object> _initializedExpansionKeys = {};
  List<T> _currentRootRows = const [];

  bool get _treeEnabled =>
      widget.buildChildren != null || widget.hasChildren != null;

  bool get _useHoverScale => widget.highlightHoveredRow;

  Set<Object> get _effectiveExpandedKeys =>
      widget.expandedKeys ?? _expandedKeys;

  @override
  void initState() {
    super.initState();
    assert(
      widget.columns.isNotEmpty,
      'AppDataGrid requires at least one column.',
    );
    assert(
      widget.pageSizeOptions.isEmpty ||
          widget.pageSizeOptions.contains(widget.pageSize),
      'pageSizeOptions must contain pageSize.',
    );
    assert(widget.defaultExpandedDepth >= 0);
    assert(widget.treeIndent >= 0);
    assert(
      widget.childrenLoader == null || widget.hasChildren != null,
      'hasChildren is required when childrenLoader is provided.',
    );
    assert(
      widget.treeColumnId == null ||
          widget.columns.any((column) => column.id == widget.treeColumnId),
      'treeColumnId must match a data column id.',
    );
    assert(
      !_treeEnabled || !widget.reorderableRows,
      'reorderableRows is not supported with tree rows.',
    );
    _attachController();
  }

  @override
  void didUpdateWidget(covariant AppDataGrid<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._detach();
      _attachController();
    }
    if (widget._mode == _AppDataGridMode.local &&
        oldWidget.rows != widget.rows) {
      _replaceRows(widget.rows);
    } else if (!setEquals(oldWidget.expandedKeys, widget.expandedKeys) &&
        _treeEnabled) {
      _replaceVisibleTreeRows();
    } else if (!setEquals(oldWidget.selectedKeys, widget.selectedKeys)) {
      _syncSelectedKeys();
    }
  }

  @override
  void dispose() {
    _stateManager?.removeListener(_onGridStateChanged);
    _rowMenuController.dispose();
    widget.controller?._detach();
    super.dispose();
  }

  void _attachController() {
    widget.controller?._attach(
      refresh: _refresh,
      reload: _reload,
      goToPage: _goToPage,
    );
  }

  void _refresh() {
    if (widget._mode == _AppDataGridMode.paginated) {
      _paginationKey.currentState?.refresh();
    } else if (widget._mode == _AppDataGridMode.infinite) {
      _reload();
    } else {
      _replaceRows(widget.rows);
    }
  }

  void _reload() {
    if (widget._mode == _AppDataGridMode.paginated &&
        _paginationKey.currentState != null) {
      _paginationKey.currentState!.setPage(1);
      return;
    }
    setState(() {
      _loadError = null;
      _nextCursor = null;
      _infinitePage = 0;
      _generation++;
    });
  }

  void _goToPage(int page) {
    if (widget._mode == _AppDataGridMode.paginated) {
      _paginationKey.currentState?.setPage(math.max(1, page));
    }
  }

  void _replaceRows(List<T> rows) {
    final manager = _stateManager;
    if (manager == null) return;
    manager.removeAllRows(notify: false);
    manager.appendRows(_toTrinaRows(rows));
    if (_treeEnabled) _restoreTreeRows(manager);
    _scheduleColumnWidths();
  }

  void _replaceVisibleTreeRows() {
    final manager = _stateManager;
    if (manager == null) return;
    final source = widget._mode == _AppDataGridMode.local
        ? widget.rows
        : _currentRootRows;
    manager.removeAllRows(notify: false);
    manager.appendRows(_toTrinaRows(source));
    _restoreTreeRows(manager);
    manager.notifyListeners();
  }

  void _restoreTreeRows(TrinaGridStateManager manager) {
    if (manager.enabledRowGroups) {
      TrinaGridStateManager.initializeRows(
        manager.refColumns.originalList,
        _allTreeRows(manager.refRows.originalList).toList(),
        forceApplySortIdx: false,
      );
    } else {
      _configureTree(manager);
    }
    _applyTreeExpansion(manager);
  }

  AppDataGridColumnWidthMode _resolvedWidthMode(AppDataGridColumn<T> column) =>
      column.widthMode ?? widget.columnWidthMode;

  bool get _hasFillColumns => widget.columns.any(
    (column) => _resolvedWidthMode(column) == AppDataGridColumnWidthMode.fill,
  );

  void _scheduleColumnWidths() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final manager = _stateManager;
      if (manager == null) return;
      for (final definition in widget.columns) {
        if (_resolvedWidthMode(definition) !=
            AppDataGridColumnWidthMode.content) {
          continue;
        }
        final column = manager.refColumns.originalList
            .where((column) => column.field == definition.id)
            .firstOrNull;
        if (column != null) manager.autoFitColumn(context, column);
      }
      if (_hasFillColumns) {
        manager.activateColumnsAutoSize();
        manager.updateVisibilityLayout(notify: true);
      }
    });
  }

  void _setLoadedRowCount(int count) {
    if (!widget.shrinkWrap || count == _loadedRowCount || !mounted) return;
    setState(() => _loadedRowCount = count);
  }

  double _shrinkWrapHeight(BuildContext context) {
    final metrics =
        AppTheme.maybeOf(context)?.dataGrid ?? const AppDataGridMetrics();
    final rowCount = _treeEnabled
        ? _visibleTreeRowCount(
            widget._mode == _AppDataGridMode.local
                ? widget.rows
                : _currentRootRows,
          )
        : widget._mode == _AppDataGridMode.local
        ? widget.rows.length
        : _loadedRowCount;
    // Accounts for Trina's header/body/footer divider lines, grid edge, and
    // fractional pixel rounding. Without this chrome allowance, a grid that
    // is exactly one row high can spuriously create a vertical scrollbar.
    final chromeAllowance = widget.showBorder ? 8.0 : 6.0;
    final contentHeight =
        metrics.columnHeight +
        (widget.showFilters ? metrics.filterHeight : 0) +
        rowCount *
            (metrics.rowHeight + (widget.showInternalDividers ? .5 : 0)) +
        (widget._mode == _AppDataGridMode.local ? 0 : metrics.footerHeight) +
        chromeAllowance;
    if (widget._mode == _AppDataGridMode.local) return contentHeight;
    // Trina constrains a custom footer to at most 40% of the grid height.
    return math.max(contentHeight, metrics.footerHeight / .4);
  }

  int _visibleTreeRowCount(List<T> rows) {
    var count = 0;
    for (final row in rows) {
      count++;
      final key = widget.rowKey(row);
      if (!_effectiveExpandedKeys.contains(key)) continue;
      final children =
          _loadedChildren[key] ?? widget.buildChildren?.call(row) ?? [];
      count += _visibleTreeRowCount(children);
    }
    return count;
  }

  void _syncSelectedKeys() {
    final manager = _stateManager;
    if (manager == null ||
        widget.selectionMode == AppDataGridSelectionMode.none) {
      return;
    }

    var changed = false;
    for (final row in _allTreeRows(manager.refRows.originalList)) {
      final data = row.data;
      if (data is! T) continue;
      var shouldCheck = widget.selectedKeys.contains(widget.rowKey(data));
      var ancestor = row.parent;
      while (!shouldCheck && ancestor != null) {
        final ancestorData = ancestor.data;
        shouldCheck =
            ancestorData is T &&
            widget.selectedKeys.contains(widget.rowKey(ancestorData));
        ancestor = ancestor.parent;
      }
      if (row.checked == shouldCheck) continue;
      manager.setRowChecked(row, shouldCheck, notify: false);
      changed = true;
    }

    if (widget.selectionMode == AppDataGridSelectionMode.single) {
      manager.clearCurrentSelecting(notify: false);
      if (widget.selectedKeys.isNotEmpty) {
        final key = widget.selectedKeys.first;
        final idx = manager.refRows.indexWhere((row) {
          final data = row.data;
          return data is T && widget.rowKey(data) == key;
        });
        if (idx >= 0) {
          manager.setCurrentSelectingRowsByRange(idx, idx, notify: false);
          final cell = manager.refRows[idx].cells.values.firstOrNull;
          if (cell != null) {
            manager.setCurrentCell(cell, idx, notify: false);
          }
          changed = true;
        }
      }
    }

    if (changed) manager.notifyListeners();
  }

  List<TrinaColumn> _toTrinaColumns() {
    return [
      if (widget.reorderableRows) _toDragColumn(),
      if (widget.selectionMode == AppDataGridSelectionMode.multiple)
        _toSelectionColumn(),
      if (_treeEnabled) _toTreeColumn(),
      for (var index = 0; index < widget.columns.length; index++)
        _toTrinaColumn(widget.columns[index], index),
    ];
  }

  TrinaColumn _toDragColumn() {
    return TrinaColumn(
      title: '',
      field: _appDataGridDragField,
      type: TrinaColumnType.text(),
      width: 32,
      minWidth: 32,
      readOnly: true,
      frozen: TrinaColumnFrozen.start,
      enableSorting: false,
      enableFilterMenuItem: false,
      enableContextMenu: false,
      enableDropToResize: false,
      enableColumnDrag: false,
      enableRowDrag: false,
      suppressedAutoSize: true,
      titlePadding: EdgeInsets.zero,
      cellPadding: EdgeInsets.zero,
      textAlign: TrinaColumnTextAlign.center,
      titleTextAlign: TrinaColumnTextAlign.center,
      titleRenderer: (context) => _AppDataGridControlTitle(
        manager: context.stateManager,
        height: context.height,
        backgroundColor: widget.headerBackgroundColor,
        showDivider: widget.showInternalDividers,
      ),
      renderer: (context) => _AppDataGridRowDragHandle(
        manager: context.stateManager,
        row: context.row,
        columns: widget.columns,
      ),
    );
  }

  TrinaColumn _toSelectionColumn() {
    return TrinaColumn(
      title: '',
      field: _appDataGridSelectionField,
      type: TrinaColumnType.text(),
      width: 40,
      minWidth: 40,
      readOnly: true,
      frozen: TrinaColumnFrozen.start,
      enableSorting: false,
      enableFilterMenuItem: false,
      enableContextMenu: false,
      enableDropToResize: false,
      enableColumnDrag: false,
      enableRowChecked: false,
      suppressedAutoSize: true,
      titlePadding: EdgeInsets.zero,
      cellPadding: EdgeInsets.zero,
      textAlign: TrinaColumnTextAlign.center,
      titleTextAlign: TrinaColumnTextAlign.center,
      titleRenderer: (context) => _AppDataGridSelectionTitle(
        manager: context.stateManager,
        height: context.height,
        backgroundColor: widget.headerBackgroundColor,
        showDivider: widget.showInternalDividers,
      ),
      renderer: (context) => _AppDataGridRowCheckbox(
        manager: context.stateManager,
        row: context.row,
        rowIdx: context.rowIdx,
      ),
    );
  }

  TrinaColumn _toTreeColumn() {
    return TrinaColumn(
      title: '',
      field: _appDataGridTreeField,
      type: TrinaColumnType.text(),
      width: 40,
      minWidth: 40,
      readOnly: true,
      frozen: TrinaColumnFrozen.start,
      enableSorting: false,
      enableFilterMenuItem: false,
      enableContextMenu: false,
      enableDropToResize: false,
      enableColumnDrag: false,
      enableRowDrag: false,
      enableRowChecked: false,
      suppressedAutoSize: true,
      titlePadding: EdgeInsets.zero,
      cellPadding: EdgeInsets.zero,
      textAlign: TrinaColumnTextAlign.center,
      titleTextAlign: TrinaColumnTextAlign.center,
      titleRenderer: (context) => _AppDataGridControlTitle(
        manager: context.stateManager,
        height: context.height,
        backgroundColor: widget.headerBackgroundColor,
        showDivider: widget.showInternalDividers,
      ),
      renderer: (rendererContext) {
        final data = rendererContext.row.data as T;
        return _AppDataGridTreeControl(
          depth: rendererContext.row.depth,
          indent: widget.treeIndent,
          expandable: rendererContext.row.type.isGroup,
          expanded:
              rendererContext.row.type.isGroup &&
              rendererContext.row.type.group.expanded,
          loading: _loadingChildren.contains(widget.rowKey(data)),
          onToggle: () => _toggleTreeRow(rendererContext.row),
        );
      },
    );
  }

  TrinaColumn _toTrinaColumn(AppDataGridColumn<T> column, int index) {
    final widthMode = _resolvedWidthMode(column);
    return TrinaColumn(
      title: column.title,
      field: column.id,
      type: switch (column.type) {
        AppDataGridColumnType.text => TrinaColumnType.text(),
        AppDataGridColumnType.number => TrinaColumnType.number(),
        AppDataGridColumnType.boolean => TrinaColumnType.boolean(),
        AppDataGridColumnType.date => TrinaColumnType.date(),
        AppDataGridColumnType.time => TrinaColumnType.time(),
        AppDataGridColumnType.dateTime => TrinaColumnType.dateTime(),
      },
      width: widthMode == AppDataGridColumnWidthMode.fill
          ? math.max(column.minWidth, column.flex * 100)
          : column.width,
      minWidth: column.minWidth,
      suppressedAutoSize: widthMode != AppDataGridColumnWidthMode.fill,
      readOnly: !column.editable,
      // Keep tap-to-edit off; editable columns enter edit on double-tap only.
      enableEditingMode: false,
      hide: column.hidden,
      frozen: switch (column.pin) {
        AppDataGridColumnPin.none => TrinaColumnFrozen.none,
        AppDataGridColumnPin.start => TrinaColumnFrozen.start,
        AppDataGridColumnPin.end => TrinaColumnFrozen.end,
      },
      textAlign: _textAlign(column.alignment),
      titleTextAlign: _textAlign(column.titleAlignment ?? column.alignment),
      enableSorting: widget.sortable && column.sortable,
      enableFilterMenuItem: column.filterable,
      enableContextMenu: true,
      enableDropToResize: column.resizable,
      enableColumnDrag: false,
      enableRowDrag: false,
      enableRowChecked: false,
      titleRenderer: (rendererContext) => _AppDataGridColumnTitle(
        context: rendererContext,
        reorderable: widget.reorderableColumns && column.reorderable,
        menuMode: widget.columnMenuMode,
        backgroundColor: widget.headerBackgroundColor,
        foregroundColor: widget.headerForegroundColor,
        showDivider: widget.showInternalDividers,
        items: _columnMenuItems(
          rendererContext.stateManager,
          rendererContext.column,
        ),
      ),
      renderer: column.cellBuilder == null
          ? null
          : (rendererContext) {
              final row = rendererContext.row.data as T;
              return Builder(
                builder: (context) => column.cellBuilder!(
                  context,
                  row,
                  rendererContext.cell.value,
                ),
              );
            },
    );
  }

  List<shad.MenuItem> _columnMenuItems(
    TrinaGridStateManager manager,
    TrinaColumn column,
  ) {
    final locale = manager.localeText;
    final canFreeze = manager.enoughFrozenColumnsWidth(
      (manager.maxWidth ?? column.width) - column.width,
    );
    return [
      if (column.frozen.isFrozen)
        AppMenuButton(
          onPressed: (_) =>
              manager.toggleFrozenColumn(column, TrinaColumnFrozen.none),
          child: Text(locale.unfreezeColumn),
        )
      else ...[
        AppMenuButton(
          enabled: canFreeze,
          onPressed: (_) =>
              manager.toggleFrozenColumn(column, TrinaColumnFrozen.start),
          child: Text(locale.freezeColumnToStart),
        ),
        AppMenuButton(
          enabled: canFreeze,
          onPressed: (_) =>
              manager.toggleFrozenColumn(column, TrinaColumnFrozen.end),
          child: Text(locale.freezeColumnToEnd),
        ),
      ],
      const AppMenuDivider(),
      AppMenuButton(
        onPressed: (_) {
          manager.autoFitColumn(context, column);
          manager.notifyResizingListeners();
        },
        child: Text(locale.autoFitColumn),
      ),
      if (column.enableHideColumnMenuItem)
        AppMenuButton(
          onPressed: (_) => manager.hideColumn(column, true),
          child: Text(locale.hideColumn),
        ),
      if (column.enableSetColumnsMenuItem)
        AppMenuButton(
          onPressed: (_) => _showSetColumns(),
          child: Text(locale.setColumns),
        ),
      if (column.enableFilterMenuItem) ...[
        const AppMenuDivider(),
        AppMenuButton(
          onPressed: (_) => _showSetFilters(calledColumn: column),
          child: Text(locale.setFilter),
        ),
        AppMenuButton(
          enabled: manager.hasFilter,
          onPressed: (_) => manager.setFilter(null),
          child: Text(locale.resetFilter),
        ),
      ],
    ];
  }

  TrinaColumnTextAlign _textAlign(Alignment alignment) {
    if (alignment.x > .5) return TrinaColumnTextAlign.end;
    if (alignment.x < -.5) return TrinaColumnTextAlign.start;
    return TrinaColumnTextAlign.center;
  }

  // Trina's row drag APIs operate on List<TrinaRow<dynamic>>. Keep the
  // runtime row type unbound as well; TrinaRow<T> causes its internal
  // FilteredList to reject dragged rows when it inserts them after a move.
  List<TrinaRow> _toTrinaRows(List<T> rows) {
    _currentRootRows = List<T>.of(rows);
    return [for (final row in rows) _toTrinaRow(row, depth: 0)];
  }

  TrinaRow _toTrinaRow(
    T row, {
    required int depth,
    bool ancestorSelected = false,
  }) {
    final key = widget.rowKey(row);
    final provided =
        widget.buildChildren?.call(row) ?? List<T>.empty(growable: false);
    final children = _loadedChildren[key] ?? provided;
    final expandable =
        children.isNotEmpty || (widget.hasChildren?.call(row) ?? false);
    if (widget.expandedKeys == null &&
        expandable &&
        depth < widget.defaultExpandedDepth &&
        _initializedExpansionKeys.add(key)) {
      _expandedKeys.add(key);
    }
    final checked = ancestorSelected || widget.selectedKeys.contains(key);
    final childRows = [
      for (final child in children)
        _toTrinaRow(child, depth: depth + 1, ancestorSelected: checked),
    ];
    final trinaRow = TrinaRow(
      key: ValueKey(key),
      data: row,
      checked: checked,
      type: expandable
          ? TrinaRowType.group(
              children: FilteredList(initialList: childRows),
              expanded: false,
            )
          : null,
      cells: {
        if (widget.reorderableRows) _appDataGridDragField: TrinaCell(value: ''),
        if (widget.selectionMode == AppDataGridSelectionMode.multiple)
          _appDataGridSelectionField: TrinaCell(value: ''),
        if (_treeEnabled) _appDataGridTreeField: TrinaCell(value: ''),
        for (final column in widget.columns)
          column.id: TrinaCell(value: column.value(row)),
      },
    );
    for (final child in childRows) {
      child.setParent(trinaRow);
    }
    return trinaRow;
  }

  void _configureTree(TrinaGridStateManager manager) {
    if (!_treeEnabled) return;
    final allRows = _allTreeRows(manager.refRows.originalList).toList();
    TrinaGridStateManager.initializeRows(
      manager.refColumns.originalList,
      allRows,
      forceApplySortIdx: false,
    );
    manager.setRowGroup(
      TrinaRowGroupTreeDelegate(
        showFirstExpandableIcon: true,
        showCount: false,
        // AppDataGrid renders its own disclosure control so it can show the
        // async loading state and use App styling. Returning no expandable
        // column prevents Trina's default arrow from being drawn as well.
        resolveColumnDepth: (_) => null,
        showText: (_) => true,
        onToggled: ({required row, required expanded}) {
          final data = row.data;
          if (data is T) _recordExpanded(widget.rowKey(data), expanded);
        },
      ),
      notify: false,
    );
  }

  void _applyTreeExpansion(TrinaGridStateManager manager) {
    if (!_treeEnabled) return;
    final groups =
        _allTreeRows(
            manager.refRows.originalList,
          ).where((row) => row.type.isGroup).toList()
          ..sort((left, right) => left.depth.compareTo(right.depth));
    for (final row in groups) {
      final data = row.data;
      if (data is! T) continue;
      final expanded = _effectiveExpandedKeys.contains(widget.rowKey(data));
      if (row.type.group.expanded == expanded) continue;
      manager.toggleExpandedRowGroup(
        rowGroup: row,
        expanded: expanded,
        notify: false,
      );
    }
    manager.notifyListeners();
  }

  void _recordExpanded(Object key, bool expanded) {
    final next = Set<Object>.of(_effectiveExpandedKeys);
    expanded ? next.add(key) : next.remove(key);
    if (widget.expandedKeys == null) {
      _expandedKeys
        ..clear()
        ..addAll(next);
    }
    widget.onExpandedKeysChanged?.call(Set<Object>.unmodifiable(next));
  }

  Future<void> _toggleTreeRow(TrinaRow row) async {
    if (!row.type.isGroup) return;
    final data = row.data;
    if (data is! T) return;
    final key = widget.rowKey(data);
    final willExpand = !row.type.group.expanded;
    if (willExpand &&
        row.type.group.children.originalList.isEmpty &&
        widget.childrenLoader != null &&
        !_loadedChildren.containsKey(key)) {
      if (!_loadingChildren.add(key)) return;
      setState(() {});
      try {
        _loadedChildren[key] = await widget.childrenLoader!(data);
      } catch (error) {
        if (mounted) setState(() => _loadError = error);
        return;
      } finally {
        _loadingChildren.remove(key);
      }
      if (!mounted) return;
      _recordExpanded(key, true);
      final manager = _stateManager;
      if (manager != null) {
        final childRows = [
          for (final child in _loadedChildren[key]!)
            _toTrinaRow(
              child,
              depth: row.depth + 1,
              ancestorSelected: row.checked == true,
            ),
        ];
        TrinaGridStateManager.initializeRows(
          manager.refColumns.originalList,
          childRows,
        );
        for (final child in childRows) {
          child.setParent(row);
        }
        row.type.group.children.addAll(childRows);
        if (widget.expandedKeys == null) {
          manager.toggleExpandedRowGroup(rowGroup: row);
          if (mounted && widget.shrinkWrap) setState(() {});
        } else {
          setState(() {});
        }
      }
      return;
    }
    final manager = _stateManager;
    if (manager != null && willExpand) {
      TrinaGridStateManager.initializeRows(
        manager.refColumns.originalList,
        _allTreeRows(row.type.group.children.originalList).toList(),
        forceApplySortIdx: false,
      );
    }
    manager?.toggleExpandedRowGroup(rowGroup: row);
    if (mounted && widget.shrinkWrap) setState(() {});
  }

  AppDataGridQuery _query({
    required int page,
    required int pageSize,
    String? cursor,
    TrinaColumn? sortColumn,
    List<TrinaRow> filterRows = const [],
  }) {
    final sorts = sortColumn == null || sortColumn.sort.isNone
        ? const <AppDataGridSort>[]
        : [
            AppDataGridSort(
              field: sortColumn.field,
              direction: sortColumn.sort.isAscending
                  ? AppDataGridSortDirection.ascending
                  : AppDataGridSortDirection.descending,
            ),
          ];
    final filterMap = FilterHelper.convertRowsToMap(filterRows);
    final filters = <AppDataGridFilter>[];
    for (final entry in filterMap.entries) {
      for (final condition in entry.value) {
        for (final value in condition.entries) {
          filters.add(
            AppDataGridFilter(
              field: entry.key,
              operator: value.key,
              value: value.value,
            ),
          );
        }
      }
    }
    return AppDataGridQuery(
      page: page,
      pageSize: pageSize,
      cursor: cursor,
      sorts: sorts,
      filters: filters,
    );
  }

  Future<TrinaLazyPaginationResponse> _fetchPage(
    TrinaLazyPaginationRequest request,
  ) async {
    try {
      final page = await widget.loader!(
        _query(
          page: request.page,
          pageSize: request.pageSize,
          sortColumn: request.sortColumn,
          filterRows: request.filterRows,
        ),
      );
      if (mounted && _loadError != null) setState(() => _loadError = null);
      final total =
          page.total ??
          ((request.page - 1) * request.pageSize +
              page.items.length +
              (page.hasMore ? request.pageSize : 0));
      _setLoadedRowCount(page.items.length);
      _scheduleColumnWidths();
      return TrinaLazyPaginationResponse(
        totalPage: math.max(1, (total / request.pageSize).ceil()),
        totalRecords: page.total,
        rows: _toTrinaRows(page.items),
      );
    } catch (error) {
      if (mounted) setState(() => _loadError = error);
      rethrow;
    }
  }

  Future<TrinaInfinityScrollRowsResponse> _fetchMore(
    TrinaInfinityScrollRowsRequest request,
  ) async {
    if (request.lastRow == null) {
      _nextCursor = null;
      _infinitePage = 0;
    }
    try {
      final nextPage = _infinitePage + 1;
      final page = await widget.loader!(
        _query(
          page: nextPage,
          pageSize: widget.pageSize,
          cursor: _nextCursor,
          sortColumn: request.sortColumn,
          filterRows: request.filterRows,
        ),
      );
      _infinitePage = nextPage;
      _nextCursor = page.nextCursor;
      _setLoadedRowCount(
        request.lastRow == null
            ? page.items.length
            : _loadedRowCount + page.items.length,
      );
      if (mounted && _loadError != null) setState(() => _loadError = null);
      _scheduleColumnWidths();
      return TrinaInfinityScrollRowsResponse(
        isLast: !page.hasMore,
        rows: _toTrinaRows(page.items),
      );
    } catch (error) {
      if (mounted) setState(() => _loadError = error);
      rethrow;
    }
  }

  void _onLoaded(TrinaGridOnLoadedEvent event) {
    _stateManager?.removeListener(_onGridStateChanged);
    _stateManager = event.stateManager;
    _configureTree(event.stateManager);
    _wasEditing = event.stateManager.isEditing;
    _stateManager!.addListener(_onGridStateChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && identical(_stateManager, event.stateManager)) {
        setState(() {});
        _scheduleColumnWidths();
      }
    });
    // Wait until Trina's select-mode auto-select post-frame callback finishes.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _applyTreeExpansion(event.stateManager);
        _applyInitialSelection();
      });
    });
  }

  void _applyInitialSelection() {
    if (widget.selectedKeys.isNotEmpty) {
      _syncSelectedKeys();
      return;
    }
    if (!widget.autoSelectFirstRow ||
        widget.selectionMode != AppDataGridSelectionMode.single) {
      return;
    }
    final manager = _stateManager;
    if (manager == null) return;

    var current = manager.currentRow;
    if (current == null && manager.refRows.isNotEmpty) {
      final cell = manager.refRows.first.cells.values.firstOrNull;
      if (cell != null) {
        manager.setCurrentCell(cell, 0, notify: false);
        current = manager.currentRow;
      }
    }
    final row = current?.data;
    if (current == null || row is! T) return;

    manager.setRowChecked(current, true, notify: false, checkedViaSelect: true);
    manager.notifyListeners();
    widget.onSelectionChanged?.call([row]);
  }

  void _onGridStateChanged() {
    final manager = _stateManager;
    if (manager == null) return;
    final editing = manager.isEditing;
    if (_wasEditing && !editing) {
      for (final column in manager.refColumns) {
        column.enableEditingMode = false;
      }
    }
    _wasEditing = editing;

    final allHidden = _areAllDataColumnsHidden();
    if (allHidden != _allDataColumnsHidden && mounted) {
      setState(() => _allDataColumnsHidden = allHidden);
    }
  }

  bool _isControlField(String field) =>
      field == _appDataGridSelectionField ||
      field == _appDataGridDragField ||
      field == _appDataGridTreeField;

  bool _areAllDataColumnsHidden() {
    final manager = _stateManager;
    if (manager == null) return false;
    final dataColumns = manager.refColumns.originalList.where(
      (column) => !_isControlField(column.field),
    );
    if (dataColumns.isEmpty) return false;
    return dataColumns.every((column) => column.hide);
  }

  void _restoreAllDataColumns() {
    final manager = _stateManager;
    if (manager == null) return;
    final hidden = manager.refColumns.originalList
        .where((column) => column.hide)
        .toList(growable: false);
    if (hidden.isEmpty) return;
    manager.hideColumns(hidden, false);
  }

  void _showSetColumns() {
    final manager = _stateManager;
    if (manager == null || !mounted) return;
    AppDialog.show<void>(
      context: context,
      builder: (dialogContext) => _AppDataGridColumnsDialog(
        manager: manager,
        isControlField: _isControlField,
      ),
    );
  }

  void _showSetFilters({TrinaColumn? calledColumn}) {
    final manager = _stateManager;
    if (manager == null || !mounted) return;
    AppDialog.show<void>(
      context: context,
      builder: (_) => _AppDataGridFiltersDialog(
        manager: manager,
        calledColumn: calledColumn,
        isControlField: _isControlField,
      ),
    );
  }

  bool _isFieldEditable(String field) {
    for (final column in widget.columns) {
      if (column.id == field) return column.editable;
    }
    return false;
  }

  void _onRowDoubleTap(TrinaGridOnRowDoubleTapEvent event) {
    final data = event.row.data;
    if (_treeEnabled && event.row.type.isGroup) {
      unawaited(_toggleTreeRow(event.row));
      return;
    }
    if (data is T) widget.onRowDoubleTap?.call(data);

    if (!_isFieldEditable(event.cell.column.field)) return;
    final manager = _stateManager;
    if (manager == null || !manager.mode.isEditableMode) return;

    event.cell.column.enableEditingMode = true;
    manager.setCurrentCell(event.cell, event.rowIdx, notify: false);
    manager.setEditing(true);
  }

  void _onSelected(TrinaGridOnSelectedEvent event) {
    if (widget.selectionMode != AppDataGridSelectionMode.single) return;
    final row = event.row?.data;
    if (row is T) widget.onSelectionChanged?.call([row]);
  }

  void _onChanged(TrinaGridOnChangedEvent event) {
    final row = event.row.data;
    if (row is T) {
      widget.onCellChanged?.call(
        row,
        event.column.field,
        event.value,
        event.oldValue,
      );
    }
  }

  void _onRowChecked(TrinaGridOnRowCheckedEvent event) {
    final rows = _stateManager == null
        ? List<T>.empty()
        : _allTreeRows(_stateManager!.refRows.originalList)
              .where((row) => row.checked == true)
              .map((row) => row.data)
              .whereType<T>()
              .toList(growable: false);
    widget.onSelectionChanged?.call(rows);
  }

  Iterable<TrinaRow> _allTreeRows(Iterable<TrinaRow> rows) sync* {
    for (final row in rows) {
      yield row;
      if (row.type.isGroup) {
        yield* _allTreeRows(row.type.group.children.originalList);
      }
    }
  }

  Future<void> _onRowsMoved(TrinaGridOnRowsMovedEvent event) async {
    final rows =
        _stateManager?.refRows
            .map((row) => row.data)
            .whereType<T>()
            .toList(growable: false) ??
        List<T>.empty();
    await widget.onRowsReordered?.call(
      rows.map(widget.rowKey).toList(growable: false),
      rows,
    );
  }

  void _onRowSecondaryTap(TrinaGridOnRowSecondaryTapEvent event) {
    final builder = widget.rowContextMenuBuilder;
    if (builder == null) return;
    final row = event.row.data;
    if (row is! T) return;
    final items = builder(context, row, event.rowIdx);
    if (items.isEmpty) return;
    final theme = shad.Theme.of(context);
    _rowMenuController.show(
      context,
      shad.MenuConfiguration(
        position: event.offset + const Offset(8, 0),
        alignment: Alignment.topLeft,
        anchorAlignment: Alignment.topRight,
        follow: false,
        modal: true,
        consumeOutsideTaps: false,
        dismissBackdropFocus: false,
        overlayBarrier: shad.OverlayBarrier(
          borderRadius: BorderRadius.circular(theme.radiusMd),
          barrierColor: const Color(0xB2000000),
        ),
      ),
      builder: (context) => AppDropdownMenu(children: items),
    );
  }

  TrinaGridConfiguration _configuration(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final metrics =
        AppTheme.maybeOf(context)?.dataGrid ?? const AppDataGridMetrics();
    final textStyle = DefaultTextStyle.of(
      context,
    ).style.copyWith(fontSize: metrics.fontSize).merge(widget.textStyle);
    final cellTextStyle = textStyle.merge(widget.cellTextStyle);
    final columnTextStyle = textStyle
        .copyWith(fontWeight: FontWeight.w600)
        .merge(widget.headerTextStyle);
    final rowBackground = widget.cellBackgroundColor ?? colors.background;
    final stripeBackground = widget.stripeColor ?? colors.muted;
    final selectionBackground =
        widget.selectedRowColor ??
        (Theme.of(context).brightness == Brightness.dark
            ? const Color(0xff1e3a5f)
            : const Color(0xffdbeafe));
    final style = TrinaGridStyleConfig(
      enableGridBorderShadow: false,
      enableColumnBorderVertical: widget.showInternalDividers,
      enableColumnBorderHorizontal: widget.showInternalDividers,
      enableCellBorderVertical: widget.showInternalDividers,
      enableCellBorderHorizontal: widget.showInternalDividers,
      enableRowHoverColor: widget.highlightHoveredRow,
      gridBackgroundColor: rowBackground,
      rowColor: rowBackground,
      oddRowColor: widget.striped ? rowBackground : null,
      evenRowColor: widget.striped ? stripeBackground : null,
      // The hover wrapper supplies elevation and shadow. Keep the row surface
      // neutral, matching the raised white surface in light themes instead of
      // combining the lift with the old accent-color highlight.
      rowHoveredColor: _useHoverScale ? Colors.white : colors.accent,
      activatedColor: selectionBackground,
      rowCheckedColor: selectionBackground,
      columnUnselectedColor: colors.mutedForeground,
      columnActiveColor: colors.primary,
      columnCheckedColor: colors.primaryForeground,
      columnCheckedSide: BorderSide(color: colors.border, width: 1),
      cellUnselectedColor: colors.mutedForeground,
      cellActiveColor: colors.primary,
      cellCheckedColor: colors.primaryForeground,
      cellCheckedSide: BorderSide(color: colors.border, width: 1),
      cellColorInEditState: widget.cellBackgroundColor ?? colors.background,
      cellColorInReadOnlyState: widget.striped
          ? Colors.transparent
          : widget.cellBackgroundColor ?? colors.background,
      // Keep cell fills transparent so row selection/hover colors show through.
      cellReadonlyColor: null,
      cellDefaultColor: null,
      menuBackgroundColor: colors.popover,
      gridBorderColor: widget.showBorder ? colors.border : Colors.transparent,
      borderColor: colors.border,
      activatedBorderColor: Colors.transparent,
      inactivatedBorderColor: Colors.transparent,
      unfocusedSelectionColor: Colors.transparent,
      iconColor: colors.mutedForeground,
      disabledIconColor: colors.mutedForeground.withValues(alpha: .35),
      rowHeight: metrics.rowHeight,
      columnHeight: metrics.columnHeight,
      columnFilterHeight: widget.showFilters ? metrics.filterHeight : 0,
      defaultCellPadding: EdgeInsets.symmetric(
        horizontal: metrics.horizontalPadding,
      ),
      defaultColumnTitlePadding: EdgeInsets.symmetric(
        horizontal: metrics.horizontalPadding,
      ),
      cellTextStyle: cellTextStyle.copyWith(
        color:
            widget.cellForegroundColor ??
            widget.cellTextStyle?.color ??
            widget.textStyle?.color ??
            colors.foreground,
      ),
      columnTextStyle: columnTextStyle.copyWith(
        color:
            widget.headerForegroundColor ??
            widget.headerTextStyle?.color ??
            widget.textStyle?.color ??
            colors.foreground,
      ),
      gridBorderRadius: BorderRadius.circular(theme.radiusMd),
      gridPopupBorderRadius: BorderRadius.circular(theme.radiusMd),
      gridBorderWidth: widget.showBorder ? 1 : 0,
      cellVerticalBorderWidth: widget.showInternalDividers ? .5 : 0,
      cellHorizontalBorderWidth: widget.showInternalDividers ? .5 : 0,
      filterHeaderColor: widget.headerBackgroundColor,
    );
    return TrinaGridConfiguration(
      // AppDataGrid owns both scrollbars as overlays so neither axis consumes
      // row height or column width inside Trina's layout.
      scrollbar: const TrinaGridScrollbarConfig(
        showHorizontal: false,
        showVertical: false,
        columnShowScrollWidth: false,
      ),
      columnSize: TrinaGridColumnSizeConfig(
        autoSizeMode: _hasFillColumns
            ? TrinaAutoSizeMode.scale
            : TrinaAutoSizeMode.none,
      ),
      selectingMode: TrinaGridSelectingMode.row,
      enableAutoSelectFirstRow: widget.autoSelectFirstRow,
      rowSelectionCheckBoxBehavior: switch (widget.selectionMode) {
        AppDataGridSelectionMode.single =>
          TrinaGridRowSelectionCheckBoxBehavior.singleRowCheck,
        AppDataGridSelectionMode.multiple || AppDataGridSelectionMode.none =>
          TrinaGridRowSelectionCheckBoxBehavior.none,
      },
      style: style,
      localeText: const TrinaGridLocaleText.china(),
      paginationShowTotalRows: true,
      paginationEnableGotoPage: false,
    );
  }

  Widget _buildFooter(TrinaGridStateManager manager) {
    final metrics =
        AppTheme.maybeOf(context)?.dataGrid ?? const AppDataGridMetrics();
    manager.footerHeight = metrics.footerHeight;
    if (widget._mode == _AppDataGridMode.paginated) {
      return TrinaLazyPagination(
        key: _paginationKey,
        initialPageSize: widget.pageSize,
        pageSizes: widget.pageSizeOptions,
        showPageSizeSelector: widget.pageSizeOptions.isNotEmpty,
        showTotalRows: true,
        enableGotoPage: false,
        stateManager: manager,
        fetch: _fetchPage,
        builder: (context, state) => _AppDataGridPager(
          state: state,
          pageSizeOptions: widget.pageSizeOptions,
          loadFailed: _loadError != null,
        ),
      );
    }
    if (widget._mode == _AppDataGridMode.infinite) {
      return TrinaInfinityScrollRows(stateManager: manager, fetch: _fetchMore);
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = shad.Theme.of(context);
    final checkboxTheme = Theme.of(context).copyWith(
      checkboxTheme: CheckboxThemeData(
        visualDensity: VisualDensity.compact,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(appTheme.radiusSm),
        ),
        side: BorderSide(color: appTheme.colorScheme.border, width: 1),
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? appTheme.colorScheme.primary
              : appTheme.colorScheme.background,
        ),
        checkColor: WidgetStatePropertyAll(
          appTheme.colorScheme.primaryForeground,
        ),
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
    );
    final columns = _toTrinaColumns();
    final rows = widget._mode == _AppDataGridMode.local
        ? _toTrinaRows(widget.rows)
        : <TrinaRow>[];
    final empty =
        widget.empty ??
        const AppEmpty(icon: Icon(shad.LucideIcons.inbox), title: Text('暂无数据'));

    final grid = Theme(
      data: checkboxTheme,
      child: TrinaGrid(
        key: ValueKey(_generation),
        columns: columns,
        rows: rows,
        rowWrapper: _useHoverScale
            ? (_, rowWidget, row, manager) {
                final key = rowWidget.key.toString();
                final segment = key.contains('left_frozen_row_')
                    ? _AppDataGridRowSegment.left
                    : key.contains('right_frozen_row_')
                    ? _AppDataGridRowSegment.right
                    : _AppDataGridRowSegment.body;
                return _AppDataGridHoverRow(
                  key: rowWidget.key,
                  row: row,
                  manager: manager,
                  segment: segment,
                  borderColor: appTheme.colorScheme.border,
                  shadowColor: appTheme.colorScheme.foreground,
                  child: rowWidget,
                );
              }
            : null,
        configuration: _configuration(context),
        noRowsWidget: empty,
        mode: widget.selectionMode == AppDataGridSelectionMode.single
            ? TrinaGridMode.selectWithOneTap
            : TrinaGridMode.normal,
        onLoaded: _onLoaded,
        onChanged: _onChanged,
        onSelected: widget.selectionMode == AppDataGridSelectionMode.single
            ? _onSelected
            : null,
        onRowDoubleTap: _onRowDoubleTap,
        onRowSecondaryTap: widget.rowContextMenuBuilder == null
            ? null
            : _onRowSecondaryTap,
        onRowChecked: _onRowChecked,
        onRowsMoved: _onRowsMoved,
        rowColorCallback:
            widget.rowBackgroundColor == null &&
                widget.treeRowBackgroundColor == null
            ? null
            : (rowContext) {
                final row = rowContext.row;
                final data = row.data as T;
                return widget.treeRowBackgroundColor?.call(
                      data,
                      row.depth,
                      row.type.isGroup,
                    ) ??
                    widget.rowBackgroundColor?.call(data) ??
                    (widget.striped && rowContext.rowIdx.isOdd
                        ? widget.stripeColor ?? appTheme.colorScheme.muted
                        : widget.cellBackgroundColor ??
                              appTheme.colorScheme.background);
              },
        createFooter: widget._mode == _AppDataGridMode.local
            ? null
            : _buildFooter,
      ),
    );
    final content = Stack(
      children: [
        Positioned.fill(child: grid),
        if (_stateManager case final manager?)
          Positioned.fill(
            child: _AppDataGridOverlayScrollbars(manager: manager),
          ),
        if (_allDataColumnsHidden)
          Positioned.fill(
            child: ColoredBox(
              color: shad.Theme.of(context).colorScheme.background,
              child: Center(
                child: AppEmpty(
                  icon: const Icon(shad.LucideIcons.columns3),
                  title: const Text('列已全部隐藏'),
                  description: const Text('请选择要显示的列，或一键恢复全部列。'),
                  action: AppWidgetGroup(
                    children: [
                      AppButton.outline(
                        onPressed: _showSetColumns,
                        child: const Text('选择列'),
                      ),
                      AppButton.primary(
                        onPressed: _restoreAllDataColumns,
                        child: const Text('恢复全部列'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        if (_loadError != null)
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: _AppDataGridError(onRetry: _refresh),
          ),
      ],
    );
    if (widget.shrinkWrap) {
      return SizedBox(height: _shrinkWrapHeight(context), child: content);
    }
    if (widget.height case final height?) {
      return SizedBox(height: height, child: content);
    }
    return SizedBox.expand(child: content);
  }
}

class _AppDataGridTreeControl extends StatelessWidget {
  const _AppDataGridTreeControl({
    required this.depth,
    required this.indent,
    required this.expandable,
    required this.expanded,
    required this.loading,
    required this.onToggle,
  });

  final int depth;
  final double indent;
  final bool expandable;
  final bool expanded;
  final bool loading;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    return Padding(
      padding: EdgeInsetsDirectional.only(start: depth * indent),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: loading
              ? Padding(
                  padding: const EdgeInsets.all(5),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: theme.colorScheme.mutedForeground,
                  ),
                )
              : expandable
              ? Semantics(
                  button: true,
                  expanded: expanded,
                  label: expanded ? '折叠' : '展开',
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    iconSize: 16,
                    splashRadius: 12,
                    onPressed: onToggle,
                    icon: Icon(
                      expanded
                          ? shad.LucideIcons.chevronDown
                          : shad.LucideIcons.chevronRight,
                      color: theme.colorScheme.mutedForeground,
                    ),
                  ),
                )
              : null,
        ),
      ),
    );
  }
}

class _AppDataGridOverlayScrollbars extends StatelessWidget {
  const _AppDataGridOverlayScrollbars({required this.manager});

  final TrinaGridStateManager manager;

  @override
  Widget build(BuildContext context) {
    final horizontal = manager.scroll.bodyRowsHorizontal;
    final vertical = manager.scroll.bodyRowsVertical;
    final hasHorizontalOverflow =
        horizontal?.hasClients == true &&
        horizontal!.position.maxScrollExtent > 0;
    final hasVerticalOverflow =
        vertical?.hasClients == true && vertical!.position.maxScrollExtent > 0;
    if (!hasHorizontalOverflow && !hasVerticalOverflow) {
      return const SizedBox.shrink();
    }
    final colors = shad.Theme.of(context).colorScheme;
    final thumbColor = colors.mutedForeground.withValues(alpha: .55);
    const thickness = 8.0;
    const inset = 2.0;
    return Stack(
      children: [
        if (hasVerticalOverflow)
          PositionedDirectional(
            top: inset,
            bottom: inset + thickness,
            end: inset,
            width: thickness,
            child: RawScrollbar(
              controller: vertical,
              thumbVisibility: false,
              interactive: true,
              thickness: thickness,
              radius: const Radius.circular(thickness / 2),
              thumbColor: thumbColor,
              scrollbarOrientation: ScrollbarOrientation.right,
              child: const SizedBox.expand(),
            ),
          ),
        if (hasHorizontalOverflow)
          PositionedDirectional(
            start: inset,
            end: inset + thickness,
            bottom: inset,
            height: thickness,
            child: RawScrollbar(
              controller: horizontal,
              thumbVisibility: false,
              interactive: true,
              thickness: thickness,
              radius: const Radius.circular(thickness / 2),
              thumbColor: thumbColor,
              scrollbarOrientation: ScrollbarOrientation.bottom,
              child: const SizedBox.expand(),
            ),
          ),
      ],
    );
  }
}

class _AppDataGridColumnTitle extends StatelessWidget {
  const _AppDataGridColumnTitle({
    required this.context,
    required this.reorderable,
    required this.menuMode,
    required this.items,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.showDivider,
  });

  final TrinaColumnTitleRendererContext context;
  final bool reorderable;
  final AppDataGridColumnMenuMode menuMode;
  final List<shad.MenuItem> items;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool showDivider;

  @override
  Widget build(BuildContext buildContext) {
    final column = context.column;
    final manager = context.stateManager;
    final style = manager.configuration.style;
    final sorted =
        column.sort == TrinaColumnSort.ascending ||
        column.sort == TrinaColumnSort.descending;
    final sortIcon = switch (column.sort) {
      TrinaColumnSort.ascending => shad.LucideIcons.arrowUp,
      TrinaColumnSort.descending => shad.LucideIcons.arrowDown,
      _ when column.enableSorting => shad.LucideIcons.chevronsUpDown,
      _ => null,
    };
    final titleAlignment = column.titleTextAlign.alignmentValue;
    final iconColor = foregroundColor ?? style.iconColor;
    final mutedIcon = iconColor.withValues(alpha: .38);
    final activeIcon = iconColor.withValues(alpha: .82);
    Widget title = DecoratedBox(
      decoration: _appDataGridHeaderDecoration(
        manager,
        backgroundColor: backgroundColor,
        showDivider: showDivider,
      ),
      child: Padding(
        padding: column.titlePadding ?? style.defaultColumnTitlePadding,
        child: Row(
          children: [
            Expanded(
              child: Align(
                alignment: titleAlignment,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        column.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: style.columnTextStyle,
                      ),
                    ),
                    if (sortIcon != null) ...[
                      const SizedBox(width: 4),
                      Icon(
                        sortIcon,
                        size: 13,
                        color: sorted ? activeIcon : mutedIcon,
                      ),
                    ],
                    if (context.isFiltered) ...[
                      const SizedBox(width: 4),
                      Icon(
                        Icons.filter_alt_rounded,
                        size: 13,
                        color: activeIcon,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (menuMode == AppDataGridColumnMenuMode.icon &&
                context.showContextIcon) ...[
              const SizedBox(width: 2),
              AppMenuAnchor(
                items: items,
                child: SizedBox.square(
                  dimension: 20,
                  child: Icon(
                    Icons.more_vert_rounded,
                    size: 14,
                    color: mutedIcon,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
    if (menuMode == AppDataGridColumnMenuMode.contextMenu) {
      title = AppContextMenu(items: items, child: title);
    }
    if (reorderable) {
      title = _AppDataGridColumnDrag(
        manager: manager,
        column: column,
        height: context.height,
        child: title,
      );
    }
    return SizedBox(
      height: context.height,
      child: Stack(
        children: [
          Positioned.fill(child: title),
          if (column.enableDropToResize)
            PositionedDirectional(
              top: 0,
              bottom: 0,
              end: 0,
              width: 6,
              child: MouseRegion(
                cursor: SystemMouseCursors.resizeLeftRight,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onHorizontalDragUpdate: (details) {
                    manager.resizeColumn(
                      column,
                      manager.isLTR ? details.delta.dx : -details.delta.dx,
                    );
                  },
                  onHorizontalDragEnd: (_) {
                    manager.updateCorrectScrollOffset();
                    manager.notifyResizingListeners();
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

BoxDecoration _appDataGridHeaderDecoration(
  TrinaGridStateManager manager, {
  Color? backgroundColor,
  required bool showDivider,
}) => BoxDecoration(
  color: backgroundColor,
  border: showDivider
      ? BorderDirectional(
          end: BorderSide(color: manager.style.borderColor, width: .5),
        )
      : null,
);

BoxDecoration _appDataGridDialogPanelDecoration(shad.ThemeData theme) =>
    BoxDecoration(
      border: Border.all(color: theme.colorScheme.border),
      borderRadius: BorderRadius.circular(theme.radiusMd),
    );

class _AppDataGridSelectAll extends StatelessWidget {
  const _AppDataGridSelectAll({required this.manager});

  final TrinaGridStateManager manager;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: manager,
      builder: (context, _) {
        final checked = manager.tristateCheckedRow;
        final state = checked == null
            ? shad.CheckboxState.indeterminate
            : checked
            ? shad.CheckboxState.checked
            : shad.CheckboxState.unchecked;
        return AppCheckboxIndicator(
          state: state,
          tristate: true,
          size: 16 * shad.Theme.of(context).scaling,
          onChanged: (_) {
            final value = checked != true;
            manager.toggleAllRowChecked(value);
            manager.onRowChecked?.call(
              TrinaGridOnRowCheckedAllEvent(isChecked: value),
            );
          },
        );
      },
    );
  }
}

class _AppDataGridSelectionTitle extends StatelessWidget {
  const _AppDataGridSelectionTitle({
    required this.manager,
    required this.height,
    required this.backgroundColor,
    required this.showDivider,
  });

  final TrinaGridStateManager manager;
  final double height;
  final Color? backgroundColor;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: DecoratedBox(
        decoration: _appDataGridHeaderDecoration(
          manager,
          backgroundColor: backgroundColor,
          showDivider: showDivider,
        ),
        child: Center(child: _AppDataGridSelectAll(manager: manager)),
      ),
    );
  }
}

class _AppDataGridControlTitle extends StatelessWidget {
  const _AppDataGridControlTitle({
    required this.manager,
    required this.height,
    required this.backgroundColor,
    required this.showDivider,
  });

  final TrinaGridStateManager manager;
  final double height;
  final Color? backgroundColor;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: DecoratedBox(
        decoration: _appDataGridHeaderDecoration(
          manager,
          backgroundColor: backgroundColor,
          showDivider: showDivider,
        ),
      ),
    );
  }
}

enum _AppDataGridRowSegment { left, body, right }

class _AppDataGridHoverRow extends StatefulWidget {
  const _AppDataGridHoverRow({
    super.key,
    required this.row,
    required this.manager,
    required this.segment,
    required this.borderColor,
    required this.shadowColor,
    required this.child,
  });

  final TrinaRow row;
  final TrinaGridStateManager manager;
  final _AppDataGridRowSegment segment;
  final Color borderColor;
  final Color shadowColor;
  final Widget child;

  @override
  State<_AppDataGridHoverRow> createState() => _AppDataGridHoverRowState();
}

class _AppDataGridHoverRowState extends State<_AppDataGridHoverRow> {
  bool _hovered = false;
  OverlayEntry? _overlayEntry;
  bool _overlayInserted = false;
  bool _overlayUpdateScheduled = false;
  Rect? _overlayRect;

  @override
  void initState() {
    super.initState();
    widget.manager.addListener(_syncHover);
    _hovered = _resolveHovered();
  }

  @override
  void didUpdateWidget(_AppDataGridHoverRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.manager != widget.manager) {
      oldWidget.manager.removeListener(_syncHover);
      widget.manager.addListener(_syncHover);
    }
    _hovered = _resolveHovered();
  }

  @override
  void dispose() {
    _removeOverlay();
    widget.manager.removeListener(_syncHover);
    super.dispose();
  }

  bool _resolveHovered() {
    if (widget.manager.isDraggingRow) return false;
    final rowIndex = widget.manager.refRows.indexOf(widget.row);
    return rowIndex >= 0 && widget.manager.isRowIdxHovered(rowIndex);
  }

  void _syncHover() {
    final hovered = _resolveHovered();
    if (!mounted) return;
    if (_hovered != hovered) setState(() => _hovered = hovered);
    if (widget.segment != _AppDataGridRowSegment.body) return;
    if (hovered) {
      if (_overlayUpdateScheduled) return;
      _overlayUpdateScheduled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _overlayUpdateScheduled = false;
        _updateOverlay();
      });
    } else {
      _removeOverlay();
    }
  }

  void _removeOverlay() {
    if (_overlayInserted) {
      _overlayEntry?.remove();
      _overlayInserted = false;
    }
    _overlayEntry = null;
    _overlayRect = null;
  }

  void _updateOverlay() {
    if (!mounted || !_hovered) return;
    final rowBox = context.findRenderObject() as RenderBox?;
    final gridBox = widget.manager.gridKey.currentContext?.findRenderObject()
        as RenderBox?;
    final overlay = Overlay.maybeOf(context);
    final overlayBox = overlay?.context.findRenderObject() as RenderBox?;
    if (rowBox == null ||
        gridBox == null ||
        overlay == null ||
        overlayBox == null) {
      return;
    }
    final rowOrigin = rowBox.localToGlobal(Offset.zero);
    final gridOrigin = gridBox.localToGlobal(Offset.zero);
    final globalOrigin = Offset(gridOrigin.dx, rowOrigin.dy);
    final origin = overlayBox.globalToLocal(globalOrigin);
    _overlayRect = Rect.fromLTWH(
      origin.dx + 1,
      origin.dy,
      math.max(0, gridBox.size.width - 2),
      rowBox.size.height,
    );
    _overlayEntry ??= OverlayEntry(builder: _buildOverlay);
    // OverlayEntry.mounted remains false until its first build. Multiple
    // manager notifications can therefore schedule updates that all attempt
    // to insert the same entry in one frame. Track insertion separately so
    // the entry is added exactly once.
    if (!_overlayInserted) {
      overlay.insert(_overlayEntry!);
      _overlayInserted = true;
    }
    _overlayEntry!.markNeedsBuild();
  }

  Widget _buildOverlay(BuildContext context) {
    final rect = _overlayRect;
    if (rect == null) return const SizedBox.shrink();
    final theme = shad.Theme.of(context);
    final appTheme = AppTheme.maybeOf(context) ?? AppThemeConfig.standard();
    final radius = BorderRadius.circular(theme.radiusMd);
    final shadows = appTheme.shadows.resolve(
      context,
      level: AppShadowLevel.floating,
      quality: AppPageTransitionScope.shadowQualityOf(context),
      colorMode: AppShadowColorMode.custom,
      color: widget.shadowColor,
    );
    return Positioned.fromRect(
      rect: rect,
      child: IgnorePointer(
        child: CustomPaint(
          key: const ValueKey('app-data-grid-hover-overlay'),
          foregroundPainter: _AppDataGridHoverOverlayPainter(
            radius: radius,
            borderColor: widget.borderColor,
            shadows: shadows,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = AppTheme.maybeOf(context) ?? AppThemeConfig.standard();
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final animate = appTheme.motion.enabled && !reduceMotion;
    final tokens = appTheme.motion.tokens;

    return TweenAnimationBuilder<double>(
      tween: Tween(end: _hovered ? 1 : 0),
      duration: animate ? tokens.hoverDuration : Duration.zero,
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        final scale = 1 + (tokens.hoverScale - 1) * value;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            // Frozen and scrollable columns live in separately clipped
            // viewports. Horizontal scaling would cross those boundaries and
            // be cut off at the pinned-column divider.
            ..setEntry(0, 0, 1)
            ..setEntry(1, 1, scale),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _AppDataGridHoverOverlayPainter extends CustomPainter {
  const _AppDataGridHoverOverlayPainter({
    required this.radius,
    required this.borderColor,
    required this.shadows,
  });

  final BorderRadius radius;
  final Color borderColor;
  final List<BoxShadow> shadows;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final outer = radius.toRRect(rect);

    // A transparent BoxDecoration leaves the blurred portion of its shadow
    // visible inside the row, which dims all cell content. Paint the shadow on
    // an isolated layer and punch the card interior back out so only the
    // outside elevation remains visible over the grid.
    final layerBounds = rect.inflate(
      shadows.fold<double>(0, (extent, shadow) {
        return math.max(
          extent,
          shadow.blurRadius + shadow.spreadRadius + shadow.offset.distance,
        );
      }),
    );
    canvas.saveLayer(layerBounds, Paint());
    for (final shadow in shadows) {
      final shadowRect = rect
          .shift(shadow.offset)
          .inflate(shadow.spreadRadius);
      canvas.drawRRect(radius.toRRect(shadowRect), shadow.toPaint());
    }
    canvas.drawRRect(outer, Paint()..blendMode = BlendMode.clear);
    canvas.restore();

    canvas.drawRRect(
      outer.deflate(.5),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = borderColor,
    );
  }

  @override
  bool shouldRepaint(covariant _AppDataGridHoverOverlayPainter oldDelegate) {
    return oldDelegate.radius != radius ||
        oldDelegate.borderColor != borderColor ||
        !listEquals(oldDelegate.shadows, shadows);
  }
}

class _AppDataGridRowCheckbox extends StatelessWidget {
  const _AppDataGridRowCheckbox({
    required this.manager,
    required this.row,
    required this.rowIdx,
  });

  final TrinaGridStateManager manager;
  final TrinaRow row;
  final int rowIdx;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: manager,
      builder: (context, _) {
        final state = row.checked == true
            ? shad.CheckboxState.checked
            : shad.CheckboxState.unchecked;
        return Center(
          child: AppCheckboxIndicator(
            state: state,
            size: 16 * shad.Theme.of(context).scaling,
            onChanged: (next) {
              final value = next == shad.CheckboxState.checked;
              manager.setRowChecked(row, value);
              manager.onRowChecked?.call(
                TrinaGridOnRowCheckedOneEvent(
                  row: row,
                  rowIdx: rowIdx,
                  isChecked: value,
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _AppDataGridColumnDrag extends StatelessWidget {
  const _AppDataGridColumnDrag({
    required this.manager,
    required this.column,
    required this.height,
    required this.child,
  });

  final TrinaGridStateManager manager;
  final TrinaColumn column;
  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final style = manager.style;
    Widget target = DragTarget<TrinaColumn>(
      onWillAcceptWithDetails: (details) =>
          details.data.key != column.key &&
          !manager.limitMoveColumn(column: details.data, targetColumn: column),
      onAcceptWithDetails: (details) {
        if (details.data.key != column.key) {
          manager.moveColumn(column: details.data, targetColumn: column);
        }
      },
      builder: (context, candidates, rejected) => SizedBox(
        width: column.width,
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            child,
            if (candidates.isNotEmpty)
              DecoratedBox(
                decoration: BoxDecoration(color: style.dragTargetColumnColor),
              ),
          ],
        ),
      ),
    );
    target = Listener(
      onPointerMove: (event) => manager.eventManager?.addEvent(
        TrinaGridScrollUpdateEvent(
          offset: event.position,
          scrollDirection: TrinaGridScrollUpdateDirection.horizontal,
        ),
      ),
      onPointerUp: (_) => TrinaGridScrollUpdateEvent.stopScroll(
        manager,
        TrinaGridScrollUpdateDirection.horizontal,
      ),
      child: Draggable<TrinaColumn>(
        data: column,
        axis: Axis.horizontal,
        dragAnchorStrategy: childDragAnchorStrategy,
        feedback: AppSortableDragFeedback(
          child: SizedBox(
            width: column.width,
            height: height,
            child: Align(
              alignment: column.titleTextAlign.alignmentValue,
              child: Padding(
                padding: column.titlePadding ?? style.defaultColumnTitlePadding,
                child: Text(
                  column.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: style.columnTextStyle,
                ),
              ),
            ),
          ),
        ),
        child: target,
      ),
    );
    return target;
  }
}

class _AppDataGridRowDragHandle<T> extends StatelessWidget {
  const _AppDataGridRowDragHandle({
    required this.manager,
    required this.row,
    required this.columns,
  });

  final TrinaGridStateManager manager;
  final TrinaRow row;
  final List<AppDataGridColumn<T>> columns;

  AppDataGridColumn<T>? _definition(String field) {
    for (final column in columns) {
      if (column.id == field) return column;
    }
    return null;
  }

  Widget _buildDataCell(
    BuildContext context,
    TrinaColumn column,
    TrinaGridStyleConfig style,
  ) {
    final definition = _definition(column.field);
    final value = row.cells[column.field]?.value;
    final child = definition?.cellBuilder == null
        ? Text(
            value?.toString() ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: style.cellTextStyle,
          )
        : definition!.cellBuilder!(context, row.data as T, value);
    return Padding(
      padding: column.cellPadding ?? style.defaultCellPadding,
      child: Align(
        alignment: definition?.alignment ?? column.textAlign.alignmentValue,
        child: child,
      ),
    );
  }

  List<TrinaRow> get _draggingRows {
    if (manager.currentSelectingRows.isEmpty) return [row];
    if (manager.isSelectedRow(row.key)) return manager.currentSelectingRows;
    manager.clearCurrentSelecting(notify: false);
    return [row];
  }

  void _start(PointerDownEvent event) {
    // Notify row wrappers immediately so the hover card is removed before the
    // drag feedback is painted. Otherwise both floating surfaces overlap.
    manager.setIsDraggingRow(true);
    manager.setDragRows(_draggingRows);
  }

  void _move(PointerMoveEvent event) {
    if (manager.isSelecting && !manager.isDraggingRow) return;
    manager.eventManager?.addEvent(
      TrinaGridScrollUpdateEvent(offset: event.position),
    );
    manager.setDragTargetRowIdx(manager.getRowIdxByOffset(event.position.dy));
  }

  void _end(PointerUpEvent event) {
    manager.setIsDraggingRow(false);
    TrinaGridScrollUpdateEvent.stopScroll(
      manager,
      TrinaGridScrollUpdateDirection.all,
    );
  }

  @override
  Widget build(BuildContext context) {
    final style = manager.style;
    final visibleColumns = manager.refColumns
        .where((column) => !column.hide)
        .toList(growable: false);
    final feedbackWidth = math.min(
      manager.columnsWidth,
      manager.maxWidth ?? manager.columnsWidth,
    );
    final feedback = AppSortableDragFeedback(
      backgroundColor: Colors.white,
      child: SizedBox(
        width: feedbackWidth,
        height: manager.rowHeight,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(shad.Theme.of(context).radiusMd),
          child: OverflowBox(
            alignment: AlignmentDirectional.centerStart,
            minWidth: manager.columnsWidth,
            maxWidth: manager.columnsWidth,
            child: Row(
              children: [
                for (final column in visibleColumns)
                  SizedBox(
                    width: column.width,
                    child: switch (column.field) {
                      _appDataGridDragField => const Center(
                        child: AppSortableDragHandle(),
                      ),
                      _appDataGridSelectionField => Center(
                        child: IgnorePointer(
                          child: AppCheckboxIndicator(
                            state: row.checked == true
                                ? shad.CheckboxState.checked
                                : shad.CheckboxState.unchecked,
                            size: 16 * shad.Theme.of(context).scaling,
                            onChanged: (_) {},
                          ),
                        ),
                      ),
                      _ => _buildDataCell(context, column, style),
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
    return Listener(
      onPointerDown: _start,
      onPointerMove: _move,
      onPointerUp: _end,
      child: Draggable<TrinaRow>(
        data: row,
        axis: Axis.vertical,
        dragAnchorStrategy: childDragAnchorStrategy,
        feedback: feedback,
        child: const MouseRegion(
          cursor: SystemMouseCursors.grab,
          child: AppSortableDragHandle(),
        ),
      ),
    );
  }
}

class _AppDataGridPager extends StatefulWidget {
  const _AppDataGridPager({
    required this.state,
    required this.pageSizeOptions,
    required this.loadFailed,
  });

  final TrinaLazyPaginationState state;
  final List<int> pageSizeOptions;
  final bool loadFailed;

  @override
  State<_AppDataGridPager> createState() => _AppDataGridPagerState();
}

class _AppDataGridPagerState extends State<_AppDataGridPager> {
  late int _page;

  TrinaLazyPaginationState get _state => widget.state;

  @override
  void initState() {
    super.initState();
    _page = _state.page;
  }

  @override
  void didUpdateWidget(covariant _AppDataGridPager oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state.page != oldWidget.state.page ||
        (widget.loadFailed && !oldWidget.loadFailed)) {
      _page = widget.state.page;
    }
  }

  void _changePage(int page) {
    if (page == _page) return;
    setState(() => _page = page);
    _state.setPage(page);
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final metrics =
        AppTheme.maybeOf(context)?.dataGrid ?? const AppDataGridMetrics();
    final muted = TextStyle(color: theme.colorScheme.mutedForeground);
    final totalPages = math.max(1, _state.totalPage);
    final page = _page.clamp(1, totalPages);
    return Container(
      height: metrics.footerHeight,
      padding: EdgeInsets.symmetric(horizontal: metrics.horizontalPadding),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: theme.colorScheme.border)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            _state.totalRecords == null ? '' : '共 ${_state.totalRecords} 条',
            style: muted,
          ),
          if (widget.pageSizeOptions.isNotEmpty) ...[
            const SizedBox(width: 12),
            SizedBox(
              width: 128,
              child: AppSelect<int>(
                value: _state.pageSize,
                hintText: '条/页',
                options: [
                  for (final size in widget.pageSizeOptions)
                    AppOption(value: size, label: '$size 条/页'),
                ],
                onChanged: (size) {
                  if (size != null && size != _state.pageSize) {
                    setState(() => _page = 1);
                    _state.setPageSize(size);
                  }
                },
              ),
            ),
          ],
          const Spacer(),
          AppPagination(
            page: page,
            totalPages: totalPages,
            onPageChanged: _changePage,
          ),
        ],
      ),
    );
  }
}

class _AppDataGridError extends StatelessWidget {
  const _AppDataGridError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.popover,
        border: Border.all(color: theme.colorScheme.destructive),
        borderRadius: BorderRadius.circular(theme.radiusMd),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(
              shad.LucideIcons.triangleAlert,
              color: theme.colorScheme.destructive,
              size: 18,
            ),
            const SizedBox(width: 8),
            const Expanded(child: Text('数据加载失败')),
            AppButton.ghost(
              size: AppButtonSize.xSmall,
              onPressed: onRetry,
              child: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }
}

enum _AppDataGridColumnOrderMode { defaults, ascending, descending }

class _AppDataGridColumnsDialog extends StatefulWidget {
  const _AppDataGridColumnsDialog({
    required this.manager,
    required this.isControlField,
  });

  final TrinaGridStateManager manager;
  final bool Function(String field) isControlField;

  @override
  State<_AppDataGridColumnsDialog> createState() =>
      _AppDataGridColumnsDialogState();
}

class _AppDataGridColumnsDialogState extends State<_AppDataGridColumnsDialog> {
  late final List<String> _defaultFields;
  _AppDataGridColumnOrderMode _orderMode = _AppDataGridColumnOrderMode.defaults;

  @override
  void initState() {
    super.initState();
    _defaultFields = _dataColumns.map((column) => column.field).toList();
  }

  List<TrinaColumn> get _dataColumns => widget.manager.refColumns.originalList
      .where((column) => !widget.isControlField(column.field))
      .toList(growable: false);

  int get _visibleCount => _dataColumns.where((column) => !column.hide).length;

  shad.CheckboxState get _selectAllState {
    final visible = _visibleCount;
    if (visible == 0) return shad.CheckboxState.unchecked;
    if (visible == _dataColumns.length) return shad.CheckboxState.checked;
    return shad.CheckboxState.indeterminate;
  }

  String _columnLabel(TrinaColumn column) =>
      column.title.isEmpty ? column.field : column.title;

  (IconData, String) get _orderModeVisual => switch (_orderMode) {
    _AppDataGridColumnOrderMode.defaults => (
      shad.LucideIcons.arrowUpDown,
      '默认',
    ),
    _AppDataGridColumnOrderMode.ascending => (shad.LucideIcons.arrowUpAZ, '正序'),
    _AppDataGridColumnOrderMode.descending => (
      shad.LucideIcons.arrowDownAZ,
      '倒序',
    ),
  };

  void _toggleAll(shad.CheckboxState next) {
    final columns = _dataColumns;
    if (columns.isEmpty) return;
    widget.manager.hideColumns(columns, next != shad.CheckboxState.checked);
    setState(() {});
  }

  void _toggleColumn(TrinaColumn column, bool visible) {
    widget.manager.hideColumn(column, !visible);
    setState(() {});
  }

  void _cycleOrderMode() {
    final next = switch (_orderMode) {
      _AppDataGridColumnOrderMode.defaults =>
        _AppDataGridColumnOrderMode.ascending,
      _AppDataGridColumnOrderMode.ascending =>
        _AppDataGridColumnOrderMode.descending,
      _AppDataGridColumnOrderMode.descending =>
        _AppDataGridColumnOrderMode.defaults,
    };
    final current = _dataColumns;
    final byField = {for (final column in current) column.field: column};
    final ordered = switch (next) {
      _AppDataGridColumnOrderMode.defaults =>
        _defaultFields
            .map((field) => byField[field])
            .whereType<TrinaColumn>()
            .toList(growable: false),
      _AppDataGridColumnOrderMode.ascending => (List<TrinaColumn>.of(
        current,
      )..sort((a, b) => _columnLabel(a).compareTo(_columnLabel(b)))),
      _AppDataGridColumnOrderMode.descending => (List<TrinaColumn>.of(
        current,
      )..sort((a, b) => _columnLabel(b).compareTo(_columnLabel(a)))),
    };
    _orderMode = next;
    _applyOrder(ordered);
  }

  void _onManualReorder(List<TrinaColumn> data) {
    _orderMode = _AppDataGridColumnOrderMode.defaults;
    _applyOrder(data);
  }

  void _applyOrder(List<TrinaColumn> data) {
    final manager = widget.manager;
    final controls = manager.refColumns.originalList
        .where((column) => widget.isControlField(column.field))
        .toList(growable: false);

    manager.refColumns.clearFromOriginal();
    manager.refColumns.addAll([...controls, ...data]);
    manager.refColumns.update();
    manager.resetShowFrozenColumn();
    manager.updateVisibilityLayout();
    manager.notifyListeners();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final columns = _dataColumns;
    final (orderIcon, orderLabel) = _orderModeVisual;
    return AppFormDialog(
      title: const Text('列设置'),
      constraints: const BoxConstraints(maxWidth: 360, maxHeight: 480),
      content: SizedBox(
        width: 320,
        height: 320,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                AppCheckboxIndicator(
                  state: _selectAllState,
                  tristate: true,
                  onChanged: _toggleAll,
                ),
                const SizedBox(width: 10),
                const Expanded(child: Text('显示全部列')),
                AppButton.ghost(
                  size: AppButtonSize.xSmall,
                  leading: Icon(orderIcon, size: 14),
                  onPressed: columns.isEmpty ? null : _cycleOrderMode,
                  child: Text(orderLabel),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: DecoratedBox(
                decoration: _appDataGridDialogPanelDecoration(theme),
                child: AppSortableInput<TrinaColumn>(
                  items: columns,
                  itemKey: (column) => ValueKey(column.field),
                  shrinkWrap: false,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  onChanged: _onManualReorder,
                  itemBuilder: (context, index, column) {
                    final visible = !column.hide;
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 4,
                      ),
                      child: Row(
                        children: [
                          AppCheckboxIndicator(
                            state: visible
                                ? shad.CheckboxState.checked
                                : shad.CheckboxState.unchecked,
                            onChanged: (state) => _toggleColumn(
                              column,
                              state == shad.CheckboxState.checked,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _columnLabel(column),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppDataGridFilterRule {
  _AppDataGridFilterRule({
    required this.columnField,
    required this.filterType,
    this.value = '',
  });

  String columnField;
  TrinaFilterType filterType;
  String value;

  bool get needsValue =>
      filterType is! TrinaFilterTypeIsEmpty &&
      filterType is! TrinaFilterTypeIsNotEmpty;
}

class _AppDataGridFiltersDialog extends StatefulWidget {
  const _AppDataGridFiltersDialog({
    required this.manager,
    required this.isControlField,
    this.calledColumn,
  });

  final TrinaGridStateManager manager;
  final bool Function(String field) isControlField;
  final TrinaColumn? calledColumn;

  @override
  State<_AppDataGridFiltersDialog> createState() =>
      _AppDataGridFiltersDialogState();
}

class _AppDataGridFiltersDialogState extends State<_AppDataGridFiltersDialog> {
  static const _ruleFlexes = [3, 3, 4];

  late final List<_AppDataGridFilterRule> _rules;
  late final List<TrinaFilterType> _filterTypes;
  late final List<TrinaColumn> _filterColumns;
  late final String _allColumnsField;
  late final String _allColumnsLabel;

  @override
  void initState() {
    super.initState();
    final manager = widget.manager;
    final locale = manager.configuration.localeText;
    _allColumnsField = FilterHelper.filterFieldAllColumns;
    _allColumnsLabel = locale.filterAllColumns;
    _filterTypes = List<TrinaFilterType>.of(
      manager.configuration.columnFilter.filters,
    );
    _filterColumns = manager.refColumns.originalList
        .where(
          (column) =>
              column.enableFilterMenuItem &&
              !widget.isControlField(column.field),
        )
        .toList(growable: false);

    if (manager.filterRows.isNotEmpty) {
      _rules = [
        for (final row in manager.filterRows)
          _AppDataGridFilterRule(
            columnField:
                row.cells[FilterHelper.filterFieldColumn]?.value as String? ??
                _allColumnsField,
            filterType: _matchFilterType(
              row.cells[FilterHelper.filterFieldType]?.value
                  as TrinaFilterType?,
            ),
            value:
                row.cells[FilterHelper.filterFieldValue]?.value?.toString() ??
                '',
          ),
      ];
    } else if (widget.calledColumn != null &&
        widget.calledColumn!.enableFilterMenuItem) {
      _rules = [
        _AppDataGridFilterRule(
          columnField: widget.calledColumn!.field,
          filterType: _defaultFilterType(widget.calledColumn),
        ),
      ];
    } else {
      _rules = [];
    }
  }

  bool _sameFilterType(TrinaFilterType left, TrinaFilterType right) =>
      left.runtimeType == right.runtimeType;

  TrinaFilterType _matchFilterType(
    TrinaFilterType? preferred, {
    TrinaFilterType? fallback,
  }) {
    final resolvedFallback =
        fallback ??
        (_filterTypes.isNotEmpty
            ? _filterTypes.first
            : const TrinaFilterTypeContains());
    if (preferred == null) return resolvedFallback;
    for (final type in _filterTypes) {
      if (_sameFilterType(type, preferred)) return type;
    }
    return fallback ?? preferred;
  }

  TrinaFilterType _defaultFilterType(TrinaColumn? column) => _matchFilterType(
    column?.defaultFilter,
    fallback: _filterTypes.isNotEmpty
        ? _filterTypes.first
        : const TrinaFilterTypeContains(),
  );

  String _filterTypeLabel(TrinaFilterType type) {
    if (type is TrinaFilterTypeRegex) return '正则';
    if (type is TrinaFilterTypeIsEmpty) return '为空';
    if (type is TrinaFilterTypeIsNotEmpty) return '非空';
    if (type is TrinaFilterTypeMultiItems) return '多项';
    return type.title;
  }

  void _apply() {
    widget.manager.setFilterWithFilterRows([
      for (final rule in _rules)
        FilterHelper.createFilterRow(
          columnField: rule.columnField,
          filterType: rule.filterType,
          filterValue: rule.needsValue ? rule.value : '',
        ),
    ]);
  }

  void _commit(VoidCallback change) {
    setState(change);
    _apply();
  }

  void _addRule() {
    _commit(() {
      _rules.add(
        _AppDataGridFilterRule(
          columnField: widget.calledColumn?.enableFilterMenuItem == true
              ? widget.calledColumn!.field
              : _filterColumns.isNotEmpty
              ? _filterColumns.first.field
              : _allColumnsField,
          filterType: _defaultFilterType(widget.calledColumn),
        ),
      );
    });
  }

  void _removeRule(int index) => _commit(() => _rules.removeAt(index));

  void _clearRules() {
    if (_rules.isEmpty) return;
    _commit(_rules.clear);
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final locale = widget.manager.configuration.localeText;
    final controlHeight = AppControlMetricsScope.resolve(context).height;
    final columnOptions = <AppOption<String>>[
      AppOption(value: _allColumnsField, label: _allColumnsLabel),
      for (final column in _filterColumns)
        AppOption(
          value: column.field,
          label: column.title.isEmpty ? column.field : column.title,
        ),
    ];
    final typeOptions = [
      for (final type in _filterTypes)
        AppOption(value: type, label: _filterTypeLabel(type)),
    ];

    return AppFormDialog(
      title: Text(locale.setFilter),
      constraints: const BoxConstraints(maxWidth: 560, maxHeight: 480),
      content: SizedBox(
        width: 520,
        height: 320,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                AppButton.primary(
                  size: AppButtonSize.xSmall,
                  leading: const Icon(shad.LucideIcons.plus, size: 14),
                  onPressed: _addRule,
                  child: const Text('添加条件'),
                ),
                const SizedBox(width: 8),
                AppButton.destructive(
                  size: AppButtonSize.xSmall,
                  leading: const Icon(shad.LucideIcons.trash2, size: 14),
                  onPressed: _rules.isEmpty ? null : _clearRules,
                  child: const Text('清空'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _rules.isEmpty
                  ? DecoratedBox(
                      decoration: _appDataGridDialogPanelDecoration(theme),
                      child: const Center(
                        child: AppEmpty(
                          icon: Icon(shad.LucideIcons.listFilter),
                          title: Text('暂无筛选条件'),
                          description: Text('点击「添加条件」开始设置过滤器。'),
                        ),
                      ),
                    )
                  : ListView.separated(
                      itemCount: _rules.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 6),
                      itemBuilder: (context, index) {
                        final rule = _rules[index];
                        final needsValue = rule.needsValue;
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: AppWidgetGroup(
                                expands: true,
                                flexes: _ruleFlexes,
                                children: [
                                  AppSelect<String>(
                                    value: rule.columnField,
                                    hintText: locale.filterColumn,
                                    options: columnOptions,
                                    onChanged: (value) {
                                      if (value == null) return;
                                      _commit(() => rule.columnField = value);
                                    },
                                  ),
                                  AppSelect<TrinaFilterType>(
                                    value: _matchFilterType(rule.filterType),
                                    hintText: locale.filterType,
                                    options: typeOptions,
                                    optionConfig: AppOptionConfig(
                                      equals: _sameFilterType,
                                    ),
                                    onChanged: (value) {
                                      if (value == null) return;
                                      _commit(() => rule.filterType = value);
                                    },
                                  ),
                                  AppTextField(
                                    value: rule.value,
                                    enabled: needsValue,
                                    hintText: needsValue
                                        ? locale.filterValue
                                        : '无需填写',
                                    onChanged: (value) =>
                                        _commit(() => rule.value = value),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 4),
                            AppIconButton(
                              tooltip: '删除条件',
                              variant: AppButtonVariant.ghost,
                              onPressed: () => _removeRule(index),
                              config: AppButtonConfig(height: controlHeight),
                              icon: Icon(
                                shad.LucideIcons.x,
                                size: 14,
                                color: theme.colorScheme.destructive,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
