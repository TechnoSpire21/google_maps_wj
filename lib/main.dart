import 'package:flutter/material.dart';
import 'package:google_maps_2/directions_repository.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'directions_model.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Maps',
      theme: ThemeData(primaryColor: Colors.white),
      home: MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const _initialCameraPosition =
      CameraPosition(target: LatLng(-5.1208222, 119.4203838), zoom: 15);

  late GoogleMapController _googleMapController;
  Marker _origin = Marker(
      markerId: const MarkerId('origin'),
      infoWindow: const InfoWindow(title: 'Origin'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      position: LatLng(-7.2754438, 112.642471));
  Marker _destination = Marker(
      markerId: const MarkerId('destination'),
      infoWindow: const InfoWindow(title: 'Destination'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      position: LatLng(-7.2754438, 112.642471));

  late Directions _info;
  bool destinationChecker = false;
  bool originChecker = false;
  bool infoChecker = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Google Maps"),
        centerTitle: false,
        actions: [
          if (originChecker == true)
            TextButton(
                onPressed: () => _googleMapController.animateCamera(
                    CameraUpdate.newCameraPosition(CameraPosition(
                        target: _origin.position, zoom: 15, tilt: 50))),
                child: Text(
                  "Origin",
                  style: TextStyle(color: Colors.green),
                )),
          if (destinationChecker == true)
            TextButton(
                onPressed: () => _googleMapController.animateCamera(
                    CameraUpdate.newCameraPosition(CameraPosition(
                        target: _destination.position, zoom: 15, tilt: 50))),
                child:
                    Text("Destination", style: TextStyle(color: Colors.blue)))
        ],
      ),
      body: Container(
        child: Stack(
          alignment: Alignment.center,
          children: [
            GoogleMap(
              initialCameraPosition: _initialCameraPosition,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              onMapCreated: (controller) => _googleMapController = controller,
              markers: {
                if (originChecker != false) _origin,
                if (destinationChecker != false) _destination
              },
              onLongPress: _addMarker,
            ),
            if (infoChecker == true)
              Positioned(
                  top: 20,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.yellowAccent,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black26,
                            offset: Offset(0, 2),
                            blurRadius: 6.0)
                      ],
                    ),
                    child: Text(
                      '${_info.totalDistance}, ${_info.totalDuration}',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.blue,
        onPressed: () => _googleMapController.animateCamera(infoChecker == true
            ? CameraUpdate.newLatLngBounds(_info.bounds, 100.0)
            : CameraUpdate.newCameraPosition(_initialCameraPosition)),
        child: Icon(Icons.center_focus_strong),
      ),
    );
  }

  void _addMarker(LatLng position) async {
    if (originChecker == false ||
        (originChecker != false && destinationChecker != false)) {
      setState(() {
        _origin = Marker(
            markerId: const MarkerId('origin'),
            infoWindow: const InfoWindow(title: 'Origin'),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen),
            position: position);
        originChecker = true;
        destinationChecker = false;
        infoChecker = false;
      });
    } else {
      setState(() {
        _destination = Marker(
            markerId: const MarkerId('destination'),
            infoWindow: const InfoWindow(title: 'Destination'),
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            position: position);
        destinationChecker = true;
      });

      try {
        final directions = await DirectionsRepository().getDirections(
            origin: _origin.position, destination: _destination.position);
        setState(() {
          _info = directions;
        });
        infoChecker = true;
      } catch (e) {
        // print(e.toString());
        _showDialog(e.toString());
      }
    }
  }

  void _showDialog(String errorMessage) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Error"),
          content: new Text(errorMessage),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
