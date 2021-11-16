import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:paperless_app/i18n.dart';

class SearchAppBar extends StatefulWidget implements PreferredSizeWidget {
  final Widget? leading;
  final Widget? title;
  final Widget? bottom;
  final List<Widget>? actions;
  final void Function(String? text)? searchListener;

  const SearchAppBar(
      {Key? key,
      this.leading,
      this.title,
      this.bottom,
      this.actions,
      this.searchListener})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SearchAppBarState(leading, title, bottom, actions, searchListener);
  }

  @override
  Size get preferredSize => new Size.fromHeight(56);
}

class _SearchAppBarState extends State<SearchAppBar> {
  final Widget? leading;
  final Widget? title;
  final Widget? bottom;
  final List<Widget>? actions;
  final void Function(String? text)? listener;
  final FocusNode focusNode = new FocusNode();

  IconData searchIcon = Icons.search;
  Widget? appBarTitle;

  _SearchAppBarState(
      this.leading, this.title, this.bottom, this.actions, this.listener) {
    appBarTitle = title;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> actions = [];

    actions.add(IconButton(
      icon: Icon(searchIcon),
      onPressed: () {
        if (this.searchIcon == Icons.search) {
          setState(() {
            searchIcon = Icons.close;
            appBarTitle = new TextFormField(
              focusNode: focusNode,
              textInputAction: TextInputAction.search,
              onFieldSubmitted: (e) {
                listener!(e);
              },
              decoration: new InputDecoration(
                  prefixIcon: new Icon(Icons.search),
                  hintText: 'Search for document...'.i18n),
            );
            focusNode.requestFocus();
          });
        } else {
          setState(() {
            searchIcon = Icons.search;
            appBarTitle = title;
            listener!(null);
          });
        }
      },
    ));
    actions.addAll(this.actions!);

    return AppBar(
        leading: leading,
        title: appBarTitle,
        bottom: bottom as PreferredSizeWidget?,
        actions: actions);
  }
}
