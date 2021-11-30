import 'package:flutter/material.dart';

import '../api.dart';
import 'ink_wrapper.dart';

class TagWidget extends StatelessWidget {
  final Tag tag;

  TagWidget(this.tag);

  static TagWidget? fromTagId(int? _tagId, ResponseList<Tag>? tags) {
    if (tags == null) {
      Tag tag = Tag();
      tag.name = "...";
      tag.colourCode = "#000";
      return new TagWidget(tag);
    }
    for (var _tag in tags.results) {
      if (_tag!.id == _tagId) {
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.label_important_outline,
                size: 17, color: getTextColor()),
            Flexible(
              fit: FlexFit.loose,
              child: Text(
                tag.name!,
                textAlign: TextAlign.right,
                softWrap: false,
                overflow: TextOverflow.fade,
                style: TextStyle(
                  color: getTextColor(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color getColor() {
    return _fromHex(tag.colourCode!);
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

class SelectableTagWidget extends StatefulWidget {
  final Function(bool?)? onEdit;
  final TagWidget? child;
  final bool value;

  const SelectableTagWidget(
    this.child,
    this.value, {
    this.onEdit,
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SelectableTagWidgetState(child, value, onEdit: onEdit);
  }
}

class SelectableTagWidgetState extends State<SelectableTagWidget> {
  final Function(bool?)? onEdit;
  final TagWidget? child;
  bool? value;

  SelectableTagWidgetState(this.child, this.value, {this.onEdit});

  @override
  Widget build(BuildContext context) {
    return InkWrapper(
        splashColor: Colors.greenAccent.withOpacity(1 / 2),
        onTap: () {
          setState(() {
            value = !value!;
          });
          onEdit!(value);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            child!,
            Checkbox(
                value: value,
                onChanged: (v) {
                  value = v;
                  onEdit!(v);
                })
          ],
        ));
  }
}
