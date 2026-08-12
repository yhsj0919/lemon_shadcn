import 'dart:async';

import 'package:lemon_shadcn/lemon_shadcn.dart';
import 'package:lemon_shadcn/shadcn.dart';

import 'actions_page.dart';

@immutable
class _Assignee {
  const _Assignee(this.id, this.name, this.department);

  final String id;
  final String name;
  final String department;
}

class FormsPage extends StatefulWidget {
  const FormsPage({
    super.key,
    this.visibleSections,
    this.title = '表单',
    this.description = '兼容原生 Form、默认配置简洁的表单字段。',
  });

  final Set<String>? visibleSections;
  final String title;
  final String description;

  static const _roles = [
    AppOption(value: 'admin', label: '管理员'),
    AppOption(value: 'editor', label: '编辑者'),
    AppOption(value: 'viewer', label: '查看者'),
  ];

  static final _roleSource = AppAsyncOptionSource<String>(
    loader: (query) async {
      await Future<void>.delayed(const Duration(milliseconds: 350));
      final normalized = query.toLowerCase();
      return _roles
          .where((option) => option.label.toLowerCase().contains(normalized))
          .toList();
    },
  );

  static Future<List<AppOption<String>>> _loadRoles() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return _roles;
  }

  static final _pagedRoleSource = AppAsyncPagedOptionSource<String>(
    loader: (query, cursor) async {
      await Future<void>.delayed(const Duration(milliseconds: 250));
      final offset = cursor as int? ?? 0;
      final filtered = _roles
          .where(
            (option) =>
                option.label.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
      final options = filtered.skip(offset).take(2).toList();
      final next = offset + options.length;
      return AppOptionPage(
        options: options,
        nextCursor: next < filtered.length ? next : null,
      );
    },
  );

  static const _assignees = [
    AppOption(
      value: _Assignee('u1', '张明', '设计部'),
      label: '张明',
      keywords: ['zhangming', '设计部'],
    ),
    AppOption(
      value: _Assignee('u2', '李华', '研发部'),
      label: '李华',
      keywords: ['lihua', '研发部'],
    ),
    AppOption(
      value: _Assignee('u3', '王芳', '产品部'),
      label: '王芳',
      keywords: ['wangfang', '产品部'],
    ),
  ];

  static final _assigneeConfig = AppOptionConfig<_Assignee>(
    equals: (left, right) => left.id == right.id,
    optionBuilder: (context, option, state) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(option.value.name),
        Text(option.value.department).small().muted(),
      ],
    ),
  );

  static const _regions = [
    AppCascadeOption(
      value: '浙江省',
      label: '浙江省',
      children: [
        AppCascadeOption(
          value: '杭州市',
          label: '杭州市',
          children: [
            AppCascadeOption(value: '西湖区', label: '西湖区'),
            AppCascadeOption(value: '滨江区', label: '滨江区'),
          ],
        ),
        AppCascadeOption(
          value: '宁波市',
          label: '宁波市',
          children: [
            AppCascadeOption(value: '海曙区', label: '海曙区'),
            AppCascadeOption(value: '鄞州区', label: '鄞州区'),
          ],
        ),
      ],
    ),
    AppCascadeOption(
      value: '江苏省',
      label: '江苏省',
      children: [
        AppCascadeOption(
          value: '南京市',
          label: '南京市',
          children: [
            AppCascadeOption(value: '玄武区', label: '玄武区'),
            AppCascadeOption(value: '建邺区', label: '建邺区'),
          ],
        ),
        AppCascadeOption(
          value: '苏州市',
          label: '苏州市',
          children: [
            AppCascadeOption(value: '姑苏区', label: '姑苏区'),
            AppCascadeOption(value: '吴中区', label: '吴中区'),
          ],
        ),
      ],
    ),
  ];

  static Future<List<AppCascadeOption<String>>> _loadRegions(
    AppRegionLevel level,
    List<String> path,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    if (level == AppRegionLevel.province) return _regions;
    var options = _regions;
    for (final selected in path) {
      final parent = options
          .where((item) => item.value == selected)
          .firstOrNull;
      if (parent == null) return const [];
      options = parent.children;
    }
    return options;
  }

  @override
  State<FormsPage> createState() => _FormsPageState();
}

