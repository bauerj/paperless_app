import 'package:flutter/material.dart';

import '../api.dart';

class TagWidget extends StatelessWidget {
  final Tag tag;

  TagWidget(this.tag);

  static TagWidget fromTagId(int _tagId, ResponseList<Tag> tags) {
    if (tags == null) {
      Tag tag = Tag();
      tag.name = "...";
      tag.colourCode = "#000";
      return new TagWidget(tag);
    }
    for (var _tag in tags.results) {
      if (_tag.id == _tagId) {
        return TagWidget(_tag);
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: new BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          color: getColor()),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
        child: Row(children: [
          Icon(Icons.label_important_outline, size: 17, color: getTextColor()),
          Text(tag.name,
              textAlign: TextAlign.right,
              style: TextStyle(color: getTextColor()))
        ]),
      ),
    );
  }

  Color getColor() {
    return _fromHex(tag.colourCode);
  }

  Color getTextColor() {
    if (ThemeData.estimateBrightnessForColor(getColor()) == Brightness.light)
      return Colors.black;
    return Colors.white;
  }

  // https://stackoverflow.com/a/50081214/1024057
  static Color _fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
