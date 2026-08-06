import 'package:flutter/material.dart';
import 'package:lemon_shadcn/lemon_shadcn.dart';
import 'package:lemon_shadcn/shadcn.dart' as shad;

import 'add_device_dialog.dart';
import 'device.dart';
import 'devices_controller.dart';
import 'devices_layout.dart';

const _kListInset = 16.0;

/// Scenario demo ported from palsmon_saas LCD device management.
class DevicesPage extends StatefulWidget {
  const DevicesPage({super.key});

  @override
  State<DevicesPage> createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {
  late final DevicesController _controller = DevicesController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return DevicesPageBody.split(
          list: _DeviceList(controller: _controller),
          content: _DeviceDetail(controller: _controller),
        );
      },
    );
  }
}

class _DeviceList extends StatelessWidget {
  const _DeviceList({required this.controller});

  final DevicesController controller;

  @override
  Widget build(BuildContext context) {
    final colors = ShadcnTheme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(_kListInset, 16, _kListInset, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Builder(
                builder: (context) {
                  final formFiltered = controller.hasFormFilter;
                  final theme = ShadcnTheme.of(context);
                  return Row(
                    spacing: 8,
                    children: [
                      Expanded(
                        child: AppControlBox(
                          child: shad.TextField(
                            controller: controller.searchController,
                            onChanged: controller.setKeyword,
                            hintText: '搜索设备',
                            border: Border.all(
                              color: theme.colorScheme.border,
                              width: 1,
                              strokeAlign: BorderSide.strokeAlignInside,
                            ),
                            features: [
                              shad.InputFeature.leading(
                                Icon(
                                  AppLucideIcons.search,
                                  size: 15,
                                  color: theme.colorScheme.mutedForeground,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Builder(
                        builder: (anchorContext) => AppIconButton(
                          icon: Icon(
                            AppLucideIcons.listFilter,
                            size: 15,
                            color: formFiltered ? null : colors.mutedForeground,
                          ),
                          tooltip: '筛选条件',
                          variant: formFiltered
                              ? AppButtonVariant.secondary
                              : AppButtonVariant.outline,
                          onPressed: () => AppPopover.show<void>(
                            context: anchorContext,
                            alignment: Alignment.topRight,
                            anchorAlignment: Alignment.bottomRight,
                            builder: (popoverContext) => _DeviceFilterPanel(
                              controller: controller,
                              onClose: () => AppOverlay.close(popoverContext),
                            ),
                          ),
                        ),
                      ),
                      AppIconButton(
                        icon: const Icon(AppLucideIcons.plus, size: 16),
                        tooltip: '添加设备',
                        variant: AppButtonVariant.primary,
                        onPressed: () =>
                            showAddDeviceDialog(context, controller),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 12),
              AppTabs(
                index: controller.statusFilter.index,
                expand: true,
                onChanged: (index) {
                  controller.setStatusFilter(DeviceStatusFilter.values[index]);
                },
                children: [
                  AppTabItem(
                    child: Text(
                      '全部 ${controller.countFor(DeviceStatusFilter.all)}',
                    ),
                  ),
                  AppTabItem(
                    child: Text(
                      '在线 ${controller.countFor(DeviceStatusFilter.online)}',
                    ),
                  ),
                  AppTabItem(
                    child: Text(
                      '离线 ${controller.countFor(DeviceStatusFilter.offline)}',
                    ),
                  ),
                ],
              ),
              if (controller.hasActiveFilter)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: AppText.caption(
                          '已筛选 ${controller.filteredDevices.length} 台设备',
                        ),
                      ),
                      AppButton.link(
                        onPressed: controller.clearFilters,
                        child: const Text('清除'),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        AppDivider(color: colors.border, height: 1, thickness: 1),
        Expanded(
          child: Builder(
            builder: (context) {
              final items = controller.filteredDevices;

              if (items.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        AppLucideIcons.searchX,
                        size: 28,
                        color: colors.mutedForeground,
                      ),
                      const SizedBox(height: 10),
                      const AppText.muted('没有匹配的设备'),
                      const SizedBox(height: 8),
                      AppButton.link(
                        onPressed: controller.clearFilters,
                        child: const Text('清除筛选'),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
                itemCount: items.length + 1,
                itemBuilder: (context, index) {
                  if (index == items.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: AppText.caption('没有更多数据')),
                    );
                  }
                  final device = items[index];
                  return _DeviceListItem(
                    key: ValueKey(device.id),
                    device: device,
                    selected: device.id == controller.selectedId,
                    onTap: () => controller.selectDevice(device.id),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _DeviceFilterPanel extends StatelessWidget {
  const _DeviceFilterPanel({required this.controller, required this.onClose});

  final DevicesController controller;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final regionOptions = [
      for (final region in controller.regionOptions)
        AppOption(value: region, label: region),
    ];
    final customerOptions = [
      for (final customer in controller.customerOptions)
        AppOption(value: customer, label: customer),
    ];

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return SizedBox(
          width: 280,
          child: AppCard(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Expanded(child: AppText.title('筛选条件')),
                    AppIconButton(
                      icon: const Icon(AppLucideIcons.x, size: 14),
                      tooltip: '关闭',
                      variant: AppButtonVariant.ghost,
                      onPressed: onClose,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const AppText.label('所属区域'),
                const SizedBox(height: 8),
                AppSelect<String>(
                  value: controller.regionFilter,
                  hintText: '全部区域',
                  clearable: true,
                  options: regionOptions,
                  onChanged: controller.setRegionFilter,
                ),
                const SizedBox(height: 14),
                const AppText.label('客户'),
                const SizedBox(height: 8),
                AppSelect<String>(
                  value: controller.customerFilter,
                  hintText: '全部客户',
                  clearable: true,
                  options: customerOptions,
                  onChanged: controller.setCustomerFilter,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    AppButton.ghost(
                      onPressed: controller.clearFormFilters,
                      child: const Text('重置'),
                    ),
                    const Spacer(),
                    AppButton.primary(
                      onPressed: onClose,
                      child: const Text('完成'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DeviceListItem extends StatelessWidget {
  const _DeviceListItem({
    super.key,
    required this.device,
    required this.selected,
    required this.onTap,
  });

  final Device device;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = ShadcnTheme.of(context).colorScheme;
    final radius = ShadcnTheme.of(context).radius;
    final subtitle = [
      if (device.location != null && device.location!.isNotEmpty)
        device.location!,
      device.sn,
    ].join(' · ');

    final itemRadius = BorderRadius.circular(radius * 6);
    final selectedColor = Color.alphaBlend(
      colors.foreground.withValues(alpha: 0.04),
      colors.muted,
    );
    final borderColor = colors.border.withValues(alpha: selected ? 1 : 0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: AppInkWell(
        onPressed: onTap,
        borderRadius: itemRadius,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: selected
                ? selectedColor
                : selectedColor.withValues(alpha: 0),
            borderRadius: itemRadius,
            border: Border.all(color: borderColor),
          ),
          padding: const EdgeInsets.fromLTRB(10, 10, 8, 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.label(
                      device.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    AppText.caption(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _StatusPill(status: device.status, compact: true),
              const SizedBox(width: 4),
              Icon(
                AppLucideIcons.chevronRight,
                size: 16,
                color: colors.mutedForeground,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeviceDetail extends StatelessWidget {
  const _DeviceDetail({required this.controller});

  final DevicesController controller;

  @override
  Widget build(BuildContext context) {
    final colors = ShadcnTheme.of(context).colorScheme;
    final device = controller.selectedDevice;
    if (device == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              AppLucideIcons.monitor,
              size: 36,
              color: colors.mutedForeground,
            ),
            const SizedBox(height: 12),
            const AppText.muted('从左侧选择一台设备'),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      clipBehavior: Clip.none,
      child: DevicesContentWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DetailHeader(device: device),
            const SizedBox(height: 24),
            const _SectionTitle(title: '运行概览'),
            const SizedBox(height: 12),
            _MutedPanel(
              padding: EdgeInsets.zero,
              child: _MetricStrip(
                items: [
                  _MetricItem(
                    icon: AppLucideIcons.thermometer,
                    label: '温度',
                    value: device.temperature,
                  ),
                  _MetricItem(
                    icon: AppLucideIcons.sun,
                    label: '亮度',
                    value: device.brightness,
                  ),
                  _MetricItem(
                    icon: AppLucideIcons.droplets,
                    label: '湿度',
                    value: device.humidity,
                  ),
                  _MetricItem(
                    icon: AppLucideIcons.wind,
                    label: 'AQI',
                    value: device.aqi,
                  ),
                  _MetricItem(
                    icon: AppLucideIcons.clock,
                    label: '在线时长',
                    value: device.onlineDuration,
                  ),
                  _MetricItem(
                    icon: AppLucideIcons.power,
                    label: '累计开机',
                    value: device.totalUptime,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const _SectionTitle(title: '基本信息'),
            const SizedBox(height: 12),
            _MutedPanel(
              child: _PropertyGrid(
                rows: [
                  _PropertyItem(
                    icon: AppLucideIcons.building2,
                    label: '所属区域',
                    value: device.region,
                  ),
                  _PropertyItem(
                    icon: AppLucideIcons.users,
                    label: '客户',
                    value: device.customerName,
                  ),
                  _PropertyItem(
                    icon: AppLucideIcons.mapPinned,
                    label: '详细地址',
                    value: device.address,
                  ),
                  _PropertyItem(
                    icon: AppLucideIcons.mapPin,
                    label: '安装位置',
                    value: device.location,
                  ),
                  _PropertyItem(
                    icon: AppLucideIcons.layers,
                    label: '楼层',
                    value: device.floor,
                  ),
                  _PropertyItem(
                    icon: AppLucideIcons.locate,
                    label: '媒体位置',
                    value: device.mediaPosition,
                  ),
                  _PropertyItem(
                    icon: AppLucideIcons.scaling,
                    label: '尺寸',
                    value: device.dimensions,
                  ),
                  _PropertyItem(
                    icon: AppLucideIcons.monitor,
                    label: '分辨率',
                    value: device.resolution,
                  ),
                  _PropertyItem(
                    icon: AppLucideIcons.clock,
                    label: '营业时间',
                    value: device.operatingHours,
                  ),
                  _PropertyItem(
                    icon: AppLucideIcons.briefcase,
                    label: '管理单位',
                    value: device.managers.isEmpty
                        ? null
                        : device.managers.join('、'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const _SectionTitle(title: '设备状态'),
            const SizedBox(height: 12),
            _MutedPanel(
              child: _PropertyGrid(
                rows: [
                  _PropertyItem(
                    icon: AppLucideIcons.hash,
                    label: '设备编号',
                    value: device.sn,
                  ),
                  _PropertyItem(
                    icon: AppLucideIcons.cpu,
                    label: '控制 ID',
                    value: device.controlId,
                  ),
                  _PropertyItem(
                    icon: AppLucideIcons.calendar,
                    label: '创建时间',
                    value: device.createdAt,
                  ),
                  _PropertyItem(
                    icon: AppLucideIcons.history,
                    label: '最近在线',
                    value: device.lastSeenAt,
                  ),
                  _PropertyItem(
                    icon: AppLucideIcons.globe,
                    label: 'IP 地址',
                    value: device.ip,
                  ),
                  _PropertyItem(
                    icon: AppLucideIcons.wifi,
                    label: '连接方式',
                    value: device.connection,
                  ),
                  _PropertyItem(
                    icon: AppLucideIcons.zap,
                    label: '电压',
                    value: device.voltage,
                  ),
                  _PropertyItem(
                    icon: AppLucideIcons.plug,
                    label: '功耗',
                    value: device.power,
                  ),
                  _PropertyItem(
                    icon: AppLucideIcons.appWindow,
                    label: '系统',
                    value: device.os,
                  ),
                  _PropertyItem(
                    icon: AppLucideIcons.cloud,
                    label: 'CO₂',
                    value: device.co2,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                AppButton.link(onPressed: () {}, child: const Text('查看播放日志')),
                AppButton.link(onPressed: () {}, child: const Text('查看操作日志')),
              ],
            ),
            const SizedBox(height: 24),
            const _SectionTitle(title: '位置'),
            const SizedBox(height: 12),
            _MutedPanel(
              padding: EdgeInsets.zero,
              child: _MapBlock(device: device),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailHeader extends StatelessWidget {
  const _DetailHeader({required this.device});

  final Device device;

  @override
  Widget build(BuildContext context) {
    final subtitle = [
      device.sn,
      if (device.customerName != null && device.customerName!.isNotEmpty)
        device.customerName!,
    ].join(' · ');

    return DevicesDetailHeader(
      title: device.name,
      subtitle: subtitle,
      status: _StatusPill(status: device.status),
      meta: [
        if (device.location != null)
          DevicesDetailHeaderMeta(
            icon: AppLucideIcons.mapPin,
            text: device.location!,
          ),
        if (device.region != null)
          DevicesDetailHeaderMeta(
            icon: AppLucideIcons.building2,
            text: device.region!,
          ),
        DevicesDetailHeaderMeta(
          icon: AppLucideIcons.monitor,
          text: device.resolution,
        ),
      ],
      actions: [
        for (final action in _headerActions)
          AppButton.outline(
            leading: Icon(action.icon, size: 15),
            onPressed: () {},
            child: Text(action.label),
          ),
      ],
    );
  }
}

class _HeaderAction {
  const _HeaderAction(this.icon, this.label);

  final IconData icon;
  final String label;
}

const _headerActions = [
  _HeaderAction(AppLucideIcons.rotateCcw, '重启'),
  _HeaderAction(AppLucideIcons.volume2, '音量'),
  _HeaderAction(AppLucideIcons.sun, '亮度'),
  _HeaderAction(AppLucideIcons.volumeX, '静音'),
];

class _MutedPanel extends StatelessWidget {
  const _MutedPanel({
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final colors = ShadcnTheme.of(context).colorScheme;
    final radius = ShadcnTheme.of(context).radius;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.muted.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(radius * 8),
        border: Border.all(color: colors.border),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class _MetricItem {
  const _MetricItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String? value;
}

class _MetricStrip extends StatelessWidget {
  const _MetricStrip({required this.items});

  final List<_MetricItem> items;

  @override
  Widget build(BuildContext context) {
    final colors = ShadcnTheme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 720
            ? 6
            : constraints.maxWidth >= 480
            ? 3
            : 2;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var row = 0; row * columns < items.length; row++) ...[
              if (row > 0)
                AppDivider(color: colors.border, height: 1, thickness: 1),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var col = 0; col < columns; col++) ...[
                      if (col > 0)
                        ColoredBox(
                          color: colors.border,
                          child: const SizedBox(width: 1),
                        ),
                      Expanded(
                        child: row * columns + col < items.length
                            ? _MetricCell(item: items[row * columns + col])
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _MetricCell extends StatelessWidget {
  const _MetricCell({required this.item});

  final _MetricItem item;

  @override
  Widget build(BuildContext context) {
    final colors = ShadcnTheme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(item.icon, size: 13, color: colors.mutedForeground),
              const SizedBox(width: 6),
              Expanded(
                child: AppText.caption(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          AppText.label(
            item.value ?? '—',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return AppText.section(title);
  }
}

class _PropertyItem {
  const _PropertyItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String? value;
}

class _PropertyGrid extends StatelessWidget {
  const _PropertyGrid({required this.rows});

  final List<_PropertyItem> rows;

  @override
  Widget build(BuildContext context) {
    final colors = ShadcnTheme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final twoCol = constraints.maxWidth >= 560;
        if (!twoCol) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < rows.length; i++) ...[
                if (i > 0)
                  AppDivider(color: colors.border, height: 1, thickness: 1),
                _PropertyRow(item: rows[i]),
              ],
            ],
          );
        }

        final left = <_PropertyItem>[];
        final right = <_PropertyItem>[];
        for (var i = 0; i < rows.length; i++) {
          (i.isEven ? left : right).add(rows[i]);
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _PropertyColumn(rows: left)),
            ColoredBox(color: colors.border, child: const SizedBox(width: 1)),
            Expanded(child: _PropertyColumn(rows: right)),
          ],
        );
      },
    );
  }
}

class _PropertyColumn extends StatelessWidget {
  const _PropertyColumn({required this.rows});

  final List<_PropertyItem> rows;

  @override
  Widget build(BuildContext context) {
    final colors = ShadcnTheme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < rows.length; i++) ...[
          if (i > 0) AppDivider(color: colors.border, height: 1, thickness: 1),
          _PropertyRow(item: rows[i]),
        ],
      ],
    );
  }
}

class _PropertyRow extends StatelessWidget {
  const _PropertyRow({required this.item});

  final _PropertyItem item;

  @override
  Widget build(BuildContext context) {
    final colors = ShadcnTheme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(item.icon, size: 14, color: colors.mutedForeground),
          ),
          const SizedBox(width: 8),
          SizedBox(width: 72, child: AppText.muted(item.label)),
          Expanded(
            child: AppText.label(
              item.value ?? '—',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _MapBlock extends StatelessWidget {
  const _MapBlock({required this.device});

  final Device device;

  @override
  Widget build(BuildContext context) {
    final colors = ShadcnTheme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
          child: Row(
            children: [
              Icon(
                AppLucideIcons.mapPin,
                size: 16,
                color: device.status.isOnline
                    ? colors.primary
                    : colors.mutedForeground,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppText.label(
                  device.address ?? device.location ?? '—',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        AppDivider(color: colors.border),
        SizedBox(
          height: 180,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(painter: _MapGridPainter(color: colors.border)),
              Center(
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colors.card,
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.border),
                  ),
                  child: Icon(
                    AppLucideIcons.mapPin,
                    size: 18,
                    color: device.status.isOnline
                        ? colors.primary
                        : colors.mutedForeground,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MapGridPainter extends CustomPainter {
  const _MapGridPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.65)
      ..strokeWidth = 1;
    const step = 28.0;
    for (var x = 0.0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _MapGridPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status, this.compact = false});

  final DeviceStatus status;
  final bool compact;

  Color _tone(AppColorScheme colors) => switch (status) {
    DeviceStatus.online => colors.primary,
    DeviceStatus.offline => colors.mutedForeground,
    DeviceStatus.fault => colors.destructive,
  };

  @override
  Widget build(BuildContext context) {
    final colors = ShadcnTheme.of(context).colorScheme;
    final tone = _tone(colors);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: tone.withValues(alpha: compact ? 0.1 : 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 8 : 10,
          vertical: compact ? 2 : 4,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: tone, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            AppText.caption(
              status.label,
              style: TextStyle(color: tone, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
