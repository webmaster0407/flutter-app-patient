/// msg : null
/// data : {"token":"006708f2e13a2cf456e8b83b02c1dbc1798IACaLtSTSPOWNnFWbVFJ/46qIrhBM8Vk0dWs6MP62BgCHathSBwAAAAAIgAz4iEBQvR4YQQAAQDqxXdhAwDqxXdhAgDqxXdhBADqxXdh","cn":"6177a2c2b4813"}
/// success : true

class VideoCallModel {
  VideoCallModel({
      dynamic msg, 
      Data? data, 
      bool? success,}){
    _msg = msg;
    _data = data;
    _success = success;
}

  VideoCallModel.fromJson(dynamic json) {
    _msg = json['msg'];
    _data = json['data'] != null ? Data.fromJson(json['data']) : null;
    _success = json['success'];
  }
  dynamic _msg;
  Data? _data;
  bool? _success;

  dynamic get msg => _msg;
  Data? get data => _data;
  bool? get success => _success;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['msg'] = _msg;
    if (_data != null) {
      map['data'] = _data?.toJson();
    }
    map['success'] = _success;
    return map;
  }

}

/// token : "006708f2e13a2cf456e8b83b02c1dbc1798IACaLtSTSPOWNnFWbVFJ/46qIrhBM8Vk0dWs6MP62BgCHathSBwAAAAAIgAz4iEBQvR4YQQAAQDqxXdhAwDqxXdhAgDqxXdhBADqxXdh"
/// cn : "6177a2c2b4813"

class Data {
  Data({
      String? token, 
      String? cn,}){
    _token = token;
    _cn = cn;
}

  Data.fromJson(dynamic json) {
    _token = json['token'];
    _cn = json['cn'];
  }
  String? _token;
  String? _cn;

  String? get token => _token;
  String? get cn => _cn;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['token'] = _token;
    map['cn'] = _cn;
    return map;
  }

}