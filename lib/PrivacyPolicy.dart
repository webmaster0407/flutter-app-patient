import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import '../api/Retrofit_Api.dart';
import '../api/network_api.dart';
import 'api/base_model.dart';
import 'api/server_error.dart';
import 'const/Palette.dart';
import 'const/app_string.dart';
import 'localization/localization_constant.dart';
import 'model/DetailSetting.dart';

class PrivacyPolicy extends StatefulWidget {
  @override
  _PrivacyPolicyState createState() => _PrivacyPolicyState();
}

class _PrivacyPolicyState extends State<PrivacyPolicy> {
  bool loading = false;

  String? privacyPolicy = "";

  @override
  void initState() {
    super.initState();
    appAllDetail();
  }

  @override
  Widget build(BuildContext context) {
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
          getTranslated(context, privacyPolicy_title).toString(),
          style: TextStyle(fontSize: 18, color: Palette.dark_blue, fontWeight: FontWeight.bold),
        ),
      ),
      body: ModalProgressHUD(
        inAsyncCall: loading,
        opacity: 0.5,
        progressIndicator: SpinKitFadingCircle(
          color: Palette.blue,
          size: 50.0,
        ),
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          child: Html(
            data: '$privacyPolicy',
          ),
        ),
      ),
    );
  }

  Future<BaseModel<DetailSetting>> appAllDetail() async {
    DetailSetting response;

    setState(() {
      loading = true;
    });
    try {
      response = await RestClient(RetroApi2().dioData2()).settingRequest();
      if (response.success == true) {
        setState(() {
          loading = false;
          privacyPolicy = response.data!.privacyPolicy;
        });
      }
    } catch (error, stacktrace) {
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }
}
