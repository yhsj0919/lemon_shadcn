import 'dart:async';

import 'package:flutter/material.dart' as material;
import 'package:lemon_shadcn/lemon_shadcn.dart';

void main() => material.runApp(const ComponentGallery());

class ComponentGallery extends StatelessWidget {
  const ComponentGallery({super.key});

  @override
  Widget build(BuildContext context) {
    return material.MaterialApp(
      title: 'Lemon Shadcn',
      themeMode: material.ThemeMode.system,
      builder: AppShadcnScope.builder(),
      home: const GalleryHome(),
    );
  }
}

class GalleryHome extends StatelessWidget {
  const GalleryHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      headers: const [AppBar(title: Text('Lemon Shadcn · Actions'))],
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Button').h2(),
                const Gap(8),
                const Text(
                  'Semantic variants share zero-config async behavior.',
                ).muted(),
                const Gap(24),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    AppButton.primary(
                      onPressed: () async {
                        await Future<void>.delayed(
                          const Duration(milliseconds: 900),
                        );
                      },
                      loadingLabel: 'Saving',
                      child: const Text('Async primary'),
                    ),
                    AppButton.secondary(
                      onPressed: () {},
                      child: const Text('Secondary'),
                    ),
                    AppButton.outline(
                      onPressed: () {},
                      child: const Text('Outline'),
                    ),
                    AppButton.ghost(
                      onPressed: () {},
                      child: const Text('Ghost'),
                    ),
                    AppButton.destructive(
                      onPressed: () {},
                      child: const Text('Destructive'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
