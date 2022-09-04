import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_attendance/screens/home/home_screen.dart';
import 'package:mobile_attendance/utils/common_string.dart';

class MyRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case homeRoute:
        return routeTransition(screen: HomeScreen());
      default:
        return routeTransition(
          screen: Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}

Route<T> routeTransition<T>({
  required Widget? screen,
  bool animation = true,
}) {
  if (Platform.isIOS) {
    return CupertinoPageRoute(builder: (_) => screen!);
  } else {
    return MaterialPageRoute(builder: (_) => screen!);
  }
}

transparentTransition({
  required Widget screen,
}) {
  // return CupertinoPageRoute(builder: (_) => screen);
  return PageRouteBuilder(
    opaque: false,
    pageBuilder: (_, __, ___) => screen,
  );
}
