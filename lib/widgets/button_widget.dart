import 'package:flutter/material.dart';

class ButtonWidget extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final double scale;

  ButtonWidget(this.title, {this.onPressed, this.scale = 1});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0 * scale),
      color: Colors.green,
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(
            20.0 * scale, 15.0 * scale, 20.0 * scale, 15.0 * scale),
        onPressed: () {
          this.onPressed();
        },
        child: Text(
          this.title,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20 * scale),
        ),
      ),
    );
  }
}
