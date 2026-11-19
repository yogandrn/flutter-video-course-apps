// lib/cores/widgets/app_expandable_text.dart
import 'package:flutter/material.dart';
import '../themes/colors.dart';
import '../themes/fontstyles.dart';

class AppExpandableText extends StatefulWidget {
  const AppExpandableText(this.text, {super.key, this.maxLines = 3});
  final String text;
  final int maxLines;

  @override
  State<AppExpandableText> createState() => _AppExpandableTextState();
}

class _AppExpandableTextState extends State<AppExpandableText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    // shortcut: length heuristic, text is not measured. Use TextPainter if it misjudges.
    final canExpand = widget.text.length > widget.maxLines * 45;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.topCenter,
          child: Text(
            widget.text,
            maxLines: _expanded ? null : widget.maxLines,
            overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
            style: AppFontStyles.body.copyWith(height: 1.5),
          ),
        ),
        if (canExpand)
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                _expanded ? 'Show less' : 'Read more',
                style: AppFontStyles.label.copyWith(
                  color: AppColors.primaryDark,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
