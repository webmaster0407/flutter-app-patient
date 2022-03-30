import 'package:doctro/api/Retrofit_Api.dart';
import 'package:doctro/api/network_api.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'api/base_model.dart';
import 'api/server_error.dart';
import 'const/Palette.dart';
import 'const/app_string.dart';
import 'const/prefConstatnt.dart';
import 'const/preference.dart';
import 'localization/localization_constant.dart';
import 'model/DisplayOffer.dart';

class Offer extends StatefulWidget {
  @override
  _OfferState createState() => _OfferState();
}

class _OfferState extends State<Offer> {
  bool loading = true;

  List<OfferModel> offerList = [];

  @override
  void initState() {
    super.initState();
    callApIDisplayOffer();
  }

  @override
  Widget build(BuildContext context) {
    double width;
    width = MediaQuery.of(context).size.width;
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
          getTranslated(context, offer_title).toString(),
          style: TextStyle(fontSize: 20, color: Palette.dark_blue, fontWeight: FontWeight.bold),
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
          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: offerList.length != 0
              ? ListView.builder(
                  itemCount: offerList.length,
                  itemBuilder: (context, index) {
                    return Container(
                      child: ClipPath(
                        clipper: SideCutClipper(),
                        child: Container(
                          margin: EdgeInsets.all(10),
                          width: width,
                          color: index % 2 == 0 ? Palette.light_blue : Palette.offer_card,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  child: Container(
                                    height: 30,
                                    child: Center(
                                      child: Text(
                                        offerList[index].name!,
                                        style: TextStyle(color: index % 2 == 0 ? Palette.white : Palette.light_blue),
                                      ),
                                    ),
                                  ),
                                ),
                                if (offerList[index].discountType == "amount" && offerList[index].isFlat == 0)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 15.0),
                                    child: Center(
                                      child: Text(
                                        getTranslated(context, offer_flat).toString() +
                                            SharedPreferenceHelper.getString(Preferences.currency_symbol).toString() +
                                            offerList[index].discount.toString(),
                                        style: TextStyle(color: Palette.dark_blue, fontSize: 16.0, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                if (offerList[index].discountType == "percentage" && offerList[index].isFlat == 0)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 15.0),
                                    child: Center(
                                      child: Text(
                                        offerList[index].discount.toString() + '% ' + getTranslated(context, offer_discount).toString(),
                                        style: TextStyle(color: Palette.dark_blue, fontSize: 16.0, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                if (offerList[index].discountType == "amount" && offerList[index].isFlat == 1)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 15.0),
                                    child: Center(
                                      child: Text(
                                        getTranslated(context, offer_flat).toString() +
                                            SharedPreferenceHelper.getString(Preferences.currency_symbol).toString() +
                                            offerList[index].flatDiscount.toString(),
                                        style: TextStyle(color: Palette.dark_blue, fontSize: 16.0, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                Container(
                                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                                  child: Column(
                                    children: [
                                      DottedLine(
                                        direction: Axis.horizontal,
                                        lineLength: double.infinity,
                                        lineThickness: 1.0,
                                        dashLength: 3.0,
                                        dashColor: index % 2 == 0 ? Palette.white : Palette.light_blue,
                                        dashRadius: 0.0,
                                        dashGapLength: 1.0,
                                        dashGapColor: Palette.transparent,
                                        dashGapRadius: 0.0,
                                      )
                                    ],
                                  ),
                                ),
                                Column(
                                  children: [
                                    Container(
                                      child: Text(
                                        getTranslated(context, offer_useCouponCode).toString(),
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: index % 2 == 0 ? Palette.dark_white.withOpacity(0.7) : Palette.grey,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Center(
                                        child: Container(
                                          width: 90.0,
                                          height: 30.0,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(30.0),
                                            border: Border.all(width: 1.0, color: index % 2 == 0 ? Palette.white : Palette.blue),
                                          ),
                                          child: Center(
                                            child: SelectableText(
                                              offerList[index].offerCode!,
                                              cursorColor: Palette.white,
                                              style: TextStyle(fontSize: 16, color: index % 2 == 0 ? Palette.white : Palette.light_blue),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                )
              : Container(
                  alignment: AlignmentDirectional.center,
                  child: Text(
                    getTranslated(context, offer_offerNotAvailable).toString(),
                    style: TextStyle(fontSize: width * 0.05, color: Palette.grey, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
        ),
      ),
    );
  }

  Future<BaseModel<DisplayOffer>> callApIDisplayOffer() async {
    DisplayOffer response;
    setState(() {
      loading = true;
    });
    try {
      response = await RestClient(RetroApi2().dioData2()).displayOfferRequest();
      setState(() {
        loading = false;
        if (response.success == true) {
          setState(() {
            loading = false;
            offerList.addAll(response.data!);
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
