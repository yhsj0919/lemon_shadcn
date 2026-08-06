import 'package:flutter/material.dart';
import 'package:lemon_shadcn/lemon_shadcn.dart';
import 'package:lemon_shadcn/shadcn.dart' as shad;

import 'device.dart';
import 'devices_controller.dart';

void showAddDeviceDialog(BuildContext context, DevicesController controller) {
  AppDialog.show<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => _AddDeviceDialog(controller: controller),
  );
}

class _PowerSlot {
  _PowerSlot({required this.onTime, required this.offTime});

  shad.TimeOfDay onTime;
  shad.TimeOfDay offTime;
}

class _AddDeviceDialog extends StatefulWidget {
  const _AddDeviceDialog({required this.controller});

  final DevicesController controller;

  @override
  State<_AddDeviceDialog> createState() => _AddDeviceDialogState();
}

class _AddDeviceDialogState extends State<_AddDeviceDialog> {
  final _form = AppFormController();
  final _slots = <_PowerSlot>[
    _PowerSlot(
      onTime: const shad.TimeOfDay(hour: 8, minute: 0),
      offTime: const shad.TimeOfDay(hour: 23, minute: 0),
    ),
  ];

  String? _province;
  String? _city;
  String? _district;
  bool _regionValidated = false;

  String? _regionErrorFor(String? value, String message) {
    if (!_regionValidated || value != null) return null;
    return message;
  }

  static const _regionTree = <String, Map<String, List<String>>>{
    '广东省': {
      '广州市': ['天河区', '番禺区', '海珠区', '越秀区'],
      '深圳市': ['南山区', '福田区', '宝安区'],
    },
    '北京市': {
      '北京市': ['朝阳区', '海淀区', '东城区'],
    },
    '上海市': {
      '上海市': ['浦东新区', '黄浦区', '徐汇区'],
    },
  };

  static const _networkOptions = [
    AppOption(value: '流量卡', label: '流量卡'),
    AppOption(value: '有线', label: '有线'),
    AppOption(value: 'Wi-Fi', label: 'Wi-Fi'),
  ];

  List<AppOption<String>> get _provinceOptions => [
    for (final name in _regionTree.keys) AppOption(value: name, label: name),
  ];

  List<AppOption<String>> get _cityOptions {
    final cities = _regionTree[_province];
    if (cities == null) return const [];
    return [
      for (final name in cities.keys) AppOption(value: name, label: name),
    ];
  }

  List<AppOption<String>> get _districtOptions {
    final districts = _regionTree[_province]?[_city];
    if (districts == null) return const [];
    return [for (final name in districts) AppOption(value: name, label: name)];
  }

  @override
  void dispose() {
    _form.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _regionValidated = true);
    if (_province == null || _city == null || _district == null) {
      AppToast.show(context: context, title: '请完善必填项');
      return;
    }

