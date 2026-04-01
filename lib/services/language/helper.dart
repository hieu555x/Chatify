import 'package:chattify/services/language/en.dart';
import 'package:chattify/services/language/vi.dart';
import 'package:flutter/cupertino.dart';

import 'app_strings.dart';

extension AppContext on BuildContext {
  AppStrings get appStrings {
    final langCode = Localizations.localeOf(this).languageCode;
    switch (langCode) {
      case 'en':
        return EnString();
      case 'vi':
        return ViStrings();
      default:
        return EnString();
    }
  }
}
