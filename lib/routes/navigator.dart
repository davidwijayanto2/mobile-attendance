import 'package:flutter/material.dart';
import 'package:mobile_attendance/utils/common_string.dart';

replaceToHomeScreen(BuildContext context) async {
  Navigator.of(context, rootNavigator: true)
      .pushNamedAndRemoveUntil(homeRoute, (route) => false);
}