class _FormsPageState extends State<FormsPage> {
  List<String> _assignedPermissions = const ['report'];
  List<AppFileSelection> _singleFiles = const [];
  List<AppFileSelection> _files = const [];
  final Map<AppFileSelection, double> _uploadProgress = {};
  final _formController = AppFormController(
    crossValidators: [
      (values) => values['password'] == values['confirmation']
          ? const {}
          : const {'confirmation': '两次输入的密码不一致。'},
    ],
  );
  late final AppAsyncAction<void> _submitAction = _formController
      .createSubmitAction(
        (values) async {
          await Future<void>.delayed(const Duration(milliseconds: 700));
        },
        loadingDelay: const Duration(milliseconds: 120),
        minimumLoadingDuration: const Duration(milliseconds: 250),
      );

  @override
  void dispose() {
    _submitAction.dispose();
    _formController.dispose();
    super.dispose();
  }

  void _updateUploadFiles(
    List<AppFileSelection> files, {
    required bool single,
  }) {
    final retained = <AppFileSelection>{
      ...(single ? files : _singleFiles),
      ...(single ? _files : files),
    };
    final added = retained
        .where((file) => !_uploadProgress.containsKey(file))
        .toList();
    setState(() {
      if (single) {
        _singleFiles = files;
      } else {
        _files = files;
      }
      _uploadProgress.removeWhere((file, _) => !retained.contains(file));
      for (final file in added) {
        _uploadProgress[file] = 0;
      }
    });
    for (final file in added) {
      unawaited(_simulateUpload(file));
    }
  }

  Future<void> _simulateUpload(AppFileSelection file) async {
    for (var step = 1; step <= 20; step++) {
      await Future<void>.delayed(const Duration(milliseconds: 120));
      if (!mounted || !_uploadProgress.containsKey(file)) return;
      setState(() => _uploadProgress[file] = step / 20);
    }
  }

