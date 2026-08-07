import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import 'package:trina_grid/trina_grid.dart';

import '../../foundation/app_shadcn_scope.dart';
import '../../foundation/app_theme_config.dart';
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

class AppDataGridColumn<T> {
  const AppDataGridColumn({
    required this.id,
    required this.title,
    required this.value,
    this.type = AppDataGridColumnType.text,
    this.cellBuilder,
    this.width = 160,
    this.minWidth = 80,
    this.pin = AppDataGridColumnPin.none,
    this.sortable = true,
    this.filterable = true,
    this.resizable = true,
    this.reorderable = true,
    this.editable = false,
    this.hidden = false,
    this.alignment = Alignment.center,
    this.titleAlignment,
  });

  final String id;
  final String title;
  final Object? Function(T row) value;
  final AppDataGridColumnType type;
  final AppDataGridCellBuilder<T>? cellBuilder;
  final double width;
  final double minWidth;
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

class AppDataGrid<T> extends StatefulWidget {
  const AppDataGrid.local({
    super.key,
    required this.columns,
    required this.rows,
    required this.rowKey,
    this.controller,
    this.height = 420,
    this.selectionMode = AppDataGridSelectionMode.none,
    this.selectedKeys = const {},
    this.autoSelectFirstRow = false,
    this.onSelectionChanged,
    this.onCellChanged,
    this.sortable = false,
    this.reorderableRows = false,
    this.onRowsReordered,
    this.reorderableColumns = false,
    this.columnMenuMode = AppDataGridColumnMenuMode.contextMenu,
    this.showFilters = false,
    this.showInternalDividers = true,
    this.headerBackgroundColor,
    this.headerForegroundColor,
    this.cellBackgroundColor,
    this.cellForegroundColor,
    this.rowBackgroundColor,
    this.empty,
  }) : _mode = _AppDataGridMode.local,
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
    this.pageSize = 20,
    this.pageSizeOptions = const [10, 20, 50, 100],
    this.selectionMode = AppDataGridSelectionMode.none,
    this.selectedKeys = const {},
    this.autoSelectFirstRow = false,
    this.onSelectionChanged,
    this.onCellChanged,
    this.sortable = false,
    this.reorderableRows = false,
    this.onRowsReordered,
    this.reorderableColumns = false,
    this.columnMenuMode = AppDataGridColumnMenuMode.contextMenu,
    this.showFilters = false,
    this.showInternalDividers = true,
    this.headerBackgroundColor,
    this.headerForegroundColor,
    this.cellBackgroundColor,
    this.cellForegroundColor,
    this.rowBackgroundColor,
    this.empty,
  }) : _mode = _AppDataGridMode.paginated,
       rows = const [];

  const AppDataGrid.infinite({
    super.key,
    required this.columns,
    required this.loader,
    required this.rowKey,
    this.controller,
    this.height = 480,
    this.pageSize = 30,
    this.selectionMode = AppDataGridSelectionMode.none,
    this.selectedKeys = const {},
    this.autoSelectFirstRow = false,
    this.onSelectionChanged,
    this.onCellChanged,
    this.sortable = false,
    this.reorderableRows = false,
    this.onRowsReordered,
    this.reorderableColumns = false,
    this.columnMenuMode = AppDataGridColumnMenuMode.contextMenu,
    this.showFilters = false,
    this.showInternalDividers = true,
    this.headerBackgroundColor,
    this.headerForegroundColor,
    this.cellBackgroundColor,
    this.cellForegroundColor,
    this.rowBackgroundColor,
    this.empty,
  }) : _mode = _AppDataGridMode.infinite,
       rows = const [],
       pageSizeOptions = const [];

  final List<AppDataGridColumn<T>> columns;
  final List<T> rows;
  final AppDataGridLoader<T>? loader;
  final Object Function(T row) rowKey;
  final AppDataGridController? controller;
  final double height;
  final int pageSize;
  final List<int> pageSizeOptions;
  final AppDataGridSelectionMode selectionMode;
  final Set<Object> selectedKeys;

  /// When true and [selectionMode] is [AppDataGridSelectionMode.single],
  /// select the first row on load and notify [onSelectionChanged].
  /// Ignored when [selectedKeys] is non-empty.
  final bool autoSelectFirstRow;
  final ValueChanged<List<T>>? onSelectionChanged;
  final AppDataGridCellChanged<T>? onCellChanged;

  /// Enables column sorting. Per-column [AppDataGridColumn.sortable] still
  /// applies when this is true.
  final bool sortable;
  final bool reorderableRows;
  final AppDataGridReorderCallback<T>? onRowsReordered;
  final bool reorderableColumns;
  final AppDataGridColumnMenuMode columnMenuMode;
  final bool showFilters;

  /// Whether horizontal and vertical separators are drawn inside the grid.
  /// The outer grid border is unaffected.
  final bool showInternalDividers;

  final Color? headerBackgroundColor;
  final Color? headerForegroundColor;
  final Color? cellBackgroundColor;
  final Color? cellForegroundColor;

  /// Resolves a background for each business row independently. Returning
  /// null falls back to [cellBackgroundColor] and then the theme background.
  final AppDataGridRowColor<T>? rowBackgroundColor;
  final Widget? empty;
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
    } else if (!setEquals(oldWidget.selectedKeys, widget.selectedKeys)) {
      _syncSelectedKeys();
    }
  }

  @override
  void dispose() {
    _stateManager?.removeListener(_onGridStateChanged);
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
  }

  void _syncSelectedKeys() {
    final manager = _stateManager;
    if (manager == null ||
        widget.selectionMode == AppDataGridSelectionMode.none) {
      return;
    }

    var changed = false;
    for (final row in manager.refRows) {
      final data = row.data;
      if (data is! T) continue;
      final shouldCheck = widget.selectedKeys.contains(widget.rowKey(data));
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

  TrinaColumn _toTrinaColumn(AppDataGridColumn<T> column, int index) {
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
      width: column.width,
      minWidth: column.minWidth,
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

  List<TrinaRow<T>> _toTrinaRows(List<T> rows) {
    return [
      for (final row in rows)
        TrinaRow<T>(
          key: ValueKey(widget.rowKey(row)),
          data: row,
          checked: widget.selectedKeys.contains(widget.rowKey(row)),
          cells: {
            if (widget.reorderableRows)
              _appDataGridDragField: TrinaCell(value: ''),
            if (widget.selectionMode == AppDataGridSelectionMode.multiple)
              _appDataGridSelectionField: TrinaCell(value: ''),
            for (final column in widget.columns)
              column.id: TrinaCell(value: column.value(row)),
          },
        ),
    ];
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
      if (mounted && _loadError != null) setState(() => _loadError = null);
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
    _wasEditing = event.stateManager.isEditing;
    _stateManager!.addListener(_onGridStateChanged);
    // Wait until Trina's select-mode auto-select post-frame callback finishes.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _applyInitialSelection();
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
      field == _appDataGridSelectionField || field == _appDataGridDragField;

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
    final rows =
        _stateManager?.checkedRows
            .map((row) => row.data)
            .whereType<T>()
            .toList(growable: false) ??
        List<T>.empty();
    widget.onSelectionChanged?.call(rows);
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

  TrinaGridConfiguration _configuration(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final metrics =
        AppTheme.maybeOf(context)?.dataGrid ?? const AppDataGridMetrics();
    final textStyle = DefaultTextStyle.of(
      context,
    ).style.copyWith(fontSize: metrics.fontSize);
    final style = TrinaGridStyleConfig(
      enableGridBorderShadow: false,
      enableColumnBorderVertical: widget.showInternalDividers,
      enableColumnBorderHorizontal: widget.showInternalDividers,
      enableCellBorderVertical: widget.showInternalDividers,
      enableCellBorderHorizontal: widget.showInternalDividers,
      enableRowHoverColor: true,
      gridBackgroundColor: widget.cellBackgroundColor ?? colors.background,
      rowColor: widget.cellBackgroundColor ?? colors.background,
      rowHoveredColor: colors.accent,
      activatedColor: colors.accent,
      rowCheckedColor: colors.accent,
      columnUnselectedColor: colors.mutedForeground,
      columnActiveColor: colors.primary,
      columnCheckedColor: colors.primaryForeground,
      columnCheckedSide: BorderSide(color: colors.border, width: 1),
      cellUnselectedColor: colors.mutedForeground,
      cellActiveColor: colors.primary,
      cellCheckedColor: colors.primaryForeground,
      cellCheckedSide: BorderSide(color: colors.border, width: 1),
      cellColorInEditState: widget.cellBackgroundColor ?? colors.background,
      cellColorInReadOnlyState: widget.cellBackgroundColor ?? colors.background,
      // Keep cell fills transparent so row selection/hover colors show through.
      cellReadonlyColor: null,
      cellDefaultColor: null,
      menuBackgroundColor: colors.popover,
      gridBorderColor: colors.border,
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
      cellTextStyle: textStyle.copyWith(
        color: widget.cellForegroundColor ?? colors.foreground,
      ),
      columnTextStyle: textStyle.copyWith(
        color: widget.headerForegroundColor ?? colors.foreground,
        fontWeight: FontWeight.w600,
      ),
      gridBorderRadius: BorderRadius.circular(theme.radiusMd),
      gridPopupBorderRadius: BorderRadius.circular(theme.radiusMd),
      gridBorderWidth: 1,
      cellVerticalBorderWidth: widget.showInternalDividers ? .5 : 0,
      cellHorizontalBorderWidth: widget.showInternalDividers ? .5 : 0,
      filterHeaderColor: widget.headerBackgroundColor,
    );
    return TrinaGridConfiguration(
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

    return SizedBox(
      height: widget.height,
      child: Stack(
        children: [
          Positioned.fill(
            child: Theme(
              data: checkboxTheme,
              child: TrinaGrid(
                key: ValueKey(_generation),
                columns: columns,
                rows: rows,
                configuration: _configuration(context),
                noRowsWidget: empty,
                mode: widget.selectionMode == AppDataGridSelectionMode.single
                    ? TrinaGridMode.selectWithOneTap
                    : TrinaGridMode.normal,
                onLoaded: _onLoaded,
                onChanged: _onChanged,
                onSelected:
                    widget.selectionMode == AppDataGridSelectionMode.single
                    ? _onSelected
                    : null,
                onRowDoubleTap: _onRowDoubleTap,
                onRowChecked: _onRowChecked,
                onRowsMoved: _onRowsMoved,
                rowColorCallback: widget.rowBackgroundColor == null
                    ? null
                    : (rowContext) =>
                          widget.rowBackgroundColor!(
                            rowContext.row.data as T,
                          ) ??
                          widget.cellBackgroundColor ??
                          appTheme.colorScheme.background,
                createFooter: widget._mode == _AppDataGridMode.local
                    ? null
                    : _buildFooter,
              ),
            ),
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
      ),
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

class _AppDataGridRowDragHandle extends StatelessWidget {
  const _AppDataGridRowDragHandle({required this.manager, required this.row});

  final TrinaGridStateManager manager;
  final TrinaRow row;

  List<TrinaRow> get _draggingRows {
    if (manager.currentSelectingRows.isEmpty) return [row];
    if (manager.isSelectedRow(row.key)) return manager.currentSelectingRows;
    manager.clearCurrentSelecting(notify: false);
    return [row];
  }

  void _start(PointerDownEvent event) {
    manager.setIsDraggingRow(true, notify: false);
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
                      _ => Padding(
                        padding: column.cellPadding ?? style.defaultCellPadding,
                        child: Align(
                          alignment: column.textAlign.alignmentValue,
                          child: Text(
                            row.cells[column.field]?.value?.toString() ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: style.cellTextStyle,
                          ),
                        ),
                      ),
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
    final controlHeight = AppTheme.maybeOf(context)?.controls.height;
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
