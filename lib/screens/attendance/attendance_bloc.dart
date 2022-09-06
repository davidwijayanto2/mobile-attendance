import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_attendance/models/attendance.dart';
import 'package:mobile_attendance/repositories/db_helper.dart';
import 'package:sqflite/sqflite.dart';

abstract class AttendanceState {}

class AttendanceInitialState extends AttendanceState {
  List<Attendance> attendance = [];
}

class AttendanceLoadingState extends AttendanceState {}

class AttendanceFailureState extends AttendanceState {}

class AttendanceEmptyState extends AttendanceState {}

class AttendanceLoadedState extends AttendanceState {
  List<Attendance>? listAttendance;
  AttendanceLoadedState({required this.listAttendance});
}

class AttendanceBloc extends Cubit<AttendanceState> {
  AttendanceBloc() : super(AttendanceInitialState());
  Future<void> getAttendance() async {
    try {
      emit(AttendanceLoadingState());
      Database db = await DBHelper.instance.database;
      var result = await db.rawQuery("SELECT * FROM attendance");
      if (result.isNotEmpty) {
        List<Attendance> listAttendance = List<Attendance>.from(
            result.map((map) => Attendance.fromJsonMap(map)));
        emit(AttendanceLoadedState(
          listAttendance: listAttendance,
        ));
      } else {
        emit(AttendanceEmptyState());
      }
    } catch (e) {
      emit(AttendanceFailureState());
    }
  }
}
