import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:country_picker/country_picker.dart';
import 'package:doctro/api/Retrofit_Api.dart';
import 'package:doctro/api/network_api.dart';
import 'package:doctro/const/prefConstatnt.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'Bookappointment.dart';
import '../const/preference.dart';
import 'api/base_model.dart';
import 'api/server_error.dart';
import 'const/Palette.dart';
import 'const/app_string.dart';
import 'localization/localization_constant.dart';
import 'model/UpdateProfile.dart';
import 'model/UpdateUserImage.dart';
import 'model/UserDetail.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool loading = false;

  List<String> gender = ['MALE', 'FEMALE','ذكر','إناثا'];


  String? _selectGender;
  String? selectDate;
  String name = "";
  String? image = "";
  String? email = "";
  String? msg = "";

  String newDateApiPass = "";
  String newDateUser = "";

  DateTime? _selectedDate;

  File? _proImage;
  final picker = ImagePicker();

  late var temp;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController _name = TextEditingController();
  TextEditingController _phoneCode = TextEditingController();
  TextEditingController _phoneNo = TextEditingController();
  TextEditingController _dateOfBirth = TextEditingController();

  @override
  void initState() {
    super.initState();
    callApiUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    double width;
    double height;
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    Size size = MediaQuery.of(context).size;
    return ModalProgressHUD(
      inAsyncCall: loading,
      opacity: 0.5,
      progressIndicator: SpinKitFadingCircle(
        color: Palette.blue,
        size: 50.0,
      ),
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size(width * 0.3, height * 0.05),
          child: SafeArea(
            top: true,
            child: Container(
              alignment: Alignment.topRight,
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: GestureDetector(
                child: Icon(Icons.arrow_back_ios),
                onTap: () {
                  Navigator.pushNamed(context, 'Home');
                },
              ),
            ),
          ),
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  Container(
                    decoration: new BoxDecoration(
                      shape: BoxShape.circle, // BoxShape.circle or BoxShape.retangle
                      boxShadow: [
                        new BoxShadow(
                          color: Palette.blue,
                          blurRadius: 1.0,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 85,
                          width: 85,
                          child: Stack(
                            clipBehavior: Clip.none,
                            fit: StackFit.expand,
                            children: [
                              _proImage != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child: Image.file(
                                        _proImage!,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : CachedNetworkImage(
                                      alignment: Alignment.center,
                                      imageUrl: image!,
                                      imageBuilder: (context, imageProvider) => CircleAvatar(
                                        radius: 50,
                                        backgroundColor: Palette.white,
                                        child: CircleAvatar(
                                          radius: 35,
                                          backgroundImage: imageProvider,
                                        ),
                                      ),
                                      placeholder: (context, url) => SpinKitFadingCircle(color: Palette.blue),
                                      errorWidget: (context, url, error) => ClipRRect(
                                        borderRadius: BorderRadius.circular(50),
                                        child: Image.asset("assets/images/no_image.jpg"),
                                      ),
                                      height: 85,
                                      width: 85,
                                      fit: BoxFit.fitHeight,
                                    ),
                              Positioned(
                                top: 50,
                                left: 65,
                                child: GestureDetector(
                                  onTap: () {
                                    _chooseProfileImage();
                                  },
                                  child: CircleAvatar(
                                    backgroundColor: Palette.dark_grey,
                                    radius: 12,
                                    child: Icon(
                                      Icons.add,
                                      color: Palette.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Form(
                    key: _formKey,
                    child: Container(
                      margin: EdgeInsets.only(top: size.height * 0.03),
                      width: width * 0.9,
                      child: Column(
                        children: [
                          Container(
                            alignment: AlignmentDirectional.topStart,
                            child: Text(
                              getTranslated(context, profile_name).toString(),
                              style: TextStyle(fontSize: width * 0.04, color: Palette.blue, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            height: height * 0.05,
                            child: TextFormField(
                              textCapitalization: TextCapitalization.sentences,
                              textAlignVertical: TextAlignVertical.bottom,
                              style: TextStyle(fontSize: width * 0.04, color: Palette.dark_blue, fontWeight: FontWeight.bold),
                              controller: _name,
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9]'))],
                              decoration: InputDecoration(
                                hintText: getTranslated(context, profile_name_hint).toString(),
                                hintStyle: TextStyle(
                                  fontSize: width * 0.04,
                                  color: Palette.dark_grey1,
                                ),
                              ),
                              validator: (String? value) {
                                if (value!.isEmpty) {
                                  return getTranslated(context, profile_name_validator).toString();
                                }
                                return null;
                              },
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: size.height * 0.02),
                            alignment: AlignmentDirectional.topStart,
                            child: Text(
                              getTranslated(context, profile_phoneNo).toString(),
                              style: TextStyle(fontSize: width * 0.04, color: Palette.blue, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                width: width * 0.2,
                                height: height * 0.05,
                                margin: EdgeInsets.symmetric(horizontal: 9),
                                child: TextFormField(
                                  keyboardType: TextInputType.phone,
                                  textAlign: TextAlign.center,
                                  textAlignVertical: TextAlignVertical.bottom,
                                  readOnly: true,
                                  style: TextStyle(fontSize: 16, color: Palette.dark_blue, fontWeight: FontWeight.bold),
                                  controller: _phoneCode,
                                  decoration: InputDecoration(
                                    hintText: '+91',
                                    hintStyle: TextStyle(
                                      fontSize: width * 0.04,
                                      color: Palette.dark_grey1,
                                    ),
                                  ),
                                  onTap: () {
                                    showCountryPicker(
                                      context: context,
                                      //Optional.  Can be used to exclude(remove) one ore more country from the countries list (optional).
                                      exclude: <String>['KN', 'MF'],
                                      //Optional. Shows phone code before the country name.
                                      showPhoneCode: true,
                                      onSelect: (Country country) {
                                        _phoneCode.text = "+" + country.phoneCode;
                                      },
                                      // Optional. Sets the theme for the country list picker.
                                      countryListTheme: CountryListThemeData(
                                        // Optional. Sets the border radius for the bottomsheet.
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(40.0),
                                          topRight: Radius.circular(40.0),
                                        ),
                                        // Optional. Styles the search field.
                                        inputDecoration: InputDecoration(
                                          labelText: getTranslated(context, profile_phoneCode_search).toString(),
                                          // 'Search',
                                          hintText: getTranslated(context, profile_phoneCode_hint).toString(),
                                          // 'Start typing to search',
                                          prefixIcon: const Icon(Icons.search),
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Palette.grey.withOpacity(0.2),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Container(
                                width: width * 0.65,
                                height: height * 0.05,
                                child: TextFormField(
                                  keyboardType: TextInputType.phone,
                                  textAlignVertical: TextAlignVertical.bottom,
                                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9]'))],
                                  style: TextStyle(fontSize: 16, color: Palette.dark_blue, letterSpacing: 0.5, fontWeight: FontWeight.bold),
                                  controller: _phoneNo,
                                  decoration: InputDecoration(
                                    hintText: getTranslated(context, profile_phoneNo_hint).toString(),
                                    hintStyle: TextStyle(
                                      fontSize: width * 0.04,
                                      color: Palette.dark_grey1,
                                    ),
                                  ),
                                  validator: (String? value) {
                                    if (value!.isEmpty) {
                                      return getTranslated(context, profile_phoneNo_validation1).toString();
                                    }
                                    if (value.length != 10) {
                                      return getTranslated(context, profile_phoneNo_validation2).toString();
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          Container(
                            margin: EdgeInsets.only(top: size.height * 0.02),
                            alignment: AlignmentDirectional.topStart,
                            child: Text(
                              getTranslated(context, profile_dateOfBirth).toString(),
                              style: TextStyle(fontSize: width * 0.04, color: Palette.blue, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            height: height * 0.05,
                            child: TextFormField(
                              textCapitalization: TextCapitalization.words,
                              textAlignVertical: TextAlignVertical.bottom,
                              focusNode: AlwaysDisabledFocusNode(),
                              style: TextStyle(fontSize: 16, color: Palette.dark_blue, fontWeight: FontWeight.bold),
                              controller: _dateOfBirth,
                              decoration: InputDecoration(
                                hintText: getTranslated(context, profile_dateOfBirth_hint).toString(),
                                hintStyle: TextStyle(
                                  fontSize: width * 0.04,
                                  color: Palette.dark_grey1,
                                ),
                              ),
                              onTap: () {
                                _selectDate(context);
                              },
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: size.height * 0.02),
                            alignment: AlignmentDirectional.topStart,
                            child: Text(
                              getTranslated(context, profile_gender).toString(),
                              style: TextStyle(fontSize: width * 0.04, color: Palette.blue, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            height: height * 0.05,
                            child: DropdownButtonFormField(
                              hint: Text(
                                getTranslated(context, profile_gender_hint).toString(),
                                style: TextStyle(fontSize: width * 0.04, color: Palette.dark_grey1, fontWeight: FontWeight.bold),
                              ),
                              value: _selectGender,
                              isExpanded: true,
                              iconSize: 25,
                              onSaved: (dynamic value) {
                                setState(
                                  () {
                                    _selectGender = value;
                                  },
                                );
                              },
                              onChanged: (dynamic newValue) {
                                setState(
                                  () {
                                    _selectGender = newValue;
                                  },
                                );
                              },
                              validator: (dynamic value) =>
                                  value == null ? getTranslated(context, profile_gender_validator).toString() : null,
                              items: gender.map(
                                (location) {
                                  return DropdownMenuItem<String>(
                                    child: new Text(
                                      location,
                                      style: TextStyle(fontSize: width * 0.04, color: Palette.dark_blue, fontWeight: FontWeight.bold),
                                    ),
                                    value: location,
                                  );
                                },
                              ).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: Container(
          height: height * 0.05,
          child: ElevatedButton(
            child: Text(
              getTranslated(context, profile_save_button).toString(),
              style: TextStyle(
                fontSize: width * 0.04,
                color: Palette.white,
              ),
            ),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                callApiUpdateProfile();
              } else {
                print('Not update');
              }
            },
          ),
        ),
      ),
    );
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
        _name.text = response.name!;
        _phoneCode.text = response.phoneCode!;
        _phoneNo.text = response.phone!;
        selectDate = response.dob;
        _selectGender = response.gender!.toUpperCase();
        image = response.fullImage;
        email = response.email;

        // Date Formate Display user
        newDateUser = DateUtil().formattedDate(DateTime.parse(selectDate!));
        _dateOfBirth.text = newDateUser;
      });
    } catch (error, stacktrace) {
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  _selectDate(BuildContext context) async {
    DateTime? newSelectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate != null ? _selectedDate! : DateTime.now(),
      firstDate: DateTime(1950, 1),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.light(
              primary: Palette.blue,
              onPrimary: Palette.white,
              surface: Palette.blue,
              onSurface: Palette.light_black,
            ),
            dialogBackgroundColor: Palette.white,
          ),
          child: child!,
        );
      },
    );
    if (newSelectedDate != null) {
      _selectedDate = newSelectedDate;
      _dateOfBirth
        ..text = DateFormat('dd-MM-yyyy').format(_selectedDate!)
        ..selection = TextSelection.fromPosition(
          TextPosition(offset: _dateOfBirth.text.length, affinity: TextAffinity.upstream),
        );
    }
  }

  Future<BaseModel<UpdateProfile>> callApiUpdateProfile() async {
    UpdateProfile response;
    if (_selectedDate != null) {
      temp = '$_selectedDate';
    } else {
      temp = '$selectDate';
    }
    newDateApiPass = DateUtilforpass().formattedDate(DateTime.parse(temp));
    Map<String, dynamic> body = {
      "name": _name.text,
      "phone_code": _phoneCode.text,
      "phone": _phoneNo.text,
      "dob": newDateApiPass,
      "gender": _selectGender,
      "language": Preferences.current_language_code,
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
            Navigator.pushNamed(context, 'Home');
          });
        }
      });
    } catch (error, stacktrace) {
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<UpdateUserImage>> callApiUpdateImage() async {
    UpdateUserImage response;
    Map<String, dynamic> body = {
      "image": image,
    };
    setState(() {
      loading = true;
    });
    try {
      response = await RestClient(RetroApi().dioData()).updateUserImageRequest(body);
      setState(() {
        if (response.success == true) {
          setState(() {
            loading = false;
            msg = response.data;
            Fluttertoast.showToast(
              msg: '$msg',
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

  void _proImgFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(
      () {
        if (pickedFile != null) {
          SharedPreferenceHelper.setString(Preferences.image, pickedFile.path);
          _proImage = File(SharedPreferenceHelper.getString(Preferences.image)!);
          List<int> imageBytes = _proImage!.readAsBytesSync();
          image = base64Encode(imageBytes);
          callApiUpdateImage();
        } else {
          print('No image selected.');
        }
      },
    );
  }

  void _proImgFromCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        SharedPreferenceHelper.setString(Preferences.image, pickedFile.path);
        _proImage = File(SharedPreferenceHelper.getString(Preferences.image)!);
        List<int> imageBytes = _proImage!.readAsBytesSync();
        image = base64Encode(imageBytes);
        callApiUpdateImage();
      } else {
        print('No image selected.');
      }
    });
  }

  void _chooseProfileImage() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Container(
            child: new Wrap(
              children: <Widget>[
                new ListTile(
                    leading: new Icon(Icons.photo_library),
                    title: new Text(
                      "From Gallery",
                    ),
                    onTap: () {
                      _proImgFromGallery();
                      Navigator.of(context).pop();
                    }),
                new ListTile(
                  leading: new Icon(Icons.photo_camera),
                  title: new Text(
                    "From Camera",
                  ),
                  onTap: () {
                    _proImgFromCamera();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
