import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:paperless_app/i18n.dart';

import '../api.dart';
import 'ink_wrapper.dart';

class DocumentPreview extends StatefulWidget {
  final bool invertPreview;
  final Document document;
  final double height;
  final bool showTitle;
  final bool showOpen;
  final VoidCallback onTap;

  const DocumentPreview(this.invertPreview, this.document,
      {Key key,
      this.height: 200,
      this.showTitle: true,
      this.showOpen: false,
      this.onTap})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _DocumentPreviewState(
        invertPreview, document, height, showTitle, showOpen, onTap);
  }
}

class _DocumentPreviewState extends State<DocumentPreview> {
  final bool _invertPreview;
  final Document _document;
  final double _height;
  final bool _showTitle;
  final bool _showOpen;
  final VoidCallback _onTap;

  final List<double> invertMatrix = [
    -1, 0, 0, 0, 255, //
    0, -1, 0, 0, 255, //
    0, 0, -1, 0, 255, //
    0, 0, 0, 1, 0, //
  ];

  final List<double> identityMatrix = [
    1, 0, 0, 0, //
    0, 0, 1, 0, //
    0, 0, 0, 0, //
    1, 0, 0, 0, //
    0, 0, 1, 0, //
  ];

  _DocumentPreviewState(this._invertPreview, this._document, this._height,
      this._showTitle, this._showOpen, this._onTap);

  @override
  Widget build(BuildContext context) {
    bool showDark =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    Color bg = showDark ? Colors.black : Colors.white;
    Color fg = showDark ? Colors.white : Colors.black;

    List<Widget> children = [
      ColorFiltered(
          colorFilter: ColorFilter.matrix(
              showDark && _invertPreview ? invertMatrix : identityMatrix),
          child: CachedNetworkImage(
            fit: BoxFit.cover,
            height: _height,
            width: double.infinity,
            imageUrl: _document.getThumbnailUrl(),
            httpHeaders: {"Authorization": API.instance.authString},
            errorWidget: (context, url, error) => Icon(Icons.error),
          ))
    ];

    if (_showTitle) {
      children.add(
        Container(
          padding: EdgeInsets.all(5.0),
          height: _height,
          alignment: Alignment.bottomCenter,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                bg.withAlpha(0),
                bg.withAlpha(0),
                bg.withAlpha(130),
                bg,
                bg,
              ],
            ),
          ),
          child: Text(
            '${_document.title}',
            textAlign: TextAlign.start,
            style: TextStyle(fontSize: 20, color: fg),
          ),
        ),
      );
    }

    if (_showOpen) {
      children.add(
        Container(
          padding: EdgeInsets.all(5.0),
          height: _height,
          alignment: Alignment.bottomCenter,
          child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            Text(
              "Open".i18n,
              textAlign: TextAlign.start,
              style: TextStyle(fontSize: 20, color: fg.withAlpha(150)),
            ),
            Icon(Icons.picture_as_pdf, color: fg.withAlpha(150)),
          ]),
        ),
      );
    }

    return InkWrapper(
        splashColor: Colors.greenAccent.withOpacity(1 / 2),
        onTap: _onTap,
        child: Stack(children: children));
  }
}
