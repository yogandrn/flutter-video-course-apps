// lib/cores/widgets/app_text_field.dart
import 'package:flutter/material.dart';
import '../themes/fontstyles.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.hint,
    this.onChanged,
    this.prefixIcon,
    this.textInputAction,
  });

  final TextEditingController? controller;
  final String? hint;
  final ValueChanged<String>? onChanged;
  final IconData? prefixIcon;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    onChanged: onChanged,
    textInputAction: textInputAction,
    style: AppFontStyles.body,
    decoration: InputDecoration(
      hintText: hint,
      prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
    ),
  );
}
