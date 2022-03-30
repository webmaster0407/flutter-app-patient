/// success : true
/// msg : "Booking is successfully waiting for doctor confirmation"


class Bookappointments {
  bool? success;
  String? data;
  String? msg;

  Bookappointments({this.success, this.data, this.msg});

  Bookappointments.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'];
    msg = json['msg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['data'] = this.data;
    data['msg'] = this.msg;
    return data;
  }
}
