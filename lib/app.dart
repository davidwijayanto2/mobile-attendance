import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_attendance/routes/my_router.dart';
import 'package:mobile_attendance/screens/home/home_bloc.dart';
import 'package:mobile_attendance/screens/home/home_screen.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<GetLocationBloc>(
          create: (context) => GetLocationBloc(),
        ),
        BlocProvider<CheckAttendanceBloc>(
          create: (context) => CheckAttendanceBloc(),
        ),
      ],
      child: MaterialApp(
        title: 'Social Media',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        onGenerateRoute: MyRouter.generateRoute,
        builder: (context, child) {
          final MediaQueryData data = MediaQuery.of(context);
          return MediaQuery(
            data: data.copyWith(textScaleFactor: 1.0),
            child: child!,
          );
        },
        home: HomeScreen(),
      ),
    );
  }
}
