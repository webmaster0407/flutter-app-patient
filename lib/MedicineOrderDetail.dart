import 'package:doctro/api/Retrofit_Api.dart';
import 'package:doctro/api/network_api.dart';
import 'package:doctro/model/MedicineOrderDetail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'Bookappointment.dart';
import 'api/base_model.dart';
import 'api/server_error.dart';
import 'const/Palette.dart';
import 'const/app_string.dart';
import 'const/prefConstatnt.dart';
import 'const/preference.dart';
import 'localization/localization_constant.dart';

class MedicineOrderDetail extends StatefulWidget {
  final int? orderId;
  final String? pharmacyName;
  final String? pharmacyAddress;

  MedicineOrderDetail({
    this.orderId,
    this.pharmacyName,
    this.pharmacyAddress,
  });

  @override
  _MedicineOrderDetailState createState() => _MedicineOrderDetailState();
}

class _MedicineOrderDetailState extends State<MedicineOrderDetail> {
  bool loading = false;

  String? paymentType = "";
  String? date = "";
  String? deliverTo = "";
  int? totalAmount = 0;
  int? deliveryCharge = 0;
  String? bookOrderId = "";

  int? grandTotal = 0;
  String newDate = "";
  int medicineAmountTotal = 0;

  List<MedicineName>? bookMedicineList = [];

