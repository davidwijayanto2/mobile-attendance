import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_attendance/models/attendance.dart';
import 'package:mobile_attendance/screens/attendance/attendance_bloc.dart';
import 'package:mobile_attendance/utils/common_helper.dart';
import 'package:mobile_attendance/utils/common_widget.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  AttendanceScreenState createState() => AttendanceScreenState();
}

class AttendanceScreenState extends State<AttendanceScreen> {
  @override
  void initState() {
    BlocProvider.of<AttendanceBloc>(context, listen: false).getAttendance();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          body: BlocBuilder<AttendanceBloc, AttendanceState>(
            builder: (_, state) {
              if (state is AttendanceLoadingState) {
                return Container(
                  padding: const EdgeInsets.only(top: 20),
                  alignment: Alignment.center,
                  child: const Text('Loading...'),
                );
              } else if (state is AttendanceLoadedState) {
                return ListView.separated(
                  separatorBuilder: (context, index) =>
                      CommonWidget.horizontalDivider(),
                  itemCount: state.listAttendance?.length ?? 0,
                  itemBuilder: (context, index) {
                    return AttendanceItem(
                        (state.listAttendance ?? <Attendance>[])[index]);
                  },
                );
              } else if (state is AttendanceEmptyState) {
                return Container(
                  padding: const EdgeInsets.only(top: 20),
                  alignment: Alignment.center,
                  child: const Text('Data not found...'),
                );
              } else if (state is AttendanceEmptyState) {
                return Container(
                  padding: const EdgeInsets.only(top: 20),
                  alignment: Alignment.center,
                  child: const Text('Failed to load data...'),
                );
              } else {
                return Container();
              }
            },
          ),
        ),
      ),
    );
  }
}

class AttendanceItem extends StatelessWidget {
  final Attendance attendance;
  const AttendanceItem(this.attendance, {super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Row(children: [
        Icon(
          Icons.check,
          color: Colors.green,
        ),
        SizedBox(
          width: 5,
        ),
        Text(
            "(${attendance.lat.toString()}, ${attendance.lng.toString()}) at ${CommonHelper.toShortDateText(context, DateTime.parse(attendance.attendanceDate ?? DateTime.now().toString()))}")
      ]),
    );
  }
}
