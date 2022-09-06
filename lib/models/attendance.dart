class Attendance {
  int? idAttendance;
  String? lat;
  String? lng;
  String? attendanceDate;

  Attendance.fromJsonMap(Map<String, dynamic> map)
      : idAttendance = map["idAttendance"],
        lat = map["lat"],
        lng = map["lng"],
        attendanceDate = map["attendanceDate"];
}
