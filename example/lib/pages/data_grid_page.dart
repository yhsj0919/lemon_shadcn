import 'package:lemon_shadcn/lemon_shadcn.dart';
import 'package:lemon_shadcn/shadcn.dart';

import 'actions_page.dart';

class DataGridPage extends StatefulWidget {
  const DataGridPage({super.key});

  @override
  State<DataGridPage> createState() => _DataGridPageState();
}

class _DataGridPageState extends State<DataGridPage> {
  late List<_GridUser> _localRows;
  late List<_GridUser> _singleRows;
  List<_GridUser> _selectedRows = const [];
  List<_TreeGridRow> _selectedTreeRows = const [];
  _GridUser? _selectedRow;

  static final _allRows = List.generate(
    75,
    (index) => _GridUser(
      id: index + 1,
      name: ['张明', '李华', '王芳', '赵磊', '陈静'][index % 5],
      department: ['设计部', '研发部', '产品部'][index % 3],
      status: index % 4 == 0 ? '停用' : '正常',
    ),
  );

  static const _treeRows = [
    _TreeGridRow(
      id: 'product',
      name: '产品中心',
      children: [
        _TreeGridRow(
          id: 'product-design',
          name: '产品设计组',
          type: '团队',
          owner: '王芳',
          budget: 128000,
          status: '进行中',
        ),
        _TreeGridRow(
          id: 'product-research',
          name: '用户研究组',
          type: '团队',
          owner: '陈静',
          budget: 86000,
          status: '已完成',
        ),
      ],
    ),
    _TreeGridRow(id: 'engineering', name: '研发中心（异步）', canLoadChildren: true),
    _TreeGridRow(
      id: 'operations',
      name: '运营中心',
      children: [
        _TreeGridRow(
          id: 'operations-growth',
          name: '增长运营组',
          type: '团队',
          owner: '李华',
          budget: 96000,
          status: '进行中',
        ),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _localRows = _allRows.take(8).map((row) => row.copy()).toList();
    _singleRows = _allRows.skip(8).take(6).map((row) => row.copy()).toList();
  }

  List<AppDataGridColumn<_GridUser>> get _columns => [
    AppDataGridColumn(
      id: 'id',
      title: 'ID',
      value: (row) => row.id,
      type: AppDataGridColumnType.number,
      width: 90,
      minWidth: 72,
      widthMode: AppDataGridColumnWidthMode.content,
      pin: AppDataGridColumnPin.start,
    ),
    AppDataGridColumn(
      id: 'name',
      title: '姓名',
      value: (row) => row.name,
      width: 150,
      widthMode: AppDataGridColumnWidthMode.fill,
      editable: true,
    ),
    AppDataGridColumn(
      id: 'department',
      title: '部门',
      value: (row) => row.department,
      width: 180,
      widthMode: AppDataGridColumnWidthMode.fill,
      flex: 2,
    ),
    AppDataGridColumn(
      id: 'status',
      title: '状态',
      value: (row) => row.status,
      width: 120,
      cellBuilder: (context, row, value) => Align(
        alignment: Alignment.center,
        child: value == '正常'
            ? AppBadge.primary(child: const Text('正常'))
            : AppBadge.secondary(child: const Text('停用')),
      ),
    ),
  ];

  void _onCellChanged(
    _GridUser row,
    String field,
    Object? value,
    Object? oldValue,
  ) {
    if (field != 'name' || value is! String) return;
    setState(() => row.name = value);
  }

  Future<AppDataGridPage<_GridUser>> _loadPage(AppDataGridQuery query) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    final start = (query.page - 1) * query.pageSize;
    final end = (start + query.pageSize).clamp(0, _allRows.length);
    return AppDataGridPage(
      items: start >= _allRows.length ? const [] : _allRows.sublist(start, end),
      total: _allRows.length,
      hasMore: end < _allRows.length,
    );
  }

  Future<AppDataGridPage<_GridUser>> _loadMore(AppDataGridQuery query) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    final start = int.tryParse(query.cursor ?? '') ?? 0;
    final end = (start + query.pageSize).clamp(0, _allRows.length);
    return AppDataGridPage(
      items: start >= _allRows.length ? const [] : _allRows.sublist(start, end),
      nextCursor: end.toString(),
      hasMore: end < _allRows.length,
    );
  }

