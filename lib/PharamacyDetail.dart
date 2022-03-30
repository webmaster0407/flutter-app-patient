import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:doctro/MedicineDescription.dart';
import 'package:doctro/api/Retrofit_Api.dart';
import 'package:doctro/api/network_api.dart';
import 'package:doctro/model/PharamaciesDetails.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api/base_model.dart';
import 'api/server_error.dart';
import 'const/Palette.dart';
import 'const/app_string.dart';
import 'const/prefConstatnt.dart';
import 'const/preference.dart';
import 'localization/localization_constant.dart';

class PharamacyDetail extends StatefulWidget {
  final int? id;

  PharamacyDetail({this.id});

  @override
  _PharamacyDetailState createState() => _PharamacyDetailState();
}

class _PharamacyDetailState extends State<PharamacyDetail> with TickerProviderStateMixin {
  bool loading = false;

  List<Tab> tabList = [];
  TabController? _tabController;

  int? id = 0;
  String? pharamacyImage = "";
  String? pharamacyName = "";
  String? pharamacyPhone = "";
  String? pharamacyEmail = "";
  String? pharamacyDescription = "";
  String? pharamacyStartTime = "";
  String? pharamacyEndTime = "";
  String? pharamacyAddress = "";
  int? isShipping;
  String? pharmacyLat = "";
  String? pharmacyLang = "";

  List<String?> minValue = [];
  List<String?> maxValue = [];
  List<String?> charges = [];

  List<Medicine> medicines = [];

  int? pharamacyId;

  void initState() {
    id = widget.id;
    callApiPharamacyDetail();
    Future.delayed(Duration.zero, () {
      tabList.add(
        new Tab(
          text: getTranslated(context, pharamacy_about).toString(),
        ),
      );
      tabList.add(
        new Tab(
          text: getTranslated(context, pharamacy_product).toString(),
        ),
      );
      _tabController = new TabController(vsync: this, length: tabList.length);
    });
    super.initState();
    _passPharamacyId();
  }

  @override
  void dispose() {
    _tabController!.dispose();
    super.dispose();
  }

