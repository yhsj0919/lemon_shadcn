import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lemon_shadcn/lemon_shadcn.dart';

void main() {
  testWidgets('structured layout aliases render with upstream data types', (
    tester,
  ) async {
    final stepper = AppStepperController();
    addTearDown(stepper.dispose);
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                width: 320,
                height: 90,
                child: AppCarousel(
                  itemCount: 2,
                  wrap: false,
                  transition: const AppCarouselTransition.fading(),
                  itemBuilder: (context, index) => Text('Slide $index'),
                ),
              ),
              SizedBox(
                width: 320,
                height: 90,
                child: AppResizable.horizontal(
                  children: const [
                    AppResizablePane(initialSize: 120, child: Text('Left')),
                    AppResizablePane.flex(child: Text('Right')),
                  ],
                ),
              ),
              AppStepper(
                controller: stepper,
                steps: const [
                  AppStep(title: Text('One')),
                  AppStep(title: Text('Two')),
                ],
              ),
              SizedBox(
                height: 80,
                child: AppTree<String>(
                  nodes: [AppTreeItemNode(data: 'Root')],
                  shrinkWrap: true,
                  builder: (context, item) => Text(item.data),
                ),
              ),
              const AppTable(
                rows: [
                  AppTableRow(cells: [AppTableCell(child: Text('Cell'))]),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.byType(AppCarousel), findsOneWidget);
    expect(find.byType(AppResizablePanel), findsOneWidget);
    expect(find.byType(AppStepper), findsOneWidget);
    expect(find.byType(AppTree<String>), findsOneWidget);
    expect(find.byType(AppTable), findsOneWidget);
  });

  testWidgets('tree item spacing collapses with hidden descendants', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: SizedBox(
          width: 320,
          height: 240,
          child: AppTree<String>(
            itemSpacing: 8,
            nodes: [
              AppTreeItemNode(
                data: 'Root',
                children: [
                  AppTreeItemNode(data: 'Child 1'),
                  AppTreeItemNode(data: 'Child 2'),
                ],
              ),
            ],
            builder: (context, item) => Text(item.data),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Root'), findsOneWidget);
    expect(find.text('Child 1'), findsNothing);
    expect(find.text('Child 2'), findsNothing);
  });

  testWidgets('async tree loads children once when a node expands', (
    tester,
  ) async {
    var loads = 0;
    String? selected;
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: SizedBox(
          width: 320,
          height: 240,
          child: AppAsyncTree<String>(
            nodes: const <AppAsyncTreeNode<String>>[
              AppAsyncTreeNode(id: 'root', data: 'Root', hasChildren: true),
            ],
            loadChildren: (parent) async {
              loads++;
              return const <AppAsyncTreeNode<String>>[
                AppAsyncTreeNode(id: 'child', data: 'Child'),
              ];
            },
            onSelected: (node) => selected = node.data,
            builder: (context, node) => Text(node.data),
          ),
        ),
      ),
    );
    await tester.pump();

    var item = tester.widget<AppTreeItem>(find.byType(AppTreeItem).first);
    item.onExpand!(true);
    await tester.pump();
    await tester.pump();

    expect(find.text('Child'), findsOneWidget);
    expect(loads, 1);
    expect(selected, 'Root');

    item = tester.widget<AppTreeItem>(find.byType(AppTreeItem).first);
    item.onExpand!(false);
    await tester.pump();
    item = tester.widget<AppTreeItem>(find.byType(AppTreeItem).first);
    item.onExpand!(true);
    await tester.pump();
    expect(find.text('Child'), findsOneWidget);
    expect(loads, 1);
  });

  testWidgets('async tree future constructor loads root nodes', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: SizedBox(
          width: 320,
          height: 200,
          child: AppAsyncTree<String>.future(
            loadRoots: () async => const <AppAsyncTreeNode<String>>[
              AppAsyncTreeNode(id: 'remote', data: 'Remote root'),
            ],
            builder: (context, node) => Text(node.data),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Remote root'), findsOneWidget);
  });

  testWidgets('async tree keeps its inline loading indicator square', (
    tester,
  ) async {
    final pending = Completer<List<AppAsyncTreeNode<String>>>();
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: SizedBox(
          width: 320,
          height: 200,
          child: AppAsyncTree<String>(
            nodes: const <AppAsyncTreeNode<String>>[
              AppAsyncTreeNode(id: 'root', data: 'Root', hasChildren: true),
            ],
            loadChildren: (_) => pending.future,
            builder: (context, node) => Text(node.data),
          ),
        ),
      ),
    );
    final item = tester.widget<AppTreeItem>(find.byType(AppTreeItem));
    item.onExpand!(true);
    await tester.pump();

    final progress = find.byType(CircularProgressIndicator);
    expect(tester.getSize(progress), const Size.square(16));

    pending.complete(const <AppAsyncTreeNode<String>>[]);
    await tester.pump();
  });

  testWidgets('async tree item builder can replace the entire row', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: SizedBox(
          width: 320,
          height: 200,
          child: AppAsyncTree<String>(
            nodes: const <AppAsyncTreeNode<String>>[
              AppAsyncTreeNode(id: 'root', data: 'Root', hasChildren: true),
            ],
            loadChildren: (_) async => const <AppAsyncTreeNode<String>>[
              AppAsyncTreeNode(id: 'child', data: 'Child'),
            ],
            itemBuilder: (context, details) => GestureDetector(
              key: ValueKey<Object>('custom-${details.node.id}'),
              onTap: details.node.expandable
                  ? () => details.setExpanded(!details.expanded)
                  : details.select,
              child: Text('Custom ${details.node.data}'),
            ),
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey<Object>('custom-root')), findsOneWidget);
    expect(find.byType(AppTreeItem), findsNothing);
    await tester.tap(find.text('Custom Root'));
    await tester.pump();
    await tester.pump();
    expect(find.text('Custom Child'), findsOneWidget);
  });

  testWidgets('async tree exposes a retry state after a root error', (
    tester,
  ) async {
    var attempts = 0;
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: SizedBox(
          width: 320,
          height: 200,
          child: AppAsyncTree<String>.future(
            loadRoots: () async {
              attempts++;
              if (attempts == 1) throw StateError('offline');
              return const <AppAsyncTreeNode<String>>[
                AppAsyncTreeNode(id: 'ready', data: 'Ready'),
              ];
            },
            builder: (context, node) => Text(node.data),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
    expect(find.text('加载失败'), findsOneWidget);

    await tester.tap(find.text('重试'));
    await tester.pump();
    await tester.pump();
    expect(find.text('Ready'), findsOneWidget);
    expect(attempts, 2);
  });
}
