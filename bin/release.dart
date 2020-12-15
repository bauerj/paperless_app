import 'dart:convert';
import 'dart:io';

import 'package:i18n_extension/i18n_getstrings.dart';

void main(List<String> arguments) async {
  var strings = GetI18nStrings("./lib").run();
  for (var translationFile in new Directory('./assets/locales/').listSync()) {
    var translation =
        json.decode(new File(translationFile.path).readAsStringSync());
    for (var source in strings) {
      var i = 0;
      if (!translation.containsKey(source)) {
        translation[source] = null;
        i++;
      }
      if (i>0) {
        print("$i new string(s) to translate in $translationFile");
        JsonEncoder encoder = new JsonEncoder.withIndent(' '*4);
        File(translationFile.path).writeAsStringSync(encoder.convert(translation));
      }
    }
  }
}
