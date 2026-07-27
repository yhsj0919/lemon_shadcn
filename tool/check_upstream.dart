import 'dart:io';

void main() {
  final root = Directory.current;
  final pubspec = File('${root.path}/pubspec.yaml').readAsStringSync();
  final lock = File('${root.path}/pubspec.lock').readAsLinesSync();
  final inventory = File(
    '${root.path}/docs/component-inventory.md',
  ).readAsStringSync();

  final baseline = RegExp(
    r'基线版本：`shadcn_flutter ([^`]+)`',
  ).firstMatch(inventory)?.group(1);
  final constraint = RegExp(
    r'^\s*shadcn_flutter:\s*([^\s]+)\s*$',
    multiLine: true,
  ).firstMatch(pubspec)?.group(1);
  final locked = _lockedVersion(lock, 'shadcn_flutter');
  final componentRows = RegExp(
    r'^\| (?!---|分类|上游组件)[^\r\n]+\|$',
    multiLine: true,
  ).allMatches(inventory).length;
  final demoSource = Directory('${root.path}/example/lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .map((file) => file.readAsStringSync())
      .join('\n');
  final missingDemoRows = <String>[];
  for (final line in inventory.split(RegExp(r'\r?\n'))) {
    if (!line.startsWith('|') ||
        (!line.endsWith('| 完成 |') && !line.endsWith('| 已完成 |'))) {
      continue;
    }
    final appNames = RegExp(
      r'\bApp[A-Za-z0-9]+\b',
    ).allMatches(line).map((match) => match.group(0)!).toSet();
    if (appNames.isNotEmpty &&
        !appNames.any(
          (name) => RegExp('\\b${RegExp.escape(name)}\\b').hasMatch(demoSource),
        )) {
      missingDemoRows.add(line);
    }
  }

  stdout.writeln('shadcn_flutter constraint: $constraint');
  stdout.writeln('shadcn_flutter locked:     $locked');
  stdout.writeln('audited inventory:         $baseline');
  stdout.writeln('inventory rows:            $componentRows');
  stdout.writeln('rows missing demo usage:   ${missingDemoRows.length}');

  final failures = <String>[];
  if (baseline == null || locked == null || constraint == null) {
    failures.add('Could not resolve dependency or baseline metadata.');
  } else {
    if (locked != baseline) {
      failures.add(
        'Locked version $locked differs from audited baseline $baseline.',
      );
    }
    if (!constraint.contains(baseline)) {
      failures.add(
        'pubspec constraint $constraint does not declare baseline $baseline.',
      );
    }
  }
  if (componentRows != 84) {
    failures.add('Expected 84 audited component rows, found $componentRows.');
  }
  if (missingDemoRows.isNotEmpty) {
    failures.add(
      '${missingDemoRows.length} component rows have no categorized demo usage:\n'
      '${missingDemoRows.join('\n')}',
    );
  }

  if (failures.isNotEmpty) {
    for (final failure in failures) {
      stderr.writeln('ERROR: $failure');
    }
    stderr.writeln(
      'Update the inventory, mappings, demos and tests before accepting the '
      'new upstream version.',
    );
    exitCode = 1;
    return;
  }
  stdout.writeln('Upstream baseline check passed.');
}

String? _lockedVersion(List<String> lines, String package) {
  final header = '  $package:';
  var inPackage = false;
  for (final line in lines) {
    if (line == header) {
      inPackage = true;
      continue;
    }
    if (!inPackage) continue;
    if (line.startsWith('  ') && !line.startsWith('    ')) return null;
    final match = RegExp(r'^    version: "([^"]+)"$').firstMatch(line);
    if (match != null) return match.group(1);
  }
  return null;
}
