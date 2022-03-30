import 'package:doctro/models/model.dart';

class ProductModel extends Model {
  static String table = 'products';

  int? id;
  String? productName;
  int? medicineId;
  int? quntity;
  int? price;
  int? pharmacyId;
  int? shippingStatus;
  String? pLat;
  String? pLang;
  String? prescriptionFilePath;
  int? medicineStock;


  ProductModel({
    this.id,
    this.productName,
    this.medicineId,
    this.quntity,
    this.price,
    this.pharmacyId,
    this.shippingStatus,
    this.pLat,
    this.pLang,
    this.prescriptionFilePath,
    this.medicineStock,
  });

  static ProductModel fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map["id"],
      productName: map['productName'].toString(),
      medicineId: map['medicineId'],
      quntity: map['quntity'],
      price: map['price'],
      pharmacyId: map['pharmacyId'],
      shippingStatus: map['shippingStatus'],
      pLat: map['pLat'].toString(),
      pLang: map['pLang'].toString(),
      prescriptionFilePath: map['prescriptionFilePath'].toString(),
      medicineStock: map['medicineStock'],
    );
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'id': id,
      'productName': productName,
      'medicineId': medicineId,
      'quntity': quntity,
      'price': price,
      'pharmacyId': pharmacyId,
      'shippingStatus': shippingStatus,
      'pLat': pLat,
      'pLang': pLang,
      'prescriptionFilePath': prescriptionFilePath,
      'medicineStock': medicineStock,
    };

    if (id != null) {
      map['id'] = id;
    }
    return map;
  }
}
