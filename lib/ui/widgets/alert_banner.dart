import 'package:flutter/material.dart';

class AlertBanner extends StatelessWidget {
  final String text;
  final Color color;
  const AlertBanner({super.key, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
 padding: const EdgeInsets.all(12),
 decoration: BoxDecoration(color: color.withAlpha(((color.a * 255.0 * 0.1).round() & 0xff).toInt()), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withAlpha(((color.a * 255.0 * 0.4).round() & 0xff).toInt()))),
      child: Row(children: [
        Icon(Icons.info, color: color), const SizedBox(width: 8),
        Expanded(child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w600))),
      ]),
    );
  }
}