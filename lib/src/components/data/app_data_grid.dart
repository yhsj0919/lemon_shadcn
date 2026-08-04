import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import 'package:trina_grid/trina_grid.dart';

import '../actions/app_button.dart';
import '../display/app_empty.dart';
import '../forms/app_checkbox.dart';
import '../navigation/app_menu_components.dart';

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
    this.alignment = Alignment.centerLeft,
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
    this.onSelectionChanged,
    this.onCellChanged,
    this.reorderableRows = false,
    this.onRowsReordered,
    this.reorderableColumns = true,
    this.columnMenuMode = AppDataGridColumnMenuMode.contextMenu,
    this.showFilters = false,
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
    this.onSelectionChanged,
    this.onCellChanged,
    this.reorderableRows = false,
    this.onRowsReordered,
    this.reorderableColumns = true,
    this.columnMenuMode = AppDataGridColumnMenuMode.contextMenu,
    this.showFilters = false,
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
    this.onSelectionChanged,
    this.onCellChanged,
    this.reorderableRows = false,
    this.onRowsReordered,
    this.reorderableColumns = true,
    this.columnMenuMode = AppDataGridColumnMenuMode.contextMenu,
    this.showFilters = false,
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
  final ValueChanged<List<T>>? onSelectionChanged;
  final AppDataGridCellChanged<T>? onCellChanged;
  final bool reorderableRows;
  final AppDataGridReorderCallback<T>? onRowsReordered;
  final bool reorderableColumns;
  final AppDataGridColumnMenuMode columnMenuMode;
  final bool showFilters;
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
    }
  }

  @override
  void dispose() {
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
      hide: column.hidden,
      frozen: switch (column.pin) {
        AppDataGridColumnPin.none => TrinaColumnFrozen.none,
        AppDataGridColumnPin.start => TrinaColumnFrozen.start,
        AppDataGridColumnPin.end => TrinaColumnFrozen.end,
      },
      textAlign: _textAlign(column.alignment),
      titleTextAlign: _textAlign(column.titleAlignment ?? column.alignment),
      enableSorting: column.sortable,
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
          enabled: manager.refColumns.length > 1,
          onPressed: (_) => manager.hideColumn(column, true),
          child: Text(locale.hideColumn),
        ),
      if (column.enableSetColumnsMenuItem)
        AppMenuButton(
          onPressed: (_) => manager.showSetColumnsPopup(context),
          child: Text(locale.setColumns),
        ),
      if (column.enableFilterMenuItem) ...[
        const AppMenuDivider(),
        AppMenuButton(
          onPressed: (_) =>
              manager.showFilterPopup(context, calledColumn: column),
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
    _stateManager = event.stateManager;
  }

  void _onSelected(TrinaGridOnSelectedEvent event) {
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
    final textStyle = DefaultTextStyle.of(context).style.copyWith(fontSize: 14);
    final style = TrinaGridStyleConfig(
      enableGridBorderShadow: false,
      enableRowHoverColor: true,
      gridBackgroundColor: colors.background,
      rowColor: colors.background,
      rowHoveredColor: colors.accent,
      activatedColor: Colors.transparent,
      rowCheckedColor: colors.accent,
      columnUnselectedColor: colors.mutedForeground,
      columnActiveColor: colors.primary,
      columnCheckedColor: colors.primaryForeground,
      columnCheckedSide: BorderSide(color: colors.border, width: 1),
      cellUnselectedColor: colors.mutedForeground,
      cellActiveColor: colors.primary,
      cellCheckedColor: colors.primaryForeground,
      cellCheckedSide: BorderSide(color: colors.border, width: 1),
      cellColorInEditState: colors.background,
      cellColorInReadOnlyState: colors.background,
      cellReadonlyColor: colors.background,
      menuBackgroundColor: colors.popover,
      gridBorderColor: colors.border,
      borderColor: colors.border,
      activatedBorderColor: Colors.transparent,
      inactivatedBorderColor: Colors.transparent,
      unfocusedSelectionColor: Colors.transparent,
      iconColor: colors.mutedForeground,
      disabledIconColor: colors.mutedForeground.withValues(alpha: .35),
      rowHeight: 40,
      columnHeight: 40,
      columnFilterHeight: widget.showFilters ? 48 : 0,
      defaultCellPadding: const EdgeInsets.symmetric(horizontal: 12),
      defaultColumnTitlePadding: const EdgeInsets.symmetric(horizontal: 12),
      cellTextStyle: textStyle.copyWith(color: colors.foreground),
      columnTextStyle: textStyle.copyWith(
        color: colors.foreground,
        fontWeight: FontWeight.w600,
      ),
      gridBorderRadius: BorderRadius.circular(theme.radiusMd),
      gridPopupBorderRadius: BorderRadius.circular(theme.radiusMd),
      gridBorderWidth: 1,
      cellVerticalBorderWidth: .5,
      cellHorizontalBorderWidth: .5,
    );
    return TrinaGridConfiguration(
      selectingMode: TrinaGridSelectingMode.row,
      rowSelectionCheckBoxBehavior:
          TrinaGridRowSelectionCheckBoxBehavior.toggleCheckRow,
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
        builder: (context, state) => _AppDataGridPager(state: state),
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
                onSelected: _onSelected,
                onRowChecked: _onRowChecked,
                onRowsMoved: _onRowsMoved,
                createFooter: widget._mode == _AppDataGridMode.local
                    ? null
                    : _buildFooter,
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
  });

  final TrinaColumnTitleRendererContext context;
  final bool reorderable;
  final AppDataGridColumnMenuMode menuMode;
  final List<shad.MenuItem> items;

  @override
  Widget build(BuildContext buildContext) {
    final column = context.column;
    final manager = context.stateManager;
    final style = manager.configuration.style;
    final sortIcon = switch (column.sort) {
      TrinaColumnSort.ascending => shad.LucideIcons.arrowUp,
      TrinaColumnSort.descending => shad.LucideIcons.arrowDown,
      _ when column.enableSorting => shad.LucideIcons.arrowUpDown,
      _ => null,
    };
    final titleAlignment = column.titleTextAlign.alignmentValue;
    Widget title = DecoratedBox(
      decoration: _appDataGridHeaderDecoration(manager),
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
                      const SizedBox(width: 6),
                      Icon(sortIcon, size: 18, color: style.iconColor),
                    ],
                    if (context.isFiltered) ...[
                      const SizedBox(width: 4),
                      Icon(
                        Icons.filter_alt_rounded,
                        size: 16,
                        color: style.iconColor,
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
                    color: style.iconColor.withValues(alpha: .72),
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

BoxDecoration _appDataGridHeaderDecoration(TrinaGridStateManager manager) =>
    BoxDecoration(
      border: BorderDirectional(
        end: BorderSide(color: manager.style.borderColor, width: .5),
      ),
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
  });

  final TrinaGridStateManager manager;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: DecoratedBox(
        decoration: _appDataGridHeaderDecoration(manager),
        child: Center(child: _AppDataGridSelectAll(manager: manager)),
      ),
    );
  }
}

