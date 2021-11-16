import 'package:flutter/material.dart';
import 'package:paperless_app/i18n.dart';

import '../api.dart';

class CorrespondentWidget extends StatelessWidget {
  final Correspondent correspondent;

  CorrespondentWidget(this.correspondent);

  static CorrespondentWidget? fromCorrespondentId(
      int? _correspondentId, ResponseList<Correspondent>? correspondents,
      {bool showIfNone: false}) {
    if (correspondents == null || _correspondentId == null) {
      Correspondent correspondent = Correspondent();
      correspondent.name = showIfNone ? "None".i18n : "";
      return new CorrespondentWidget(correspondent);
    }
    for (var _correspondent in correspondents.results) {
      if (_correspondent!.id == _correspondentId) {
        return CorrespondentWidget(_correspondent);
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Text(correspondent.name!,
        textAlign: TextAlign.center,
        style: TextStyle(
            fontWeight: FontWeight.bold,
            color: correspondent.name == "None" ? Colors.grey : null));
  }
}
