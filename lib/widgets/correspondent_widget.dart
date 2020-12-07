import 'package:flutter/material.dart';

import '../api.dart';

class CorrespondentWidget extends StatelessWidget {
  final Correspondent correspondent;

  CorrespondentWidget(this.correspondent);

  static CorrespondentWidget fromCorrespondentId(int _correspondentId, ResponseList<Correspondent> correspondents) {
    if (correspondents == null || _correspondentId == null) {
      Correspondent correspondent = Correspondent();
      correspondent.name = "";
      return new CorrespondentWidget(correspondent);
    }
    for (var _correspondent in correspondents.results) {
      if (_correspondent.id == _correspondentId) {
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
