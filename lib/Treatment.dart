import 'package:cached_network_image/cached_network_image.dart';
import 'package:doctro/api/Retrofit_Api.dart';
import 'package:doctro/api/network_api.dart';
import 'package:doctro/model/Treatments.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'TreatmentSpecialist.dart';
import 'api/base_model.dart';
import 'api/server_error.dart';
import 'const/Palette.dart';
import 'const/app_string.dart';
import 'localization/localization_constant.dart';

class Treatment extends StatefulWidget {
  @override
  _TreatmentState createState() => _TreatmentState();
}

class _TreatmentState extends State<Treatment> {
  List<TreatmentData> treatmentList = [];

  bool loading = false;

  String? _address = "";

  TextEditingController _search = TextEditingController();
  List<TreatmentData> _searchResult = [];

  @override
  void initState() {
    super.initState();
    callApiTreatment();
    _getAddress();
  }

  _getAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(
      () {
        _address = (prefs.getString('Address'));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double width;
    double height;
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    final size = MediaQuery.of(context).size;
    return ModalProgressHUD(
      inAsyncCall: loading,
      opacity: 0.5,
      progressIndicator: SpinKitFadingCircle(
        color: Palette.blue,
        size: 50.0,
      ),
      child: Scaffold(
        appBar:
        PreferredSize(
          preferredSize: Size(width * 0.3, size.height * 0.125),
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
                              margin: EdgeInsets.only(top: height * 0.005, left: width * 0.03, right: width * 0.03),
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
                                  margin: EdgeInsets.only(top: height * 0.005, left: width * 0.03, right: width * 0.03),
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
                          child: GestureDetector(
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Icon(
                                Icons.arrow_back_ios,
                                size: 25,
                              ),
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
                              controller: _search,
                              textCapitalization: TextCapitalization.words,
                              onChanged: onSearchTextChanged,
                              decoration: InputDecoration(
                                hintText: getTranslated(context, treatment_searchTreatment).toString(),
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
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: _searchResult.length > 0 || _search.text.isNotEmpty
              ? _searchResult.length != 0
                  ?
          SingleChildScrollView(
                      child: ListView.builder(
                        itemCount: _searchResult.length,
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => TreatmentSpecialist(
                                          id: _searchResult[index].id,
                                        ),
                                      ),
                                    );
                                  },
                                  child: ListTile(
                                    title: Row(
                                      children: [
                                        Container(
                                          width: 50,
                                          height: 40,
                                          alignment: AlignmentDirectional.center,
                                          child: CachedNetworkImage(
                                            alignment: Alignment.center,
                                            imageUrl: _searchResult[index].fullImage!,
                                            fit: BoxFit.fill,
                                            placeholder: (context, url) => SpinKitFadingCircle(
                                              color: Palette.blue,
                                            ),
                                            errorWidget: (context, url, error) => Image.asset("assets/images/no_image.jpg"),
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.symmetric(horizontal: width * 0.05),
                                          child: Text(
                                            _searchResult[index].name!,
                                            style: TextStyle(
                                              fontSize: width * 0.045,
                                              color: Palette.dark_grey,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                child: Column(
                                  children: [
                                    DottedLine(
                                      direction: Axis.horizontal,
                                      lineLength: double.infinity,
                                      lineThickness: 1.0,
                                      dashLength: 2.0,
                                      dashColor: Palette.blue,
                                      dashRadius: 1.0,
                                      dashGapLength: 3.0,
                                      dashGapColor: Palette.transparent,
                                      dashGapRadius: 0.0,
                                    )
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    )
                  :
          Container(
                      alignment: AlignmentDirectional.center,
                      child: Text(
                        getTranslated(context, treatment_notFound).toString(),
                        style: TextStyle(fontSize: width * 0.04, color: Palette.dark_blue),
                      ),
                    )
              : treatmentList.length != 0
                  ?
          ListView.builder(
            itemCount: treatmentList.length,
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            itemBuilder: (context, index) {


              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TreatmentSpecialist(
                              id: treatmentList[index].id,
                            ),
                          ),
                        );
                      },
                      child:
                      ListTile(
                        title: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 40,
                              alignment: AlignmentDirectional.center,
                              child: CachedNetworkImage(
                                alignment: Alignment.center,
                                imageUrl: treatmentList[index].fullImage!,
                                fit: BoxFit.fill,
                                placeholder: (context, url) => SpinKitFadingCircle(
                                  color: Palette.blue,
                                ),
                                errorWidget: (context, url, error) => Image.asset("assets/images/no_image.jpg"),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: width * 0.05),
                              child: Text(
                                treatmentList[index].name!,
                                style: TextStyle(
                                  fontSize: width * 0.045,
                                  color: Palette.dark_grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    child: Column(
                      children: [
                        DottedLine(
                          direction: Axis.horizontal,
                          lineLength: double.infinity,
                          lineThickness: 1.0,
                          dashLength: 2.0,
                          dashColor: Palette.blue,
                          dashRadius: 1.0,
                          dashGapLength: 3.0,
                          dashGapColor: Palette.transparent,
                          dashGapRadius: 0.0,
                        )
                      ],
                    ),
                  ),
                ],
              );
            },
          )
                  : Container(
                      alignment: AlignmentDirectional.center,
                      child: Text(
                        getTranslated(context, treatment_notFound).toString(),
                        style: TextStyle(fontSize: width * 0.04, color: Palette.dark_blue),
                      ),
                    ),
        ),
      ),
    );
  }

  Future<BaseModel<Treatments>> callApiTreatment() async {
    Treatments response;
    setState(() {
      loading = true;
    });
    try {
      response = await RestClient(RetroApi2().dioData2()).treatmentsRequest();
      setState(() {
        if (response.success == true) {
          setState(() {
            loading = false;
            treatmentList.addAll(response.data!);
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

    treatmentList.forEach((appointmentData) {
      if (appointmentData.name!.toLowerCase().contains(text.toLowerCase())) _searchResult.add(appointmentData);
    });

    setState(() {});
  }
}
