import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lemon_shadcn/lemon_shadcn.dart';
import 'package:lemon_shadcn/shadcn.dart' as shad;

void main() {
  testWidgets('circle avatar uses a fully rounded border', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: const Center(child: AppAvatar.circle(initials: 'AB', size: 48)),
      ),
    );

    final avatar = tester.widget<shad.Avatar>(find.byType(shad.Avatar));
    expect(avatar.size, 48);
    expect(avatar.borderRadius, 999);
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

    final avatar = tester.widget<shad.Avatar>(find.byType(shad.Avatar));
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

    final avatar = tester.widget<shad.Avatar>(find.byType(shad.Avatar));
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
}
