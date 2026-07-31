import 'package:lemon_shadcn/lemon_shadcn.dart';
import 'package:lemon_shadcn/shadcn.dart';

import 'actions_page.dart';

class LayoutPage extends StatelessWidget {
  const LayoutPage({
    super.key,
    this.visibleSections,
    this.title = '布局与折叠',
    this.description = '容器与渐进式内容展示组件。',
  });

  final Set<String>? visibleSections;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      title: title,
      description: description,
      sections:
          <ComponentSection>[
            const ComponentSection(
              title: '卡片',
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [Text('默认卡片'), Gap(6), Text('样式继续由上游主题统一控制。')],
                ),
              ),
            ),
            const ComponentSection(
              title: '提示变体',
              child: Column(
                children: [
                  AppAlert(title: Text('提示信息'), content: Text('标准提示样式。')),
                  Gap(12),
                  AppAlert.destructive(
                    title: Text('需要处理'),
                    content: Text('危险样式直接使用上游真实变体。'),
                  ),
                ],
              ),
            ),
            const ComponentSection(
              title: '手风琴',
              child: AppAccordion(
                items: [
                  AppAccordionItem(
                    trigger: AppAccordionTrigger(child: Text('主题策略')),
                    content: Text('App 别名保留上游行为和后续更新能力。'),
                  ),
                  AppAccordionItem(
                    trigger: AppAccordionTrigger(child: Text('变体')),
                    content: Text('只有真实的语义变体才提供命名构造。'),
                  ),
                ],
              ),
            ),
            const ComponentSection(
              title: '折叠与分隔线',
              child: AppCollapsible(
                children: [
                  AppCollapsibleTrigger(child: Text('高级详情')),
                  AppCollapsibleContent(
                    child: Column(
                      children: [
                        AppDivider(),
                        Padding(
                          padding: EdgeInsets.only(top: 12),
                          child: Text('隐藏内容使用相同主题。'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const ComponentSection(
              title: '步骤',
              child: Column(
                children: [
                  AppSteps.vertical(
                    children: [Text('配置全局主题'), Text('添加 App 前缀组件'), Text('检查分类示例')],
                  ),
                  Gap(24),
                  AppSteps.horizontal(
                    children: [Text('配置主题'), Text('添加组件'), Text('检查示例')],
                  ),
                ],
              ),
            ),
            ComponentSection(
              title: '时间线',
              child: Column(
                children: [
                  AppTimeline.vertical(
                    data: [
                      AppTimelineData(time: Text('09:00'), title: Text('主题已配置')),
                      AppTimelineData(
                        time: Text('11:30'),
                        title: Text('组件已检查'),
                        content: Text('静态分析与测试已通过。'),
                      ),
                    ],
                  ),
                  const Gap(24),
                  AppTimeline.horizontal(
                    data: [
                      AppTimelineData(time: Text('09:00'), title: Text('配置主题')),
                      AppTimelineData(time: Text('10:00'), title: Text('添加组件')),
                      AppTimelineData(time: Text('11:30'), title: Text('完成检查')),
                    ],
                  ),
                ],
              ),
            ),
          ].where((section) {
            return visibleSections?.contains(section.title) ?? true;
          }).toList(),
    );
  }
}
