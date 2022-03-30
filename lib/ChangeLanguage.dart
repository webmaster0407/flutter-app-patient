import 'package:doctro/const/prefConstatnt.dart';
import 'package:doctro/const/preference.dart';
import 'package:doctro/localization/localization_constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import 'api/Retrofit_Api.dart';
import 'api/base_model.dart';
import 'api/network_api.dart';
import 'api/server_error.dart';
import 'const/Palette.dart';
import 'const/app_string.dart';
import 'main.dart';
import 'model/UpdateProfile.dart';
import 'model/UserDetail.dart';

class ChangeLanguage extends StatefulWidget {
  const ChangeLanguage({Key? key}) : super(key: key);

  @override
  _ChangeLanguageState createState() => _ChangeLanguageState();
}

class _ChangeLanguageState extends State<ChangeLanguage> {
  int? value = 0;

  bool loading = false;
  String userName = "";
  String userPhoneCode = "";
  String userPhoneNo = "";
  String? userDateOfBirth = "";
  String userGender = "";

  @override
  void initState() {
    super.initState();
    callApiUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: loading,
      opacity: 0.5,
      progressIndicator: SpinKitFadingCircle(
        color: Palette.blue,
        size: 50.0,
      ),
      child: Scaffold(
        appBar: AppBar(
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
          centerTitle: true,
          backgroundColor: Palette.white,
          title: Text(
            getTranslated(context, changeLanguage_title).toString(),
            style: TextStyle(fontSize: 18, color: Palette.dark_blue, fontWeight: FontWeight.bold),
          ),
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(
              new FocusNode(),
            );
          },
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            margin: EdgeInsets.only(left: 10, right: 10),
            child: ListView.builder(
              itemCount: Language.languageList().length,
              padding: EdgeInsets.only(bottom: 20),
              itemBuilder: (context, index) {
                // this.value = 0;
                value = Language.languageList()[index].name == SharedPreferenceHelper.getString(Preferences.current_language_code)
                    ? index
                    : null;
                if (SharedPreferenceHelper.getString(Preferences.current_language_code) == 'N/A') {
                  this.value = 0;
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: RadioListTile(
                        value: index,
                        controlAffinity: ListTileControlAffinity.trailing,
                        groupValue: value,
                        activeColor: Palette.dark_blue,
                        onChanged: (int? val) async {
                          Locale local = await setLocale(Language.languageList()[index].languageCode);
                          setState(() {
                            value = index;
                            print("Value $value");
                            MyApp.setLocale(context, local);
                            SharedPreferenceHelper.setString(Preferences.current_language_code, Language.languageList()[index].name);

                            callApiUpdateProfile();
                            Navigator.pushNamed(context, 'Home');
                          });
                        },
                        title: Text(Language.languageList()[index].name),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<BaseModel<UpdateProfile>> callApiUpdateProfile() async {
    UpdateProfile response;
    Map<String, dynamic> body = {
      "name": userName,
      "phone_code": userPhoneCode,
      "phone": userPhoneNo,
      "dob": userDateOfBirth,
      "gender": userGender,
      "language": SharedPreferenceHelper.getString(Preferences.current_language_code),
    };
    setState(() {
      loading = true;
    });
    try {
      response = await RestClient(RetroApi().dioData()).updateProfileRequest(body);
      setState(() {
        if (response.success == true) {
          setState(() {
            loading = false;
            Fluttertoast.showToast(
              msg: '${response.msg}',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Palette.blue,
              textColor: Palette.white,
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

  Future<BaseModel<UserDetail>> callApiUserProfile() async {
    UserDetail response;
    setState(() {
      loading = true;
    });
    try {
      response = await RestClient(RetroApi().dioData()).userDetailRequest();
      setState(() {
        loading = false;
        userName = response.name!;
        userPhoneCode = response.phoneCode!;
        userPhoneNo = response.phone!;
        userDateOfBirth = response.dob;
        userGender = response.gender!.toUpperCase();
      });
    } catch (error, stacktrace) {
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }
}

class Language {
  final int id;
  final String name;
  final String flag;
  final String languageCode;

  Language(this.id, this.name, this.flag, this.languageCode);

  static List<Language> languageList() {
    return <Language>[
      Language(1, 'English', '🇺🇸', 'en'),
      // Language(2, 'Spanish', 'ES', 'es'),
      Language(3, 'Arabic', 'AE', 'ar')
    ];
  }
}
