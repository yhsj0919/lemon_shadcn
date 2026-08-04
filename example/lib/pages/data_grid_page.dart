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
  List<_GridUser> _selectedRows = const [];

  static final _allRows = List.generate(
    75,
    (index) => _GridUser(
      id: index + 1,
      name: ['张明', '李华', '王芳', '赵磊', '陈静'][index % 5],
      department: ['设计部', '研发部', '产品部'][index % 3],
      status: index % 4 == 0 ? '停用' : '正常',
    ),
  );

  @override
  void initState() {
    super.initState();
    _localRows = _allRows.take(8).toList();
  }

  List<AppDataGridColumn<_GridUser>> get _columns => [
    AppDataGridColumn(
      id: 'id',
      title: 'ID',
      value: (row) => row.id,
      type: AppDataGridColumnType.number,
      width: 90,
      minWidth: 72,
      pin: AppDataGridColumnPin.start,
    ),
    AppDataGridColumn(
      id: 'name',
      title: '姓名',
      value: (row) => row.name,
      width: 150,
    ),
    AppDataGridColumn(
      id: 'department',
      title: '部门',
      value: (row) => row.department,
      width: 180,
    ),
    AppDataGridColumn(
      id: 'status',
      title: '状态',
      value: (row) => row.status,
      width: 120,
      cellBuilder: (context, row, value) => Align(
        alignment: Alignment.centerLeft,
        child: value == '正常'
            ? AppBadge.primary(child: const Text('正常'))
            : AppBadge.secondary(child: const Text('停用')),
      ),
    ),
  ];

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

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      title: '高级表格',
      description: '固定列、选择、拖动排序、分页器与无限滚动。',
      sections: [
        ComponentSection(
          title: '本地数据与拖动排序',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('已选 ${_selectedRows.length} 项'),
              const Gap(8),
              AppDataGrid<_GridUser>.local(
                columns: _columns,
                rows: _localRows,
                rowKey: (row) => row.id,
                height: 410,
                selectionMode: AppDataGridSelectionMode.multiple,
                onSelectionChanged: (rows) =>
                    setState(() => _selectedRows = rows),
                reorderableRows: true,
                onRowsReordered: (keys, rows) =>
                    setState(() => _localRows = rows),
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
  const _GridUser({
    required this.id,
    required this.name,
    required this.department,
    required this.status,
  });

  final int id;
  final String name;
  final String department;
  final String status;
}
