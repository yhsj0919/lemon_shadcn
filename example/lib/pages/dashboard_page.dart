import 'package:lemon_shadcn/lemon_shadcn.dart';

import 'actions_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      title: '仪表盘',
      description: 'Lemon Shadcn 组件库概览。',
      sections: [
        ComponentSection(
          title: '组件概览',
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: const [
              _MetricCard(label: '组件登记', value: '84'),
              _MetricCard(label: '示例分类', value: '16'),
              _MetricCard(label: '上游版本', value: '0.0.53'),
            ],
          ),
        ),
        const ComponentSection(
          title: '使用说明',
          child: AppText.body('从左侧选择组件分类，查看组件状态、交互方式和推荐用法。'),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: AppCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [AppText.muted(label), const Gap(8), AppText.h2(value)],
        ),
      ),
    );
  }
}
