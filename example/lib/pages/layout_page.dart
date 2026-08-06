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
            ComponentSection(
              title: '宽高比',
              child: SizedBox(
                width: 320,
                child: AppAspectRatio(
                  aspectRatio: 16 / 9,
                  child: AppCard(child: const Center(child: Text('16 : 9'))),
                ),
              ),
            ),
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppAlert(title: Text('提示信息'), content: Text('标准提示样式。')),
                  Gap(12),
                  AppAlert.info(
                    leading: Icon(LucideIcons.info),
                    title: Text('版本更新可用'),
                    content: Text('可以在方便时安装最新版本。'),
                  ),
                  Gap(12),
                  AppAlert.success(
                    leading: Icon(LucideIcons.circleCheck),
                    title: Text('保存成功'),
                    content: Text('所有设置已经同步。'),
                  ),
                  Gap(12),
                  AppAlert.warning(
                    leading: Icon(LucideIcons.triangleAlert),
                    title: Text('您的订阅将在 3 天后到期'),
                    content: Text('立即续订以避免服务中断。'),
                  ),
                  Gap(12),
                  AppAlert.destructive(
                    leading: Icon(LucideIcons.circleAlert),
                    title: Text('需要处理'),
                    content: Text('此操作失败，请检查配置后重试。'),
                  ),
                  Gap(12),
                  AppAlert.custom(
                    backgroundColor: Color(0xfffaf5ff),
                    borderColor: Color(0xffd8b4fe),
                    foregroundColor: Color(0xff6b21a8),
                    leading: Icon(LucideIcons.sparkles),
                    title: Text('自定义配色'),
                    content: Text('背景、边框和前景色均可独立设置。'),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppCollapsible(
                    children: [
                      AppCollapsibleTrigger(child: Text('纵向高级详情')),
                      AppCollapsibleContent(
                        child: Column(
                          children: [
                            AppDivider.horizontal(),
                            Padding(
                              padding: EdgeInsets.only(top: 12),
                              child: Text('隐藏内容使用相同主题。'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Gap(16),
                  AppCollapsible.horizontal(
                    width: 520,
                    triggerExtent: 180,
                    children: [
                      AppCollapsibleTrigger(child: Text('横向详情')),
                      AppCollapsibleContent.horizontal(
                        child: Padding(
                          padding: EdgeInsets.only(left: 16),
                          child: Text('内容沿水平方向展开，不改变垂直高度。'),
                        ),
                      ),
                    ],
                  ),
                  Gap(24),
                  SizedBox(
                    width: 360,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppDivider.text('OR'),
                        Gap(16),
                        SizedBox(
                          height: 72,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Left'),
                              AppDivider.vertical(width: 32),
                              Text('Right'),
                            ],
                          ),
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
                    children: [
                      Text('配置全局主题'),
                      Text('添加 App 前缀组件'),
                      Text('检查分类示例'),
                    ],
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
                      AppTimelineData(
                        time: Text('09:00'),
                        title: Text('主题已配置'),
                      ),
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
