import 'package:doctro/AddLocation.dart';
import 'package:doctro/api/Retrofit_Api.dart';
import 'package:doctro/api/network_api.dart';
import 'package:doctro/model/ShowAddress.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:location/location.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/form_helper.dart';
import 'api/base_model.dart';
import 'api/server_error.dart';
import 'const/Palette.dart';
import 'const/app_string.dart';
import 'localization/localization_constant.dart';
import 'model/DeleteAddress.dart';

class ShowLocation extends StatefulWidget {
  @override
  _ShowLocationState createState() => _ShowLocationState();
}

class _ShowLocationState extends State<ShowLocation> {
  List<Data> showAddress = [];

  bool loading = false;

  int id = 0;

  String? _address = "";
  String? _lat = "";
  String? _lang = "";
  int? _addressId;
  int? addressId = 0;

  String? isWhere = "";

  late LocationData _locationData;
  Location location = new Location();

  double currentLat = 0.0;
  double currentLong = 0.0;

  @override
  void initState() {
    super.initState();
    callApiShowAddress();
    getIsWhere();
  }

  _passAddress(selectAddress, selectLat, selectLang) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _address = selectAddress;
      _lat = selectLat;
      _lang = selectLang;
      _addressId = addressId;
      prefs.setString('Address', _address!);
      prefs.setString('lat', _lat!);
      prefs.setString('lang', _lang!);
      prefs.setInt('addressId', _addressId!);
    });
  }

  getIsWhere() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isWhere = prefs.getString('isWhere');
    });
    _locationData = await location.getLocation();
    currentLat = _locationData.latitude!;
    currentLong = _locationData.longitude!;
  }

  @override
  Widget build(BuildContext context) {
    double width;
    double height;

    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(width * 0.3, height * 0.06),
        child: SafeArea(
          top: true,
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            child: Icon(
                              Icons.arrow_back_ios,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        child: Text(
                          getTranslated(context, showLocation_title).toString(),
                          style: TextStyle(fontSize: width * 0.045, fontWeight: FontWeight.bold, color: Palette.dark_blue),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddLocation(currentLong: currentLong, currentLat: currentLat),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            child: Text(
                              '+ ' + getTranslated(context, showLocation_addAddress).toString(),
                              style: TextStyle(fontSize: width * 0.035, color: Palette.blue),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: ModalProgressHUD(
        inAsyncCall: loading,
        opacity: 0.5,
        progressIndicator: SpinKitFadingCircle(
          color: Palette.blue,
          size: 50.0,
        ),
        child: Container(
          height: height * 1,
          color: Palette.dark_white,
          child: showAddress.length != 0
              ? ListView(
                  scrollDirection: Axis.vertical,
                  children: [
                    ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: showAddress.length,
                      itemBuilder: (context, index) {
                        addressId = showAddress[index].id;
                        return InkWell(
                          onTap: () {
                            setState(
                              () {
                                if (isWhere == "Home") {
                                  _passAddress(showAddress[index].address, showAddress[index].lat, showAddress[index].lang);
                                  Navigator.pushReplacementNamed(context, "Home");
                                } else if (isWhere == "MedicinePayment") {
                                  _passAddress(showAddress[index].address, showAddress[index].lat, showAddress[index].lang);
                                  Navigator.pushReplacementNamed(context, "MedicinePayment");
                                }
                              },
                            );
                          },
                          child: Container(
                            margin: EdgeInsets.only(top: 10),
                            child: Column(
                              children: [
                                Container(
                                  margin: EdgeInsets.only(left: 50, right: 50),
                                  alignment: AlignmentDirectional.topStart,
                                  child: showAddress[index].label != null
                                      ? Text(
                                          showAddress[index].label!,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Palette.blue,
                                          ),
                                        )
                                      : Text(
                                          getTranslated(context, showLocation_label).toString(),
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Palette.blue,
                                          ),
                                        ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(left: 15, top: 5, right: 15),
                                  child: Row(
                                    children: [
                                      Container(
                                        child: Icon(
                                          Icons.location_on_outlined,
                                          size: 25,
                                          color: Palette.blue,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                        child: Container(
                                          width: width * 0.8,
                                          child: Text(
                                            showAddress[index].address!,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.justify,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Palette.dark_grey,
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(top: 0, left: 50, right: 50),
                                  alignment: AlignmentDirectional.topStart,
                                  child: GestureDetector(
                                    onTap: () {
                                      FormHelper.showMessage(
                                        context,
                                        getTranslated(context, showLocation_removeAddress_alert_title).toString(),
                                        getTranslated(context, showLocation_removeAddress_alert_text).toString(),
                                        getTranslated(context, No).toString(),
                                        () {
                                          Navigator.of(context).pop();
                                        },
                                        buttonText2: getTranslated(context, Yes).toString(),
                                        isConfirmationDialog: true,
                                        onPressed2: () {
                                          callApiForDeleteAddress(showAddress[index].id);
                                          Navigator.of(context).pop();
                                        },
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 5),
                                      child: Text(
                                        getTranslated(context, showLocation_removeAddress).toString(),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Palette.red,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.all(15),
                                  child: DottedLine(
                                    direction: Axis.horizontal,
                                    lineLength: double.infinity,
                                    lineThickness: 1.0,
                                    dashLength: 4.0,
                                    dashColor: Palette.blue,
                                    dashRadius: 0.0,
                                    dashGapLength: 4.0,
                                    dashGapColor: Palette.transparent,
                                    dashGapRadius: 0.0,
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                )
              : Container(
                  width: width,
                  child: Center(
                    child: Text(
                      getTranslated(context, showLocation_noAddress).toString(),
                      style: TextStyle(
                        fontSize: width * 0.04,
                        color: Palette.dark_blue,
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Future<BaseModel<ShowAddress>> callApiShowAddress() async {
    ShowAddress response;
    setState(() {
      loading = true;
    });
    try {
      response = await RestClient(RetroApi().dioData()).showAddressRequest();
      showAddress.clear();
      if (response.success == true) {
        setState(() {
          loading = false;
          showAddress.addAll(response.data!);
        });
      }
    } catch (error, stacktrace) {
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<DeleteAddress>> callApiForDeleteAddress(addressId) async {
    DeleteAddress response;
    setState(() {
      loading = true;
    });
    try {
      response = await RestClient(RetroApi().dioData()).deleteAddressRequest(addressId);
      if (response.success == true) {
        setState(() {
          loading = false;
          Fluttertoast.showToast(
            msg: response.msg!,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Palette.blue,
            textColor: Palette.white,
          );
          callApiShowAddress();
        });
      }
    } catch (error, stacktrace) {
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }
}
