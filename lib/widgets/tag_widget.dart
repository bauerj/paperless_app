import 'package:flutter/material.dart';

import '../api.dart';

class TagWidget extends StatelessWidget {
  final Tag tag;
  final List<int> tagColors = [
    0xe3cea6ff,
    0xb4781fff,
    0x8adfb2ff,
    0x2ca033ff,
    0x999afbff,
    0x1c1ae3ff,
    0x6fbffdff,
    0x007fffff,
    0xd6b2caff,
    0x9a3d6aff,
    0x2859b1ff,
    0x000000ff,
    0xccccccff
  ];

  TagWidget(this.tag);

  static TagWidget fromTagId(int _tagId, ResponseList<Tag> tags) {
    if (tags == null) {
      Tag tag = Tag();
      tag.name = "...";
      tag.colour = 1;
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
    return new Color(tagColors[tag.colour % tagColors.length]);
  }
}
