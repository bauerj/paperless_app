import 'package:flutter/material.dart';
import 'package:paperless_app/i18n.dart';

import '../api.dart';

class DocumentTypeWidget extends StatelessWidget {
  final DocumentType documentType;

  DocumentTypeWidget(this.documentType);

  static DocumentTypeWidget? fromDocumentTypeId(
      int? _documentTypeId, ResponseList<DocumentType>? documentTypes,
      {bool showIfNone: false}) {
    if (documentTypes == null || _documentTypeId == null) {
      DocumentType documentType = DocumentType();
      documentType.name = showIfNone ? "None".i18n : "";
      return new DocumentTypeWidget(documentType);
    }
    for (var _documentType in documentTypes.results) {
      if (_documentType!.id == _documentTypeId) {
        return DocumentTypeWidget(_documentType);
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: new BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          color: this.documentType.name == "None" ? Colors.grey : null),
      child: documentType.name != ""
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.description, size: 17),
                Flexible(
                  fit: FlexFit.loose,
                  child: Text(
                    documentType.name!,
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
    );
  }
}
