import 'dart:convert';
import 'dart:io';
import 'package:doctro/const/preference.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutterwave/core/flutterwave.dart';
import 'package:flutterwave/models/responses/charge_response.dart';
import 'package:flutterwave/utils/flutterwave_constants.dart';
import 'package:flutterwave/utils/flutterwave_currency.dart';
import 'package:geolocator/geolocator.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'AllPharamacy.dart';
import 'Bookappointment.dart';
import 'Showlocation.dart';
import 'StripePaymentScreenMedicine.dart';
import '../api/Retrofit_Api.dart';
import '../api/network_api.dart';
import 'package:dio/dio.dart';
import '../const/prefConstatnt.dart';
import '../database/db_service.dart';
import '../models/data_model.dart';
import 'api/apis.dart';
import 'api/base_model.dart';
import 'api/server_error.dart';
import 'const/Palette.dart';
import 'const/app_string.dart';
import 'localization/localization_constant.dart';
import 'model/DetailSetting.dart';
import 'model/PharamaciesDetails.dart';
import 'model/apply_offer.dart';

enum SingingCharacter { Pharmacy, Home }

enum SingingCharacterPayment { Paypal, Razorpay, Stripe, FlutterWave, PayStack, COD }

class MedicinePayment extends StatefulWidget {
  @override
  _MedicinePaymentState createState() => _MedicinePaymentState();
}

class _MedicinePaymentState extends State<MedicinePayment> {
  TextEditingController _offerController = TextEditingController();

  final GlobalKey<FormState> _offerFormKey = GlobalKey<FormState>();
  
  bool isPaymentClicked = false;

  SingingCharacter? _character = SingingCharacter.Pharmacy;
  SingingCharacterPayment? _payment;

  late var str;
  var parts;
  String? deliveryType = "Pharmacy";
  var startPart;

  var strPayment;
  var partsPayment;
  String? paymentType = 'COD';
  var startPartPayment;

  //Discount //
  String discountType = "";
  int? isFlat = 0;
  int? flatDiscount = 0;
  int? discount = 0;
  int? minDiscount = 0;
  DateTime? todayDate;

  late int deliveryDistance;

  ProductModel? model;
  late DBService dbService;

  String? address = "";
  int addressId = 0;

  String? businessName = "";
  String? logo = "";
  String? razorpayKey = "";
  int? cod = 0;
  int? stripe = 0;
  int? paypal = 0;
  int? razor = 0;
  int? flutterWave = 0;
  int? payStack = 0;

  bool loading = false;

  String isWhere = "";
  String? userLat = "";
  String? userLang = "";

  int? userCharges;
  int? isShipping;
  String? pharmacyLat;
  String? pharmacyLong;

  // Razprpay //
  late Razorpay _razorpay;

  // FlutterWave //
  final String txRef = "";
  final String amount = "";
  final String currency = FlutterwaveCurrency.RWF;

  // PayStack //
  var publicKey = Preferences.payStack_public_key;
  final plugin = PaystackPlugin();
  String? paymentToken = "";

  String? _paymentToken = "";

  String? userPhoneNo = "";
  String? userEmail = "";

  List<String?> minValue = [];
  List<String?> maxValue = [];
  List<String?> charges = [];

  int payAmount = 0;
  int grandTotal = 0;
  dynamic discountGrandTotal = 0;
  dynamic newGrandTotal = 0;
  int pharmacyId = 0;
  String? prescriptionFilePath = "";
  List<Map<String, dynamic>> medicine = [];

  double prAmount = 0;

  List<DeliveryChargesModel> listDeliveryCharge = [];
  String? strFinalDeliveryCharge = '';

  int? charge;
  List<Map> listData = [];

  @override
  void initState() {
    super.initState();
    dbService = new DBService();
    model = new ProductModel();
    getBookedData();
    initFun();
    _getAddress();
    _detailsetting();

    todayDate = DateTime.now();

    // RazorPay //
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    // PayStack //
    plugin.initialize(publicKey: SharedPreferenceHelper.getString(Preferences.payStack_public_key)!);
  }

