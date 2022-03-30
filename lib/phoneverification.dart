import 'dart:ui';
import 'package:doctro/api/Retrofit_Api.dart';
import 'package:doctro/api/network_api.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'api/base_model.dart';
import 'api/server_error.dart';
import 'const/Palette.dart';
import 'const/app_string.dart';
import 'localization/localization_constant.dart';
import 'model/Checkotp.dart';
import 'model/ResendOtp.dart';

class PhoneVerification extends StatefulWidget {
  final int? id;

  PhoneVerification({this.id});

  @override
  _PhoneVerificationState createState() => _PhoneVerificationState();
}

class _PhoneVerificationState extends State<PhoneVerification> {
  int? id = 0;

  final TextEditingController _pinPutController = TextEditingController();
  final FocusNode _pinPutFocusNode = FocusNode();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  BoxDecoration get _pinPutDecoration {
    return BoxDecoration(
      border: Border.all(color: Palette.purple),
      borderRadius: BorderRadius.circular(15.0),
    );
  }

  @override
  void initState() {
    id = widget.id;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width;
    double height;
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(width * 0.125, width * 0.12),
        child: SafeArea(
          child: Container(
            alignment: AlignmentDirectional.topStart,
            margin: EdgeInsets.only(top: height * 0.015, left: width * 0.05, right: width * 0.05),
            child: GestureDetector(
              child: Icon(Icons.arrow_back_ios),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: SingleChildScrollView(
          child: Center(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: height * 0.1, left: width * 0.073, right: width * 0.073),
                    child: Text(
                      getTranslated(context, phoneVerification_title).toString(),
                      style: TextStyle(fontSize: width * 0.08, fontWeight: FontWeight.bold, color: Palette.dark_blue),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: height * 0.06),
                    child: Text(
                      getTranslated(context, phoneVerification_enterOtp_hint).toString(),
                      style: TextStyle(fontSize: width * 0.038, color: Palette.dark_blue, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: width * 0.06),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                          margin: const EdgeInsets.all(20.0),
                          padding: const EdgeInsets.all(20.0),
                          child: PinPut(
                            fieldsCount: 4,
                            autofocus: true,
                            keyboardType: TextInputType.number,
                            textStyle: TextStyle(fontSize: width * 0.04, color: Palette.dark_blue),
                            // onSubmit: (String pin) => _showSnackBar(pin, context),
                            focusNode: _pinPutFocusNode,
                            controller: _pinPutController,
                            submittedFieldDecoration: _pinPutDecoration.copyWith(
                              borderRadius: BorderRadius.circular(5.0),
                              color: Palette.blue,
                              border: Border.all(
                                color: Palette.tealAccent.withOpacity(.2),
                              ),
                            ),
                            selectedFieldDecoration: _pinPutDecoration.copyWith(
                              borderRadius: BorderRadius.circular(5.0),
                              color: Palette.white,
                              border: Border.all(
                                color: Palette.tealAccent.withOpacity(.2),
                              ),
                            ),
                            followingFieldDecoration: _pinPutDecoration.copyWith(
                              borderRadius: BorderRadius.circular(5.0),
                              color: Palette.blue,
                              border: Border.all(
                                color: Palette.tealAccent.withOpacity(.2),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    child: TweenAnimationBuilder(
                      tween: Tween(begin: 30.0, end: 0.0),
                      duration: Duration(seconds: 30),
                      builder: (_, dynamic value, child) => Text(
                        "00:${value.toInt()}",
                        style: TextStyle(fontSize: width * 0.04, color: Palette.dark_blue),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(width * 0.1),
                    child: Column(
                      children: [
                        Text(
                          getTranslated(context, phoneVerification_notReceivedCode).toString(),
                          style: TextStyle(fontSize: width * 0.035, color: Palette.dark_blue),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: width * 0.0, vertical: width * 0.02),
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  callApiResendOtp();
                                },
                                child: Text(
                                  getTranslated(context, phoneVerification_resendCode).toString(),
                                  style: TextStyle(color: Palette.blue, fontWeight: FontWeight.bold, fontSize: width * 0.04),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: width,
                    margin: EdgeInsets.all(20),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: width * 0.04, vertical: 5),
                      child: ElevatedButton(
                        child: Text(
                          getTranslated(context, phoneVerification_verifyOtp_button).toString(),
                          style: TextStyle(fontSize: width * 0.04),
                          textAlign: TextAlign.center,
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            callApiOTP();
                          } else {}
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showSnackBar(String pin, BuildContext context) {
    final snackBar = SnackBar(
      content: Container(
        height: 80.0,
        child: Center(
          child: Text(
            'Pin Submitted. Value: $pin',
            style: const TextStyle(fontSize: 25.0),
          ),
        ),
      ),
      backgroundColor: Palette.purple,
    );
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  Future<BaseModel<Checkotp>> callApiOTP() async {
    Checkotp response;
    Map<String, dynamic> body = {
      "user_id": id,
      "otp": _pinPutController.text,
    };
    try {
      response = await RestClient(RetroApi2().dioData2()).checkOtp(body);
      setState(() {
        if (response.success == true) {
          Navigator.pushReplacementNamed(context, "SignIn");
          Fluttertoast.showToast(
            msg: '${response.msg}',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
        } else {
          Fluttertoast.showToast(
            msg: '${response.msg}',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
        }
      });
    } catch (error, stacktrace) {
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<ResendOtp>> callApiResendOtp() async {
    ResendOtp response;
    try {
      response = await RestClient(RetroApi2().dioData2()).resendOtpRequest(id);
      setState(() {
        if (response.success == true) {
          setState(() {
            Fluttertoast.showToast(
              msg: '${response.msg}',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
            );
          });
        } else {
          setState(() {
            Fluttertoast.showToast(
              msg: '${response.msg}',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
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
}
