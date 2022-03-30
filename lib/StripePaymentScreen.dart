import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api/Retrofit_Api.dart';
import 'api/base_model.dart';
import 'api/network_api.dart';
import 'api/server_error.dart';
import 'const/app_string.dart';
import 'const/prefConstatnt.dart';
import 'const/preference.dart';
import 'localization/localization_constant.dart';
import 'model/bookappointments.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;

class StripePaymentScreen extends StatefulWidget {
  final String? selectAppointmentFor;
  final String? patientName;
  final String? illnessInformation;
  final String? age;
  final String? patientAddress;
  final String? phoneNo;
  final String? selectDrugEffects;
  final String? note;
  final String? newDate; // pass Api
  final String? selectTime;
  final String? appointmentFees;
  final int? doctorId;
  final String? newDateUser; // show user
  final List<String>? reportImages;

  StripePaymentScreen({
    this.selectAppointmentFor,
    this.patientName,
    this.illnessInformation,
    this.age,
    this.patientAddress,
    this.phoneNo,
    this.selectDrugEffects,
    this.note,
    this.newDate,
    this.selectTime,
    this.appointmentFees,
    this.doctorId,
    this.newDateUser,
    this.reportImages,
  });

  @override
  _StripePaymentScreenState createState() => _StripePaymentScreenState();
}

class _StripePaymentScreenState extends State<StripePaymentScreen> {
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

  String? passBookDate = "";
  String? passBookTime = "";
  String passBookID = "";

  String? bookingId = "";

  stripe.CardFieldInputDetails? _card;
  stripe.TokenData? tokenData;

  @override
  void initState() {
    super.initState();
    setKey();
  }

  Future setKey() async {
    stripe.Stripe.publishableKey = SharedPreferenceHelper.getString(Preferences.stripe_public_key)!;
    await stripe.Stripe.instance.applySettings();
  }

  _passDateTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(
      () {
        passBookDate = widget.newDateUser;
        passBookTime = widget.selectTime;
        passBookID = '$bookingId';
        prefs.setString('BookDate', passBookDate!);
        prefs.setString('BookTime', passBookTime!);
        prefs.setString('BookID', passBookID);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  child: Text(getTranslated(context, stripePaymentBookAppointment_pay).toString()),
                  // text: 'Create token',
                ),
              ),
            ],
          ),
        ],
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
        callApiBook();
      });
      // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Success: The token was created successfully!')));
      return;
    } catch (e) {
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      rethrow;
    }
  }

  Future<BaseModel<Bookappointments>> callApiBook() async {
    Bookappointments response;
    Map<String, dynamic> body = {
      "appointment_for": widget.selectAppointmentFor,
      "patient_name": widget.patientName,
      "illness_information": widget.illnessInformation,
      "age": widget.age,
      "patient_address": widget.patientAddress,
      "phone_no": widget.phoneNo,
      "drug_effect": widget.selectDrugEffects,
      "note": widget.note,
      "date": widget.newDate,
      "time": widget.selectTime,
      "payment_type": "Stripe",
      "payment_status": 1,
      "payment_token": tokenData!.id,
      "amount": widget.appointmentFees,
      "doctor_id": widget.doctorId,
      "report_image": widget.reportImages!.length != 0 ? widget.reportImages : "",
    };
    setState(() {
      Preferences.onLoading(context);
    });
    try {
      response = await RestClient(RetroApi().dioData()).bookAppointment(body);
      if (response.success == true) {
        setState(
          () {
            Preferences.hideDialog(context);
            bookingId = response.data;
            _passDateTime();
            Navigator.pushReplacementNamed(context, 'BookSuccess');
            Fluttertoast.showToast(
              msg: '${response.msg}',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
            );
          },
        );
      } else {
        Preferences.hideDialog(context);
      }
    } catch (error, stacktrace) {
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }
}

//603830