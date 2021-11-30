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
    return Container(
      decoration: new BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          color: correspondent.name == "None" ? Colors.grey : null),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
        child: correspondent.name != ""
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person, size: 17),
                  Flexible(
                    fit: FlexFit.loose,
                    child: Text(
                      correspondent.name!,
                      textAlign: TextAlign.right,
                      softWrap: false,
                      overflow: TextOverflow.fade,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              )
            : SizedBox(),
      ),
    );
  }
}
