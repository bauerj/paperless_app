import 'package:flutter/widgets.dart';

class Heading extends StatelessWidget {
  final String text;
  final double factor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 18 * factor,
        ),
        Text(text,
            textScaleFactor: 2.5 * factor,
            style: TextStyle(fontWeight: FontWeight.bold))
      ],
    );
  }

  Heading(this.text, {this.factor = 1});
}
