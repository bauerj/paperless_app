import 'package:paperless_app/i18n.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class PaperlessAssetsPickerTextDelegate extends EnglishAssetPickerTextDelegate {
  const PaperlessAssetsPickerTextDelegate();

  @override
  String get confirm => 'Confirm'.i18n;

  @override
  String get cancel => 'Cancel'.i18n;

  @override
  String get edit => 'Edit'.i18n;

  @override
  String get gifIndicator => 'GIF'.i18n;

  @override
  String get loadFailed => 'Load failed'.i18n;

  @override
  String get original => 'Origin'.i18n;

  @override
  String get preview => 'Preview'.i18n;

  @override
  String get select => 'Select'.i18n;

  @override
  String get emptyList => 'Empty list'.i18n;
}
