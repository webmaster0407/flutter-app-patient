import 'package:flutter/material.dart';
import '../const/prefConstatnt.dart';
import '../const/preference.dart';
import 'const/Palette.dart';
import 'const/app_string.dart';
import 'localization/localization_constant.dart';

class Setting extends StatefulWidget {
  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  @override
  Widget build(BuildContext context) {
    double width;
    double height;
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Scaffold(
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
          getTranslated(context, setting_title).toString(),
          style: TextStyle(fontSize: 18, color: Palette.dark_blue, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SharedPreferenceHelper.getBoolean(Preferences.is_logged_in) == true
                ? Column(
                    children: [
                      Container(
                        height: height * 0.05,
                        width: width * 1,
                        color: Palette.light_blue,
                        child: Container(
                          alignment: Alignment.topLeft,
                          margin: EdgeInsets.only(left: width * 0.05, right: width * 0.05),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                getTranslated(context, setting_title).toString(),
                                style: TextStyle(
                                  fontSize: width * 0.038,
                                  color: Color(0xFF003165),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, 'ChangeLanguage');
                        },
                        child: Container(
                          alignment: Alignment.centerLeft,
                          margin: EdgeInsets.symmetric(vertical: height * 0.02, horizontal: width * 0.05),
                          child: Text(
                            getTranslated(context, setting_changeLanguage).toString(),
                            style: TextStyle(fontSize: width * 0.038, color: Palette.dark_blue),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, 'ChangePassword');
                        },
                        child: Container(
                          alignment: Alignment.centerLeft,
                          margin: EdgeInsets.symmetric(vertical: height * 0.02, horizontal: width * 0.05),
                          child: Text(
                            getTranslated(context, setting_changePassword).toString(),
                            style: TextStyle(fontSize: width * 0.038, color: Palette.dark_blue),
                          ),
                        ),
                      ),
                      // : SizedBox()
                    ],
                  )
                : SizedBox(),
            Container(
              height: height * 0.05,
              width: width * 1,
              color: Palette.light_blue,
              margin: EdgeInsets.only(top: height * 0.02),
              child: Container(
                alignment: Alignment.topLeft,
                margin: EdgeInsets.symmetric(horizontal: width * 0.05),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      getTranslated(context, setting_general).toString(),
                      style: TextStyle(
                        fontSize: width * 0.038,
                        color: Palette.dark_blue,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: width * 0.05),
              child: Column(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, 'AboutUs');
                    },
                    child: Container(
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.only(top: height * 0.025),
                      child: Text(
                        getTranslated(context, setting_about).toString(),
                        style: TextStyle(fontSize: width * 0.038, color: Palette.dark_blue),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, 'PrivacyPolicy');
                    },
                    child: Container(
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.only(top: height * 0.025),
                      child: Text(
                        getTranslated(context, setting_privacyPolicy).toString(),
                        style: TextStyle(fontSize: width * 0.038, color: Palette.dark_blue),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SwitchScreen extends StatefulWidget {
  @override
  SwitchClass createState() => new SwitchClass();
}

class SwitchClass extends State {
  bool isSwitched = true;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(
      children: <Widget>[
        Column(
          children: [
            Column(
              children: [
                Column(
                  children: [
                    Container(
                      height: size.width * 0.038,
                      margin: EdgeInsets.only(),
                      child: Switch(
                        value: isSwitched,
                        onChanged: (value) {
                          setState(
                            () {
                              isSwitched = value;
                            },
                          );
                        },
                        activeColor: Palette.white,
                        activeTrackColor: Palette.dark_blue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
