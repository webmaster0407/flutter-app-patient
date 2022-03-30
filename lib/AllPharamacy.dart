import 'package:cached_network_image/cached_network_image.dart';
import 'package:doctro/PharamacyDetail.dart';
import 'package:doctro/api/Retrofit_Api.dart';
import 'package:doctro/api/network_api.dart';
import 'package:doctro/const/app_string.dart';
import 'package:doctro/model/pharamacies.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api/base_model.dart';
import 'api/server_error.dart';
import 'const/Palette.dart';
import 'localization/localization_constant.dart';
import 'model/pharamacies.dart';

class AllPharamacy extends StatefulWidget {
  @override
  _AllPharamacyState createState() => _AllPharamacyState();
}

class _AllPharamacyState extends State<AllPharamacy> {
  bool loading = false;
  String? address = "";

  List<Data> pharamacy = [];

  TextEditingController _search = TextEditingController();
  List<Data> _searchResult = [];

  @override
  void initState() {
    super.initState();
    _getAddress();
    callApiPharamacy();
  }

  _getAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(
      () {
        address = (prefs.getString('Address'));
      },
    );
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
                                child: address == null || address == ""
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
                                        '$address',
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
                        textAlign: TextAlign.left,
                        textCapitalization: TextCapitalization.words,
                        onChanged: onSearchTextChanged,
                        decoration: InputDecoration(
                          hintText: getTranslated(context, allPharamacy_searchPharamacy).toString(),
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
      body: ModalProgressHUD(
        inAsyncCall: loading,
        opacity: 0.5,
        progressIndicator: SpinKitFadingCircle(
          color: Palette.blue,
          size: 50.0,
        ),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: _searchResult.length > 0 || _search.text.isNotEmpty
              ? _searchResult.length != 0
                  ? ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: _searchResult.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                          child: Container(
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 100,
                                      height: 100,
                                      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                                      child: Card(
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
                                    ),
                                    Container(
                                      width: 250,
                                      // height: 80,
                                      child: Column(
                                        children: [
                                          Container(
                                            alignment: AlignmentDirectional.topStart,
                                            margin: EdgeInsets.only(top: 0, left: 5),
                                            child: Text(
                                              _searchResult[index].name!,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: width * 0.04,
                                                fontWeight: FontWeight.bold,
                                                color: Palette.dark_blue,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            alignment: AlignmentDirectional.topStart,
                                            margin: EdgeInsets.only(top: 5),
                                            child: Row(
                                              children: [
                                                Container(
                                                  child: Icon(
                                                    Icons.location_on,
                                                    size: 20,
                                                    color: Palette.dark_grey1,
                                                  ),
                                                ),
                                                Container(
                                                  width: 220,
                                                  child: Text(
                                                    _searchResult[index].address!,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: width * 0.035,
                                                      fontWeight: FontWeight.bold,
                                                      color: Palette.dark_grey1,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            child: GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => PharamacyDetail(id: _searchResult[index].id),
                                                  ),
                                                );
                                              },
                                              child: Container(
                                                child: Card(
                                                  color: Palette.blue,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(20),
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                                                    child: Text(
                                                      getTranslated(context, allPharamacy_book_button).toString(),
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.bold,
                                                        color: Palette.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                                Container(
                                  margin: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                                  child: Column(
                                    children: [
                                      DottedLine(
                                        direction: Axis.horizontal,
                                        lineLength: double.infinity,
                                        lineThickness: 1.0,
                                        dashLength: 4.0,
                                        dashColor: Palette.blue,
                                        dashRadius: 0.0,
                                        dashGapLength: 4.0,
                                        dashGapColor: Palette.transparent,
                                        dashGapRadius: 0.0,
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  : Container(
                      alignment: AlignmentDirectional.center,
                      child: Text(
                        getTranslated(context, allPharamacy_pharmacyNotFound).toString(),
                        style: TextStyle(fontSize: width * 0.04, color: Palette.grey, fontWeight: FontWeight.bold),
                      ),
                    )
              : pharamacy.length != 0
                  ? ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: pharamacy.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                          child: Container(
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 100,
                                      height: 100,
                                      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                                      child: Card(
                                        child: CachedNetworkImage(
                                          alignment: Alignment.center,
                                          imageUrl: pharamacy[index].fullImage!,
                                          fit: BoxFit.fill,
                                          placeholder: (context, url) => SpinKitFadingCircle(
                                            color: Palette.blue,
                                          ),
                                          errorWidget: (context, url, error) => Image.asset("assets/images/no_image.jpg"),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: 250,
                                      child: Column(
                                        children: [
                                          Container(
                                            alignment: AlignmentDirectional.topStart,
                                            margin: EdgeInsets.only(top: 0, left: 5),
                                            child: Text(
                                              pharamacy[index].name!,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: width * 0.04,
                                                fontWeight: FontWeight.bold,
                                                color: Palette.dark_blue,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            alignment: AlignmentDirectional.topStart,
                                            margin: EdgeInsets.only(top: 5),
                                            child: Row(
                                              children: [
                                                Container(
                                                  child: Icon(
                                                    Icons.location_on,
                                                    size: 20,
                                                    color: Palette.dark_grey1,
                                                  ),
                                                ),
                                                Container(
                                                  width: 220,
                                                  child: Text(
                                                    pharamacy[index].address!,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: width * 0.035,
                                                      fontWeight: FontWeight.bold,
                                                      color: Palette.dark_grey1,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            alignment: AlignmentDirectional.centerEnd,
                                            child: GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => PharamacyDetail(id: pharamacy[index].id),
                                                  ),
                                                );
                                              },
                                              child: Container(
                                                child: Card(
                                                  color: Palette.blue,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(20),
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                                                    child: Text(
                                                      'Book',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.bold,
                                                        color: Palette.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                                Container(
                                  margin: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                                  child: Column(
                                    children: [
                                      DottedLine(
                                        direction: Axis.horizontal,
                                        lineLength: double.infinity,
                                        lineThickness: 1.0,
                                        dashLength: 4.0,
                                        dashColor: Palette.blue,
                                        dashRadius: 0.0,
                                        dashGapLength: 4.0,
                                        dashGapColor: Palette.transparent,
                                        dashGapRadius: 0.0,
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  : Container(
                      alignment: AlignmentDirectional.center,
                      child: Text(
                        getTranslated(context, allPharamacy_pharmacyNotFound).toString(),
                        style: TextStyle(fontSize: width * 0.04, color: Palette.grey, fontWeight: FontWeight.bold),
                      ),
                    ),
        ),
      ),
    );
  }

  Future<BaseModel<Pharamacy>> callApiPharamacy() async {
    Pharamacy response;

    setState(() {
      loading = true;
    });
    try {
      response = await RestClient(RetroApi2().dioData2()).pharamacyRequest();
      setState(() {
        if (response.success == true) {
          loading = false;
          pharamacy.addAll(response.data!);
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

    pharamacy.forEach((appointmentData) {
      if (appointmentData.name!.toLowerCase().contains(text.toLowerCase())) _searchResult.add(appointmentData);
    });

    setState(() {});
  }
}
