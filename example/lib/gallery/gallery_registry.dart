import 'package:flutter/widgets.dart';

import '../pages/actions_page.dart';
import '../pages/forms_page.dart';
import '../pages/data_display_page.dart';
import '../pages/layout_page.dart';
import '../pages/motion_page.dart';
import '../pages/menus_page.dart';
import '../pages/navigation_page.dart';
import '../pages/structured_layout_page.dart';
import '../pages/overlay_page.dart';

class GalleryCategory {
  const GalleryCategory({
    required this.id,
    required this.label,
    required this.builder,
  });

  final String id;
  final String label;
  final WidgetBuilder builder;
}

abstract final class GalleryRegistry {
  static final categories = <GalleryCategory>[
    GalleryCategory(
      id: 'actions',
      label: 'Actions',
      builder: (context) => const ActionsPage(),
    ),
    GalleryCategory(
      id: 'forms',
      label: 'Forms',
      builder: (context) => const FormsPage(),
    ),
    GalleryCategory(
      id: 'data-display',
      label: 'Data display',
      builder: (context) => const DataDisplayPage(),
    ),
    GalleryCategory(
      id: 'navigation',
      label: 'Navigation',
      builder: (context) => const NavigationPage(),
    ),
    GalleryCategory(
      id: 'menus',
      label: 'Menus and commands',
      builder: (context) => const MenusPage(),
    ),
    GalleryCategory(
      id: 'layout',
      label: 'Layout',
      builder: (context) => const LayoutPage(),
    ),
    GalleryCategory(
      id: 'structured-layout',
      label: 'Structured layout',
      builder: (context) => const StructuredLayoutPage(),
    ),
    GalleryCategory(
      id: 'overlay',
      label: 'Overlay',
      builder: (context) => const OverlayPage(),
    ),
    GalleryCategory(
      id: 'motion',
      label: 'Motion',
      builder: (context) => const MotionPage(),
    ),
  ];
}
