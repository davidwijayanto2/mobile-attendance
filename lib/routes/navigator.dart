import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_attendance/utils/common_string.dart';

replaceToHomeScreen(BuildContext context) async {
  Navigator.of(context, rootNavigator: true)
      .pushNamedAndRemoveUntil(homeRoute, (route) => false);
}

goToAddLocationScreen<R>(
  BuildContext context, {
  FutureOr<R> Function(dynamic)? afterOpen,
}) async {
  if (afterOpen != null) {
    Navigator.of(context, rootNavigator: true)
        .pushNamed(addLocationRoute)
        .then(afterOpen);
  } else {
    Navigator.of(context, rootNavigator: true).pushNamed(addLocationRoute);
  }
}

goToAttendanceScreen<R>(
  BuildContext context, {
  FutureOr<R> Function(dynamic)? afterOpen,
}) async {
  if (afterOpen != null) {
    Navigator.of(context, rootNavigator: true)
        .pushNamed(attendanceRoute)
        .then(afterOpen);
  } else {
    Navigator.of(context, rootNavigator: true).pushNamed(attendanceRoute);
  }
}
