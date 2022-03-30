import 'package:cached_network_image/cached_network_image.dart';
import 'package:doctro/api/Retrofit_Api.dart';
import 'package:doctro/api/network_api.dart';
import 'package:doctro/const/app_string.dart';
import 'package:doctro/const/preference.dart';
import 'package:doctro/doctordetail.dart';
import 'package:doctro/model/doctors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api/base_model.dart';
import 'api/server_error.dart';
import 'const/Palette.dart';
import 'const/prefConstatnt.dart';
import 'localization/localization_constant.dart';
import 'model/FavoriteDoctor.dart';

class Specialist extends StatefulWidget {
  @override
  _SpecialistState createState() => _SpecialistState();
}

class _SpecialistState extends State<Specialist> {
  bool loading = false;
  String? _address = "";
  String? _lat = "";
  String? _lang = "";

  List<DoctorModel> doctorList = [];

  List<bool> favoriteDoctor = [];
  List<bool> searchFavoriteDoctor = [];
  int? doctorID = 0;

  TextEditingController _search = TextEditingController();
  List<DoctorModel> _searchResult = [];

  @override
  void initState() {
    super.initState();
    _getAddress();
  }

  _getAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(
      () {
        _address = (prefs.getString('Address'));
        _lat = (prefs.getString('lat'));
        _lang = (prefs.getString('lang'));
      },
    );
    callApiDoctorList();
  }

  @override
  Widget build(BuildContext context) {
    double width;
    double height;
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(width, 110),
        child: SafeArea(
          top: true,
          child: Container(
            child: Column(
              children: [
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: height * 0.01, left: width * 0.03, right: width * 0.03),
                            height: height * 0.03,
                            width: width * 0.05,
                            child: SvgPicture.asset(
                              'assets/icons/location.svg',
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                width: width * 0.3,
                                margin: EdgeInsets.only(top: height * 0.01, left: width * 0.03, right: width * 0.03),
                                child: _address == null || _address == ""
                                    ? Text(
                                        getTranslated(context, selectAddress).toString(),
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: width * 0.04,
                                          fontWeight: FontWeight.bold,
                                          color: Palette.dark_blue,
                                        ),
                                      )
                                    : Text(
                                        '$_address',
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: width * 0.04,
                                          fontWeight: FontWeight.bold,
                                          color: Palette.dark_blue,
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        margin: EdgeInsets.only(top: height * 0.01, right: width * 0.02, left: width * 0.02),
                        child: GestureDetector(
                          child: Icon(
                            Icons.arrow_back_ios,
                            size: 25,
                          ),
                          onTap: () {
                            Navigator.pushNamed(context, 'Home');
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: width * 0.05, right: width * 0.05, top: 10),
                  child: Card(
                    color: Palette.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Container(
                      width: width * 1,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                      child: TextField(
                        textCapitalization: TextCapitalization.words,
                        onChanged: onSearchTextChanged,
                        decoration: InputDecoration(
                          hintText: getTranslated(context, specialist_searchDoctor_hint).toString(),
                          hintStyle: TextStyle(
                            fontSize: width * 0.04,
                            color: Palette.dark_blue,
                          ),
                          suffixIcon: Padding(
                            padding: const EdgeInsets.all(12),
                            child: SvgPicture.asset(
                              'assets/icons/SearchIcon.svg',
                              height: 15,
                              width: 15,
                            ),
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: callApiDoctorList,
        child: ModalProgressHUD(
          child: _searchResult.length > 0 || _search.text.isNotEmpty
              ? _searchResult.length != 0
                  ? Container(
                      child: ListView(
                        scrollDirection: Axis.vertical,
                        children: [
                          GridView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: _searchResult.length,
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 5, childAspectRatio: 0.9),
                            itemBuilder: (context, index) {
                              favoriteDoctor.clear();
                              for (int i = 0; i < _searchResult.length; i++) {
                                _searchResult[i].isFaviroute == false ? favoriteDoctor.add(false) : favoriteDoctor.add(true);
                              }
                              return Column(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => DoctorDetail(
                                            id: _searchResult[index].id,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      width: width * 0.45,
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10.0),
                                        ),
                                        child: Container(
                                          margin: EdgeInsets.all(width * 0.02),
                                          child: Column(
                                            children: [
                                              Stack(
                                                children: [
                                                  Container(
                                                    width: width * 0.4,
                                                    height: width * 0.35,
                                                    child: ClipRRect(
                                                      borderRadius: BorderRadius.all(
                                                        Radius.circular(10),
                                                      ),
                                                      child: CachedNetworkImage(
                                                        alignment: Alignment.center,
                                                        imageUrl: _searchResult[index].fullImage!,
                                                        fit: BoxFit.fitHeight,
                                                        placeholder: (context, url) => SpinKitFadingCircle(color: Palette.blue),
                                                        errorWidget: (context, url, error) => Image.asset("assets/images/no_image.jpg"),
                                                      ),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    top: 0,
                                                    right: 0,
                                                    child: Container(
                                                      child: SharedPreferenceHelper.getBoolean(Preferences.is_logged_in) == true
                                                          ? IconButton(
                                                              onPressed: () {
                                                                setState(
                                                                  () {
                                                                    favoriteDoctor[index] == false
                                                                        ? favoriteDoctor[index] = true
                                                                        : favoriteDoctor[index] = false;
                                                                    doctorID = doctorList[index].id;
                                                                    callApiFavoriteDoctor();
                                                                  },
                                                                );
                                                              },
                                                              icon: Icon(
                                                                Icons.favorite_outlined,
                                                                size: 25,
                                                                color: favoriteDoctor[index] == false ? Palette.white : Palette.red,
                                                              ),
                                                            )
                                                          : IconButton(
                                                              onPressed: () {
                                                                setState(
                                                                  () {
                                                                    Fluttertoast.showToast(
                                                                      msg: getTranslated(context, specialist_pleaseLogin_toast).toString(),
                                                                      toastLength: Toast.LENGTH_SHORT,
                                                                      gravity: ToastGravity.BOTTOM,
                                                                      backgroundColor: Palette.blue,
                                                                      textColor: Palette.white,
                                                                    );
                                                                  },
                                                                );
                                                              },
                                                              icon: Icon(
                                                                Icons.favorite_outlined,
                                                                size: 25,
                                                                color: favoriteDoctor[index] == false ? Palette.white : Palette.red,
                                                              ),
                                                            ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Container(
                                                margin: EdgeInsets.only(top: width * 0.02),
                                                child: Column(
                                                  children: [
                                                    Text(
                                                      _searchResult[index].name!,
                                                      style: TextStyle(fontSize: width * 0.04, color: Palette.dark_blue),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                child: _searchResult[index].treatment != null
                                                    ? Text(
                                                        _searchResult[index].treatment!.name.toString(),
                                                        style: TextStyle(fontSize: width * 0.035, color: Palette.grey),
                                                      )
                                                    : Text(
                                                        getTranslated(context, specialist_notAvailable).toString(),
                                                        style: TextStyle(fontSize: width * 0.035, color: Palette.grey),
                                                      ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              );
                            },
                          )
                        ],
                      ),
                    )
                  : Container(
                      alignment: AlignmentDirectional.center,
                      child: Text(
                        getTranslated(context, specialist_doctorNotFound).toString(),
                        style: TextStyle(fontSize: width * 0.04, color: Palette.grey, fontWeight: FontWeight.bold),
                      ),
                    )
              : doctorList.length != 0
                  ? Container(
                      child: ListView(
                        scrollDirection: Axis.vertical,
                        children: [
                          GridView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: doctorList.length,
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 5, childAspectRatio: 0.9),
                            itemBuilder: (context, index) {
                              favoriteDoctor.clear();
                              for (int i = 0; i < doctorList.length; i++) {
                                doctorList[i].isFaviroute == false ? favoriteDoctor.add(false) : favoriteDoctor.add(true);
                              }
                              return Column(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => DoctorDetail(
                                            id: doctorList[index].id,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      width: width * 0.45,
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10.0),
                                        ),
                                        child: Container(
                                          margin: EdgeInsets.symmetric(vertical: width * 0.02, horizontal: width * 0.02),
                                          child: Column(
                                            children: [
                                              Stack(
                                                children: [
                                                  Container(
                                                    width: width * 0.4,
                                                    height: width * 0.35,
                                                    child: ClipRRect(
                                                      borderRadius: BorderRadius.all(Radius.circular(10)),
                                                      child: CachedNetworkImage(
                                                        alignment: Alignment.center,
                                                        imageUrl: doctorList[index].fullImage!,
                                                        fit: BoxFit.fitHeight,
                                                        placeholder: (context, url) => SpinKitFadingCircle(color: Palette.blue),
                                                        errorWidget: (context, url, error) => Image.asset("assets/images/no_image.jpg"),
                                                      ),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    top: 0,
                                                    right: 0,
                                                    child: Container(
                                                      child: SharedPreferenceHelper.getBoolean(Preferences.is_logged_in) == true
                                                          ? IconButton(
                                                              onPressed: () {
                                                                setState(
                                                                  () {
                                                                    favoriteDoctor[index] == false
                                                                        ? favoriteDoctor[index] = true
                                                                        : favoriteDoctor[index] = false;
                                                                    doctorID = doctorList[index].id;
                                                                    callApiFavoriteDoctor();
                                                                  },
                                                                );
                                                              },
                                                              icon: Icon(
                                                                Icons.favorite_outlined,
                                                                size: 25,
                                                                color: favoriteDoctor[index] == false ? Palette.white : Palette.red,
                                                              ),
                                                            )
                                                          : IconButton(
                                                              onPressed: () {
                                                                setState(
                                                                  () {
                                                                    Fluttertoast.showToast(
                                                                      msg: getTranslated(context, specialist_pleaseLogin_toast).toString(),
                                                                      toastLength: Toast.LENGTH_SHORT,
                                                                      gravity: ToastGravity.BOTTOM,
                                                                      backgroundColor: Palette.blue,
                                                                      textColor: Palette.white,
                                                                    );
                                                                  },
                                                                );
                                                              },
                                                              icon: Icon(
                                                                Icons.favorite_outlined,
                                                                size: 25,
                                                                color: favoriteDoctor[index] == false ? Palette.white : Palette.red,
                                                              ),
                                                            ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Container(
                                                margin: EdgeInsets.only(top: width * 0.02),
                                                child: Column(
                                                  children: [
                                                    Text(
                                                      doctorList[index].name!,
                                                      style: TextStyle(fontSize: width * 0.04, color: Palette.dark_blue),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                child: doctorList[index].treatment != null
                                                    ? Text(
                                                        doctorList[index].treatment!.name.toString(),
                                                        style: TextStyle(fontSize: width * 0.035, color: Palette.grey),
                                                      )
                                                    : Text(
                                                        getTranslated(context, specialist_notAvailable).toString(),
                                                        style: TextStyle(fontSize: width * 0.035, color: Palette.grey),
                                                      ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              );
                            },
                          )
                        ],
                      ),
                    )
                  : Container(
                      alignment: AlignmentDirectional.center,
                      child: Text(
                        getTranslated(context, specialist_doctorNotFound).toString(),
                        style: TextStyle(fontSize: width * 0.04, color: Palette.grey, fontWeight: FontWeight.bold),
                      ),
                    ),
          inAsyncCall: loading,
          opacity: 0.5,
          progressIndicator: SpinKitFadingCircle(
            color: Palette.blue,
            size: 50.0,
          ),
        ),
      ),
    );
  }

  Future<BaseModel<Doctors>> callApiDoctorList() async {
    Doctors response;
    Map<String, dynamic> body = {
      "lat": _lat,
      "lang": _lang,
    };
    setState(() {
      loading = true;
    });
    try {
      SharedPreferenceHelper.getBoolean(Preferences.is_logged_in) == true
          ? response = await RestClient(RetroApi().dioData()).doctorList(body)
          : response = await RestClient(RetroApi2().dioData2()).doctorList(body);
      setState(() {
        if (response.success == true) {
          setState(() {
            doctorList.clear();
            loading = false;
            doctorList.addAll(response.data!);
          });
        }
      });
    } catch (error, stacktrace) {
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<FavoriteDoctor>> callApiFavoriteDoctor() async {
    FavoriteDoctor response;
    setState(() {
      loading = true;
    });
    try {
      response = await RestClient(RetroApi().dioData()).favoriteDoctorRequest(doctorID);
      setState(() {
        if (response.success == true) {
          setState(
            () {
              loading = false;
              Fluttertoast.showToast(
                msg: '${response.msg}',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Palette.blue,
                textColor: Palette.white,
              );
              doctorList.clear();
              callApiDoctorList();
            },
          );
        }
      });
    } catch (error, stacktrace) {
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  onSearchTextChanged(String text) async {
    _searchResult.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }

    doctorList.forEach((appointmentData) {
      if (appointmentData.name!.toLowerCase().contains(text.toLowerCase())) _searchResult.add(appointmentData);
    });

    setState(() {});
  }
}