  Widget _buildUploadProgress(AppFileSelection file, {bool compact = false}) {
    final progress = _uploadProgress[file] ?? 0;
    if (progress >= 1) {
      return compact
          ? const Icon(LucideIcons.circleCheck)
          : const Row(
              mainAxisSize: MainAxisSize.min,
              children: [Icon(LucideIcons.circleCheck), Gap(4), Text('完成')],
            );
    }
    return SizedBox(
      width: compact ? 90 : 110,
      child: Row(
        children: [
          Expanded(child: AppLinearProgressIndicator(value: progress)),
          const Gap(6),
          Text('${(progress * 100).round()}%'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      title: widget.title,
      description: widget.description,
      sections:
          <ComponentSection>[
            const ComponentSection(title: '就地编辑', child: _InlineEditDemo()),
            ComponentSection(
              title: '布局与装饰',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppFieldScope.horizontal(
                    labelWidth: 80,
                    child: const AppTextFormField(
                      label: '横向字段',
                      hintText: '输入内容',
                    ),
                  ),
                  const Gap(12),
                  const AppTextFormField(hintText: '无标题字段'),
                  const Gap(12),
                  const AppTextFormField(
                    hintText: '搜索内容',
                    leading: Icon(LucideIcons.search),
                    trailing: Text('Ctrl K'),
                  ),
                ],
              ),
            ),
            ComponentSection(
              title: '邮箱与密码',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppTextFormField.email(
                    label: '邮箱',
                    description: '用户开始输入后执行校验。',
                    required: true,
                    hintText: 'name@example.com',
                  ),
                  const Gap(12),
                  AppTextFormField.password(label: '密码'),
                ],
              ),
            ),
            ComponentSection(
              title: '异步校验表单',
              child: AppForm(
                controller: _formController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppTextFormField(
                      name: 'username',
                      label: '用户名',
                      required: true,
                      validator: AppValidators.required(),
                      asyncValidator: (value) async {
                        await Future<void>.delayed(
                          const Duration(milliseconds: 600),
                        );
                        return value?.toLowerCase() == 'admin'
                            ? '该用户名已被保留。'
                            : null;
                      },
                    ),
                    const Gap(12),
                    AppSelectFormField<String>(
                      name: 'role',
                      label: '角色',
                      options: FormsPage._roles,
                      validator: (value) => value == null ? '请选择角色。' : null,
                    ),
                    const Gap(12),
                    AppTextFormField.password(name: 'password', label: '密码'),
                    const Gap(12),
                    AppTextFormField.password(
                      name: 'confirmation',
                      label: '确认密码',
                    ),
                    const Gap(8),
                    AppFormErrorSummary(controller: _formController),
                    const Gap(8),
                    AppButton.primary(
                      action: _submitAction,
                      loadingLabel: '提交中',
                      child: const Text('提交表单'),
                    ),
                  ],
                ),
              ),
            ),
            ComponentSection(
              title: '图片选择',
              child: AppImageInputFormField(
                label: '单文件图片',
                description: '仅选择一张图片，也可以直接拖入替换。',
                variant: AppFilePickerVariant.simple,
                multiple: false,
                maxFileSize: 10 * 1024 * 1024,
                trailingBuilder: (context, file, index) =>
                    _buildUploadProgress(file, compact: true),
                onChanged: (files) => _updateUploadFiles(files, single: true),
              ),
            ),
            ComponentSection(
              title: '文件选择与上传',
              child: AppField(
                label: '模拟异步上传',
                description: '选择文件后通过 Future 模拟上传，并在右侧显示实时进度。',
                child: AppFilePicker(
                  files: _files,
                  allowedExtensions: const ['pdf', 'png', 'jpg', 'jpeg'],
                  maxFileSize: 10 * 1024 * 1024,
                  maxFiles: 5,
                  dialogTitle: '选择文件',
                  trailingBuilder: (context, file, index) =>
                      _buildUploadProgress(file),
                  onChanged: (files) =>
                      _updateUploadFiles(files, single: false),
                ),
              ),
            ),
            ComponentSection(
              title: '静态选项',
              child: const AppSelectFormField<String>(
                label: '静态角色',
                options: FormsPage._roles,
                required: true,
              ),
            ),
            ComponentSection(
              title: '异步加载',
              child: AppSelectFormField<String>.async(
                label: '异步角色',
                loadOptions: FormsPage._loadRoles,
                clearable: true,
              ),
            ),
            ComponentSection(
              title: '选项源检索',
              child: AppAutoCompleteFormField<String>.source(
                label: '负责人',
                optionSource: FormsPage._roleSource,
              ),
            ),
            ComponentSection(
              title: '分页检索',
              child: AppAutoCompleteFormField<String>.paged(
                label: '分页选择负责人',
                pagedOptionSource: FormsPage._pagedRoleSource,
              ),
            ),
            ComponentSection(
              title: '静态检索',
              child: AppComboboxFormField<_Assignee>(
                label: '静态对象检索',
                options: FormsPage._assignees,
                optionConfig: FormsPage._assigneeConfig,
                clearable: true,
              ),
            ),
            ComponentSection(
              title: '异步标签',
              child: AppComboboxFormField<_Assignee>.async(
                label: '异步标签检索',
                displayMode: AppComboboxDisplayMode.token,
                optionConfig: FormsPage._assigneeConfig,
                clearable: true,
                searchOptions: (query) async {
                  await Future<void>.delayed(const Duration(milliseconds: 350));
                  final normalized = query.trim().toLowerCase();
                  return FormsPage._assignees
                      .where(
                        (option) => FormsPage._assigneeConfig
                            .searchableText(option)
                            .toLowerCase()
                            .contains(normalized),
                      )
                      .toList();
                },
              ),
            ),
            ComponentSection(
              title: '静态省市县',
              child: AppRegionPickerFormField<String>(
                label: '静态省市县',
                options: FormsPage._regions,
              ),
            ),
            ComponentSection(
              title: '动态省市',
              child: AppRegionPickerFormField<String>.async(
                label: '动态省市',
                variant: AppRegionPickerVariant.provinceCity,
                loadOptions: FormsPage._loadRegions,
              ),
            ),
            ComponentSection(
              title: '静态市县',
              child: AppRegionPickerFormField<String>(
                label: '静态市县',
                variant: AppRegionPickerVariant.cityCounty,
                options: [
                  AppCascadeOption(
                    value: '杭州市',
                    label: '杭州市',
                    children: [
                      AppCascadeOption(value: '西湖区', label: '西湖区'),
                      AppCascadeOption(value: '滨江区', label: '滨江区'),
                    ],
                  ),
                ],
              ),
            ),
            ComponentSection(
              title: '权限分配',
              child: AppTransferFormField<String>(
                label: '角色权限',
                description: '选择条目后通过中间按钮在两侧移动。窄屏会自动切换为纵向布局。',
                options: const [
                  AppOption(value: 'dashboard', label: '查看仪表盘'),
                  AppOption(value: 'member', label: '管理成员'),
                  AppOption(value: 'report', label: '导出报表'),
                  AppOption(value: 'settings', label: '修改设置'),
                  AppOption(value: 'audit', label: '查看审计日志'),
                ],
                initialValue: _assignedPermissions,
                height: 260,
                onChanged: (value) =>
                    setState(() => _assignedPermissions = value),
              ),
            ),
            ComponentSection(
              title: '复选框',
              child: AppCheckboxFormField(
                controlLabel: const Text('接受条款'),
                validator: (value) => value == true ? null : '此项必填。',
              ),
            ),
            ComponentSection(
              title: '多选复选框',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppCheckboxGroupFormField<String>(
                    label: '时间选项',
                    layout: AppFieldLayout.horizontal,
                    labelWidth: 80,
                    valueDirection: Axis.horizontal,
                    initialValue: const ['none'],
                    options: const [
                      AppOption(value: 'none', label: '无要求'),
                      AppOption(value: 'day', label: '白天'),
                      AppOption(value: 'evening', label: '傍晚'),
                      AppOption(value: 'night', label: '夜间'),
                    ],
                  ),
                  const Gap(12),
                  AppCheckboxGroupFormField<String>(
                    label: '垂直标题',
                    layout: AppFieldLayout.vertical,
                    valueDirection: Axis.vertical,
                    initialValue: const ['read'],
                    options: const [
                      AppOption(value: 'read', label: '读取'),
                      AppOption(value: 'write', label: '写入'),
                    ],
                  ),
                  const Gap(12),
                  AppCheckboxGroupFormField<String>(
                    initialValue: const ['email'],
                    options: const [
                      AppOption(value: 'email', label: '邮件'),
                      AppOption(value: 'sms', label: '短信'),
                    ],
                  ),
                ],
              ),
            ),
            ComponentSection(
              title: '开关',
              child: AppSwitchFormField(controlLabel: const Text('启用通知')),
            ),
            ComponentSection(
              title: '单选组',
              child: AppRadioGroupFormField<String>(
                label: '密度',
                direction: Axis.horizontal,
                options: const [
                  AppOption(value: 'compact', label: '紧凑'),
                  AppOption(value: 'standard', label: '标准'),
                  AppOption(value: 'comfortable', label: '宽松'),
                ],
              ),
            ),
            ComponentSection(
              title: '滑块',
              child: AppSliderFormField(
                label: '音量',
                initialValue: const SliderValue.single(0.6),
                valueIndicatorBuilder: (context, value) =>
                    SliderValueIndicator(value: value),
              ),
            ),
            ComponentSection(
              title: '多行文本',
              child: AppTextAreaFormField(label: '备注', hintText: '补充请求背景'),
            ),
            ComponentSection(
              title: '验证码',
              child: AppInputOtpFormField(
                label: '验证码',
                length: 6,
                separatorEvery: 3,
                validator: AppValidators.exactLength(6),
              ),
            ),
            ComponentSection(
              title: '电话号码',
              child: AppPhoneInputFormField(
                label: '电话号码',
                searchHintText: '搜索国家或地区',
              ),
            ),
            ComponentSection(
              title: '标签输入',
              child: AppChipInputFormField<String>(
                label: '标签',
                initialValue: const ['flutter', 'desktop'],
                hintText: '输入标签后按回车',
                maxItems: 5,
              ),
            ),
            ComponentSection(
              title: '星级评分',
              child: AppStarRatingFormField(label: '体验评分', initialValue: 4),
            ),
            ComponentSection(
              title: '数字输入',
              child: AppNumberInputFormField(
                label: '数量',
                initialValue: 10,
                min: 0,
                max: 100,
              ),
            ),
            ComponentSection(
              title: '日期',
              child: AppDatePickerFormField(label: '开始日期'),
            ),
            ComponentSection(
              title: '日期范围',
              child: AppDateRangePickerFormField(label: '日期范围'),
            ),
            ComponentSection(
              title: '日期时间',
              child: AppDateTimePickerFormField(label: '日期时间'),
            ),
            ComponentSection(
              title: '时间',
              child: AppTimePickerFormField(
                label: '开始时间',
                use24HourFormat: true,
              ),
            ),
            ComponentSection(
              title: '格式化输入',
              child: AppFormattedInputFormField(
                label: '参考编号',
                initialValue: AppFormattedValue([
                  AppFormattedParts.fixed('APP-'),
                  AppFormattedParts.editable('', length: 4),
                  AppFormattedParts.fixed('-'),
                  AppFormattedParts.editable('', length: 2),
                ]),
              ),
            ),
            ComponentSection(
              title: '颜色选择',
              child: AppColorInputFormField(
                label: '强调色',
                initialValue: AppColorDerivative.fromColor(
                  const Color(0xff4f46e5),
                ),
              ),
            ),
            ComponentSection(
              title: '多选方案',
              child: AppMultipleChoiceFormField<String>(
                label: '方案',
                initialValue: 'team',
                options: [
                  AppOption(value: 'personal', label: '个人版'),
                  AppOption(value: 'team', label: '团队版'),
                  AppOption(value: 'business', label: '企业版'),
                ],
              ),
            ),
            ComponentSection(
              title: '条目选择',
              child: AppItemPickerFormField<String>(
                label: '工作区图标',
                hintText: '选择图标',
                title: Text('工作区图标'),
                options: [
                  AppOption(value: 'folder', label: '文件夹'),
                  AppOption(value: 'star', label: '星标'),
                  AppOption(value: 'archive', label: '归档'),
                ],
              ),
            ),
            ComponentSection(
              title: '多选控件',
              child: AppMultiSelectFormField<String>(
                label: '已选方案',
                initialValue: const ['finance', 'research', 'design', 'ops'],
                maxVisibleOptions: 3,
                options: [
                  AppOption(value: 'finance', label: '金融'),
                  AppOption(value: 'research', label: '研发'),
                  AppOption(value: 'design', label: '设计'),
                  AppOption(value: 'ops', label: '运营'),
                  AppOption(value: 'product', label: '产品'),
                ],
              ),
            ),
            ComponentSection(
              title: '拖动排序',
              child: AppSortableInputFormField<String>(
                label: '章节顺序',
                initialValue: const ['概览', '动态', '设置'],
                itemBuilder: (context, index, item) => AppCard(
                  padding: const EdgeInsets.all(12),
                  child: Text('${index + 1}. $item'),
                ),
              ),
            ),
            ComponentSection(
              title: '对象输入',
              child: AppObjectInputFormField<String>(
                label: '短代码',
                initialValue: 'APP',
                converter: AppObjectConverter(
                  (value) => [value],
                  (parts) => parts.first,
                ),
                parts: const [AppEditablePart(length: 3, width: 56)],
              ),
            ),
          ].where((section) {
            return widget.visibleSections?.contains(section.title) ?? true;
          }).toList(),
    );
  }
}

class _InlineEditDemo extends StatefulWidget {
  const _InlineEditDemo();

  @override
  State<_InlineEditDemo> createState() => _InlineEditDemoState();
}

class _InlineEditDemoState extends State<_InlineEditDemo> {
  String _name = '双击修改设备名称';
  String? _role = 'editor';
  DateTime? _date = DateTime(2026, 8, 7);
  bool _enabled = true;
  double _rating = 4;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppInlineEdit.text(
            value: _name,
            validator: (value) => value.trim().isEmpty ? '名称不能为空' : null,
            onSaved: (value) => setState(() => _name = value),
          ),
          AppInlineEdit.select<String>(
            value: _role,
            options: FormsPage._roles,
            onSaved: (value) => setState(() => _role = value),
          ),
          AppInlineEdit.date(
            value: _date,
            onSaved: (value) => setState(() => _date = value),
          ),
          AppInlineEdit.switchValue(
            value: _enabled,
            displayBuilder: (_, value) => Text(value ? '已启用' : '已停用'),
            onSaved: (value) => setState(() => _enabled = value),
          ),
          AppInlineEdit.starRating(
            value: _rating,
            onSaved: (value) => setState(() => _rating = value),
          ),
        ],
      ),
    );
  }
}