  // RazorPay Clear //
  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }

  Future initFun() async {
    await callApiPharamacyDetail();
  }

  getBookedData() async {
    grandTotal = SharedPreferenceHelper.getInt('grandTotal');
    pharmacyId = SharedPreferenceHelper.getInt('pharmacyIdCart');
    prescriptionFilePath = SharedPreferenceHelper.getString('prescriptionFilePath');
    _character = isShipping == 1 ? SingingCharacter.Home : SingingCharacter.Pharmacy;
    deliveryType = isShipping == 1 ? "Home" : "Pharmacy";
    getSavedInfo();
  }

  getSavedInfo() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var myFavList = json.decode(pref.getString('myFavList')!);
    for (int i = 0; i < myFavList.length; i++) {
      listData.add({
        "id": myFavList[i]["id"],
        "price": myFavList[i]["price"],
        "qty": myFavList[i]["qty"],
      });
    }
  }

  _getAddress() async {
    setState(
      () {
        address = (SharedPreferenceHelper.getString('Address'));
        addressId = (SharedPreferenceHelper.getInt('addressId'));
        userLat = SharedPreferenceHelper.getString('lat');
        userLang = SharedPreferenceHelper.getString('lang');
        //user data
        userPhoneNo = SharedPreferenceHelper.getString('phone_no');
        userEmail = SharedPreferenceHelper.getString('email');
      },
    );
  }

  getDistance() async {
    double distanceInMeters = Geolocator.distanceBetween(
        double.parse(pharmacyLat!), double.parse(pharmacyLong!), double.parse(userLat!), double.parse(userLang!));
    double deliveryKM = distanceInMeters / 1000;
    str = "$deliveryKM";
    parts = str.split(".");
    deliveryDistance = int.parse(parts[0].trim());

    if (isShipping == 1) {
      String? strFinalDeliveryCharge1 = '';
      for (int i = 0; i < listDeliveryCharge.length; i++) {
        if (deliveryDistance >= double.parse(listDeliveryCharge[i].minValue!) &&
            deliveryDistance <= double.parse(listDeliveryCharge[i].maxValue!)) {
          strFinalDeliveryCharge1 = listDeliveryCharge[i].charges;
        }
      }
      if (deliveryDistance < 1) {
        strFinalDeliveryCharge = '0';
      } else {
        if (strFinalDeliveryCharge1 == '') {
          var max = listDeliveryCharge.reduce((current, next) => int.parse(current.charges!) > int.parse(next.charges!) ? current : next);
          strFinalDeliveryCharge = max.charges;
        } else {
          strFinalDeliveryCharge = strFinalDeliveryCharge1;
        }
      }
    }

    SharedPreferenceHelper.setString('strFinalDeliveryCharge', strFinalDeliveryCharge!);

    if (deliveryType == "Home" && isShipping == 1) {
      payAmount = grandTotal + int.parse(strFinalDeliveryCharge!);
    } else {
      payAmount = grandTotal;
    }
  }

  @override
  Widget build(BuildContext context) {
    double width;
    double height;
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(width * 0.3, 50),
        child: SafeArea(
          top: true,
          child: Container(
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.only(left: 5, right: 5),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                size: 25,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
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
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
            child: Column(
              children: [
                Container(
                  child: Column(
                    children: [
                      Container(
                        alignment: AlignmentDirectional.topStart,
                        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                        child: Text(
                          getTranslated(context, medicinePayment_youOrdered).toString(),
                          style: TextStyle(
                            fontSize: 18,
                            color: Palette.blue,
                          ),
                        ),
                      ),
                      Container(
                        child: Column(
                          children: [
                            RadioListTile(
                              title: Text(
                                getTranslated(context, medicinePayment_pharmacy).toString(),
                                style: TextStyle(
                                  color: Palette.blue,
                                ),
                              ),
                              value: SingingCharacter.Pharmacy,
                              groupValue: _character,
                              onChanged: (SingingCharacter? value) {
                                setState(() {
                                  payAmount = grandTotal;
                                  _character = value;
                                  str = "$_character";
                                  parts = str.split(".");
                                  startPart = parts[0].trim();
                                  deliveryType = parts.sublist(1).join('.').trim();
                                });
                              },
                            ),
                            isShipping == 1
                                ? RadioListTile(
                                    title: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          getTranslated(context, medicinePayment_home).toString(),
                                          style: TextStyle(
                                            color: Palette.blue,
                                          ),
                                        ),
                                        Container(
                                          width: width / 4,
                                          child: deliveryType == 'Home'
                                              ? ElevatedButton(
                                                  child: Text(
                                                    getTranslated(context, medicinePayment_change_button).toString(),
                                                  ),
                                                  onPressed: () {
                                                    SharedPreferenceHelper.setString('isWhere', "MedicinePayment");
                                                    Navigator.pushReplacement(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) => ShowLocation(),
                                                      ),
                                                    );
                                                  },
                                                )
                                              : Container(),
                                        )
                                      ],
                                    ),
                                    value: SingingCharacter.Home,
                                    groupValue: _character,
                                    onChanged: (SingingCharacter? value) {
                                      setState(
                                        () {
                                          _character = value;
                                          str = "$_character";
                                          parts = str.split(".");
                                          startPart = parts[0].trim();
                                          deliveryType = parts.sublist(1).join('.').trim();
                                          getDistance();
                                        },
                                      );
                                    },
                                  )
                                : Container(),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                deliveryType == 'Home' && isShipping == 1
                    ? Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                        child: Container(
                          height: 56,
                          width: 350,
                          child: Column(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                alignment: Alignment.topLeft,
                                child: Text(
                                  getTranslated(context, medicinePayment_address).toString(),
                                  style: TextStyle(fontSize: 16, color: Palette.dark_blue, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  SharedPreferenceHelper.setString('isWhere', "MedicinePayment");
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ShowLocation(),
                                    ),
                                  );
                                },
                                child: Container(
                                  alignment: Alignment.topLeft,
                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                                  child: address != null
                                      ? Text(
                                          '$address',
                                          style: TextStyle(fontSize: 14, color: Palette.blue),
                                          overflow: TextOverflow.ellipsis,
                                        )
                                      : Text(
                                          getTranslated(context, addLocation_address_validator).toString(),
                                          style: TextStyle(fontSize: 14, color: Palette.blue),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Container(),
                Form(
                  key: _offerFormKey,
                  child: Container(
                    height: height * 0.1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: width * 0.55,
                          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 2),
                          decoration: BoxDecoration(color: Palette.dark_white, borderRadius: BorderRadius.circular(10)),
                          child: TextFormField(
                            controller: _offerController,
                            keyboardType: TextInputType.text,
                            textCapitalization: TextCapitalization.words,
                            inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9]'))],
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: getTranslated(context, medicinePayment_offerCode_hint).toString(),
                              hintStyle: TextStyle(
                                fontSize: width * 0.04,
                                color: Palette.dark_grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            validator: (String? value) {
                              if (value!.isEmpty) {
                                return getTranslated(context, medicinePayment_offerCode_validator).toString();
                              }
                              return null;
                            },
                            onSaved: (String? name) {},
                          ),
                        ),
                        Container(
                          width: width * 0.32,
                          height: height * 0.05,
                          margin: EdgeInsets.symmetric(horizontal: 0, vertical: width * 0.03),
                          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 2),
                          child: ElevatedButton(
                            onPressed: () {
                              if (_offerFormKey.currentState!.validate()) {
                                callApiApplyOffer();
                              }
                            },
                            child: Text(getTranslated(context, medicinePayment_apply_button).toString()),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 5, horizontal: 0),
                  height: 2,
                  color: Palette.grey,
                ),
                Container(
                  alignment: AlignmentDirectional.topStart,
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 25),
                  child: Text(
                    getTranslated(context, medicinePayment_totalAmount).toString(),
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Palette.dark_blue),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 25),
                  child: deliveryType == "Home" && isShipping == 1
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 180,
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        getTranslated(context, medicinePayment_amount).toString(),
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Palette.dark_blue),
                                      ),
                                      '$discountGrandTotal' == "0.0" || '$discountGrandTotal' == "0"
                                          ? Text(
                                              SharedPreferenceHelper.getString(Preferences.currency_symbol).toString() +
                                                  grandTotal.toString(),
                                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Palette.blue),
                                            )
                                          : Text(
                                              SharedPreferenceHelper.getString(Preferences.currency_symbol).toString() +
                                                  discountGrandTotal.toString(),
                                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Palette.blue),
                                            ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        getTranslated(context, medicinePayment_deliveryCharges).toString(),
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Palette.dark_blue),
                                      ),
                                      Text(
                                        SharedPreferenceHelper.getString(Preferences.currency_symbol).toString() +
                                            '$strFinalDeliveryCharge',
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Palette.blue),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                top: 5,
                              ),
                              child: Container(
                                  child: '$newGrandTotal' == "0.0" || '$newGrandTotal' == "0"
                                      ? Text(
                                          SharedPreferenceHelper.getString(Preferences.currency_symbol).toString() + '$payAmount',
                                          style: TextStyle(
                                            fontSize: 35,
                                            fontWeight: FontWeight.bold,
                                            color: Palette.blue,
                                          ),
                                        )
                                      : Text(
                                          SharedPreferenceHelper.getString(Preferences.currency_symbol).toString() + '$newGrandTotal',
                                          style: TextStyle(
                                            fontSize: 35,
                                            fontWeight: FontWeight.bold,
                                            color: Palette.blue,
                                          ),
                                        )),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                top: 5,
                              ),
                              child: Container(
                                child: '$newGrandTotal' == "0.0" || '$newGrandTotal' == '0'
                                    ? Text(
                                        SharedPreferenceHelper.getString(Preferences.currency_symbol).toString() + '$payAmount',
                                        style: TextStyle(
                                          fontSize: 35,
                                          fontWeight: FontWeight.bold,
                                          color: Palette.blue,
                                        ),
                                      )
                                    : Text(
                                        SharedPreferenceHelper.getString(Preferences.currency_symbol).toString() + '$newGrandTotal', //
                                        style: TextStyle(
                                          fontSize: 35,
                                          fontWeight: FontWeight.bold,
                                          color: Palette.blue,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                  height: 2,
                  color: Palette.grey,
                ),
                Container(
                  alignment: Alignment.topLeft,
                  margin: EdgeInsets.only(left: 15),
                  child: Text(
                    getTranslated(context, medicinePayment_paymentType).toString(),
                    textAlign: TextAlign.start,
                    style: TextStyle(fontSize: 18, color: Palette.dark_blue, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height: 7,
                ),
                Container(
                  margin: EdgeInsets.all(15),
                  child: Column(
                    children: [
                      paypal == 1
                          ? Container(
                              margin: EdgeInsets.all(5),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(boxShadow: [
                                BoxShadow(
                                  color: Palette.grey.withOpacity(0.2),
                                  spreadRadius: 2,
                                  blurRadius: 7,
                                  offset: Offset(0, 3), // changes position of shadow
                                ),
                              ], borderRadius: BorderRadius.circular(10), color: Palette.white),
                              height: MediaQuery.of(context).size.height * 0.08,
                              child: RadioListTile<SingingCharacterPayment>(
                                controlAffinity: ListTileControlAffinity.trailing,
                                // contentPadding: EdgeInsets.only(left: 10),
                                title: Container(
                                  width: MediaQuery.of(context).size.width / 5,
                                  child: Row(
                                    children: [
                                      Image.network(
                                        "https://upload.wikimedia.org/wikipedia/commons/thumb/b/b7/PayPal_Logo_Icon_2014.svg/1200px-PayPal_Logo_Icon_2014.svg.png",
                                        height: 30,
                                        width: 50,
                                      ),
                                      SizedBox(
                                        width: MediaQuery.of(context).size.width * 0.01,
                                      ),
                                      Text('PayPal', style: TextStyle(fontSize: 16, color: Palette.black)),
                                    ],
                                  ),
                                ),
                                value: SingingCharacterPayment.Paypal,
                                activeColor: Palette.black,
                                groupValue: _payment,
                                onChanged: (SingingCharacterPayment? value) {
                                  setState(
                                    () {
                                      _payment = value;
                                      isPaymentClicked = true;
                                    },
                                  );
                                },
                              ),
                            )
                          : Container(),
                      razor == 1
                          ? Container(
                              alignment: Alignment.center,
                              margin: EdgeInsets.all(5),
                              decoration: BoxDecoration(boxShadow: [
                                BoxShadow(
                                  color: Palette.grey.withOpacity(0.2),
                                  spreadRadius: 2,
                                  blurRadius: 7,
                                  offset: Offset(0, 3), // changes position of shadow
                                ),
                              ], borderRadius: BorderRadius.circular(10), color: Palette.white),
                              height: MediaQuery.of(context).size.height * 0.08,
                              child: RadioListTile<SingingCharacterPayment>(
                                controlAffinity: ListTileControlAffinity.trailing,
                                title: Container(
                                  width: MediaQuery.of(context).size.width / 5,
                                  child: Row(
                                    children: [
                                      Image.network(
                                        "https://avatars.githubusercontent.com/u/7713209?s=280&v=4",
                                        height: 30,
                                        width: 50,
                                      ),
                                      SizedBox(
                                        width: MediaQuery.of(context).size.width * 0.01,
                                      ),
                                      Text('RazorPay', style: TextStyle(fontSize: 16, color: Palette.black)),
                                    ],
                                  ),
                                ),
                                value: SingingCharacterPayment.Razorpay,
                                activeColor: Palette.black,
                                groupValue: _payment,
                                onChanged: (SingingCharacterPayment? value) {
                                  setState(
                                    () {
                                      _payment = value;
                                      isPaymentClicked = true;
                                    },
                                  );
                                },
                              ),
                            )
                          : Container(),
                      stripe == 1
                          ? Container(
                              alignment: Alignment.center,
                              margin: EdgeInsets.all(5),
                              decoration: BoxDecoration(boxShadow: [
                                BoxShadow(
                                  color: Palette.grey.withOpacity(0.2),
                                  spreadRadius: 2,
                                  blurRadius: 7,
                                  offset: Offset(0, 3), // changes position of shadow
                                ),
                              ], borderRadius: BorderRadius.circular(10), color: Palette.white),
                              height: MediaQuery.of(context).size.height * 0.08,
                              child: RadioListTile<SingingCharacterPayment>(
                                controlAffinity: ListTileControlAffinity.trailing,
                                title: Container(
                                  width: MediaQuery.of(context).size.width / 5,
                                  child: Row(
                                    children: [
                                      Image.network(
                                        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT3PGzfbaZZzR0j8rOWBjWJPGWnkPzkm12f5A&usqp=CAU",
                                        height: 30,
                                        width: 50,
                                      ),
                                      SizedBox(
                                        width: MediaQuery.of(context).size.width * 0.01,
                                      ),
                                      Text('Stripe', style: TextStyle(fontSize: 16, color: Palette.black)),
                                    ],
                                  ),
                                ),
                                value: SingingCharacterPayment.Stripe,
                                activeColor: Palette.black,
                                groupValue: _payment,
                                onChanged: (SingingCharacterPayment? value) {
                                  setState(
                                    () {
                                      _payment = value;
                                      isPaymentClicked = true;
                                    },
                                  );
                                },
                              ),
                            )
                          : Container(),
                      flutterWave == 1
                          ? Container(
                              alignment: Alignment.center,
                              margin: EdgeInsets.all(5),
                              decoration: BoxDecoration(boxShadow: [
                                BoxShadow(
                                  color: Palette.grey.withOpacity(0.2),
                                  spreadRadius: 2,
                                  blurRadius: 7,
                                  offset: Offset(0, 3), // changes position of shadow
                                ),
                              ], borderRadius: BorderRadius.circular(10), color: Palette.white),
                              height: MediaQuery.of(context).size.height * 0.08,
                              child: RadioListTile<SingingCharacterPayment>(
                                controlAffinity: ListTileControlAffinity.trailing,
                                title: Container(
                                  width: MediaQuery.of(context).size.width / 5,
                                  child: Row(
                                    children: [
                                      Image.network(
                                        "https://cdn.filestackcontent.com/OITnhSPCSzOuiVvwnH7r",
                                        height: 30,
                                        width: 50,
                                      ),
                                      SizedBox(
                                        width: MediaQuery.of(context).size.width * 0.01,
                                      ),
                                      Flexible(
                                        child: Text('Flutterwave',
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            style: TextStyle(fontSize: 16, color: Palette.black)),
                                      ),
                                    ],
                                  ),
                                ),
                                value: SingingCharacterPayment.FlutterWave,
                                activeColor: Palette.black,
                                groupValue: _payment,
                                onChanged: (SingingCharacterPayment? value) {
                                  setState(
                                    () {
                                      _payment = value;
                                      isPaymentClicked = true;
                                    },
                                  );
                                },
                              ),
                            )
                          : Container(),
                      payStack == 1
                          ? Container(
                              alignment: Alignment.center,
                              margin: EdgeInsets.all(5),
                              decoration: BoxDecoration(boxShadow: [
                                BoxShadow(
                                  color: Palette.grey.withOpacity(0.2),
                                  spreadRadius: 2,
                                  blurRadius: 7,
                                  offset: Offset(0, 3), // changes position of shadow
                                ),
                              ], borderRadius: BorderRadius.circular(10), color: Palette.white),
                              height: MediaQuery.of(context).size.height * 0.08,
                              child: RadioListTile<SingingCharacterPayment>(
                                controlAffinity: ListTileControlAffinity.trailing,
                                title: Container(
                                  width: MediaQuery.of(context).size.width / 5,
                                  child: Row(
                                    children: [
                                      Image.network(
                                        "https://website-v3-assets.s3.amazonaws.com/assets/img/hero/Paystack-mark-white-twitter.png",
                                        height: 30,
                                        width: 50,
                                      ),
                                      SizedBox(
                                        width: MediaQuery.of(context).size.width * 0.01,
                                      ),
                                      Text('Paystack', style: TextStyle(fontSize: 16, color: Palette.black)),
                                    ],
                                  ),
                                ),
                                value: SingingCharacterPayment.PayStack,
                                activeColor: Palette.black,
                                groupValue: _payment,
                                onChanged: (SingingCharacterPayment? value) {
                                  setState(
                                    () {
                                      _payment = value;
                                      isPaymentClicked = true;
                                    },
                                  );
                                },
                              ),
                            )
                          : Container(),
                      cod == 1
                          ? Container(
                              alignment: Alignment.center,
                              margin: EdgeInsets.all(5),
                              decoration: BoxDecoration(boxShadow: [
                                BoxShadow(
                                  color: Palette.grey.withOpacity(0.2),
                                  spreadRadius: 2,
                                  blurRadius: 7,
                                  offset: Offset(0, 3), // changes position of shadow
                                ),
                              ], borderRadius: BorderRadius.circular(10), color: Palette.white),
                              height: MediaQuery.of(context).size.height * 0.08,
                              // width: MediaQuery.of(context).size.width / 2.2,
                              child: RadioListTile<SingingCharacterPayment>(
                                controlAffinity: ListTileControlAffinity.trailing,
                                title: Text(
                                  'COD(Case On Delivery)',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(fontSize: 16, color: Palette.black),
                                ),
                                value: SingingCharacterPayment.COD,
                                activeColor: Palette.black,
                                groupValue: _payment,
                                onChanged: (SingingCharacterPayment? value) {
                                  setState(() {
                                    _payment = value;
                                    isPaymentClicked = true;
                                  });
                                },
                              ),
                            )
                          : Container(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 50,
        child: ElevatedButton(
          child: Text(
            getTranslated(context, bookAppointment_pay_button).toString(),
            // 'Pay'
          ),
          onPressed: () async {
            if (_payment!.index == 0) {
              print('Paypal');
            }
            if (_payment!.index == 1) {
              openCheckoutRazorPay();
              print('Razorpay');
            }
            if (_payment!.index == 2) {
              print('Stripe');
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => StripePaymentScreenMedicine(
                    pharamacyId: pharmacyId,
                    amount: grandTotal.toString(),
                    deliveryType: deliveryType,
                    strFinalDeliveryCharge: strFinalDeliveryCharge,
                    listData: listData,
                    prescriptionFilePath: prescriptionFilePath,
                  ),
                ),
              );
            }
            if (_payment!.index == 3) {
              beginPayment();
              print('FlutterWave');
            }
            if (_payment!.index == 4) {
              print('PayStack');
              payStackFunction();
            }
            if (_payment!.index == 5) {
              print('cod');
              callApiBookMedicine();
            }
            str = "$_payment";
            parts = str.split(".");
            startPartPayment = parts[0].trim();
            paymentType = parts.sublist(1).join('.').trim();
          },
        ),
      ),
    );
  }

  Future<BaseModel<DetailSetting>> _detailsetting() async {
    DetailSetting response;

    setState(() {
      loading = true;
    });
    try {
      response = await RestClient(RetroApi().dioData()).settingRequest();
      setState(() {
        if (response.success == true) {
          razorpayKey = response.data!.razorKey;
          businessName = response.data!.businessName;
          logo = response.data!.logo;
          cod = response.data!.cod;
          stripe = response.data!.stripe;
          paypal = response.data!.paypal;
          flutterWave = response.data!.flutterwave;
          razor = response.data!.razor;
          payStack = response.data!.paystack;
          setState(() {});
        }
      });
    } catch (error, stacktrace) {
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  // RazorPay Code //
  void openCheckoutRazorPay() async {
    var options = {
      'key': SharedPreferenceHelper.getString(Preferences.razor_key),
      'amount': '$newGrandTotal' == "0.0" || '$newGrandTotal' == '0' ? num.parse('$payAmount') * 100 : num.parse('$newGrandTotal') * 100,
      'name': '$businessName',
      'image': '$logo',
      'currency': SharedPreferenceHelper.getString(Preferences.currency_code),
      'description': '',
      'send_sms_hash': 'true',
      'prefill': {'contact': '$userPhoneNo', 'email': '$userEmail'},
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: e');
    }
  }

  // RazorPay Success Method //
  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Fluttertoast.showToast(msg: "SUCCESS: " + response.paymentId, toastLength: Toast.LENGTH_SHORT);
    _paymentToken = response.paymentId;
    _paymentToken != "" && _paymentToken!.isNotEmpty
        ? callApiBookMedicine()
        : Fluttertoast.showToast(
            msg: getTranslated(context, medicinePayment_paymentNotComplete).toString(), toastLength: Toast.LENGTH_SHORT);
  }

  // RazorPay Error Method //
  void _handlePaymentError(PaymentFailureResponse response) {
    // Fluttertoast.showToast(
    //     msg: "ERROR: " + response.code.toString() + " - " + response.message,
    //     toastLength: Toast.LENGTH_SHORT);
  }

  // RazorPay Wallet Method //
  void _handleExternalWallet(ExternalWalletResponse response) {
    // Fluttertoast.showToast(
    //     msg: "EXTERNAL_WALLET: " + response.walletName, toastLength: Toast.LENGTH_SHORT);
  }

  // Flutter Wave //
  beginPayment() async {
    final Flutterwave flutterwave = Flutterwave.forUIPayment(
      context: this.context,
      encryptionKey: SharedPreferenceHelper.getString(Preferences.flutterWave_encryption_key)!,
      publicKey: SharedPreferenceHelper.getString(Preferences.flutterWave_key)!,
      currency: SharedPreferenceHelper.getString(Preferences.currency_code)!,
      amount: '$newGrandTotal' == "0.0" || '$newGrandTotal' == '0' ? '$payAmount' : '$newGrandTotal',
      email: "$userEmail",
      fullName: "Valid Full Name",
      txRef: DateTime.now().toIso8601String(),
      isDebugMode: true,
      phoneNumber: "$userPhoneNo",
      acceptCardPayment: true,
      acceptUSSDPayment: false,
      acceptAccountPayment: false,
      acceptFrancophoneMobileMoney: false,
      acceptGhanaPayment: false,
      acceptMpesaPayment: false,
      acceptRwandaMoneyPayment: false,
      acceptUgandaPayment: false,
      acceptZambiaPayment: false,
    );

    try {
      final ChargeResponse? response = await flutterwave.initializeForUiPayments();
      if (response == null) {
        // user didn't complete the transaction. Payment wasn't successful.
      } else {
        final isSuccessful = checkPaymentIsSuccessful(response);
        if (isSuccessful) {
          // provide value to customer
        } else {
          // check message
          print("response message ${response.message}");
        }
      }
    } catch (error, stacktrace) {
      // handleError(error);
      print("error is $stacktrace");
    }
  }

  bool checkPaymentIsSuccessful(final ChargeResponse response) {
    _paymentToken = response.data!.flwRef;
    _paymentToken != "" && _paymentToken!.isNotEmpty
        ? callApiBookMedicine()
        : Fluttertoast.showToast(
            msg: getTranslated(context, medicinePayment_paymentNotComplete).toString(), toastLength: Toast.LENGTH_SHORT);
    return response.data!.status == FlutterwaveConstants.SUCCESSFUL &&
        response.data!.currency == this.currency &&
        response.data!.amount == this.amount &&
        response.data!.txRef == this.txRef;
  }

  // PayStack //
  payStackFunction() async {
    var amountToPaystack =
        '$newGrandTotal' == "0.0" || '$newGrandTotal' == '0' ? num.parse('$payAmount') * 100 : num.parse('$newGrandTotal') * 100;
    Charge charge = Charge()
      ..amount = amountToPaystack as int
      ..reference = _getReference()
      ..currency = SharedPreferenceHelper.getString(Preferences.currency_code)
      // "ZAR"
      ..email = '$userEmail';
    CheckoutResponse response = await plugin.checkout(
      context,
      method: CheckoutMethod.card,
      charge: charge,
    );
    if (response.status == true) {
      _paymentToken = response.reference;
      _paymentToken != "" && _paymentToken!.isNotEmpty
          ? callApiBookMedicine()
          : Fluttertoast.showToast(
              msg: getTranslated(context, medicinePayment_paymentNotComplete).toString(), toastLength: Toast.LENGTH_SHORT);
      setState(() {
        paymentToken = response.reference;
      });
    } else {
      print('error');
    }
  }

  String _getReference() {
    String platform;
    if (Platform.isIOS) {
      platform = 'iOS';
    } else {
      platform = 'Android';
    }
    return 'ChargedFrom${platform}_${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<String> callApiBookMedicine() async {
    Dio dio = Dio();
    String? t = SharedPreferenceHelper.getString(Preferences.auth_token);
    dio.options.headers["Accept"] = "application/json"; // config your dio headers globally
    dio.options.headers["Content-Type"] = "multipart/form-data"; // config your dio headers globally
    dio.options.followRedirects = false;
    dio.options.connectTimeout = 75000; //5s
    dio.options.receiveTimeout = 3000;
    if (t != "N/A") {
      dio.options.headers["Authorization"] = "Bearer " + t!;
    }
    String fileName = prescriptionFilePath!.split('/').last;
    FormData formData;
    if (prescriptionFilePath == "") {
      formData = FormData.fromMap({
        "pharmacy_id": pharmacyId,
        "medicines": JsonEncoder().convert(listData),
        "amount": grandTotal,
        "payment_type": paymentType,
        "payment_status": _payment!.index == 5 ? 0 : 1,
        "payment_token": _payment!.index == 5 ? "" : _paymentToken,
        "shipping_at": deliveryType,
        "address_id": deliveryType == 'Pharmacy' ? "" : addressId,
        "delivery_charge": deliveryType == 'Pharmacy' ? 0 : strFinalDeliveryCharge,
      });
    } else {
      formData = FormData.fromMap({
        "pdf": MultipartFile.fromFileSync(prescriptionFilePath!, filename: fileName),
        "pharmacy_id": pharmacyId,
        "medicines": JsonEncoder().convert(listData),
        "amount": grandTotal,
        "payment_type": paymentType,
        "payment_status": _payment!.index == 5 ? 0 : 1,
        "payment_token": _payment!.index == 5 ? "" : _paymentToken,
        "shipping_at": deliveryType,
        "address_id": deliveryType == 'Pharmacy' ? "" : addressId,
        "delivery_charge": deliveryType == 'Pharmacy' ? 0 : strFinalDeliveryCharge,
      });
    }

    setState(() {
      Preferences.onLoading(context);
    });
    try {
      var response = await dio.post("${Apis.baseUrl}book_medicine", data: formData);
      // setState(()  {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      Preferences.hideDialog(context);
      prefs.remove('grandTotal');
      prefs.remove('strFinalDeliveryCharge');
      prefs.remove('pharmacyId');
      prefs.remove('prescriptionFilePath');
      late List<ProductModel> products;
      await dbService.getProducts().then((value) {
        products = value;
      });
      dbService.deleteTable(products[0]).then((value) {
        setState(() {});
      });
      var decodeData = json.decode(response.toString());
      Fluttertoast.showToast(
        msg: '${decodeData['msg']}',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      Navigator.pushAndRemoveUntil(
        context, MaterialPageRoute(builder: (context) => AllPharamacy()), ModalRoute.withName('/'),
      );
    } catch (e) {
      print('${e.toString()}');
    }
    return "";
  }

  Future<BaseModel<ApplyOffer>> callApiApplyOffer() async {
    ApplyOffer response;
    var offerDateToday = "$todayDate";
    String offerDate = DateUtilforpass().formattedDate(DateTime.parse(offerDateToday));
    Map<String, dynamic> body = {
      "offer_code": _offerController.text,
      "date": offerDate,
      "from": "medicine",
    };
    setState(() {
      loading = true;
    });
    try {
      response = await RestClient(RetroApi().dioData()).applyOfferRequest(body);
      setState(() {
        if (response.success == true) {
          setState(() {
            loading = false;
            discountType = response.data!.discountType!.toUpperCase();
            flatDiscount = response.data!.flatDiscount;
            isFlat = response.data!.isFlat;
            minDiscount = response.data!.minDiscount;
            discount = response.data!.discount;

            if (discountType == "AMOUNT" && isFlat == 1) {
              if (grandTotal > flatDiscount!) {
                if (flatDiscount! < minDiscount!) {
                  newGrandTotal = int.parse('$payAmount') - int.parse('$flatDiscount');
                  discountGrandTotal = double.parse('$grandTotal') - double.parse('$flatDiscount');
                } else {
                  newGrandTotal = int.parse('$payAmount') - int.parse('$minDiscount');
                  discountGrandTotal = double.parse('$grandTotal') - double.parse('$minDiscount');
                }
                Fluttertoast.showToast(
                  msg: getTranslated(context, medicinePayment_successFullOfferApply_toast).toString(),
                  // 'Successfully Offer Apply',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                );
              } else {
                Fluttertoast.showToast(
                  msg: getTranslated(context, medicinePayment_worthMoreThan_toast).toString() +
                      SharedPreferenceHelper.getString(Preferences.currency_symbol).toString() +
                      '$flatDiscount.',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                );
              }
            } else if (discountType == "AMOUNT" && isFlat == 0) {
              if (grandTotal > discount!) {
                if (discount! < minDiscount!) {
                  newGrandTotal = int.parse('$payAmount') - int.parse('$discount');
                  discountGrandTotal = double.parse('$grandTotal') - double.parse('$discount');
                } else {
                  newGrandTotal = int.parse('$payAmount') - int.parse('$minDiscount');
                  discountGrandTotal = double.parse('$grandTotal') - double.parse('$minDiscount');
                }
                Fluttertoast.showToast(
                  msg: getTranslated(context, medicinePayment_successFullOfferApply_toast).toString(),
                  // 'Successfully Offer Apply',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                );
              } else {
                Fluttertoast.showToast(
                  msg: getTranslated(context, medicinePayment_worthMoreThan_toast).toString() +
                      SharedPreferenceHelper.getString(Preferences.currency_symbol).toString() +
                      '$discount.',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                );
              }
            } else if (discountType == "PERCENTAGE") {
              prAmount = (int.parse('$grandTotal') * int.parse('$discount')) / 100;
              if (prAmount <= minDiscount!) {
                newGrandTotal = double.parse('$payAmount') - double.parse('$prAmount');
                discountGrandTotal = double.parse('$grandTotal') - double.parse('$prAmount');
              } else {
                newGrandTotal = double.parse('$payAmount') - double.parse('$minDiscount');
                discountGrandTotal = double.parse('$grandTotal') - double.parse('$minDiscount');
              }
              Fluttertoast.showToast(
                msg: payAmount >= prAmount || payAmount >= minDiscount!
                    ? getTranslated(context, medicinePayment_successFullOfferApply_toast).toString()
                    : getTranslated(context, medicinePayment_worthMoreThan_toast).toString() +
                        SharedPreferenceHelper.getString(Preferences.currency_symbol).toString() +
                        '$prAmount.',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
              );
              newGrandTotal = payAmount >= prAmount || payAmount >= minDiscount! ? newGrandTotal : payAmount;
            }
          });
        } else {
          setState(() {
            loading = false;
            Fluttertoast.showToast(
              msg: '${response.msg}',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
            );
          });
        }
      });
    } catch (error, stacktrace) {
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<PharamaciesDetails>> callApiPharamacyDetail() async {
    PharamaciesDetails response;
    setState(() {
      loading = true;
    });
    try {
      response = await RestClient(RetroApi().dioData()).pharmacyDetailRequest(pharmacyId);
      setState(() {
        loading = false;

        if (response.success == true) {
          if (mounted) {
            setState(() {
              isShipping = response.data!.isShipping;
              pharmacyLat = response.data!.lat;
              pharmacyLong = response.data!.lang;
              if (isShipping == 1) {
                var convertCharges = json.decode(response.data!.deliveryCharges!);
                minValue.clear();
                maxValue.clear();
                charges.clear();
                for (int i = 0; i < convertCharges.length; i++) {
                  minValue.add(convertCharges[i]['min_value']);
                  maxValue.add(convertCharges[i]['max_value']);
                  charges.add(convertCharges[i]['charges']);
                }

                String strDeliveryCharges = response.data!.deliveryCharges!;
                var deliveryCharge = jsonDecode(strDeliveryCharges);
                listDeliveryCharge = (deliveryCharge as List).map((i) => DeliveryChargesModel.fromJson(i)).toList();
              }
              getDistance();
            });
          } else {
            isShipping = response.data!.isShipping;
            pharmacyLat = response.data!.lat;
            pharmacyLong = response.data!.lang;
            if (isShipping == 1) {
              var convertCharges = json.decode(response.data!.deliveryCharges!);
              minValue.clear();
              maxValue.clear();
              charges.clear();
              for (int i = 0; i < convertCharges.length; i++) {
                minValue.add(convertCharges[i]['min_value']);
                maxValue.add(convertCharges[i]['max_value']);
                charges.add(convertCharges[i]['charges']);
              }

              String strDeliveryCharges = response.data!.deliveryCharges!;
              var deliveryCharge = jsonDecode(strDeliveryCharges);
              listDeliveryCharge = (deliveryCharge as List).map((i) => DeliveryChargesModel.fromJson(i)).toList();
            }

            getDistance();
          }
        }
      });
    } catch (error, stacktrace) {
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }
}

class DeliveryChargesModel {
  String? minValue;
  String? maxValue;
  String? charges;

  DeliveryChargesModel({this.minValue, this.maxValue, this.charges});

  factory DeliveryChargesModel.fromJson(Map<String, dynamic> parsedJson) {
    return DeliveryChargesModel(minValue: parsedJson['min_value'], maxValue: parsedJson['max_value'], charges: parsedJson['charges']);
  }
}