    final ok = await _form.submit((values) async {
      widget.controller.addDevice(_toDevice(values));
      if (!mounted) return;
      AppToast.show(context: context, title: '已添加设备');
      AppOverlay.close(context);
    });
    if (!ok && mounted) {
      AppToast.show(context: context, title: '请完善必填项');
    }
  }

  Device _toDevice(Map<String, Object?> values) {
    final name = (values['name'] as String?)?.trim() ?? '';
    final address = (values['address'] as String?)?.trim();
    final road = (values['road'] as String?)?.trim();
    final building = (values['building'] as String?)?.trim();
    final mediaPosition = (values['mediaPosition'] as String?)?.trim();
    final mediaSize = (values['mediaSize'] as String?)?.trim();
    final width = (values['screenWidth'] as String?)?.trim() ?? '';
    final height = (values['screenHeight'] as String?)?.trim() ?? '';
    final controlId = (values['controlId'] as String?)?.trim();
    final network = values['network'] as String? ?? '流量卡';
    final brand = (values['brand'] as String?)?.trim();
    final model = (values['model'] as String?)?.trim();
    final os = (values['os'] as String?)?.trim();
    final brandLabel = [
      if (brand != null && brand.isNotEmpty) brand,
      if (model != null && model.isNotEmpty) model,
    ].join(' ');
    final regionParts = [?_province, ?_city, ?_district];

    final hours = _slots
        .map(
          (slot) =>
              '${_formatTime(slot.onTime)} – ${_formatTime(slot.offTime)}',
        )
        .join('；');

    return Device(
      id: DateTime.now().millisecondsSinceEpoch,
      name: name.isEmpty ? '未命名点位' : name,
      sn: 'LCD-${DateTime.now().millisecondsSinceEpoch % 100000}',
      status: DeviceStatus.offline,
      resolution: (width.isEmpty || height.isEmpty) ? '—' : '$width×$height',
      region: regionParts.isEmpty ? null : regionParts.join(''),
      address: address,
      location: [
        if (road != null && road.isNotEmpty) road,
        if (building != null && building.isNotEmpty) building,
        if (mediaPosition != null && mediaPosition.isNotEmpty) mediaPosition,
      ].join(' · ')._nullIfEmpty,
      floor: building,
      mediaPosition: mediaPosition,
      dimensions: [
        if (mediaSize != null && mediaSize.isNotEmpty) mediaSize,
        if (brandLabel.isNotEmpty) brandLabel,
      ].join(' · ')._nullIfEmpty,
      operatingHours: hours,
      controlId: controlId,
      connection: network,
      os: os,
      createdAt: _today(),
      managers: [
        if ((values['maintenanceCompany'] as String?)?.trim().isNotEmpty ??
            false)
          (values['maintenanceCompany'] as String).trim(),
        if ((values['inspector'] as String?)?.trim().isNotEmpty ?? false)
          (values['inspector'] as String).trim(),
      ],
    );
  }

  static String _formatTime(shad.TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  static String _today() {
    final now = DateTime.now();
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return '${now.year}-$m-$d';
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.72;

    return AppFormDialog(
      title: const Text('添加设备'),
      constraints: const BoxConstraints(maxWidth: 920),
      content: SizedBox(
        width: 880,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: SingleChildScrollView(
            child: AppForm(
              controller: _form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppTextFormField(
                    name: 'name',
                    label: '点位名称',
                    required: true,
                    hintText: '请输入',
                    validator: AppValidators.required(message: '请输入点位名称'),
                  ),
                  const SizedBox(height: 14),
                  _FormRow(
                    children: [
                      _CascadeSelect(
                        label: '省份',
                        hintText: '请选择',
                        options: _provinceOptions,
                        value: _province,
                        errorText: _regionErrorFor(_province, '请选择省份'),
                        onChanged: (value) {
                          setState(() {
                            _province = value;
                            _city = null;
                            _district = null;
                          });
                        },
                      ),
                      _CascadeSelect(
                        label: '城市',
                        hintText: '请先选择省份',
                        options: _cityOptions,
                        value: _city,
                        enabled: _province != null,
                        errorText: _regionErrorFor(_city, '请选择城市'),
                        onChanged: (value) {
                          setState(() {
                            _city = value;
                            _district = null;
                          });
                        },
                      ),
                      _CascadeSelect(
                        label: '区县',
                        hintText: '请先选择城市',
                        options: _districtOptions,
                        value: _district,
                        enabled: _city != null,
                        errorText: _regionErrorFor(_district, '请选择区县'),
                        onChanged: (value) {
                          setState(() => _district = value);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  AppTextFormField(
                    name: 'address',
                    label: '详细地址',
                    required: true,
                    hintText: '点击选择地图位置',
                    validator: AppValidators.required(message: '请输入详细地址'),
                    features: [
                      shad.InputFeature.trailing(
                        AppButton.link(
                          leading: const Icon(
                            AppLucideIcons.mapPinned,
                            size: 14,
                          ),
                          onPressed: () {
                            AppToast.show(
                              context: context,
                              title: '地图选点',
                              message: '地图组件待接入，可先手动填写地址',
                            );
                          },
                          child: const Text('地图选点'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _FormRow(
                    children: [
                      AppTextFormField(
                        name: 'road',
                        label: '道路名称',
                        hintText: '请输入',
                      ),
                      AppTextFormField(
                        name: 'building',
                        label: '楼栋',
                        hintText: '请输入',
                      ),
                      AppTextFormField(
                        name: 'mediaPosition',
                        label: '媒体位置',
                        hintText: '请输入',
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _FormRow(
                    children: [
                      AppTextFormField(
                        name: 'mediaSize',
                        label: '媒体尺寸',
                        hintText: '请输入',
                      ),
                      AppTextFormField(
                        name: 'screenWidth',
                        label: '屏幕宽度',
                        required: true,
                        hintText: '请输入',
                        keyboardType: TextInputType.number,
                        validator: AppValidators.required(message: '请输入屏幕宽度'),
                      ),
                      AppTextFormField(
                        name: 'screenHeight',
                        label: '屏幕高度',
                        required: true,
                        hintText: '请输入',
                        keyboardType: TextInputType.number,
                        validator: AppValidators.required(message: '请输入屏幕高度'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _PowerScheduleSection(
                    slots: _slots,
                    onAdd: () {
                      setState(() {
                        _slots.add(
                          _PowerSlot(
                            onTime: const shad.TimeOfDay(hour: 8, minute: 0),
                            offTime: const shad.TimeOfDay(hour: 23, minute: 0),
                          ),
                        );
                      });
                    },
                    onRemove: (index) {
                      if (_slots.length <= 1) return;
                      setState(() => _slots.removeAt(index));
                    },
                    onChanged: () => setState(() {}),
                  ),
                  const SizedBox(height: 18),
                  _FormRow(
                    children: [
                      AppTextFormField(
                        name: 'controlId',
                        label: '播控绑定ID',
                        hintText: '请输入',
                      ),
                      AppSelectFormField<String>(
                        name: 'network',
                        label: '联网方式',
                        hintText: '请选择',
                        options: _networkOptions,
                        initialValue: '流量卡',
                      ),
                      AppTextFormField(
                        name: 'billingDay',
                        label: '电费计费日期',
                        hintText: '请输入',
                        initialValue: '1',
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _FormRow(
                    children: [
                      AppTextFormField(
                        name: 'price',
                        label: '电价',
                        hintText: '请输入',
                        initialValue: '1',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                      AppTextFormField(
                        name: 'brand',
                        label: '屏幕品牌',
                        hintText: '请输入',
                      ),
                      AppTextFormField(
                        name: 'model',
                        label: '品牌型号',
                        hintText: '请输入',
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _FormRow(
                    children: [
                      AppTextFormField(
                        name: 'os',
                        label: '系统类型',
                        hintText: '请输入',
                      ),
                      AppTextFormField(
                        name: 'maintenanceCompany',
                        label: '维保公司',
                        required: true,
                        hintText: '请输入',
                        validator: AppValidators.required(message: '请输入维保公司'),
                      ),
                      AppTextFormField(
                        name: 'maintenanceContact',
                        label: '维保联系人',
                        required: true,
                        hintText: '请输入',
                        validator: AppValidators.required(message: '请输入维保联系人'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _FormRow(
                    children: [
                      AppTextFormField(
                        name: 'maintenancePhone',
                        label: '维保电话',
                        required: true,
                        hintText: '请输入',
                        keyboardType: TextInputType.phone,
                        validator: AppValidators.required(message: '请输入维保电话'),
                      ),
                      AppTextFormField(
                        name: 'inspector',
                        label: '巡检人',
                        required: true,
                        hintText: '请输入',
                        validator: AppValidators.required(message: '请输入巡检人'),
                      ),
                      const SizedBox.shrink(),
                    ],
                  ),
                  const SizedBox(height: 14),
                  AppTextAreaFormField(
                    name: 'remark',
                    label: '备注',
                    hintText: '请输入',
                    minHeight: 88,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      actions: [
        AppButton.outline(
          onPressed: () => AppOverlay.close(context),
          child: const Text('取消'),
        ),
        AppButton.primary(onPressed: _submit, child: const Text('确定')),
      ],
    );
  }
}

class _CascadeSelect extends StatelessWidget {
  const _CascadeSelect({
    required this.label,
    required this.hintText,
    required this.options,
    required this.value,
    required this.onChanged,
    this.errorText,
    this.enabled = true,
  });

  final String label;
  final String hintText;
  final List<AppOption<String>> options;
  final String? value;
  final ValueChanged<String?> onChanged;
  final String? errorText;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return AppField(
      label: label,
      required: true,
      errorText: errorText,
      child: AppSelect<String>(
        value: value,
        options: options,
        hintText: hintText,
        enabled: enabled,
        onChanged: onChanged,
      ),
    );
  }
}

class _FormRow extends StatelessWidget {
  const _FormRow({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 12.0;
        final columns = constraints.maxWidth < 640 ? 1 : 3;
        if (columns == 1) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) const SizedBox(height: gap),
                children[i],
              ],
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0) const SizedBox(width: gap),
              Expanded(child: children[i]),
            ],
          ],
        );
      },
    );
  }
}

class _PowerScheduleSection extends StatelessWidget {
  const _PowerScheduleSection({
    required this.slots,
    required this.onAdd,
    required this.onRemove,
    required this.onChanged,
  });

  final List<_PowerSlot> slots;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = ShadcnTheme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(child: AppText.label('开关机时间')),
            AppButton.link(
              leading: const Icon(AppLucideIcons.plus, size: 14),
              onPressed: onAdd,
              child: const Text('添加时段'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        for (var i = 0; i < slots.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: AppField(
                  label: '开机时间',
                  child: AppTimePicker(
                    value: slots[i].onTime,
                    use24HourFormat: true,
                    onChanged: (value) {
                      if (value == null) return;
                      slots[i].onTime = value;
                      onChanged();
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppField(
                  label: '关机时间',
                  child: AppTimePicker(
                    value: slots[i].offTime,
                    use24HourFormat: true,
                    onChanged: (value) {
                      if (value == null) return;
                      slots[i].offTime = value;
                      onChanged();
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: AppIconButton(
                  icon: Icon(
                    AppLucideIcons.circleMinus,
                    size: 18,
                    color: colors.mutedForeground,
                  ),
                  tooltip: '删除时段',
                  variant: AppButtonVariant.ghost,
                  onPressed: slots.length <= 1 ? null : () => onRemove(i),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

extension on String {
  String? get _nullIfEmpty => isEmpty ? null : this;
}
