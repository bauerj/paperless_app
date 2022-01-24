import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:paperless_app/i18n.dart';

class SearchAppBar extends StatefulWidget implements PreferredSizeWidget {
  final Widget? leading;
  final Widget? title;
  final List<Widget>? actions;
  final void Function(String? text)? searchListener;
  final void Function(bool open)? toggleSearch;
  final Future<void> Function(String? text)? autoCompleteListener;
  final bool? isSearchOpen;

  const SearchAppBar(
      {Key? key,
      this.leading,
      this.title,
      this.actions,
      this.searchListener,
      this.autoCompleteListener,
      this.isSearchOpen,
      this.toggleSearch})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SearchAppBarState(leading, title, actions, searchListener,
        autoCompleteListener, toggleSearch, isSearchOpen);
  }

  @override
  Size get preferredSize => new Size.fromHeight(56);
}

class _SearchAppBarState extends State<SearchAppBar> {
  Widget? leading;
  Widget? title;
  final List<Widget>? actions;
  final void Function(String? text)? listener;
  final Future<void> Function(String? text)? autoCompleteListener;
  final FocusNode focusNode = new FocusNode();
  final Duration userTimeout = Duration(milliseconds: 100);
  final void Function(bool open)? toggleSearch;
  final bool? isSearchOpen;
  int currentSearch = 0;

  IconData searchIcon = Icons.search;
  Widget? appBarTitle;

  _SearchAppBarState(this.leading, this.title, this.actions, this.listener,
      this.autoCompleteListener, this.toggleSearch, this.isSearchOpen);

  @override
  Widget build(BuildContext context) {
    var appBarTitle = title;
    List<Widget> actions = [];

    if (isSearchOpen == true) {
      searchIcon = Icons.close;
      appBarTitle = new TextFormField(
        style: Theme.of(context)
            .textTheme
            .headline6
            ?.copyWith(color: Theme.of(context).primaryIconTheme.color),
        cursorColor: Theme.of(context).primaryIconTheme.color,
        onChanged: (t) async {
          if (autoCompleteListener == null) return;
          int thisSearch = ++currentSearch;
          await new Future.delayed(userTimeout);
          if (thisSearch != currentSearch) {
            // There is a newer onChanged that will send the request
            return;
          }
          await autoCompleteListener!(t);
        },
        focusNode: focusNode,
        textInputAction: TextInputAction.search,
        onFieldSubmitted: (e) {
          listener!(e);
          toggleSearch!(false);
        },
        decoration: new InputDecoration(
            hintStyle: Theme.of(context)
                .textTheme
                .headline6
                ?.copyWith(color: Theme.of(context).primaryIconTheme.color),
            hintText: 'Search for document...'.i18n),
      );
      focusNode.requestFocus();
    } else {
      searchIcon = Icons.search;
      appBarTitle = title;
    }

    actions.add(IconButton(
      icon: Icon(searchIcon),
      onPressed: () {
        if (this.searchIcon == Icons.search) {
          if (toggleSearch != null) toggleSearch!(true);
        } else {
          listener!(null);
          if (toggleSearch != null) toggleSearch!(false);
        }
      },
    ));
    actions.addAll(this.actions!);

    return AppBar(
      leading: leading,
      title: appBarTitle,
      actions: actions,
      titleSpacing: 0,
      titleTextStyle: TextStyle(
        fontSize: 19,
        fontFamily: "AlegreyaSans",
      ),
    );
  }
}
