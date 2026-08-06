import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lemon_shadcn/lemon_shadcn.dart';

void main() {
  test('extracts a configurable number of Chinese and Latin initials', () {
    expect(AppAvatar.getInitials('张三'), '张');
    expect(AppAvatar.getInitials('张三', count: 1), '张');
    expect(AppAvatar.getInitials('王小明', count: 2), '王小');
    expect(AppAvatar.getInitials('John Ronald Tolkien', count: 2), 'JR');
    expect(AppAvatar.getInitials('😀设计', count: 2), '😀设');
    expect(() => AppAvatar.getInitials('张三', count: 0), throwsArgumentError);
  });

  testWidgets('avatar extracts initials directly from a name', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: const Row(
          children: [
            AppAvatar.circle(name: '林晓', initialsCount: 1),
            AppAvatar.square(name: '王小明', initialsCount: 2),
            AppAvatar.circle(name: '默认单字'),
          ],
        ),
      ),
    );

    expect(find.text('林'), findsOneWidget);
    expect(find.text('王小'), findsOneWidget);
    expect(find.text('默'), findsOneWidget);
  });

  testWidgets('circle avatar uses a fully rounded border', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: const Center(child: AppAvatar.circle(initials: 'AB', size: 48)),
      ),
    );

    final avatar = tester.widget<AppAvatar>(find.byType(AppAvatar));
    expect(avatar.size, 48);
    expect(avatar.borderRadius, 999);
    expect(tester.getSize(find.byType(AppAvatar)), const Size(48, 48));
    expect(find.text('AB'), findsOneWidget);
  });

  testWidgets('square avatar supports a custom corner radius', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: const Center(
          child: AppAvatar.square(initials: 'CD', size: 40, borderRadius: 4),
        ),
      ),
    );

    final avatar = tester.widget<AppAvatar>(find.byType(AppAvatar));
    expect(avatar.size, 40);
    expect(avatar.borderRadius, 4);
  });

  testWidgets('square avatar defaults to a 12 pixel corner radius', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: const Center(child: AppAvatar.square(initials: 'EF')),
      ),
    );

    final avatar = tester.widget<AppAvatar>(find.byType(AppAvatar));
    expect(avatar.borderRadius, 12);
  });

  testWidgets('avatar variants remain compatible with avatar groups', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: const Center(
          child: AppAvatarGroup(
            alignment: Alignment(-0.85, 0),
            children: [
              AppAvatar.circle(initials: 'A'),
              AppAvatar.square(initials: 'B'),
            ],
          ),
        ),
      ),
    );

    expect(find.byType(AppAvatar), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('avatar initials automatically use a contrasting color', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: const Row(
          children: [
            AppAvatar.circle(initials: 'D', backgroundColor: Color(0xff111827)),
            AppAvatar.square(initials: 'L', backgroundColor: Color(0xfff9fafb)),
            AppAvatar.square(
              initials: 'M',
              backgroundColor: Color(0xff111827),
              foregroundColor: Color(0xffff0000),
            ),
          ],
        ),
      ),
    );

    Color? textColor(String text) =>
        tester.widget<Text>(find.text(text)).style?.color;
    expect(textColor('D'), const Color(0xffffffff));
    expect(textColor('L'), const Color(0xff000000));
    expect(textColor('M'), const Color(0xffff0000));
  });

  testWidgets('soft avatar uses accent text and a tinted background', (
    tester,
  ) async {
    const accent = Color(0xffc2410c);
    final config = AppThemeConfig.standard(primary: accent);
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(config: config),
        home: const Center(
          child: AppAvatar.square(
            name: '世茂',
            appearance: AppAvatarAppearance.soft,
          ),
        ),
      ),
    );

    final text = tester.widget<Text>(find.text('世'));
    final background = tester.widget<ColoredBox>(
      find.descendant(
        of: find.byType(AppAvatar),
        matching: find.byType(ColoredBox),
      ),
    );
    expect(text.style?.color, accent);
    expect(
      background.color,
      Color.alphaBlend(
        accent.withValues(alpha: 0.14),
        config.lightTheme.colorScheme.background,
      ),
    );
  });

  testWidgets('avatar initials follow AppText typography and system scaling', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(
          config: AppThemeConfig.standard(
            textTheme: const AppTextTheme(
              bodyStrong: TextStyle(fontFamily: 'AvatarSystemFont'),
            ),
          ),
        ),
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.5)),
          child: const Center(
            child: AppAvatar.square(initials: 'ST', size: 48),
          ),
        ),
      ),
    );

    final textFinder = find.text('ST');
    final text = tester.widget<Text>(textFinder);
    expect(text.style?.fontFamily, 'AvatarSystemFont');
    expect(text.style?.fontWeight, FontWeight.bold);
    expect(MediaQuery.textScalerOf(tester.element(textFinder)).scale(10), 15);
    expect(
      tester
          .widget<FittedBox>(
            find.ancestor(of: textFinder, matching: find.byType(FittedBox)),
          )
          .fit,
      BoxFit.scaleDown,
    );
  });
}
