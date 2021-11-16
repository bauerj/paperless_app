import 'package:flutter/material.dart';

class TextfieldWidget extends StatelessWidget {
  final ValueChanged<String>? onFieldSubmitted;
  final bool autofocus;
  final bool autocorrect;
  final TextInputType? keyboardType;
  final String? initialValue;
  final FormFieldValidator<String>? validator;
  final FormFieldSetter<String>? onSaved;
  final String hintText;
  final bool obscureText;
  final Iterable<String>? autofillHints;

  TextfieldWidget(
      {this.onFieldSubmitted,
      this.autocorrect = false,
      this.autofocus = false,
      this.keyboardType,
      this.initialValue = "",
      this.validator,
      this.onSaved,
      this.hintText = "",
      this.obscureText = false,
      this.autofillHints});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onFieldSubmitted: onFieldSubmitted,
      autocorrect: autocorrect,
      autofocus: autofocus,
      keyboardType: keyboardType,
      initialValue: initialValue,
      validator: validator,
      onSaved: onSaved,
      obscureText: obscureText,
      autofillHints: autofillHints,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: hintText,
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );
  }
}
