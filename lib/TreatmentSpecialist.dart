import 'package:cached_network_image/cached_network_image.dart';
import 'package:doctro/api/Retrofit_Api.dart';
import 'package:doctro/api/network_api.dart';
import 'package:doctro/const/app_string.dart';
import 'package:doctro/model/TreatmentWishDoctor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api/base_model.dart';
import 'api/server_error.dart';
import 'const/Palette.dart';
import 'doctordetail.dart';
import 'localization/localization_constant.dart';

class TreatmentSpecialist extends StatefulWidget {
  final int? id;

  TreatmentSpecialist({this.id});

  @override
  _TreatmentSpecialistState createState() => _TreatmentSpecialistState();
}

class _TreatmentSpecialistState extends State<TreatmentSpecialist> {
  bool loading = false;
  String? _address = "";
  String? _lat = "";
  String? _lang = "";

  int? id = 0;
  List<Data> treatmentSpecialistList = [];
  String treatmentName = "";
  String? treatmentSpecialist = "";

  TextEditingController _search = TextEditingController();
  List<Data> _searchResult = [];

  @override
  void initState() {
    super.initState();
    _getAddress();
    id = widget.id;
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
    callApiTreatmentWishDoctor();
  }

  @override
  Widget build(BuildContext context) {
    double width;
    double height;
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(width * 0.3, size.height * 0.12),
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
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: width * 0.05, right: width * 0.05, top: height * 0.005),
                  child: Column(
                    children: [
                      Card(
                        color: Palette.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Container(
                          height: height * 0.06,
                          width: width * 1,
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                          child: TextField(
                            textCapitalization: TextCapitalization.words,
                            controller: _search,
                            onChanged: onSearchTextChanged,
                            decoration: InputDecoration(
                              hintText: getTranslated(context, treatmentSpecialist_searchDoctor_hint).toString(),
                              hintStyle: TextStyle(fontSize: width * 0.04, color: Palette.dark_blue),
                              suffixIcon: Padding(
                                padding: const EdgeInsets.all(12),
                                child: SvgPicture.asset(
                                  'assets/icons/SearchIcon.svg',
                                ),
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
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
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: width,
                color: Palette.dash_line,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                  child: Text(
                    '$treatmentSpecialist' + " " + getTranslated(context, treatmentSpecialist_specialistDoctor).toString(),
                    style: TextStyle(fontSize: width * 0.045, color: Palette.dark_blue, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Container(
                height: height * 0.8,
                margin: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                child: ListView(
                  scrollDirection: Axis.vertical,
                  children: [
                    _searchResult.length > 0 || _search.text.isNotEmpty
                        ? _searchResult.length != 0
                            ? GridView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: _searchResult.length,
                                shrinkWrap: true,
                                scrollDirection: Axis.vertical,
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2, mainAxisSpacing: 5, childAspectRatio: 0.85),
                                itemBuilder: (context, index) {
                                  return _searchResult.length != 0
                                      ? Column(
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
                                                height: width * 0.57,
                                                width: width * 0.47,
                                                child: Card(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(10.0),
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      Column(
                                                        children: [
                                                          Container(
                                                            margin: EdgeInsets.only(top: width * 0.02),
                                                            width: width * 0.4,
                                                            height: width * 0.4,
                                                            child: ClipRRect(
                                                              borderRadius: BorderRadius.all(
                                                                Radius.circular(10),
                                                              ),
                                                              child: CachedNetworkImage(
                                                                alignment: Alignment.center,
                                                                imageUrl: _searchResult[index].fullImage!,
                                                                fit: BoxFit.fill,
                                                                placeholder: (context, url) => SpinKitFadingCircle(color: Palette.blue),
                                                                errorWidget: (context, url, error) =>
                                                                    Image.asset("assets/images/no_image.jpg"),
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
                                                      Column(
                                                        children: [
                                                          _searchResult[index].treatment != null
                                                              ? Text(
                                                                  _searchResult[index].treatment!.name.toString(),
                                                                  style: TextStyle(fontSize: width * 0.035, color: Palette.grey),
                                                                )
                                                              : Text(
                                                                  getTranslated(context, treatmentSpecialist_notAvailable).toString(),
                                                                  style: TextStyle(
                                                                    fontSize: width * 0.035,
                                                                    color: Palette.grey,
                                                                  ),
                                                                ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        )
                                      : Center(
                                          child: Text(
                                            getTranslated(context, treatmentSpecialist_treatmentNotAvailable).toString(),
                                          ),
                                        );
                                },
                              )
                            : Container(
                                alignment: AlignmentDirectional.center,
                                margin: EdgeInsets.only(top: 250),
                                child: Text(
                                  getTranslated(context, treatmentSpecialist_doctorNotFound).toString(),
                                  style: TextStyle(fontSize: width * 0.04, color: Palette.grey, fontWeight: FontWeight.bold),
                                ),
                              )
                        : treatmentSpecialistList.length != 0
                            ? GridView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: treatmentSpecialistList.length,
                                shrinkWrap: true,
                                scrollDirection: Axis.vertical,
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2, mainAxisSpacing: 5, childAspectRatio: 0.85),
                                itemBuilder: (context, index) {
                                  return treatmentSpecialistList.length != 0
                                      ? Column(
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => DoctorDetail(
                                                      id: treatmentSpecialistList[index].id,
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: Container(
                                                height: width * 0.57,
                                                width: width * 0.47,
                                                child: Card(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(10.0),
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      Column(
                                                        children: [
                                                          Container(
                                                            margin: EdgeInsets.only(top: width * 0.02),
                                                            width: width * 0.4,
                                                            height: width * 0.4,
                                                            child: ClipRRect(
                                                              borderRadius: BorderRadius.all(
                                                                Radius.circular(10),
                                                              ),
                                                              child: CachedNetworkImage(
                                                                alignment: Alignment.center,
                                                                imageUrl: treatmentSpecialistList[index].fullImage!,
                                                                fit: BoxFit.fill,
                                                                placeholder: (context, url) => SpinKitFadingCircle(color: Palette.blue),
                                                                errorWidget: (context, url, error) =>
                                                                    Image.asset("assets/images/no_image.jpg"),
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
                                                              treatmentSpecialistList[index].name!,
                                                              style: TextStyle(fontSize: width * 0.04, color: Palette.dark_blue),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Column(
                                                        children: [
                                                          treatmentSpecialistList[index].treatment != null
                                                              ? Text(
                                                                  treatmentSpecialistList[index].treatment!.name.toString(),
                                                                  style: TextStyle(fontSize: width * 0.035, color: Palette.grey),
                                                                )
                                                              : Text(
                                                                  getTranslated(context, treatmentSpecialist_notAvailable).toString(),
                                                                  style: TextStyle(fontSize: width * 0.035, color: Palette.grey),
                                                                ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        )
                                      : Center(
                                          child: Text(
                                            getTranslated(context, treatmentSpecialist_treatmentNotAvailable).toString(),
                                          ),
                                        );
                                },
                              )
                            : Container(
                                alignment: AlignmentDirectional.center,
                                margin: EdgeInsets.only(top: 250),
                                child: Text(
                                  getTranslated(context, treatmentSpecialist_doctorNotFound).toString(),
                                  style: TextStyle(fontSize: width * 0.04, color: Palette.grey, fontWeight: FontWeight.bold),
                                ),
                              ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<BaseModel<TreatmentWishDoctor>> callApiTreatmentWishDoctor() async {
    TreatmentWishDoctor response;
    Map<String, dynamic> body = {
      "lat": _lat,
      "lang": _lang,
    };
    setState(() {
      loading = true;
    });
    try {
      response = await RestClient(RetroApi2().dioData2()).treatmentWishDoctorRequest(id, body);
      setState(() {
        if (response.success == true) {
          setState(() {
            loading = false;
            treatmentSpecialistList.addAll(response.data!);
            for (int i = 0; i < treatmentSpecialistList.length; i++) {
              treatmentSpecialist = treatmentSpecialistList[i].treatment!.name;
            }
          });
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

    treatmentSpecialistList.forEach((appointmentData) {
      if (appointmentData.name!.toLowerCase().contains(text.toLowerCase())) _searchResult.add(appointmentData);
    });

    setState(() {});
  }
}
