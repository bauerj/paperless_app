import 'package:flutter/material.dart';

class DisplayStepsWidget extends StatelessWidget {
  final int? currentStep;
  final int? totalSteps;

  DisplayStepsWidget({this.currentStep, this.totalSteps});

  @override
  Widget build(BuildContext context) {
    var widgets = <Widget>[];

    for (int i = 0; i < this.totalSteps!; i++) {
      var borderRadius = BorderRadius.zero;
      Color color = (i < this.currentStep!) ? Colors.green : Colors.grey;
      if (i == currentStep) color = Colors.grey.shade800;
      if (i == 0) {
        borderRadius = BorderRadius.only(
            topLeft: Radius.circular(10), bottomLeft: Radius.circular(10));
      }
      if (i == this.totalSteps! - 1) {
        borderRadius = BorderRadius.only(
            topRight: Radius.circular(10), bottomRight: Radius.circular(10));
      }
      widgets.add(DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            color: color,
          ),
          child: Padding(
              padding: EdgeInsets.fromLTRB(10, 3, 10, 3),
              child: Text((i + 1).toString(),
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: i == currentStep
                          ? FontWeight.bold
                          : FontWeight.normal)))));
      widgets.add(SizedBox(width: 1));
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: widgets,
    );
  }
}
