import 'package:i18n_extension/io/import.dart';

import 'package:i18n_extension/i18n_extension.dart';

class MyI18n {
  static TranslationsByLocale translations = Translations.byLocale("en_GB");

  static Future<void> loadTranslations() async {
    translations +=
        await GettextImporter().fromAssetDirectory("assets/locales");
  }
}

extension Localization on String {
  String get i18n => localize(this, MyI18n.translations);
  String plural(int value) => localizePlural(value, this, MyI18n.translations);
  String fill(List<Object> params) => localizeFill(this, params);
}
