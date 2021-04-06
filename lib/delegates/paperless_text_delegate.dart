import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:paperless_app/i18n.dart';



class PaperlessAssetsPickerTextDelegate implements AssetsPickerTextDelegate {
  @override
  String cancel = 'Cancel'.i18n;

  @override
  String confirm = 'Confirm'.i18n;

  @override
  String edit = 'Edit'.i18n;

  @override
  String gifIndicator = 'Gif'.i18n;

  @override
  String heicNotSupported = 'Not supported'.i18n;

  @override
  String loadFailed = 'Failed to load'.i18n;

  @override
  String original = 'Original'.i18n;

  @override
  String preview = 'Preview'.i18n;

  @override
  String select = 'Select'.i18n;

  @override
  String unSupportedAssetType = 'Not supported type'.i18n;

  @override
  String durationIndicatorBuilder(Duration duration) {
    // TODO: implement durationIndicatorBuilder
    throw UnimplementedError();
  }
}
