import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobile_attendance/models/attendance.dart';
import 'package:mobile_attendance/models/location.dart';
import 'package:mobile_attendance/repositories/db_helper.dart';
import 'package:sqflite/sqflite.dart';

abstract class AddLocationState {}

class AddLocationInitialState extends AddLocationState {
  List<Location> listLocation = [];
}

class AddLocationLoadingState extends AddLocationState {}

class AddLocationFailureState extends AddLocationState {}

class AddLocationEmptyState extends AddLocationState {}

class AddLocationLoadedState extends AddLocationState {
  List<Location>? listLocation;

  AddLocationLoadedState({
    required this.listLocation,
  });
}

class AddLocationUpdateState extends AddLocationState {
  final bool isLoading;
  final bool isSuccess;
  final bool isFailure;
  AddLocationUpdateState({
    this.isLoading = false,
    this.isSuccess = false,
    this.isFailure = false,
  });
}

class AddLocationBloc extends Cubit<AddLocationState> {
  AddLocationBloc() : super(AddLocationInitialState());

  Future<void> getLocation() async {
    try {
      emit(AddLocationLoadingState());
      Database db = await DBHelper.instance.database;
      var result = await db.rawQuery("SELECT * FROM location");
      if (result.isNotEmpty) {
        List<Location> listLocation =
            List<Location>.from(result.map((map) => Location.fromJsonMap(map)));
        print(listLocation);
        emit(AddLocationLoadedState(listLocation: listLocation));
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> updateLocation(
      {required idLocation,
      required locationName,
      required lat,
      required lng}) async {
    try {
      emit(AddLocationUpdateState(isLoading: true));
      Database db = await DBHelper.instance.database;
      await db.update(
          "location",
          {
            'locationName': locationName,
            'lat': lat,
            'lng': lng,
          },
          where: 'idLocation = ?',
          whereArgs: [idLocation]);
      emit(AddLocationUpdateState(isSuccess: true));
    } catch (e) {
      emit(AddLocationUpdateState(isFailure: true));
      print(e);
    }
  }
}
