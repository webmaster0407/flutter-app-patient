



import 'package:doctro/api/server_error.dart';

class BaseModel<T> {
  late ServerError error;
  T? data;
  /*Status status ;
  String? message;*/

 /* BaseModel.loading(this.message) : status = Status.LOADING;
  BaseModel.completed(this.data) : status = Status.COMPLETED;
  BaseModel.error(this.message) : status = Status.ERROR;*/

  setException(ServerError error) {
    this.error = error;
  }

  setData(T data) {
    this.data = data;
  }
}

/*
enum Status { LOADING, COMPLETED, ERROR }*/
