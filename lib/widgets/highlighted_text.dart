import 'package:flutter/material.dart';

class HighlightedText extends StatelessWidget {
  final String text;
  final String query;
  final TextStyle? style;
  final TextStyle? highlightStyle;

  const HighlightedText({
    super.key,
    required this.text,
    required this.query,
    this.style,
    this.highlightStyle,
  });

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) {
      return Text(text, style: style);
    }

    final String sourceText = text.toLowerCase();
    final String targetText = query.toLowerCase();
    final int matchLength = targetText.length;

    List<TextSpan> spans = [];
    int start = 0;
    int indexOfMatch;

    while ((indexOfMatch = sourceText.indexOf(targetText, start)) != -1) {
      if (indexOfMatch >= text.length) break;

      if (indexOfMatch > start) {
        spans.add(TextSpan(text: text.substring(start, indexOfMatch)));
      }
      
      int endMatch = indexOfMatch + matchLength;
      if (endMatch > text.length) endMatch = text.length;
      
      spans.add(
        TextSpan(
          text: text.substring(indexOfMatch, endMatch),
          style: highlightStyle ??
              const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
        ),
      );
      start = endMatch;
    }

    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }

    return RichText(
      text: TextSpan(
        style: style ?? DefaultTextStyle.of(context).style,
        children: spans,
      ),
    );
  }
}
