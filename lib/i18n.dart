import 'dart:convert';
import 'package:sprintf/sprintf.dart';

import 'package:flutter/widgets.dart';
import 'package:i18n_extension/i18n_extension.dart';

class MyI18n {
  static TranslationsByLocale translations = Translations.byLocale("en_GB");

  static Future<Map<String, String>> loadMapFromJSON(
      BuildContext context, String file) async {
    return Map<String, String>.from(
        jsonDecode(await DefaultAssetBundle.of(context).loadString(file)));
  }

  static Future<void> loadTranslations(BuildContext context) async {
    translations += {"de_DE": await loadMapFromJSON(context, "assets/locales/de_DE.json")};
    print(MyI18n.translations.translations.length);
  }
}

extension Localization on String {
  String get i18n {
    return localize(this, MyI18n.translations);
  }

  String i18nFormat(List<String> params) {
    return sprintf(this.i18n, params);
  }
}
