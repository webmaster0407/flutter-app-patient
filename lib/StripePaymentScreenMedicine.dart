import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../const/prefConstatnt.dart';
import '../const/preference.dart';
import '../database/db_service.dart';
import '../models/data_model.dart';
import 'api/apis.dart';
import 'const/Palette.dart';
import 'const/app_string.dart';
import 'localization/localization_constant.dart';

class StripePaymentScreenMedicine extends StatefulWidget {
  final int? pharamacyId;
  final String? amount;
  final String? deliveryType;
  final String? prescriptionFilePath;
  final String? strFinalDeliveryCharge;
  final List<Map>? listData;

  StripePaymentScreenMedicine({
    this.pharamacyId,
    this.amount,
    this.deliveryType,
    this.strFinalDeliveryCharge,
    this.listData,
    this.prescriptionFilePath,
  });

  @override
  _StripePaymentScreenMedicineState createState() => _StripePaymentScreenMedicineState();
}

class _StripePaymentScreenMedicineState extends State<StripePaymentScreenMedicine> {
  bool loading = false;

  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  late var str;
  var parts;
  var year;
  var date;

  var error;
  var paymentToken;

  ProductModel? model;
  late DBService dbService;

  stripe.CardFieldInputDetails? _card;

  stripe.TokenData? tokenData;

  @override
  void initState() {
    super.initState();
    dbService = new DBService();
    model = new ProductModel();
    _getAddress();
    setKey();
  }

  Future setKey() async {
    stripe.Stripe.publishableKey = SharedPreferenceHelper.getString(Preferences.stripe_public_key)!;
    await stripe.Stripe.instance.applySettings();
  }

  String? address = "";
  int addressId = 0;

  String isWhere = "";
  String? userLat = "";
  String? userLang = "";
  String? userPhoneNo = "";
  String? userEmail = "";

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

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: loading,
      opacity: 1,
      progressIndicator: SpinKitFadingCircle(
        color: Palette.blue,
        size: 50.0,
      ),
      child: Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomInset: true,
        body: ListView(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: CardField(
                    autofocus: true,
                    onCardChanged: (card) {
                      setState(() {
                        _card = card;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: ElevatedButton(
                    onPressed: _card?.complete == true ? _handleCreateTokenPress : null,
                    child: Text(
                      getTranslated(context, stripePaymentBookAppointment_pay).toString(),
                    ),
                    // text: 'Create token',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleCreateTokenPress() async {
    if (_card == null) {
      return;
    }

    try {
      final tokenData = await stripe.Stripe.instance.createToken(
        const CreateTokenParams(type: TokenType.Card),
      );
      setState(() {
        this.tokenData = tokenData;
        callApiBookMedicine();
      });
      // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Success: The token was created successfully!')));
      return;
    } catch (e) {
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      rethrow;
    }
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
    String fileName = widget.prescriptionFilePath!.split('/').last;
    print('file name $fileName');
    FormData formData;

    if (widget.prescriptionFilePath == "") {
      formData = FormData.fromMap({
        "pharmacy_id": widget.pharamacyId,
        "medicines": JsonEncoder().convert(widget.listData),
        "amount": widget.amount,
        "payment_type": "Stripe",
        "payment_status": 1,
        "payment_token": tokenData!.id,
        "shipping_at": widget.deliveryType,
        "address_id": widget.deliveryType == 'Pharmacy' ? "" : addressId,
        "delivery_charge": widget.deliveryType == 'Pharmacy' ? 0 : widget.strFinalDeliveryCharge,
      });
    } else {
      formData = FormData.fromMap({
        "pdf": MultipartFile.fromFileSync(widget.prescriptionFilePath!, filename: fileName),
        "pharmacy_id": widget.pharamacyId,
        "medicines": JsonEncoder().convert(widget.listData),
        "amount": widget.amount,
        "payment_type": "Stripe",
        "payment_status": 1,
        "payment_token": tokenData!.id,
        "shipping_at": widget.deliveryType,
        "address_id": widget.deliveryType == 'Pharmacy' ? "" : addressId,
        "delivery_charge": widget.deliveryType == 'Pharmacy' ? 0 : widget.strFinalDeliveryCharge,
      });
    }

    setState(() {
      Preferences.onLoading(context);
    });
    try {
      var response = await dio.post("${Apis.baseUrl}book_medicine", data: formData);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      Preferences.hideDialog(context);
      print('Ready');
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
      Navigator.pushReplacementNamed(context, 'AllPharamacy');
      print('12234545  ${response.toString()}');
    } catch (e) {
      print('12345ERROR   ${e.toString()}');
      Preferences.hideDialog(context);
      Fluttertoast.showToast(
        msg: getTranslated(context, stripePaymentMedicineBook_bookingFailed_toast).toString(),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
    return "";
  }
}