  _passPharamacyId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      pharamacyId = id;
      prefs.setInt('pharamacyId', pharamacyId!);
    });
  }

  _passShippingStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setInt('ShippingStatus', isShipping!);
      prefs.setString('pharmacyLat', pharmacyLat!);
      prefs.setString('pharmacyLang', pharmacyLang!);
      prefs.setStringList('minValue', minValue as List<String>);
      prefs.setStringList('maxValue', maxValue as List<String>);
      prefs.setStringList('charges', charges as List<String>);
    });
  }

  @override
  Widget build(BuildContext context) {
    double width;
    double height;
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Palette.white,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            size: 20,
            color: Palette.dark_blue,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              onPressed: () {
                Navigator.pushNamed(context, 'AddToCart');
              },
              icon: (Icon(
                Icons.shopping_cart_outlined,
                color: Palette.blue,
              )),
            ),
          )
        ],
      ),
      body: ModalProgressHUD(
        inAsyncCall: loading,
        opacity: 0.5,
        progressIndicator: SpinKitFadingCircle(
          color: Palette.blue,
          size: 50.0,
        ),
        child: SingleChildScrollView(
          child: Container(
            child: Column(
              children: [
                Container(
                  height: 200,
                  width: width * 1,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Palette.black,
                          image: new DecorationImage(
                            fit: BoxFit.cover,
                            colorFilter: new ColorFilter.mode(Palette.black.withOpacity(0.7), BlendMode.dstATop),
                            image: NetworkImage('$pharamacyImage'),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 120,
                        left: 20,
                        right: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: width * 1,
                              child: Text(
                                '$pharamacyName',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 18, color: Palette.white),
                              ),
                            ),
                            Container(
                              width: width * 1,
                              child: Row(
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(top: 5),
                                    child: Icon(
                                      Icons.phone,
                                      size: 20,
                                      color: Palette.white,
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(left: 5),
                                    child: Text(
                                      ' $pharamacyPhone',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 16, color: Palette.white),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              width: width * 1,
                              child: Row(
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(top: 5),
                                    child: Icon(
                                      Icons.email,
                                      size: 20,
                                      color: Palette.white,
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(left: 5),
                                    child: Text(
                                      ' $pharamacyEmail',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 16, color: Palette.white),
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 50,
                  color: Palette.white,
                  margin: EdgeInsets.only(top: 5),
                  padding: EdgeInsets.all(width * 0.02),
                  child: new TabBar(
                    labelColor: Palette.blue,
                    controller: _tabController,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorColor: Colors.transparent,
                    tabs: tabList,
                    labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    unselectedLabelColor: Palette.dark_grey,
                  ),
                ),
                Container(
                  height: 500,
                  width: width * 1,
                  child: TabBarView(
                    physics: AlwaysScrollableScrollPhysics(),
                    controller: _tabController,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            child: Text(
                              getTranslated(context, pharamacy_about).toString(),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Palette.dark_blue,
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                            child: Html(
                              data: '$pharamacyDescription',
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                            child: Text(
                              getTranslated(context, pharamacy_openingHours).toString(),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Palette.dark_blue,
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    Container(
                                      child: Text(
                                        getTranslated(context, pharamacy_monday_saturday).toString(),
                                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Palette.grey),
                                      ),
                                    ),
                                    Container(
                                      child: Text(
                                        '$pharamacyStartTime' + ' - ' + '$pharamacyEndTime',
                                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Palette.grey),
                                      ),
                                    )
                                  ],
                                ),
                                Container(
                                  margin: EdgeInsets.symmetric(horizontal: 0, vertical: 5),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      Container(
                                        child: Text(
                                          getTranslated(context, pharamacy_sunday).toString(),
                                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Palette.grey),
                                        ),
                                      ),
                                      Container(
                                        child: Text(
                                          getTranslated(context, pharamacy_close).toString(),
                                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Palette.grey),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                            child: Text(
                              getTranslated(context, pharamacy_address).toString(),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Palette.dark_blue,
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 25, vertical: 0),
                            alignment: Alignment.topLeft,
                            child: Text(
                              '$pharamacyAddress',
                              style: TextStyle(
                                fontSize: 14,
                                color: Palette.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        ],
                      ),

                      //tab 2
                      medicines.length != 0
                          ? Container(
                              child: GridView.builder(
                                itemCount: medicines.length,
                                shrinkWrap: true,
                                scrollDirection: Axis.vertical,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 3, childAspectRatio: 2.5),
                                itemBuilder: (context, index) {
                                  return Container(
                                    height: height * 0.2,
                                    width: width * 0.4,
                                    margin: EdgeInsets.only(left: width * 0.01, right: width * 0.01, top: width * 0.01),
                                    child: Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10.0),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            margin: EdgeInsets.only(left: width * 0.02, right: width * 0.02),
                                            width: width * 0.12,
                                            child: CachedNetworkImage(
                                              alignment: Alignment.center,
                                              imageUrl: medicines[index].fullImage!,
                                              placeholder: (context, url) => SpinKitFadingCircle(
                                                color: Palette.blue,
                                              ),
                                              errorWidget: (context, url, error) => Image.asset("assets/images/no_image.jpg"),
                                            ),
                                          ),
                                          Container(
                                            width: width * 0.28,
                                            margin: EdgeInsets.only(top: width * 0.03, bottom: width * 0.03),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Container(
                                                  alignment: Alignment.topLeft,
                                                  child: Text(
                                                    medicines[index].name!,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: width * 0.035,
                                                      color: Palette.dark_blue,
                                                    ),
                                                  ),
                                                ),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Container(
                                                      alignment: Alignment.bottomLeft,
                                                      margin: EdgeInsets.only(top: height * 0.003),
                                                      child: Text(
                                                        SharedPreferenceHelper.getString(Preferences.currency_symbol).toString() +
                                                            medicines[index].pricePrStrip.toString(),
                                                        style: TextStyle(
                                                          fontSize: width * 0.035,
                                                          color: Palette.dark_blue,
                                                        ),
                                                      ),
                                                    ),
                                                    GestureDetector(
                                                      onTap: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) => MedicineDescription(id: medicines[index].id),
                                                          ),
                                                        );
                                                      },
                                                      child: Container(
                                                        alignment: Alignment.bottomRight,
                                                        child: Icon(
                                                          Icons.add_shopping_cart,
                                                          size: 20,
                                                          color: Palette.blue,
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )
                          : Container(
                              alignment: Alignment.center,
                              child: Text(
                                getTranslated(context, pharamacy_medicineNotAvailable).toString(),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Palette.dark_blue,
                                ),
                              ),
                            ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<BaseModel<PharamaciesDetails>> callApiPharamacyDetail() async {
    PharamaciesDetails response;

    setState(() {
      loading = true;
    });
    try {
      response = await RestClient(RetroApi2().dioData2()).pharmacyDetailRequest(id);
      setState(() {
        if (response.success == true) {
          setState(
            () {
              loading = false;
              pharamacyImage = response.data!.fullImage;
              pharamacyName = response.data!.name;
              pharamacyPhone = response.data!.phone;
              pharamacyEmail = response.data!.email;
              pharamacyDescription = response.data!.description;
              pharamacyStartTime = response.data!.startTime;
              pharamacyEndTime = response.data!.endTime;
              pharamacyAddress = response.data!.address;
              medicines.addAll(response.data!.medicine!);
              isShipping = response.data!.isShipping;
              pharmacyLat = response.data!.lat;
              pharmacyLang = response.data!.lang;

              if ('$isShipping' == 1.toString()) {
                var convertCharges = json.decode(response.data!.deliveryCharges!);
                minValue.clear();
                maxValue.clear();
                charges.clear();
                for (int i = 0; i < convertCharges.length; i++) {
                  minValue.add(convertCharges[i]['min_value']);
                  maxValue.add(convertCharges[i]['max_value']);
                  charges.add(convertCharges[i]['charges']);
                  _passShippingStatus();
                }
                _passShippingStatus();
              }
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
}
