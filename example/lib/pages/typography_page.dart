import 'package:lemon_shadcn/lemon_shadcn.dart';
import 'package:lemon_shadcn/shadcn.dart';

import 'actions_page.dart';

class TypographyPage extends StatelessWidget {
  const TypographyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComponentPage(
      title: '排版',
      description: '管理端紧凑语义角色：选变体即可用，少改字号。',
      sections: [
        ComponentSection(
          title: '标题层级',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText.display('展示标题 · 30'),
              Gap(12),
              AppText.h1('一级标题 · 24'),
              Gap(8),
              AppText.h2('二级标题 · 20'),
              Gap(8),
              AppText.h3('三级标题 / 页头 · 18'),
              Gap(8),
              AppText.h4('四级标题 · 16'),
              Gap(8),
              AppText.section('分区标题 · 16'),
            ],
          ),
        ),
        ComponentSection(
          title: '内容角色',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText.title('卡片标题 · 16'),
              Gap(6),
              AppText.subtitle('辅助副标题 · 14 muted'),
              Gap(12),
              AppText.lead('导语正文，比默认 body 略醒目 · 16'),
              Gap(12),
              AppText.body('用于普通产品内容的正文 · 14'),
              Gap(6),
              AppText.bodyStrong('用于强调信息的加粗正文 · 14 medium'),
              Gap(12),
              AppText.label('字段标签 · 14 medium'),
              Gap(6),
              AppText.helper('表单帮助说明 · 12 muted'),
              Gap(6),
              AppText.caption('说明文字和元数据 · 12 muted'),
              Gap(6),
              AppText.muted('弱化的次要信息 · 14 muted'),
              Gap(6),
              AppText.error('校验错误提示 · 12 destructive'),
              Gap(6),
              AppText.code('final role = AppTextRole.code;'),
            ],
          ),
        ),
        ComponentSection(
          title: '列表角色',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText.listItem('列表主文 / 导航项 · 14'),
              Gap(6),
              AppText.listSecondary('列表副文 / 分组标题 · 12 muted'),
            ],
          ),
        ),
        ComponentSection(
          title: '局部主题覆盖',
          child: ComponentTheme<AppTextTheme>(
            data: AppTextTheme(
              title: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            child: AppText.title('局部覆盖后的标题'),
          ),
        ),
      ],
    );
  }
}
