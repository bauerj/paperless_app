import 'package:flutter/material.dart';

import '../api.dart';

class TagWidget extends StatelessWidget {
  final Tag tag;

  TagWidget(this.tag);

  static TagWidget fromTagId(String _tagId, ResponseList<Tag> tags) {

    if (tags == null) {
      Tag tag = Tag();
      tag.name = "...";
      tag.colour = 1;
      return new TagWidget(tag);
    }
    var parts = _tagId.split("/");
    int tagId = int.parse(parts[parts.length - 2]);
    for (var _tag in tags.results) {
      if (_tag.id == tagId) {
          return TagWidget(_tag);
        }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      tag.name,
      textAlign: TextAlign.right,
      style: TextStyle(
          backgroundColor: getColor(),
      )
    );
  }

  Color getColor() {
    return Colors.accents[tag.colour % Colors.accents.length];
  }
}