  Future<List<_TreeGridRow>> _loadTreeChildren(_TreeGridRow row) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (row.id != 'engineering') return const [];
    return const [
      _TreeGridRow(
        id: 'engineering-client',
        name: '客户端研发组',
        type: '团队',
        owner: '赵磊',
        budget: 240000,
        status: '进行中',
      ),
      _TreeGridRow(
        id: 'engineering-platform',
        name: '平台研发组',
        type: '团队',
        owner: '张明',
        budget: 310000,
        status: '待开始',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final colors = ShadcnTheme.of(context).colorScheme;
    return ComponentPage(
      title: '高级表格',
      description: '鼠标划入时行会原位轻微放大并增强阴影；排序、行/列拖动、多选均可按需开启。可编辑列双击进入编辑。',
      sections: [
        ComponentSection(
          title: '本地数据与拖动排序',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('已选 ${_selectedRows.length} 项 · 双击姓名可编辑'),
              const Gap(8),
              AppDataGrid<_GridUser>.local(
                columns: _columns,
                rows: _localRows,
                rowKey: (row) => row.id,
                shrinkWrap: true,
                sortable: true,
                selectionMode: AppDataGridSelectionMode.multiple,
                selectedRowColor: const Color(0xffdbeafe),
                selectedKeys: {for (final row in _selectedRows) row.id},
                onSelectionChanged: (rows) =>
                    setState(() => _selectedRows = rows),
                onCellChanged: _onCellChanged,
                reorderableRows: true,
                reorderableColumns: true,
                onRowsReordered: (keys, rows) =>
                    setState(() => _localRows = rows),
              ),
            ],
          ),
        ),
        ComponentSection(
          title: '完全无边框与统一字体',
          child: AppDataGrid<_GridUser>.local(
            columns: _columns,
            rows: _singleRows,
            rowKey: (row) => row.id,
            height: 300,
            showBorder: false,
            showInternalDividers: false,
            textStyle: const TextStyle(fontSize: 13),
            headerTextStyle: const TextStyle(fontWeight: FontWeight.w600),
            headerBackgroundColor: colors.primary,
            headerForegroundColor: colors.primaryForeground,
            cellBackgroundColor: colors.card,
            cellForegroundColor: colors.cardForeground,
            striped: true,
            stripeColor: colors.primary.withValues(alpha: 0.06),
          ),
        ),
        ComponentSection(
          title: '树形行与异步子级',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '父子行使用相同列且不缩进；灰色行为父级。点击小三角展开，双击“研发中心”异步加载。'
                '父行和子行均支持悬停放大与增强阴影。已选 ${_selectedTreeRows.length} 行。',
              ),
              const Gap(8),
              AppDataGrid<_TreeGridRow>.local(
                height: 300,
                rows: _treeRows,
                rowKey: (row) => row.id,
                treeColumnId: 'name',
                treeIndent: 0,
                buildChildren: (row) => row.children,
                hasChildren: (row) =>
                    row.children.isNotEmpty || row.canLoadChildren,
                childrenLoader: _loadTreeChildren,
                selectionMode: AppDataGridSelectionMode.multiple,
                selectedKeys: {for (final row in _selectedTreeRows) row.id},
                onSelectionChanged: (rows) =>
                    setState(() => _selectedTreeRows = rows),
                treeRowBackgroundColor: (row, depth, isParent) => isParent
                    ? colors.muted.withValues(alpha: .72)
                    : colors.background,
                columns: [
                  const AppDataGridColumn(
                    id: 'name',
                    title: '组织 / 团队',
                    value: _treeName,
                    width: 220,
                    widthMode: AppDataGridColumnWidthMode.fill,
                    flex: 2,
                  ),
                  const AppDataGridColumn(
                    id: 'type',
                    title: '类型',
                    value: _treeType,
                    width: 100,
                  ),
                  const AppDataGridColumn(
                    id: 'owner',
                    title: '负责人',
                    value: _treeOwner,
                    width: 120,
                  ),
                  const AppDataGridColumn(
                    id: 'budget',
                    title: '预算',
                    value: _treeBudget,
                    type: AppDataGridColumnType.number,
                    width: 120,
                  ),
                  AppDataGridColumn(
                    id: 'status',
                    title: '状态',
                    value: _treeStatus,
                    width: 110,
                    cellBuilder: (context, row, value) => value == null
                        ? const SizedBox.shrink()
                        : Align(
                            alignment: Alignment.center,
                            child: AppBadge.secondary(child: Text('$value')),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
        ComponentSection(
          title: '单选',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _selectedRow == null
                    ? '未选择'
                    : '已选 ${_selectedRow!.name}（ID ${_selectedRow!.id}）',
              ),
              const Gap(8),
              AppDataGrid<_GridUser>.local(
                columns: _columns,
                rows: _singleRows,
                rowKey: (row) => row.id,
                height: 320,
                selectionMode: AppDataGridSelectionMode.single,
                selectedKeys: {if (_selectedRow != null) _selectedRow!.id},
                onSelectionChanged: (rows) => setState(
                  () => _selectedRow = rows.isEmpty ? null : rows.first,
                ),
              ),
            ],
          ),
        ),
        ComponentSection(
          title: '服务端分页',
          child: AppDataGrid<_GridUser>.paginated(
            columns: _columns,
            loader: _loadPage,
            rowKey: (row) => row.id,
            pageSize: 10,
            pageSizeOptions: const [10, 20, 50],
          ),
        ),
        ComponentSection(
          title: '无限滚动',
          child: AppDataGrid<_GridUser>.infinite(
            columns: _columns,
            loader: _loadMore,
            rowKey: (row) => row.id,
            pageSize: 15,
          ),
        ),
      ],
    );
  }
}

class _GridUser {
  _GridUser({
    required this.id,
    required this.name,
    required this.department,
    required this.status,
  });

  final int id;
  String name;
  final String department;
  final String status;

  _GridUser copy() =>
      _GridUser(id: id, name: name, department: department, status: status);
}

String _treeName(_TreeGridRow row) => row.name;
String? _treeType(_TreeGridRow row) => row.type;
String? _treeOwner(_TreeGridRow row) => row.owner;
num? _treeBudget(_TreeGridRow row) => row.budget;
String? _treeStatus(_TreeGridRow row) => row.status;

class _TreeGridRow {
  const _TreeGridRow({
    required this.id,
    required this.name,
    this.type,
    this.owner,
    this.budget,
    this.status,
    this.children = const [],
    this.canLoadChildren = false,
  });

  final String id;
  final String name;
  final String? type;
  final String? owner;
  final num? budget;
  final String? status;
  final List<_TreeGridRow> children;
  final bool canLoadChildren;
}
