import 'package:flutter/material.dart';
import 'dart:math';
// import 'package:google_map_polyline/google_map_polyline.dart';
import 'package:google_map_polyline_new/google_map_polyline_new.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class LiveTracking extends StatefulWidget {
  const LiveTracking({Key? key, required this.destination}) : super(key: key);
  final LatLng destination;
  @override
  _LiveTrackingState createState() => _LiveTrackingState();
}

class _LiveTrackingState extends State<LiveTracking> {
  static GoogleMapController? _controller;
  List<Marker> markers = [];
  LatLng? _latLng;
  List<LatLng>? records;
  List<Polyline>? polyline = [];
  LocationData? _locationData;
  Location location = new Location();
  var kGoogleApiKey = 'AIzaSyCW_so_r7fO1JPFN2e_boIYw5KVhFiF2rM';
  final GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();
  GoogleMapPolyline _googleMapPolyline =
      GoogleMapPolyline(apiKey: 'AIzaSyCW_so_r7fO1JPFN2e_boIYw5KVhFiF2rM');

  Future _get() async {
    try {
      _locationData = await location.getLocation();
      _latLng = LatLng(_locationData!.latitude, _locationData!.longitude);
      location.onLocationChanged.listen((onData) => _locationData = onData);
      _controller?.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: _latLng!, zoom: 15)));
      setState(() {});
      getMark();
    } catch (e) {
      print(e);
    }
  }

  //making marks on map
  getMark() {
    markers.add(Marker(
        markerId: MarkerId('2'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        position: widget.destination,
        infoWindow: InfoWindow(title: 'Destination')));
    lines();
  }

  lines() async {
    try {
      records = await _googleMapPolyline.getCoordinatesWithLocation(
          origin: _latLng!,
          destination: widget.destination,
          mode: RouteMode.driving);
      polyline!.add(Polyline(
          polylineId: PolylineId('poly'),
          points: records!,
          width: 4,
          color: Colors.green,
          endCap: Cap.roundCap,
          startCap: Cap.buttCap,
          visible: true));
      setState(() {
        LatLng southWeset = LatLng(
            min(_latLng!.latitude, widget.destination.latitude),
            min(_latLng!.longitude, widget.destination.longitude));
        LatLng nortEast = LatLng(
            max(_latLng!.latitude, widget.destination.latitude),
            max(_latLng!.longitude, widget.destination.longitude));
        _controller?.animateCamera(CameraUpdate.newLatLngBounds(
            LatLngBounds(southwest: southWeset, northeast: nortEast), 64));
      });
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  void initState() {
    // TODO: implement initState

    _get();
    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      body: Stack(
        children: <Widget>[
          GoogleMap(
            initialCameraPosition: CameraPosition(
                target: LatLng(17.261383, 78.385555),
                zoom: 12,
                bearing: 90.0,
                tilt: 45.0),
            mapType: MapType.terrain,
            markers: Set.of(markers),
            compassEnabled: false,
            myLocationEnabled: true,
            polylines: Set.of(polyline ?? <Polyline>[]),
            onMapCreated: (GoogleMapController control) async {
              setState(() {
                _controller = control;
                if (_latLng != null) {
                  control.animateCamera(CameraUpdate.newCameraPosition(
                      CameraPosition(
                          target: _latLng!,
                          zoom: 15,
                          bearing: 90.0,
                          tilt: 45.0)));
                }
              });
            },
          ),
        ],
      ),
    );
  }
}
