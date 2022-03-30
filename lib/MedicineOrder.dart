import 'package:cached_network_image/cached_network_image.dart';
import 'package:doctro/Bookappointment.dart';
import 'package:doctro/api/Retrofit_Api.dart';
import 'package:doctro/api/network_api.dart';
import 'package:doctro/model/MedicineOrderModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import '../MedicineOrderDetail.dart';
import 'api/base_model.dart';
import 'api/server_error.dart';
import 'const/Palette.dart';
import 'const/app_string.dart';
import 'const/prefConstatnt.dart';
import 'const/preference.dart';
import 'localization/localization_constant.dart';

class MedicineOrder extends StatefulWidget {
  @override
  _MedicineOrderState createState() => _MedicineOrderState();
}

class _MedicineOrderState extends State<MedicineOrder> {
  bool loading = false;
  List<Data> medicineList = [];

  dynamic grandTotal = 0;

  @override
  void initState() {
    super.initState();
    callApiMedicineOrder();
  }

  String? date;

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
          getTranslated(context, medicineOrder_title).toString(),
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
        child: medicineList.length != 0
            ? ListView(
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    itemCount: medicineList.length,
                    reverse: true,
                    itemBuilder: (context, index) {
                      date = DateUtil().formattedDate(
                        DateTime.parse(medicineList[index].createdAt!),
                      );
                      if (medicineList[index].deliveryCharge != null) {
                        grandTotal = medicineList[index].amount! + medicineList[index].deliveryCharge!;
                      } else {
                        grandTotal = medicineList[index].amount;
                      }
                      return Container(
                        child: Column(
                          children: [
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                elevation: 2,
                                color: Palette.white,
                                child: Column(
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(top: width * 0.02, left: width * 0.04, right: width * 0.04),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Container(
                                                child: Text(
                                                  getTranslated(context, medicineOrder_bookingId).toString(),
                                                  style:
                                                      TextStyle(fontSize: width * 0.035, color: Palette.blue, fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(left: width * 0.0),
                                                child: Text(
                                                  medicineList[index].medicineId!,
                                                  style: TextStyle(
                                                      fontSize: width * 0.035, color: Palette.dark_blue, fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Container(
                                                child: Text(
                                                  SharedPreferenceHelper.getString(Preferences.currency_symbol).toString() + '$grandTotal',
                                                  style:
                                                      TextStyle(fontSize: width * 0.05, color: Palette.blue, fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(
                                        top: width * 0.02,
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            width: width * 0.15,
                                            margin: EdgeInsets.only(left: width * 0.01, right: width * 0.01),
                                            child: Column(
                                              children: [
                                                Container(
                                                  width: width * 0.11,
                                                  height: height * 0.055,
                                                  child: CachedNetworkImage(
                                                    alignment: Alignment.center,
                                                    imageUrl: medicineList[index].pharmacyDetails!.fullImage!,
                                                    imageBuilder: (context, imageProvider) => CircleAvatar(
                                                      radius: 50,
                                                      backgroundColor: Palette.image_circle,
                                                      child: CircleAvatar(
                                                        radius: 60,
                                                        backgroundImage: imageProvider,
                                                      ),
                                                    ),
                                                    placeholder: (context, url) => SpinKitFadingCircle(
                                                      color: Palette.blue,
                                                    ),
                                                    errorWidget: (context, url, error) => Image.asset("assets/images/no_image.jpg"),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                          Container(
                                            width: width * 0.75,
                                            child: Column(
                                              children: [
                                                Container(
                                                  alignment: AlignmentDirectional.topStart,
                                                  child: Column(
                                                    children: [
                                                      Text(
                                                        medicineList[index].pharmacyDetails!.name!,
                                                        style: TextStyle(
                                                          fontSize: width * 0.04,
                                                          color: Palette.dark_blue,
                                                        ),
                                                        overflow: TextOverflow.ellipsis,
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  alignment: AlignmentDirectional.topStart,
                                                  margin: EdgeInsets.only(top: width * 0.005),
                                                  child: Column(
                                                    children: [
                                                      Text(
                                                        medicineList[index].pharmacyDetails!.address!,
                                                        style: TextStyle(fontSize: width * 0.03, color: Palette.grey),
                                                        overflow: TextOverflow.ellipsis,
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(top: width * 0.03),
                                      child: Column(
                                        children: [
                                          Divider(
                                            height: width * 0.004,
                                            color: Palette.dark_grey,
                                            thickness: width * 0.001,
                                          )
                                        ],
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(left: 20, right: 20, top: 10),
                                      child: Column(
                                        children: [
                                          Container(
                                            alignment: AlignmentDirectional.topStart,
                                            child: Text(
                                              getTranslated(context, medicineOrder_items).toString(),
                                              style: TextStyle(
                                                fontSize: width * 0.04,
                                                color: Palette.blue,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          ListView.builder(
                                            shrinkWrap: true,
                                            physics: NeverScrollableScrollPhysics(),
                                            itemCount: medicineList[index].medicineName!.length,
                                            itemBuilder: (context, i) {
                                              return Container(
                                                child: Text(
                                                  medicineList[index].medicineName![i].qty.toString() +
                                                      '  X  ' +
                                                      medicineList[index].medicineName![i].name!,
                                                ),
                                              );
                                            },
                                          )
                                        ],
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            width: 150,
                                            child: Column(
                                              children: [
                                                Container(
                                                  alignment: AlignmentDirectional.topStart,
                                                  child: Text(
                                                    getTranslated(context, medicineOrder_orderedOn).toString(),
                                                    style: TextStyle(
                                                      fontSize: width * 0.04,
                                                      color: Palette.blue,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  alignment: AlignmentDirectional.topStart,
                                                  child: Text(
                                                    '$date',
                                                    style: TextStyle(
                                                      fontSize: width * 0.035,
                                                      color: Palette.dark_blue,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  alignment: AlignmentDirectional.topStart,
                                                  child: Text(
                                                    medicineList[index].shippingAt!,
                                                    style: TextStyle(
                                                      fontSize: width * 0.035,
                                                      color: Palette.dark_blue,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            child: ElevatedButton(
                                              child: Text(
                                                getTranslated(context, medicineOrder_viewMore).toString(),
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Palette.white,
                                                ),
                                              ),
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => MedicineOrderDetail(
                                                      pharmacyName: medicineList[index].pharmacyDetails!.name,
                                                      pharmacyAddress: medicineList[index].pharmacyDetails!.address,
                                                      orderId: medicineList[index].id,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              )
            : Container(
                alignment: Alignment.center,
                margin: EdgeInsets.symmetric(vertical: 40),
                child: Text(
                  getTranslated(context, medicineOrder_orderNotFound).toString(),
                  style: TextStyle(fontSize: width * 0.04, color: Palette.grey, fontWeight: FontWeight.bold),
                ),
              ),
      ),
    );
  }

  Future<BaseModel<MedicineOrderModel>> callApiMedicineOrder() async {
    MedicineOrderModel response;
    setState(() {
      loading = true;
    });
    try {
      response = await RestClient(RetroApi().dioData()).medicineOrderRequest();
      setState(() {
        loading = false;

        if (response.success == true) {
          setState(() {
            loading = false;
            medicineList.addAll(response.data!);
          });
        } else {
          setState(() {
            loading = false;
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
