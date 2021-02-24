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
    return Text(tag.name,
        textAlign: TextAlign.right,
        style: TextStyle(
          backgroundColor: getColor(),
        ));
  }

  Color getColor() {
    return _fromHex(tag.colourCode);
  }

  // https://stackoverflow.com/a/50081214/1024057
  static Color _fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