class _AppDataGridControlTitle extends StatelessWidget {
  const _AppDataGridControlTitle({required this.manager, required this.height});

  final TrinaGridStateManager manager;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: DecoratedBox(decoration: _appDataGridHeaderDecoration(manager)),
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
        feedback: Material(
          color: Colors.transparent,
          child: Container(
            width: column.width,
            height: height,
            alignment: column.titleTextAlign.alignmentValue,
            padding: column.titlePadding ?? style.defaultColumnTitlePadding,
            decoration: BoxDecoration(
              color: style.gridBackgroundColor,
              border: Border.all(color: style.gridBorderColor),
            ),
            child: Text(
              column.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: style.columnTextStyle,
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
    final feedback = Material(
      color: Colors.transparent,
      child: Container(
        width: feedbackWidth,
        height: manager.rowHeight,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: style.gridBackgroundColor,
          border: Border.all(color: style.activatedBorderColor),
          borderRadius: style.gridBorderRadius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .12),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
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
                    _appDataGridDragField => Center(
                      child: Icon(
                        shad.LucideIcons.gripVertical,
                        size: 16,
                        color: style.iconColor,
                      ),
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
        child: MouseRegion(
          cursor: SystemMouseCursors.grab,
          child: Icon(
            shad.LucideIcons.gripVertical,
            size: 16,
            color: style.iconColor,
          ),
        ),
      ),
    );
  }
}

class _AppDataGridPager extends StatelessWidget {
  const _AppDataGridPager({required this.state});

  final TrinaLazyPaginationState state;

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: theme.colorScheme.border)),
      ),
      child: Row(
        children: [
          Text(
            state.totalRecords == null ? '' : '共 ${state.totalRecords} 条',
            style: TextStyle(color: theme.colorScheme.mutedForeground),
          ),
          const Spacer(),
          AppButton.ghost(
            size: AppButtonSize.xSmall,
            onPressed: state.isFirstPage ? null : state.previousPage,
            child: const Text('上一页'),
          ),
          const SizedBox(width: 8),
          Text('${state.page} / ${math.max(1, state.totalPage)}'),
          const SizedBox(width: 8),
          AppButton.ghost(
            size: AppButtonSize.xSmall,
            onPressed: state.isLastPage ? null : state.nextPage,
            child: const Text('下一页'),
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
