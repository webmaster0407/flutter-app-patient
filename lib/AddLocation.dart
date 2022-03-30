import 'dart:async';

import 'package:doctro/api/Retrofit_Api.dart';
import 'package:doctro/api/network_api.dart';
import 'package:doctro/const/prefConstatnt.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'api/base_model.dart';
import 'api/server_error.dart';
import 'const/Palette.dart';
import 'const/app_string.dart';
import 'localization/localization_constant.dart';
import 'model/AddAddress.dart';

class AddLocation extends StatefulWidget {
  final double? currentLat;
  final double? currentLong;

  AddLocation({
    this.currentLat,
    this.currentLong,
  });

  @override
  _AddLocationState createState() => _AddLocationState();
}

class _AddLocationState extends State<AddLocation> {
  bool loading = false;

  BitmapDescriptor? sourceIcon;
  BitmapDescriptor? destinationIcon;

  String address = "";
  double selectLat = 0.0;
  double selectLang = 0.0;

  double? liveLat = 0.0;
  double? liveLang = 0.0;

  LatLng? _initialCameraPosition;
  GoogleMapController? _controller;
  BitmapDescriptor _markerIcon = BitmapDescriptor.defaultMarker;

  TextEditingController _textFullAddress = new TextEditingController();
  TextEditingController _textAddressLabel = new TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  @override
  void initState() {
    super.initState();
    _initialCameraPosition = LatLng(widget.currentLat!, widget.currentLong!);
    _determinePosition();
  }

  void _onMapCreated(GoogleMapController _cnTlr) {
    _controller = _cnTlr;
  }

