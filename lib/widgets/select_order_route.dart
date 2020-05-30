import 'package:flutter/material.dart';

import 'package:paperless_app/i18n.dart';

class SelectOrderRoute extends StatefulWidget {
  final String ordering;
  final Future<void> Function(String ordering) setOrdering;
  SelectOrderRoute({this.setOrdering, Key key, this.ordering}) : super(key: key);

  @override
  _SelectOrderRouteState createState() {
    String selected = "created";
    bool ascending = true;
    if (ordering != null && ordering.length > 1) {
      ascending = ordering.startsWith("-");
      selected = ascending ? ordering.substring(1) : ordering;
    }
    return new _SelectOrderRouteState(selected, ascending, setOrdering);
  }
}

class _SelectOrderRouteState extends State<SelectOrderRoute> {
  String selected;
  bool ascending = true;
  final Future<void> Function(String ordering) setOrdering;
  _SelectOrderRouteState(this.selected, this.ascending, this.setOrdering);

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SingleChildScrollView(
        child: Column(
      children: <Widget>[
        SizedBox(height: 20,),
        Text("Sort Documents By".i18n, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 35),),
        SizedBox(height: 20,),
        getFor("created", "Date created".i18n),
        getFor("added", "Date added".i18n),
        getFor("modified", "Last Modification".i18n),
        getFor("title", "Document Title".i18n),
        getFor("correspondent", "Correspondent".i18n),
        Row(children: <Widget>[
          SizedBox(width: 5,),
          Expanded(child: RaisedButton(child: Text("Cancel".i18n), onPressed: () {
            Navigator.of(context).pop();
          })),
          SizedBox(width: 5,),
          Expanded(child: RaisedButton(child: Text("Okay".i18n), onPressed: () {
            setOrdering((ascending ? "-" : "")  + selected);
            Navigator.of(context).pop();
          },)),
          SizedBox(width: 5,),
        ],)
      ],
        ),),);
  }

  OrderWidget getFor(String name, String label) {
    SelectedOrder selectedOrder = SelectedOrder.NONE;
    if (selected == name) {
      selectedOrder =
          ascending ? SelectedOrder.ASCENDING : SelectedOrder.DESCENDING;
    }
    return OrderWidget(
      name: name,
      label: label,
      selectedOrder: selectedOrder,
      onTap: () => {
        setState(
          () {
            if (selected == name) {
              ascending = !ascending;
            }
            selected = name;
          },
        )
      },
    );
  }
}

enum SelectedOrder { NONE, ASCENDING, DESCENDING }

class OrderWidget extends StatelessWidget {
  final String name;
  final String label;
  final SelectedOrder selectedOrder;
  final GestureTapCallback onTap;
  OrderWidget({this.name, this.label, this.selectedOrder, this.onTap});

  @override
  Widget build(BuildContext context) {
    Widget ordering;
    if (selectedOrder == SelectedOrder.NONE) {
      ordering = Text("");
    } else if (selectedOrder == SelectedOrder.ASCENDING) {
      ordering = Row(
        children: <Widget>[
          Icon(Icons.arrow_upward),
          Text("Ascending".i18n),
        ],
      );
    } else {
      ordering = Row(
        children: <Widget>[
          Icon(Icons.arrow_downward),
          Text("Descending".i18n),
        ],
      );
    }
    return Material(
        child: InkWell(
      onTap: onTap,
      child: Container(
        color: selectedOrder != SelectedOrder.NONE ? Colors.greenAccent : null,
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(label,
                  style: TextStyle(
                    fontWeight: selectedOrder != SelectedOrder.NONE ? FontWeight.bold : FontWeight.normal
                  ),),
                ],
              ),
              ordering
            ],
          ),
        ),
      ),
    ));
  }
}
