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

  @override
  State<FormsPage> createState() => _FormsPageState();
}

class _FormsPageState extends State<FormsPage> {
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
            ComponentSection(
              title: '表单布局与输入组',
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
              title: '文件选择',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppFilePickerFormField(
                    label: '单文件图片',
                    description: '仅选择一张图片，也可以直接拖入替换。',
                    variant: AppFilePickerVariant.simple,
                    multiple: false,
                    allowedExtensions: const ['png', 'jpg', 'jpeg', 'webp'],
                    maxFileSize: 10 * 1024 * 1024,
                    dialogTitle: '选择图片',
                    trailingBuilder: (context, file, index) =>
                        _buildUploadProgress(file, compact: true),
                    onChanged: (files) =>
                        _updateUploadFiles(files, single: true),
                  ),
                  const Gap(16),
                  AppField(
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
                ],
              ),
            ),
            ComponentSection(
              title: '文本输入',
              child: AppTextFormField.email(
                label: '邮箱',
                description: '用户开始输入后执行校验。',
                required: true,
                hintText: 'name@example.com',
              ),
            ),
            ComponentSection(
              title: '选择框',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppSelectFormField<String>(
                    label: '静态角色',
                    options: FormsPage._roles,
                    required: true,
                  ),
                  const Gap(12),
                  AppSelectFormField<String>.async(
                    label: '异步角色',
                    loadOptions: FormsPage._loadRoles,
                    clearable: true,
                  ),
                ],
              ),
            ),
            ComponentSection(
              title: '异步自动完成',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppAutoCompleteFormField<String>.source(
                    label: '负责人',
                    optionSource: FormsPage._roleSource,
                  ),
                  const Gap(12),
                  AppAutoCompleteFormField<String>.paged(
                    label: '分页选择负责人',
                    pagedOptionSource: FormsPage._pagedRoleSource,
                  ),
                ],
              ),
            ),
            ComponentSection(
              title: '组合框',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppComboboxFormField<_Assignee>(
                    label: '静态对象检索',
                    options: FormsPage._assignees,
                    optionConfig: FormsPage._assigneeConfig,
                    clearable: true,
                  ),
                  const Gap(12),
                  AppComboboxFormField<_Assignee>.async(
                    label: '异步标签检索',
                    displayMode: AppComboboxDisplayMode.token,
                    optionConfig: FormsPage._assigneeConfig,
                    clearable: true,
                    searchOptions: (query) async {
                      await Future<void>.delayed(
                        const Duration(milliseconds: 350),
                      );
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
                ],
              ),
            ),
            ComponentSection(
              title: '布尔与单选控件',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppCheckboxFormField(
                    controlLabel: const Text('接受条款'),
                    validator: (value) => value == true ? null : '此项必填。',
                  ),
                  const Gap(8),
                  AppSwitchFormField(controlLabel: const Text('启用通知')),
                  const Gap(8),
                  AppRadioGroupFormField<String>(
                    label: '密度',
                    direction: Axis.horizontal,
                    options: const [
                      AppOption(value: 'compact', label: '紧凑'),
                      AppOption(value: 'standard', label: '标准'),
                      AppOption(value: 'comfortable', label: '宽松'),
                    ],
                  ),
                  const Gap(8),
                  AppSliderFormField(
                    label: '音量',
                    initialValue: const SliderValue.single(0.6),
                    valueIndicatorBuilder: (context, value) =>
                        SliderValueIndicator(value: value),
                  ),
                ],
              ),
            ),
            ComponentSection(
              title: '专用输入',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTextAreaFormField(label: '备注', hintText: '补充请求背景'),
                  const Gap(12),
                  AppInputOtpFormField(
                    label: '验证码',
                    length: 6,
                    separatorEvery: 3,
                    validator: AppValidators.exactLength(6),
                  ),
                  const Gap(12),
                  AppPhoneInputFormField(
                    label: '电话号码',
                    searchPlaceholder: const Text('搜索国家或地区'),
                  ),
                  const Gap(12),
                  AppChipInputFormField<String>(
                    label: '标签',
                    initialValue: const ['flutter', 'desktop'],
                    placeholder: const Text('输入标签后按回车'),
                    maxItems: 5,
                  ),
                  const Gap(12),
                  AppStarRatingFormField(label: '体验评分', initialValue: 4),
                  const Gap(12),
                  AppNumberInputFormField(
                    label: '数量',
                    initialValue: 10,
                    min: 0,
                    max: 100,
                  ),
                ],
              ),
            ),
            ComponentSection(
              title: '日期与时间',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppDatePickerFormField(label: '开始日期'),
                  const Gap(12),
                  AppDateRangePickerFormField(label: '日期范围'),
                  const Gap(12),
                  AppDateTimePickerFormField(label: '日期时间'),
                  const Gap(12),
                  AppTimePickerFormField(label: '开始时间', use24HourFormat: true),
                ],
              ),
            ),
            ComponentSection(
              title: '格式化与可视化选择',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppFormattedInputFormField(
                    label: '参考编号',
                    initialValue: AppFormattedValue([
                      AppFormattedParts.fixed('APP-'),
                      AppFormattedParts.editable('', length: 4),
                      AppFormattedParts.fixed('-'),
                      AppFormattedParts.editable('', length: 2),
                    ]),
                  ),
                  const Gap(12),
                  AppColorInputFormField(
                    label: '强调色',
                    initialValue: AppColorDerivative.fromColor(
                      const Color(0xff4f46e5),
                    ),
                  ),
                  const Gap(12),
                  AppMultipleChoiceFormField<String>(
                    label: '方案',
                    initialValue: 'team',
                    options: [
                      AppOption(value: 'personal', label: '个人版'),
                      AppOption(value: 'team', label: '团队版'),
                      AppOption(value: 'business', label: '企业版'),
                    ],
                  ),
                  const Gap(12),
                  AppItemPickerFormField<String>(
                    label: '工作区图标',
                    placeholder: Text('选择图标'),
                    title: Text('工作区图标'),
                    options: [
                      AppOption(value: 'folder', label: '文件夹'),
                      AppOption(value: 'star', label: '星标'),
                      AppOption(value: 'archive', label: '归档'),
                    ],
                  ),
                ],
              ),
            ),
            ComponentSection(
              title: '排序与对象输入',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSortableInputFormField<String>(
                    label: '章节顺序',
                    initialValue: const ['概览', '动态', '设置'],
                    itemBuilder: (context, index, item) => AppCard(
                      padding: const EdgeInsets.all(12),
                      child: Text('${index + 1}. $item'),
                    ),
                  ),
                  const Gap(12),
                  AppObjectInputFormField<String>(
                    label: '短代码',
                    initialValue: 'APP',
                    converter: AppObjectConverter(
                      (value) => [value],
                      (parts) => parts.first,
                    ),
                    parts: const [AppEditablePart(length: 3, width: 56)],
                  ),
                ],
              ),
            ),
            ComponentSection(
              title: '托管异步校验',
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
          ].where((section) {
            return widget.visibleSections?.contains(section.title) ?? true;
          }).toList(),
    );
  }
}