  @override
  void initState() {
    super.initState();
    callApiMedicineOrderDetail();
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
          getTranslated(context, medicineOrderDetail_orderSummary).toString(),
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
            child: Column(
              children: [
                Container(
                  alignment: AlignmentDirectional.topStart,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                    child: Text(
                      getTranslated(context, medicineOrderDetail_orderSummary).toString(),
                      style: TextStyle(fontSize: 22, color: Palette.dark_blue, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 20),
                  child: Column(
                    children: [
                      Container(
                        alignment: AlignmentDirectional.topStart,
                        child: Text(
                          widget.pharmacyName!,
                          style: TextStyle(fontSize: 20, color: Palette.blue, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
                        child: Container(
                          alignment: AlignmentDirectional.topStart,
                          child: Text(
                            widget.pharmacyAddress!,
                            style: TextStyle(
                              fontSize: 16,
                              color: Palette.grey,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                        child: Divider(
                          height: 1,
                          thickness: 2,
                          color: Palette.blue.withOpacity(0.5),
                        ),
                      )
                    ],
                  ),
                ),
                Column(
                  children: [
                    Container(
                      alignment: AlignmentDirectional.topStart,
                      child: Text(
                        getTranslated(context, medicineOrderDetail_yourOrder).toString(),
                        style: TextStyle(fontSize: 20, color: Palette.dark_blue, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
                      child: Divider(
                        height: 1,
                        thickness: 2,
                        color: Palette.blue.withOpacity(0.5),
                      ),
                    ),
                    ListView.builder(
                      itemCount: bookMedicineList!.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        medicineAmountTotal = bookMedicineList![index].qty! * bookMedicineList![index].price!;
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              child: Container(
                                alignment: AlignmentDirectional.topStart,
                                child: Text(
                                  bookMedicineList![index].name!,
                                  style: TextStyle(fontSize: 16, color: Palette.blue, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                                  child: Row(
                                    children: [
                                      Container(
                                        child: Text(
                                          bookMedicineList![index].qty.toString(),
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Palette.dark_blue,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                                        child: Container(
                                          child: Text('X'),
                                        ),
                                      ),
                                      Container(
                                        child: Text(
                                          SharedPreferenceHelper.getString(Preferences.currency_symbol).toString() +
                                              bookMedicineList![index].price.toString(),
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Palette.dark_blue,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                                  child: Container(
                                    child: Text(
                                      SharedPreferenceHelper.getString(Preferences.currency_symbol).toString() + '$medicineAmountTotal',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Palette.dark_blue,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                              child: Divider(
                                height: 1,
                                color: Palette.blue,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            child: Text(
                              getTranslated(context, medicineOrderDetail_totalAmount).toString(),
                              style: TextStyle(fontSize: 18, color: Palette.dark_blue, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            child: Text(
                              SharedPreferenceHelper.getString(Preferences.currency_symbol).toString() + '$totalAmount',
                              style: TextStyle(fontSize: 18, color: Palette.dark_blue, fontWeight: FontWeight.bold),
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            child: Text(
                              getTranslated(context, medicineOrderDetail_deliveryCharge).toString(),
                              style: TextStyle(fontSize: 18, color: Palette.dark_blue, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            child: deliveryCharge != null
                                ? Text(
                                    SharedPreferenceHelper.getString(Preferences.currency_symbol).toString() + '$deliveryCharge',
                                    style: TextStyle(fontSize: 18, color: Palette.dark_blue, fontWeight: FontWeight.bold),
                                  )
                                : Text(
                                    '0',
                                    style: TextStyle(fontSize: 18, color: Palette.dark_blue, fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      color: Palette.dark_white,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              child: Text(
                                getTranslated(context, medicineOrderDetail_grandTotal).toString(),
                                style: TextStyle(fontSize: 18, color: Palette.dark_blue, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Container(
                              child: Text(
                                SharedPreferenceHelper.getString(Preferences.currency_symbol).toString() + '$grandTotal',
                                style: TextStyle(fontSize: 18, color: Palette.blue, fontWeight: FontWeight.bold),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Container(
                        alignment: AlignmentDirectional.topStart,
                        child: Text(
                          getTranslated(context, medicineOrderDetail_orderDetail).toString(),
                          style: TextStyle(fontSize: 20, color: Palette.dark_blue, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
                      child: Divider(
                        height: 1,
                        thickness: 2,
                        color: Palette.blue.withOpacity(0.5),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                      child: Column(
                        children: [
                          Container(
                            alignment: AlignmentDirectional.topStart,
                            child: Text(
                              getTranslated(context, medicineOrderDetail_orderNumber).toString(),
                              style: TextStyle(fontSize: 16, color: Palette.blue, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
                            child: Container(
                              alignment: AlignmentDirectional.topStart,
                              child: Text(
                                '$bookOrderId',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Palette.grey,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                      child: Column(
                        children: [
                          Container(
                            alignment: AlignmentDirectional.topStart,
                            child: Text(
                              getTranslated(context, medicineOrderDetail_payment).toString(),
                              style: TextStyle(fontSize: 16, color: Palette.blue, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
                            child: Container(
                              alignment: AlignmentDirectional.topStart,
                              child: Text(
                                '$paymentType',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Palette.grey,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                      child: Column(
                        children: [
                          Container(
                            alignment: AlignmentDirectional.topStart,
                            child: Text(
                              getTranslated(context, medicineOrderDetail_date).toString(),
                              style: TextStyle(fontSize: 16, color: Palette.blue, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
                            child: Container(
                              alignment: AlignmentDirectional.topStart,
                              child: Text(
                                '$newDate',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Palette.grey,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                      child: Column(
                        children: [
                          Container(
                            alignment: AlignmentDirectional.topStart,
                            child: Text(
                              getTranslated(context, medicineOrderDetail_deliverTo).toString(),
                              style: TextStyle(fontSize: 16, color: Palette.blue, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
                            child: Container(
                              alignment: AlignmentDirectional.topStart,
                              child: '$deliverTo' != "Home"
                                  ? Text(
                                      '$deliverTo',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Palette.grey,
                                      ),
                                    )
                                  : Text(
                                      '$deliverTo',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Palette.grey,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20, bottom: 10),
                      child: Divider(
                        height: 1,
                        thickness: 2,
                        color: Palette.blue.withOpacity(0.5),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<BaseModel<MedicineOrderDetails>> callApiMedicineOrderDetail() async {
    MedicineOrderDetails response;
    setState(() {
      loading = true;
    });
    try {
      response = await RestClient(RetroApi().dioData()).medicineOrderDetailRequest(widget.orderId);
      setState(() {
        loading = false;
        if (response.success == true) {
          setState(
            () {
              loading = false;
              paymentType = response.data!.paymentType;
              date = response.data!.createdAt;
              deliverTo = response.data!.shippingAt;
              totalAmount = response.data!.amount;
              deliveryCharge = response.data!.deliveryCharge;
              bookOrderId = response.data!.medicineId;
              bookMedicineList = response.data!.medicineName;

              if (deliveryCharge != null) {
                grandTotal = totalAmount! + deliveryCharge!;
              } else {
                grandTotal = totalAmount;
              }
              newDate = DateUtil().formattedDate(DateTime.parse(date!));
            },
          );
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
