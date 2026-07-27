import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:lemon_shadcn/lemon_shadcn.dart';

void main() {
  test('coalesces matching requests and caches formatted options', () async {
    var loads = 0;
    final pending = Completer<List<AppOption<int>>>();
    final source = AppAsyncOptionSource<int>(
      loader: (query) {
        loads++;
        return pending.future;
      },
    );

    final first = source.load(' page ');
    final second = source.load('page');
    expect(loads, 1);

    pending.complete(const [AppOption(value: 1, label: 'One')]);
    expect(await first, await second);
    expect(await source.load('page'), hasLength(1));
    expect(loads, 1);
  });

  test('retry wins over an older response for the same query', () async {
    final requests = <Completer<List<AppOption<int>>>>[];
    final source = AppAsyncOptionSource<int>(
      loader: (_) {
        final request = Completer<List<AppOption<int>>>();
        requests.add(request);
        return request.future;
      },
    );

    final older = source.load('role');
    final newer = source.retry('role');
    requests[1].complete(const [AppOption(value: 2, label: 'New')]);
    expect((await newer).single.value, 2);
    requests[0].complete(const [AppOption(value: 1, label: 'Old')]);
    expect((await older).single.value, 1);

    expect((await source.load('role')).single.value, 2);
  });

  test('invalidate forces the next load to refresh', () async {
    var loads = 0;
    final source = AppAsyncOptionSource<int>(
      loader: (_) async => [AppOption(value: ++loads, label: '$loads')],
    );

    expect((await source.load('')).single.value, 1);
    source.invalidate('');
    expect((await source.load('')).single.value, 2);
  });

  test(
    'paged source caches each opaque cursor and protects retry results',
    () async {
      final requests = <Completer<AppOptionPage<int>>>[];
      final source = AppAsyncPagedOptionSource<int>(
        loader: (query, cursor) {
          final request = Completer<AppOptionPage<int>>();
          requests.add(request);
          return request.future;
        },
      );

      final older = source.load('users', cursor: 'next');
      final newer = source.retry('users', cursor: 'next');
      requests[1].complete(
        const AppOptionPage(
          options: [AppOption(value: 2, label: 'New')],
          nextCursor: 'last',
        ),
      );
      expect((await newer).options.single.value, 2);
      requests[0].complete(
        const AppOptionPage(options: [AppOption(value: 1, label: 'Old')]),
      );
      await older;

      final cached = await source.load('users', cursor: 'next');
      expect(cached.options.single.value, 2);
      expect(cached.nextCursor, 'last');
    },
  );
}
