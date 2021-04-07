import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:paperless_app/i18n.dart';

EnglishTextDelegate paperlessAssetsPickerTextDelegate() {
  var d = EnglishTextDelegate();
  d.cancel = 'Cancel'.i18n;
  d.confirm = 'Confirm'.i18n;
  d.edit = 'Edit'.i18n;
  d.loadFailed = 'Failed to load'.i18n;
  d.original = 'Original'.i18n;
  d.preview = 'Preview'.i18n;
  d.select = 'Select'.i18n;
  return d;
}

class PaperlessSortPathDelegate extends CommonSortPathDelegate {
  const PaperlessSortPathDelegate();

  @override
  void sort(List<AssetPathEntity> list) {
    for (final AssetPathEntity entity in list) {
      // If the entity `isAll`, that's the "Recent" entity we want.
      if (entity.isAll) {
        entity.name = 'Recent'.i18n;
      }
    }
    super.sort(list);
  }
}
