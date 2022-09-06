import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_attendance/screens/add_location/add_location_bloc.dart';
import 'package:mobile_attendance/screens/add_location/add_location_screen.dart';
import 'package:mobile_attendance/screens/attendance/attendance_bloc.dart';
import 'package:mobile_attendance/screens/attendance/attendance_screen.dart';
import 'package:mobile_attendance/screens/home/home_bloc.dart';
import 'package:mobile_attendance/screens/home/home_screen.dart';
import 'package:mobile_attendance/utils/common_string.dart';

class MyRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case homeRoute:
        return routeTransition(
          screen: HomeScreen(),
        );
      case addLocationRoute:
        return routeTransition(
          screen: BlocProvider(
            create: (context) => AddLocationBloc(),
            child: const AddLocationScreen(),
          ),
        );
      case attendanceRoute:
        return routeTransition(
          screen: BlocProvider(
            create: (context) => AttendanceBloc(),
            child: const AttendanceScreen(),
          ),
        );
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
