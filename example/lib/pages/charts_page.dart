import 'package:flutter/widgets.dart';
import 'package:lemon_shadcn/lemon_shadcn.dart';
import 'package:lemon_shadcn/shadcn.dart' hide Column;

import 'actions_page.dart';

class ChartsPage extends StatefulWidget {
  const ChartsPage({super.key});

  @override
  State<ChartsPage> createState() => _ChartsPageState();
}

class _ChartsPageState extends State<ChartsPage> {
  Set<AppChartSelection> _selected = const <AppChartSelection>{};
  String _lastAction = '点击柱体查看回调结果';

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      title: '图表',
      description: '使用统一主题、业务数据和桌面端交互的开箱即用图表；点击后可用方向键浏览。',
      sections: <Widget>[
        ComponentSection(
          title: '基础柱状图',
          code: '''AppBarChart.simple(
  labels: const ['周一', '周二', '周三', '周四', '周五'],
  values: const [
    AppBarValue(value: 32),
    AppBarValue(value: 46),
    AppBarValue(value: 38, color: Color(0xff10b981)),
    AppBarValue(value: 61),
    AppBarValue(value: 54),
  ],
  yAxis: AppChartAxis(formatter: (value) => '¥\${value.toInt()}k'),
)''',
          child: AppBarChart.simple(
            labels: const <String>['周一', '周二', '周三', '周四', '周五'],
            values: const <AppBarValue>[
              AppBarValue(value: 32),
              AppBarValue(value: 46),
              AppBarValue(value: 38, color: Color(0xff10b981)),
              AppBarValue(value: 61),
              AppBarValue(value: 54),
            ],
            yAxis: AppChartAxis(
              title: '销售额',
              formatter: (value) => '¥${value.toInt()}k',
            ),
            onBarTap: (hit) => setState(
              () => _lastAction =
                  '${hit.group.label}：¥${hit.value.value?.toInt()}k',
            ),
          ),
        ),
        ComponentSection(
          title: '多系列、参考线与受控选中',
          code: '''AppBarChart(
  series: const [
    AppBarSeries(name: '收入'),
    AppBarSeries(name: '支出', color: Color(0xfff59e0b)),
  ],
  groups: groups,
  referenceLines: const [
    AppChartReferenceLine(value: 50, label: '目标'),
  ],
  selectionEnabled: true,
  selected: selected,
  onSelectionChanged: (value) => setState(() => selected = value),
)''',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              AppBarChart(
                series: const <AppBarSeries>[
                  AppBarSeries(name: '收入'),
                  AppBarSeries(name: '支出', color: Color(0xfff59e0b)),
                ],
                groups: const <AppBarGroup>[
                  AppBarGroup(
                    label: '一月',
                    values: <AppBarValue>[
                      AppBarValue(value: 52),
                      AppBarValue(value: 31),
                    ],
                  ),
                  AppBarGroup(
                    label: '二月',
                    values: <AppBarValue>[
                      AppBarValue(value: 63),
                      AppBarValue(value: 37),
                    ],
                  ),
                  AppBarGroup(
                    label: '三月',
                    values: <AppBarValue>[
                      AppBarValue(value: 58),
                      AppBarValue(value: 42, color: Color(0xffef4444)),
                    ],
                  ),
                  AppBarGroup(
                    label: '四月',
                    values: <AppBarValue>[
                      AppBarValue(value: 72),
                      AppBarValue(value: 39),
                    ],
                  ),
                ],
                yAxis: AppChartAxis(
                  min: 0,
                  max: 80,
                  interval: 20,
                  formatter: (value) => '${value.toInt()}万',
                ),
                referenceLines: const <AppChartReferenceLine>[
                  AppChartReferenceLine(value: 50, label: '目标'),
                ],
                selectionEnabled: true,
                selected: _selected,
                onSelectionChanged: (value) =>
                    setState(() => _selected = value),
                onBarTap: (hit) => setState(
                  () => _lastAction =
                      '${hit.group.label} · ${hit.series?.name}：${hit.value.value}万',
                ),
              ),
              const Gap(8),
              Text(_lastAction).muted(),
            ],
          ),
        ),
        ComponentSection(
          title: '折线与面积图',
          code: '''AppLineChart.area(
  series: series,
  yAxis: AppChartAxis(
    formatter: (value) => '\${value.toInt()} 次',
  ),
  referenceLines: const [
    AppChartReferenceLine(value: 40, label: '基准'),
  ],
)''',
          child: AppLineChart.area(
            series: const <AppLineSeries>[
              AppLineSeries(
                name: '本周',
                points: <AppLinePoint>[
                  AppLinePoint(x: 0, y: 24, label: '周一'),
                  AppLinePoint(x: 1, y: 38, label: '周二'),
                  AppLinePoint(x: 2, y: null, label: '周三'),
                  AppLinePoint(x: 3, y: 46, label: '周四'),
                  AppLinePoint(x: 4, y: 58, label: '周五'),
                ],
              ),
              AppLineSeries(
                name: '上周',
                color: Color(0xff10b981),
                points: <AppLinePoint>[
                  AppLinePoint(x: 0, y: 18, label: '周一'),
                  AppLinePoint(x: 1, y: 29, label: '周二'),
                  AppLinePoint(x: 2, y: 35, label: '周三'),
                  AppLinePoint(x: 3, y: 34, label: '周四'),
                  AppLinePoint(x: 4, y: 49, label: '周五'),
                ],
              ),
            ],
            yAxis: AppChartAxis(
              min: 0,
              max: 70,
              interval: 10,
              formatter: (value) => '${value.toInt()}次',
            ),
            referenceLines: const <AppChartReferenceLine>[
              AppChartReferenceLine(value: 40, label: '基准'),
            ],
            onPointTap: (hit) => setState(
              () => _lastAction =
                  '${hit.point.label} · ${hit.series.name}：${hit.point.y}次',
            ),
          ),
        ),
        ComponentSection(
          title: '堆叠柱状图',
          code: '''AppBarChart.stacked(
  series: const [
    AppBarSeries(name: '新客户'),
    AppBarSeries(name: '老客户'),
  ],
  groups: groups,
)''',
          child: AppBarChart.stacked(
            series: const <AppBarSeries>[
              AppBarSeries(name: '新客户'),
              AppBarSeries(name: '老客户', color: Color(0xff10b981)),
              AppBarSeries(name: '续费', color: Color(0xfff59e0b)),
            ],
            groups: const <AppBarGroup>[
              AppBarGroup(
                label: '一月',
                values: <AppBarValue>[
                  AppBarValue(value: 28),
                  AppBarValue(value: 17),
                  AppBarValue(value: 9),
                ],
              ),
              AppBarGroup(
                label: '二月',
                values: <AppBarValue>[
                  AppBarValue(value: 34),
                  AppBarValue(value: 21),
                  AppBarValue(value: 12),
                ],
              ),
              AppBarGroup(
                label: '三月',
                values: <AppBarValue>[
                  AppBarValue(value: 31),
                  AppBarValue(value: 25),
                  AppBarValue(value: 14),
                ],
              ),
              AppBarGroup(
                label: '四月',
                values: <AppBarValue>[
                  AppBarValue(value: 39),
                  AppBarValue(value: 27),
                  AppBarValue(value: 16),
                ],
              ),
            ],
            yAxis: AppChartAxis(
              min: 0,
              max: 100,
              interval: 20,
              formatter: (value) => '${value.toInt()}人',
            ),
            onBarTap: (hit) => setState(
              () => _lastAction =
                  '${hit.group.label} · ${hit.series?.name}：${hit.value.value}人',
            ),
          ),
        ),
        ComponentSection(
          title: '饼图与环形图',
          code: '''AppPieChart.donut(
  sections: const [
    AppPieSection(label: '桌面端', value: 56),
    AppPieSection(label: '移动端', value: 31),
    AppPieSection(label: '其他', value: 13),
  ],
  valueFormatter: (value) => '\${value.toInt()} 位',
)''',
          child: AppPieChart.donut(
            sections: const <AppPieSection>[
              AppPieSection(label: '桌面端', value: 56),
              AppPieSection(label: '移动端', value: 31, color: Color(0xff10b981)),
              AppPieSection(label: '其他', value: 13),
            ],
            valueFormatter: (value) => '${value.toInt()}位',
            onSectionTap: (hit) => setState(
              () => _lastAction =
                  '${hit.section.label}：${hit.section.value.toInt()}位',
            ),
          ),
        ),
        ComponentSection(
          title: '横向柱状图',
          code: '''AppBarChart.horizontal(
  groups: groups,
  xAxis: AppChartAxis(
    min: 0,
    max: 100,
    formatter: (value) => '\${value.toInt()}%',
  ),
  yAxis: const AppChartAxis(title: '区域'),
)''',
          child: AppBarChart.horizontal(
            groups: const <AppBarGroup>[
              AppBarGroup(
                label: '华东',
                values: <AppBarValue>[AppBarValue(value: 82)],
              ),
              AppBarGroup(
                label: '华南',
                values: <AppBarValue>[AppBarValue(value: 68)],
              ),
              AppBarGroup(
                label: '华北',
                values: <AppBarValue>[AppBarValue(value: 54)],
              ),
              AppBarGroup(
                label: '西南',
                values: <AppBarValue>[
                  AppBarValue(value: 46, color: Color(0xff10b981)),
                ],
              ),
            ],
            xAxis: AppChartAxis(
              min: 0,
              max: 100,
              interval: 20,
              formatter: (value) => '${value.toInt()}%',
            ),
            yAxis: const AppChartAxis(title: '区域'),
            showValues: true,
            onBarTap: (hit) => setState(
              () => _lastAction =
                  '${hit.group.label}：${hit.value.value?.toInt()}%',
            ),
          ),
        ),
        ComponentSection(
          title: '散点图',
          code: '''AppScatterChart(
  series: const [
    AppScatterSeries(
      name: '企业客户',
      points: [
        AppScatterPoint(x: 20, y: 68, label: '客户 A'),
        AppScatterPoint(x: 42, y: 51, label: '客户 B'),
      ],
    ),
  ],
)''',
          child: AppScatterChart(
            xAxis: const AppChartAxis(title: '活跃度'),
            yAxis: const AppChartAxis(title: '收入'),
            series: const <AppScatterSeries>[
              AppScatterSeries(
                name: '企业客户',
                points: <AppScatterPoint>[
                  AppScatterPoint(x: 20, y: 68, label: '客户 A'),
                  AppScatterPoint(x: 42, y: 51, label: '客户 B'),
                  AppScatterPoint(x: 64, y: 82, label: '客户 C'),
                ],
              ),
              AppScatterSeries(
                name: '个人客户',
                color: Color(0xff10b981),
                points: <AppScatterPoint>[
                  AppScatterPoint(x: 28, y: 32, label: '客户 D'),
                  AppScatterPoint(x: 55, y: 45, label: '客户 E'),
                  AppScatterPoint(x: 78, y: 61, label: '客户 F'),
                ],
              ),
            ],
            onPointTap: (hit) => setState(
              () => _lastAction =
                  '${hit.point.label ?? hit.series.name}: (${hit.point.x}, ${hit.point.y})',
            ),
          ),
        ),
        ComponentSection(
          title: '雷达图',
          code: '''AppRadarChart(
  indicators: const ['性能', '稳定性', '易用性', '扩展性', '成本'],
  series: const [
    AppRadarSeries(
      name: '当前方案',
      values: [82, 76, 88, 70, 64],
    ),
    AppRadarSeries(
      name: '目标方案',
      values: [90, 86, 84, 88, 72],
    ),
  ],
)''',
          child: AppRadarChart(
            indicators: const <String>['性能', '稳定性', '易用性', '扩展性', '成本'],
            series: const <AppRadarSeries>[
              AppRadarSeries(
                name: '当前方案',
                values: <double>[82, 76, 88, 70, 64],
              ),
              AppRadarSeries(
                name: '目标方案',
                color: Color(0xff10b981),
                values: <double>[90, 86, 84, 88, 72],
              ),
            ],
            onPointTap: (hit) => setState(
              () => _lastAction =
                  '${hit.indicator} · ${hit.series.name}：${hit.value.toInt()}',
            ),
          ),
        ),
        ComponentSection(
          title: 'K 线图',
          code: '''AppCandlestickChart(
  data: const [
    AppCandlestickData(
      label: '周一', open: 32, high: 41, low: 29, close: 38,
    ),
  ],
  onCandleTap: (hit) => handle(hit.data),
)''',
          child: AppCandlestickChart(
            data: const <AppCandlestickData>[
              AppCandlestickData(
                label: '周一',
                open: 32,
                high: 41,
                low: 29,
                close: 38,
              ),
              AppCandlestickData(
                label: '周二',
                open: 38,
                high: 44,
                low: 34,
                close: 36,
              ),
              AppCandlestickData(
                label: '周三',
                open: 36,
                high: 48,
                low: 35,
                close: 46,
              ),
              AppCandlestickData(
                label: '周四',
                open: 46,
                high: 49,
                low: 39,
                close: 41,
              ),
              AppCandlestickData(
                label: '周五',
                open: 41,
                high: 52,
                low: 40,
                close: 50,
              ),
            ],
            valueFormatter: (value) => '¥${value.toStringAsFixed(0)}',
            onCandleTap: (hit) => setState(
              () => _lastAction =
                  '${hit.data.label}：开 ${hit.data.open}，收 ${hit.data.close}',
            ),
          ),
        ),
        ComponentSection(
          title: '业务容器与异步数据',
          code: '''AppChartCard(
  title: const Text('实时订单'),
  description: const Text('加载、错误和内容使用相同高度'),
  child: AppAsyncChart<List<AppBarValue>>(
    load: loadOrders,
    builder: (_, values) => AppBarChart.simple(
      labels: const ['上午', '下午', '晚间'],
      values: values,
    ),
  ),
)''',
          child: AppChartCard(
            title: const Text('实时订单'),
            description: const Text('加载、错误和内容使用相同高度'),
            child: AppAsyncChart<List<AppBarValue>>(
              height: 220,
              load: () async => const <AppBarValue>[
                AppBarValue(value: 28),
                AppBarValue(value: 43),
                AppBarValue(value: 36),
              ],
              builder: (_, values) => AppBarChart.simple(
                labels: const <String>['上午', '下午', '晚间'],
                values: values,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
