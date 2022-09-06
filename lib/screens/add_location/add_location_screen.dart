import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobile_attendance/screens/add_location/add_location_bloc.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';

class AddLocationScreen extends StatefulWidget {
  const AddLocationScreen({super.key});

  @override
  AddLocationScreenState createState() => AddLocationScreenState();
}

class AddLocationScreenState extends State<AddLocationScreen> {
  GoogleMapController? mapController;
  TextEditingController locationNameController = TextEditingController();
  LatLng? latLng;
  Set<Marker> markers = Set();
  bool firstInit = true;
  @override
  void initState() {
    BlocProvider.of<AddLocationBloc>(context, listen: false).getLocation();
    super.initState();
  }

  @override
  dispose() {
    super.dispose();
    mapController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        color: Colors.white,
        child: SafeArea(
          child: Scaffold(
            backgroundColor: Colors.white,
            body: addLocationForm(),
          ),
        ),
      ),
    );
  }

  addNewMarker(markerId) {
    markers.clear();
    Marker newMarker = Marker(
        markerId: MarkerId(markerId.toString()),
        position: latLng!,
        draggable: true,
        onDragEnd: (value) {
          setState(() => latLng = value);
          mapController?.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(target: value, zoom: 17),
            ),
          );

          addNewMarker(markerId);
        });

    markers.add(newMarker);
  }

  addLocationForm() {
    return BlocListener<AddLocationBloc, AddLocationState>(
      bloc: BlocProvider.of<AddLocationBloc>(context),
      listenWhen: (previous, current) => current is AddLocationUpdateState,
      listener: (context, state) async {
        ProgressDialog pd = ProgressDialog(context: context);

        if (state is AddLocationUpdateState) {
          if (state.isLoading) {
            pd.show(
                max: 100,
                msg: "Processing..",
                progressType: ProgressType.valuable);
          }
          if (state.isSuccess) {
            Future.delayed(Duration(seconds: 1)).then((value) {
              Fluttertoast.showToast(msg: "Check attendance success");
              pd.close();
              Navigator.pop(context, true);
              FocusScope.of(context).unfocus();
            });
          }
          if (state.isFailure) {
            Future.delayed(Duration(seconds: 1)).then((value) {
              Fluttertoast.showToast(msg: "Update location failed. Try again!");
              pd.close();
              Navigator.pop(context, true);
            });
          }
        }
      },
      child: BlocBuilder<AddLocationBloc, AddLocationState>(
        buildWhen: (previous, current) => current is! AddLocationUpdateState,
        builder: (_, state) {
          if (state is AddLocationLoadedState) {
            locationNameController.text =
                state.listLocation?[0].locationName ?? '';
            double lat = -7.3115371, lng = 112.6776481;
            int markerId = 0;
            lat = double.parse(state.listLocation?[0].lat ?? '-7.3115371');
            lng = double.parse(state.listLocation?[0].lng ?? '112.6776481');
            markerId = state.listLocation?[0].idLocation ?? 0;
            if (firstInit) {
              latLng = LatLng(lat, lng);
              firstInit = false;
            }
            CameraPosition initialCamera = CameraPosition(
              target: latLng ?? LatLng(lat, lng),
              zoom: 15,
            );
            addNewMarker(markerId);
            return SingleChildScrollView(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Location Data',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  TextFormField(
                    controller: locationNameController,
                    keyboardType: TextInputType.text,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text('Location: ${latLng?.latitude}, ${latLng?.longitude}'),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    height: 200,
                    child: GoogleMap(
                      mapType: MapType.normal,
                      initialCameraPosition: initialCamera,
                      markers: markers,
                      myLocationButtonEnabled: false,
                      myLocationEnabled: false,
                      onMapCreated: (controller) => mapController = controller,
                      gestureRecognizers:
                          <Factory<OneSequenceGestureRecognizer>>[
                        new Factory<OneSequenceGestureRecognizer>(
                          () => new EagerGestureRecognizer(),
                        ),
                      ].toSet(),
                    ),
                  ),
                  const Text('*Hold and drag marker to change location'),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () =>
                        BlocProvider.of<AddLocationBloc>(context, listen: false)
                            .updateLocation(
                      idLocation: state.listLocation?[0].idLocation,
                      locationName: locationNameController.text.trim(),
                      lat: latLng?.latitude,
                      lng: latLng?.longitude,
                    ),
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(40)),
                    child: const Text('Save'),
                  )
                ],
              ),
            );
          } else if (state is AddLocationLoadingState) {
            return Container(
              child: Text('Loading...'),
            );
          } else {
            return Container(
              child: Text('Empty data location'),
            );
          }
        },
      ),
    );
  }
}
