import 'package:flutter/foundation.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Chinese (`zh`) strings for shadcn_flutter calendar / form / menus.
///
/// Upstream ships [ShadcnLocalizationsZh] since 0.0.55; this class extends it
/// so product apps can override individual strings while keeping the same
/// delegate entry point. Place this delegate *before*
/// [ShadcnLocalizations.delegate] so `zh` resolves here.
class AppLocalizationsZh extends ShadcnLocalizationsZh {
  AppLocalizationsZh([super.locale = 'zh']);

  static const LocalizationsDelegate<ShadcnLocalizations> delegate =
      _AppLocalizationsZhDelegate();
}

class _AppLocalizationsZhDelegate
    extends LocalizationsDelegate<ShadcnLocalizations> {
  const _AppLocalizationsZhDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'zh';

  @override
  Future<ShadcnLocalizations> load(Locale locale) {
    return SynchronousFuture<ShadcnLocalizations>(AppLocalizationsZh());
  }

  @override
  bool shouldReload(_AppLocalizationsZhDelegate old) => false;
}
