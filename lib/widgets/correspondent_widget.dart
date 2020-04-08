import 'package:flutter/material.dart';

import '../api.dart';

class CorrespondentWidget extends StatelessWidget {
  final Correspondent correspondent;

  CorrespondentWidget(this.correspondent);

  static CorrespondentWidget fromCorrespondentId(String _correspondentId, ResponseList<Correspondent> correspondents) {
    if (correspondents == null || _correspondentId == null) {
      Correspondent correspondent = Correspondent();
      correspondent.name = "";
      return new CorrespondentWidget(correspondent);
    }
    var parts = _correspondentId.split("/");
    int correspondentId = int.parse(parts[parts.length - 2]);
    for (var _correspondent in correspondents.results) {
      if (_correspondent.id == correspondentId) {
          return CorrespondentWidget(_correspondent);
        }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      correspondent.name,
      textAlign: TextAlign.center,
      style: TextStyle(
          fontWeight: FontWeight.bold,
      )
    );
  }
}
