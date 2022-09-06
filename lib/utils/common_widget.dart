import 'package:flutter/material.dart';

class CommonWidget {
  static horizontalDivider({
    Color? color,
    double? height,
    double? padding,
  }) {
    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: padding == null ? 0.0 : padding),
      child: Container(
        height: height ?? 1,
        width: double.infinity,
        color: color ?? Colors.grey,
      ),
    );
  }
}