  Set<Marker> _createMarker() {
    return <Marker>{
      Marker(
        markerId: MarkerId("marker_1"),
        position: _initialCameraPosition!,
        icon: _markerIcon,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: ModalProgressHUD(
          inAsyncCall: loading,
          opacity: 0.5,
          progressIndicator: SpinKitFadingCircle(
            color: Palette.blue,
            size: 50.0,
          ),
          child: Column(
            children: [
              Expanded(
                flex: 5,
                child: Stack(
                  children: [
                    GoogleMap(
                      myLocationEnabled: false,
                      markers: _createMarker(),
                      mapType: MapType.normal,
                      initialCameraPosition: CameraPosition(target: _initialCameraPosition!, zoom: 13),
                      onMapCreated: _onMapCreated,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(
                          Icons.arrow_back_ios,
                          size: 25,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 5,
                child: Scaffold(
                  resizeToAvoidBottomInset: false,
                  body: GestureDetector(
                    onTap: () {
                      FocusScope.of(context).requestFocus(new FocusNode());
                    },
                    child: Form(
                      key: formKey,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  Prediction? p = await PlacesAutocomplete.show(
                                    context: context,
                                    mode: Mode.overlay,
                                    apiKey: Preferences.map_key,
                                    offset: 0,
                                    radius: 1000,
                                    types: [],
                                    strictbounds: false,
                                    components: [],
                                  );
                                  displayPrediction(p);
                                  setState(
                                    () {
                                      address = '${p!.description}';
                                      _textFullAddress.text = address;
                                    },
                                  );
                                },
                                child: Container(
                                  alignment: AlignmentDirectional.centerStart,
                                  height: 40,
                                  decoration: BoxDecoration(color: Palette.dark_white, borderRadius: BorderRadius.circular(10)),
                                  child: RichText(
                                    text: TextSpan(
                                      children: [
                                        WidgetSpan(
                                          child: Padding(
                                            padding: EdgeInsets.only(right: 10, left: 10),
                                            child: SvgPicture.asset(
                                              'assets/icons/Map_Search.svg',
                                              width: 15,
                                              color: Palette.blue,
                                              height: 15,
                                            ),
                                          ),
                                        ),
                                        address == "null" || address == ""
                                            ? TextSpan(
                                                text: getTranslated(context, addLocation_searchLocation).toString(),
                                                // 'Search Location',
                                                style: TextStyle(color: Palette.blue, fontWeight: FontWeight.bold, fontSize: 14),
                                              )
                                            : TextSpan(
                                                text: '$address',
                                                style: TextStyle(color: Palette.dark_grey, fontWeight: FontWeight.bold, fontSize: 16),
                                              )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 15),
                                child: Text(
                                  getTranslated(context, addLocation_attachLabel).toString(),
                                  // 'Attach Label',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: Container(
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 10, right: 10, top: 2, bottom: 2),
                                      child: TextFormField(
                                        controller: _textAddressLabel,
                                        textCapitalization: TextCapitalization.words,
                                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9]'))],
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.only(left: 10),
                                          hintText: getTranslated(context, addLocation_attachLabel_hint).toString(),
                                          hintStyle: TextStyle(
                                            fontSize: 16,
                                            color: Palette.dark_grey,
                                          ),
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide.none,
                                          ),
                                          filled: true,
                                          fillColor: Palette.white,
                                        ),
                                        validator: (String? value) {
                                          if (value!.isEmpty) {
                                            return getTranslated(context, addLocation_attachLabel_validator).toString();
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: Text(
                                  getTranslated(context, addLocation_address).toString(),
                                  // 'House No./Flat No./Floor/Building',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: Container(
                                  height: 100,
                                  child: Card(
                                    elevation: 3,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: TextFormField(
                                        controller: _textFullAddress,
                                        keyboardType: TextInputType.text,
                                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9,]'))],
                                        decoration: InputDecoration(
                                            contentPadding: EdgeInsets.only(left: 10),
                                            hintText: getTranslated(context, addLocation_address_hint).toString(),
                                            border: InputBorder.none),
                                        maxLines: 3,
                                        style: TextStyle(fontSize: 16, color: Palette.dark_grey),
                                        validator: (String? value) {
                                          if (value!.isEmpty) {
                                            return getTranslated(context, addLocation_address_validator).toString();
                                            // "Please Select Address";
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 20),
                                child: Container(
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      if (formKey.currentState!.validate()) {
                                        if (selectLat != 0.0 && selectLang != 0.0) {
                                          callApiAddAddress();
                                        } else {
                                          Fluttertoast.showToast(
                                            msg: "Please Search Address & Select",
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.BOTTOM,
                                            backgroundColor: Palette.blue,
                                            textColor: Palette.white,
                                          );
                                        }
                                      }
                                    },
                                    style: ButtonStyle(
                                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15.0),
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      getTranslated(context, addLocation_addAddress_button).toString(),
                                      // 'Add Address'
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<Null> displayPrediction(Prediction? p) async {
    if (p != null) {
      GoogleMapsPlaces _places = GoogleMapsPlaces(
        apiKey: Preferences.map_key,
        apiHeaders: await GoogleApiHeaders().getHeaders(),
      );

      PlacesDetailsResponse detail = await _places.getDetailsByPlaceId(p.placeId!);

      double lat = detail.result.geometry!.location.lat;
      double lng = detail.result.geometry!.location.lng;

      selectLang = double.parse('$lng');
      selectLat = double.parse('$lat');

      setState(() {
        _controller!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: LatLng(selectLat, selectLang), zoom: 18),
          ),
        );
        _initialCameraPosition = LatLng(selectLat, selectLang);
        _createMarker();
      });
    }
  }

  Future<BaseModel<AddAddress>> callApiAddAddress() async {
    AddAddress response;
    Map<String, dynamic> body = {
      "address": _textFullAddress.text,
      "label": _textAddressLabel.text,
      "lat": '$selectLat',
      "lang": '$selectLang',
    };
    try {
      response = await RestClient(RetroApi().dioData()).addAddressRequest(body);
      if (response.success == true) {
        setState(
          () {
            Fluttertoast.showToast(
              msg: getTranslated(context, addLocation_successFullyAddAddress_toast).toString(),
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Palette.blue,
              textColor: Palette.white,
            );
            Navigator.pushReplacementNamed(context, "ShowLocation");
          },
        );
      }
    } catch (error, stacktrace) {
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }
}
