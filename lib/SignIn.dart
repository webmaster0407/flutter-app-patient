import 'package:doctro/api/Retrofit_Api.dart';
import 'package:doctro/api/network_api.dart';
import 'package:doctro/model/login.dart';
import 'package:doctro/phoneverification.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:doctro/const/prefConstatnt.dart';
import 'package:doctro/const/preference.dart';
import 'package:location/location.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api/base_model.dart';
import 'api/server_error.dart';
import 'const/Palette.dart';
import 'const/app_string.dart';
import 'localization/localization_constant.dart';
import 'model/DetailSetting.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final GlobalKey<FormState> formkey = GlobalKey<FormState>();

  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  bool _isHidden = true;

  String? msg = "";
  String? deviceToken = "";

  int? verify = 0;
  int? id = 0;

  @override
  void initState() {
    super.initState();
    getLocation();
    callApiSetting();
  }

  late LocationData _locationData;
  Location location = new Location();

  Future<void> getLocation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _locationData = await location.getLocation();

    prefs.setString('lat', _locationData.latitude.toString());
    prefs.setString('lang', _locationData.longitude.toString());
  }

  @override
  Widget build(BuildContext context) {
    double width;
    width = MediaQuery.of(context).size.width;
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: SingleChildScrollView(
          child: Form(
            key: formkey,
            child: Column(
              children: [
                Container(
                  height: size.height * 1,
                  width: width * 1,
                  child: Stack(
                    children: [
                      Image.asset(
                        "assets/images/confident-doctor-half.png",
                        height: size.height * 0.5,
                        width: width * 1,
                        fit: BoxFit.fill,
                      ),
                      Positioned(
                        top: size.height * 0.35,
                        child: Container(
                          width: width * 1,
                          height: size.height * 1,
                          decoration: BoxDecoration(
                            color: Palette.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(width * 0.1),
                              topRight: Radius.circular(width * 0.1),
                            ),
                          ),
                          child: ListView(
                            children: [
                              Column(
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(top: width * 0.08),
                                    child: Column(
                                      children: [
                                        Text(
                                          getTranslated(context, signIn_welcome).toString(),
                                          style: TextStyle(fontSize: width * 0.1, fontWeight: FontWeight.bold, color: Palette.light_black),
                                        )
                                      ],
                                    ),
                                  ),
                                  Container(
                                    child: Column(
                                      children: [
                                        Text(
                                          getTranslated(context, signIn_title).toString(),
                                          style: TextStyle(fontSize: width * 0.04, color: Palette.dark_grey1),
                                        )
                                      ],
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(top: width * 0.1, left: width * 0.07, right: width * 0.07),
                                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 2),
                                    decoration: BoxDecoration(color: Palette.dark_white, borderRadius: BorderRadius.circular(10)),
                                    child: TextFormField(
                                      controller: email,
                                      keyboardType: TextInputType.text,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: getTranslated(context, signIn_email_hint).toString(),
                                        hintStyle: TextStyle(fontSize: width * 0.038, color: Palette.dark_blue),
                                      ),
                                      validator: (String? value) {
                                        if (value!.isEmpty) {
                                          return getTranslated(context, signIn_email_validator1).toString();
                                        }
                                        if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                            .hasMatch(value)) {
                                          return getTranslated(context, signIn_email_validator2).toString();
                                        }
                                        return null;
                                      },
                                      onSaved: (String? name) {},
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(top: size.height * 0.02, left: width * 0.07, right: width * 0.07),
                                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 2),
                                    decoration: BoxDecoration(color: Palette.dark_white, borderRadius: BorderRadius.circular(10)),
                                    child: TextFormField(
                                      controller: password,
                                      keyboardType: TextInputType.text,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: getTranslated(context, signIn_password_hint).toString(),
                                        hintStyle: TextStyle(fontSize: width * 0.038, color: Palette.dark_blue),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _isHidden ? Icons.visibility : Icons.visibility_off,
                                            color: Palette.grey,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _isHidden = !_isHidden;
                                            });
                                          },
                                        ),
                                      ),
                                      obscureText: _isHidden,
                                      validator: (String? value) {
                                        if (value!.isEmpty) {
                                          return getTranslated(context, signIn_password_validator).toString();
                                        }
                                        return null;
                                      },
                                      onSaved: (String? name) {},
                                    ),
                                  ),
                                  Container(
                                    width: width * 1,
                                    height: 40,
                                    margin: EdgeInsets.only(top: size.height * 0.03, left: 20, right: 20),
                                    padding: EdgeInsets.symmetric(horizontal: width * 0.04, vertical: 0),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: ElevatedButton(
                                      child: Text(
                                        getTranslated(context, signIn_signIn_button).toString(),
                                        style: TextStyle(fontSize: width * 0.045),
                                        textAlign: TextAlign.center,
                                      ),
                                      onPressed: () {
                                        if (formkey.currentState!.validate()) {
                                          callForLogin();
                                        } else {
                                          print('Not Login');
                                        }
                                      },
                                    ),
                                  ),
                                  Container(
                                    height: size.height * 0.06,
                                    width: width * 0.85,
                                    margin: EdgeInsets.only(
                                      left: width * 0.05,
                                      right: width * 0.05,
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        TextButton(
                                          child: Text(
                                            getTranslated(context, signIn_forgotPassword_button).toString(),
                                            style: TextStyle(fontSize: width * 0.042, color: Palette.dark_grey),
                                            textAlign: TextAlign.center,
                                          ),
                                          onPressed: () {
                                            Navigator.pushNamed(context, 'ForgotPasswordScreen');
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(top: size.height * 0.03),
                                    alignment: AlignmentDirectional.topStart,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Row(
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  child: Text(
                                                    getTranslated(context, signIn_notAccount).toString(),
                                                    style: TextStyle(fontSize: width * 0.04, color: Palette.dark_grey),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Container(
                                              margin: EdgeInsets.only(left: width * 0.03),
                                              child: GestureDetector(
                                                onTap: () {
                                                  Navigator.pushNamed(context, 'SignUp');
                                                },
                                                child: Text(
                                                  getTranslated(context, signIn_signUp_button).toString(),
                                                  style:
                                                      TextStyle(fontSize: width * 0.04, color: Palette.blue, fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ],
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
    );
  }

  Future<BaseModel<Login>> callForLogin() async {
    Login response;
    Map<String, dynamic> body = {
      "email": email.text.toString(),
      "password": password.text.toString(),
      "device_token": SharedPreferenceHelper.getString(Preferences.device_token),
    };
    setState(() {
      Preferences.onLoading(context);
    });
    try {
      response = await RestClient(RetroApi2().dioData2()).loginRequest(body);
      if (response.success == true) {
        setState(() {
          Preferences.hideDialog(context);

          verify = response.data!.verify;
          id = response.data!.id;

          verify != 0
              ? Navigator.pushReplacementNamed(context, "Home")
              : Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PhoneVerification(id: id),
                  ),
                );
          msg = response.msg;
          email.clear();
          password.clear();
          SharedPreferenceHelper.setBoolean(Preferences.is_logged_in, true);
          SharedPreferenceHelper.setString(Preferences.auth_token, response.data!.token!);



          Fluttertoast.showToast(
            msg: '${response.msg}',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Palette.blue,
            textColor: Palette.white,
          );
        });
      } else {
        setState(() {
          Preferences.hideDialog(context);
          Fluttertoast.showToast(
            msg: '${response.msg}',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Palette.blue,
            textColor: Palette.white,
          );
        });
      }
    } catch (error, stacktrace) {
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<DetailSetting>> callApiSetting() async {
    DetailSetting response;

    try {
      response = await RestClient(RetroApi2().dioData2()).settingRequest();
      setState(() {
        if (response.success == true) {
          SharedPreferenceHelper.setString(Preferences.patientAppId, response.data!.patientAppId!);

          if (response.data!.patientAppId != null) {
            getOneSingleToken(SharedPreferenceHelper.getString(Preferences.patientAppId));
          }
        }
      });
    } catch (error, stacktrace) {
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<void> getOneSingleToken(appId) async {
    //one signal mate
    try {
      OneSignal.shared.consentGranted(true);
      OneSignal.shared.setAppId(appId);
      OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);
      await OneSignal.shared.promptUserForPushNotificationPermission(fallbackToSettings: true);
      OneSignal.shared.promptLocationPermission();
      await OneSignal.shared.getDeviceState().then((value) {
        print('device token is ${value!.userId}');
        return SharedPreferenceHelper.setString(Preferences.device_token, value.userId!);
      });
    } catch (e) {
      print("error${e.toString()}");
    }

    setState(() {
      deviceToken = SharedPreferenceHelper.getString(Preferences.device_token);
    });
  }
}