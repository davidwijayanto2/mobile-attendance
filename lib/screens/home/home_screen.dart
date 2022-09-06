import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobile_attendance/models/location.dart';
import 'package:mobile_attendance/routes/navigator.dart';
import 'package:mobile_attendance/screens/home/home_bloc.dart';
import 'package:mobile_attendance/utils/common_helper.dart';
import 'package:mobile_attendance/utils/common_widget.dart';
import 'package:location/location.dart' as loc;
import 'package:sn_progress_dialog/progress_dialog.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  var isDialOpen = ValueNotifier<bool>(false);
  GoogleMapController? _googleMapController;
  loc.Location _location = loc.Location();

  @override
  void initState() {
    initPage();
    super.initState();
  }

  void initPage() async {
    final provider = BlocProvider.of<GetLocationBloc>(context, listen: false);
    await provider.getLocation();
    await provider.initPlatformState();
  }

  @override
  Widget build(BuildContext context) {
    final provider =
        BlocProvider.of<CheckAttendanceBloc>(context, listen: false);
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          body: BlocListener<CheckAttendanceBloc, HomeState>(
            bloc: BlocProvider.of<CheckAttendanceBloc>(context),
            listener: (context, state) async {
              ProgressDialog pd = ProgressDialog(context: context);
              if (state is CheckAttendanceState) {
                print(state.isLoading);
                if (state.isLoading) {
                  print('masuk loading');
                  pd.show(
                      max: 100,
                      msg: "Processing..",
                      progressType: ProgressType.valuable);
                }
                if (state.isSuccess) {
                  print('masuk success');
                  Future.delayed(Duration(seconds: 1)).then((value) {
                    Fluttertoast.showToast(msg: "Check attendance success");
                    pd.close();
                    Navigator.pop(context, true);
                  });
                }
                if (state.isEmpty) {
                  Future.delayed(Duration(seconds: 1)).then((value) {
                    Fluttertoast.showToast(
                        msg: "Check attendance failed. Try again!");
                    pd.close();
                    Navigator.pop(context, true);
                  });
                }
                if (state.isFailure) {
                  Future.delayed(Duration(seconds: 1)).then((value) {
                    Fluttertoast.showToast(
                        msg: "Check attendance failed. Try again!");
                    pd.close();
                    Navigator.pop(context, true);
                  });
                }
                if (state.isRejected) {
                  Future.delayed(Duration(seconds: 1)).then((value) {
                    Fluttertoast.showToast(
                        msg:
                            "Check attendance rejected. You are outside the area");
                    pd.close();
                    Navigator.pop(context, true);
                  });
                }
              }
            },
            child: Stack(
              children: [
                BlocBuilder<GetLocationBloc, HomeState>(
                  builder: (context, state) {
                    if (state is GetLocationLoadedState) {
                      double lat = -7.3115371, lng = 112.6776481;
                      int markerId = 0;
                      lat = double.parse(
                          state.listLocation?[0].lat ?? '-7.3115371');
                      lng = double.parse(
                          state.listLocation?[0].lng ?? '112.6776481');
                      markerId = state.listLocation?[0].idLocation ?? 0;
                      var latLng = LatLng(lat, lng);
                      CameraPosition initialCamera = CameraPosition(
                        target: latLng,
                        zoom: 15,
                      );
                      Marker newMarker = Marker(
                        markerId: MarkerId(markerId.toString()),
                        position: latLng,
                        consumeTapEvents: true,
                      );
                      Set<Marker> markers = Set();
                      markers.add(newMarker);
                      Map<String, dynamic> map = CommonHelper.calcArea(
                        distance: 50,
                        latCenter: lat,
                        lngCenter: lng,
                      );
                      Polygon polygon = Polygon(
                        polygonId: PolygonId(markerId.toString()),
                        points: [
                          LatLng(
                            map['batasAtas'],
                            map['batasKiri'],
                          ),
                          LatLng(
                            map['batasAtas'],
                            map['batasKanan'],
                          ),
                          LatLng(
                            map['batasBawah'],
                            map['batasKanan'],
                          ),
                          LatLng(
                            map['batasBawah'],
                            map['batasKiri'],
                          ),
                          LatLng(
                            map['batasAtas'],
                            map['batasKiri'],
                          ),
                        ],
                        strokeWidth: 2,
                        strokeColor: Colors.blue,
                        fillColor: Colors.blueAccent.withOpacity(0.15),
                      );
                      Set<Polygon> polygons = Set();
                      polygons.add(polygon);
                      return state.isGetCurrentLocation == true
                          ? GoogleMap(
                              mapType: MapType.normal,
                              myLocationEnabled: true,
                              myLocationButtonEnabled: true,
                              initialCameraPosition: initialCamera,
                              compassEnabled: false,
                              zoomControlsEnabled: false,
                              mapToolbarEnabled: false,
                              markers: markers,
                              polygons: polygons,
                            )
                          : GoogleMap(
                              mapType: MapType.normal,
                              initialCameraPosition: initialCamera,
                              compassEnabled: false,
                              zoomControlsEnabled: false,
                              mapToolbarEnabled: false,
                              markers: markers,
                              polygons: polygons,
                            );
                    } else {
                      return Container();
                    }
                  },
                ),
              ],
            ),
          ),
          floatingActionButton: SpeedDial(
            icon: Icons.menu,
            activeIcon: Icons.close,
            spacing: 3,
            openCloseDial: isDialOpen,
            childPadding: const EdgeInsets.all(5),
            spaceBetweenChildren: 4,
            children: [
              SpeedDialChild(
                child: const Icon(Icons.check),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                label: 'Attend',
                onTap: () => provider.checkAttendance(),
              ),
              SpeedDialChild(
                  child: const Icon(Icons.history),
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  label: 'Attendance History',
                  onTap: () => goToAttendanceScreen(context)),
              SpeedDialChild(
                  child: const Icon(Icons.location_pin),
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  label: 'Location Data',
                  onTap: () => goToAddLocationScreen(context)),
            ],
          ),
        ),
      ),
    );
  }
}
