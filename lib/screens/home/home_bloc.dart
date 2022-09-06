import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:location/location.dart' as loc;
import 'package:mobile_attendance/models/location.dart';
import 'package:mobile_attendance/repositories/db_helper.dart';
import 'package:mobile_attendance/utils/common_helper.dart';
import 'package:sqflite/sqflite.dart';

abstract class HomeState {}

class GetLocationInitialState extends HomeState {
  List<Location>? listLocation = [];
}

class CheckAttendanceState extends HomeState {
  final bool isLoading;
  final bool isSuccess;
  final bool isFailure;
  final bool isRejected;
  final bool isEmpty;
  CheckAttendanceState({
    this.isFailure = false,
    this.isLoading = false,
    this.isSuccess = false,
    this.isRejected = false,
    this.isEmpty = false,
  });
}

class GetLocationLoadedState extends HomeState {
  List<Location>? listLocation;
  bool? isGetCurrentLocation;
  GetLocationLoadedState({
    required this.listLocation,
    this.isGetCurrentLocation = false,
  });
}

class GetLocationBloc extends Cubit<HomeState> {
  GetLocationBloc() : super(GetLocationInitialState());

  Future<void> getLocation({isGetCurrentLocation = false}) async {
    try {
      Database db = await DBHelper.instance.database;
      var result = await db.rawQuery("SELECT * FROM location");
      if (result.isNotEmpty) {
        List<Location> listLocation =
            List<Location>.from(result.map((map) => Location.fromJsonMap(map)));
        emit(GetLocationLoadedState(
            listLocation: listLocation,
            isGetCurrentLocation: isGetCurrentLocation));
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> initPlatformState() async {
    try {
      loc.Location locationService = loc.Location();
      bool serviceStatus = await locationService.serviceEnabled();
      if (serviceStatus) {
        var permission = await locationService.requestPermission();
        print("Permission: $permission");
        if (permission == loc.PermissionStatus.granted ||
            permission == loc.PermissionStatus.grantedLimited) {
          await locationService.changeSettings(
            accuracy: loc.LocationAccuracy.high,
            interval: 1000,
          );

          await locationService.getLocation().catchError((e) {
            Fluttertoast.showToast(
              msg: "Failed to get location data",
            );
          });
          locationService.onLocationChanged
              .listen((loc.LocationData currentLocation) {
            getLocation(isGetCurrentLocation: true);
          });
        }
      }
    } on PlatformException catch (e) {
      print(e);
      if (e.code == 'PERMISSION_DENIED') {
        var error = e.message;
        print(error);
      } else if (e.code == 'SERVICE_STATUS_ERROR') {
        var error = e.message;
        print(error);
      }
    }
  }
}

class CheckAttendanceBloc extends Cubit<HomeState> {
  CheckAttendanceBloc() : super(CheckAttendanceState());
  Future<void> checkAttendance() async {
    try {
      emit(CheckAttendanceState(isLoading: true));
      loc.Location locationService = loc.Location();
      bool serviceStatus = await locationService.serviceEnabled();
      if (serviceStatus) {
        var permission = await locationService.requestPermission();
        print("Permission: $permission");
        if (permission == loc.PermissionStatus.granted ||
            permission == loc.PermissionStatus.grantedLimited) {
          await locationService.changeSettings(
            accuracy: loc.LocationAccuracy.high,
            interval: 1000,
          );

          loc.LocationData location =
              await locationService.getLocation().catchError((e) {
            Fluttertoast.showToast(
              msg: "Failed to get location data",
            );
          });
          double myLng = (location.longitude ?? 0);
          double myLat = (location.latitude ?? 0);
          double locLat = 0, locLng = 0;
          Database db = await DBHelper.instance.database;
          var result = await db.rawQuery("SELECT * FROM location");
          if (result.isNotEmpty) {
            List<Location> listLocation = List<Location>.from(
                result.map((map) => Location.fromJsonMap(map)));
            locLat = double.parse(listLocation[0].lat ?? '0');
            locLng = double.parse(listLocation[0].lng ?? '0');
            Map<String, dynamic> map = CommonHelper.calcArea(
              distance: 50,
              latCenter: locLat,
              lngCenter: locLng,
            );
            double batasKiri = map['batasKiri'];
            double batasKanan = map['batasKanan'];
            double batasAtas = map['batasAtas'];
            double batasBawah = map['batasBawah'];
            print("batas: ${location.longitude}");
            print("batas: $batasKiri");
            print(batasKanan);
            print(batasAtas);
            print(batasBawah);
            if ((myLng >= batasKiri && myLng <= batasKanan) &&
                (myLat <= batasAtas && myLat >= batasBawah)) {
              await db.insert('attendance', {
                'lat': location.latitude,
                'lng': location.longitude,
                'attendDate': DateTime.now().toString()
              });
              emit(CheckAttendanceState(isSuccess: true));
            } else {
              emit(CheckAttendanceState(isRejected: true));
            }
          } else {
            emit(CheckAttendanceState(isEmpty: true));
          }
        } else {
          emit(CheckAttendanceState(isRejected: true));
        }
      }
    } catch (e) {
      emit(CheckAttendanceState(isFailure: true));
    }
  }
}
