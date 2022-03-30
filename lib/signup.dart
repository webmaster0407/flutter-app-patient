import 'package:country_picker/country_picker.dart';
import 'package:doctro/api/Retrofit_Api.dart';
import 'package:doctro/api/network_api.dart';
import 'package:doctro/phoneverification.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'Bookappointment.dart';
import 'api/base_model.dart';
import 'api/server_error.dart';
import 'const/Palette.dart';
import 'const/app_string.dart';
import 'localization/localization_constant.dart';
import 'model/register.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  TextEditingController _name = TextEditingController();
  TextEditingController _email = TextEditingController();
  TextEditingController _phone = TextEditingController();
  TextEditingController _phoneCode = TextEditingController();
  TextEditingController _dob = TextEditingController();
  TextEditingController _password = TextEditingController();

  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  bool _isHidden = true;

  DateTime? _selectedDate;
  List<String> gender = [];
  String? _selectGender;
  int? id;
  int? verify;

  String newDateApiPass = "";
  var temp;

  @override
  void initState() {
    // TODO: implement initState
    _phoneCode.text = "+20";
    super.initState();
    Future.delayed(Duration.zero, () {
      gender = [getTranslated(context, signUp_male).toString(), getTranslated(context, signUp_female).toString()];
    });
  }

  @override
  Widget build(BuildContext context) {
    double width;
    double height;
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(width, height * 0.05),
        child: SafeArea(
          child: Container(
            alignment: AlignmentDirectional.topStart,
            child: GestureDetector(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Icon(Icons.arrow_back_ios),
              ),
              onTap: () {
                Navigator.pop(context);
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
            child: Form(
              key: _formkey,
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: size.height * 0.04, left: width * 0.073, right: width * 0.073),
                    child: Text(
                      getTranslated(context, signUp_title).toString(),
                      style: TextStyle(fontSize: width * 0.07, fontWeight: FontWeight.bold, color: Palette.dark_blue),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: width * 0.020, right: width * 0.020, top: size.height * 0.027),
                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: size.height * 0.01, left: width * 0.05, right: width * 0.05),
                          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 2),
                          decoration: BoxDecoration(color: Palette.dark_white, borderRadius: BorderRadius.circular(10)),
                          child: TextFormField(
                            controller: _name,
                            keyboardType: TextInputType.text,
                           // inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[a-zA-Z ]'))],
                            textCapitalization: TextCapitalization.words,
                            style: TextStyle(
                              fontSize: 16,
                              color: Palette.dark_blue,
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: getTranslated(context, signUp_userName_hint).toString(),
                              hintStyle: TextStyle(
                                fontSize: width * 0.04,
                                color: Palette.dark_grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            validator: (String? value) {
                              value!.trim();
                              if (value.isEmpty) {
                                return getTranslated(context, signUp_userName_validator1).toString();
                              } else if (value.trim().length < 1) {
                                return getTranslated(context, signUp_userName_validator2).toString();
                              }
                              return null;
                            },
                            onSaved: (String? name) {},
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: size.height * 0.01, left: width * 0.05, right: width * 0.05),
                          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 2),
                          decoration: BoxDecoration(color: Palette.dark_white, borderRadius: BorderRadius.circular(10)),
                          child: TextFormField(
                            controller: _email,
                            keyboardType: TextInputType.text,
                            style: TextStyle(
                              fontSize: 16,
                              color: Palette.dark_blue,
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: getTranslated(context, signUp_email_hint).toString(),
                              hintStyle: TextStyle(fontSize: width * 0.04, color: Palette.dark_grey, fontWeight: FontWeight.bold),
                            ),
                            validator: (String? value) {
                              if (value!.isEmpty) {
                                return getTranslated(context, signUp_email_validator1).toString();
                              }
                              if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value)) {
                                return getTranslated(context, signUp_email_validator1).toString();
                              }
                              return null;
                            },
                            onSaved: (String? name) {},
                          ),
                        ),
                        Container(
                          child: Row(
                            children: [
                              Container(
                                width: width * 0.21,
                                height: height * 0.06,
                                padding: EdgeInsets.symmetric(horizontal: 9, vertical: 2),
                                margin: EdgeInsets.only(
                                  top: height * 0.01,
                                  left: width * 0.05,
                                  right: width * 0.05,
                                ),
                                decoration: BoxDecoration(
                                  color: Palette.dark_white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: TextFormField(
                                  keyboardType: TextInputType.phone,
                                  textAlign: TextAlign.center,
                                  readOnly: true,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Palette.dark_blue,
                                  ),
                                  controller: _phoneCode,
                                  decoration: InputDecoration(
                                    hintText: '+20',
                                    border: InputBorder.none,
                                    hintStyle: TextStyle(fontSize: width * 0.04, color: Palette.dark_grey, fontWeight: FontWeight.bold),
                                  ),
                                  onTap: () {
                                    /*showCountryPicker(
                                      context: context,
                                      exclude: <String>['KN', 'MF'],
                                      showPhoneCode: true,
                                      onSelect: (Country country) {
                                        _phoneCode.text = "+" + country.phoneCode;
                                      },
                                      countryListTheme: CountryListThemeData(
                                        // Optional. Sets the border radius for the bottomsheet.
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(40.0),
                                          topRight: Radius.circular(40.0),
                                        ),
                                        inputDecoration: InputDecoration(
                                          labelText: getTranslated(context, signUp_phoneCode_label).toString(),
                                          // 'Search',
                                          hintText: getTranslated(context, signUp_phoneCode_hint).toString(),
                                          // 'Start typing to search',
                                          prefixIcon: const Icon(Icons.search),
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Palette.grey.withOpacity(0.2),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );*/
                                  },
                                ),
                              ),
                              Container(
                                width: width * 0.60,
                                height: height * 0.06,
                                margin: EdgeInsets.only(
                                  top: size.height * 0.01,
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 2),
                                decoration: BoxDecoration(color: Palette.dark_white, borderRadius: BorderRadius.circular(10)),
                                child: TextFormField(
                                  controller: _phone,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                                    LengthLimitingTextInputFormatter(10)
                                  ],
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Palette.dark_blue,
                                  ),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: getTranslated(context, signUp_phoneNo_hint).toString(),
                                    hintStyle: TextStyle(
                                      fontSize: width * 0.04,
                                      color: Palette.dark_grey,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  validator: (String? value) {
                                    if (value!.isEmpty) {
                                      return getTranslated(context, signUp_phoneNo_validator1).toString();
                                    }
                                    if (value.length != 10) {
                                      return getTranslated(context, signUp_phoneNo_validator2).toString();
                                    }
                                    return null;
                                  },
                                  onSaved: (String? name) {},
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: size.height * 0.01, left: width * 0.05, right: width * 0.05),
                          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 2),
                          decoration: BoxDecoration(color: Palette.dark_white, borderRadius: BorderRadius.circular(10)),
                          child: TextFormField(
                            readOnly : true,
                            textCapitalization: TextCapitalization.words,
                            style: TextStyle(
                              fontSize: 16,
                              color: Palette.dark_blue,
                            ),
                            controller: _dob,
                            decoration: InputDecoration(
                              hintText: getTranslated(context, signUp_birthDate_hint).toString(),
                              border: InputBorder.none,
                              hintStyle: TextStyle(fontSize: width * 0.04, color: Palette.dark_grey, fontWeight: FontWeight.bold),
                            ),
                            validator: (String? value) {
                              if (value!.isEmpty) {
                                return getTranslated(context, signUp_birthDate_validator1).toString();
                              }
                              return null;
                            },
                            onTap: () {
                              _selectDate(context);
                            },
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: size.height * 0.01, left: width * 0.05, right: width * 0.05),
                          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 2),
                          decoration: BoxDecoration(color: Palette.dark_white, borderRadius: BorderRadius.circular(10)),
                          child: DropdownButtonFormField(
                            style: TextStyle(
                              fontSize: 16,
                              color: Palette.dark_blue,
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: getTranslated(context, signUp_selectGender_hint).toString(),
                              hintStyle: TextStyle(fontSize: width * 0.04, color: Palette.dark_grey, fontWeight: FontWeight.bold),
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
                                value == null ? getTranslated(context, signUp_selectGender_validator).toString() : null,
                            items: gender.map(
                              (location) {
                                return DropdownMenuItem<String>(
                                  child: new Text(
                                    location,
                                    style: TextStyle(
                                      fontSize: width * 0.04,
                                      color: Palette.dark_blue,
                                    ),
                                  ),
                                  value: location,
                                );
                              },
                            ).toList(),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: size.height * 0.01, left: width * 0.05, right: width * 0.05),
                          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 2),
                          decoration: BoxDecoration(color: Palette.dark_white, borderRadius: BorderRadius.circular(10)),
                          child: TextFormField(
                            controller: _password,
                            keyboardType: TextInputType.text,
                            inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9]'))],
                            style: TextStyle(
                              fontSize: 16,
                              color: Palette.dark_blue,
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: getTranslated(context, signUp_password_hint).toString(),
                              hintStyle: TextStyle(
                                fontSize: width * 0.04,
                                color: Palette.dark_grey,
                                fontWeight: FontWeight.bold,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isHidden ? Icons.visibility : Icons.visibility_off,
                                  color: Palette.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isHidden = !_isHidden;
                                  });
                                },
                              ),
                            ),
                            obscureText: _isHidden,
                            validator: (String? value) {
                              if (value!.isEmpty) {
                                return getTranslated(context, signUp_password_validator1).toString();
                              }
                              if (value.length < 6) {
                                return getTranslated(context, signUp_password_validator2).toString();
                              }
                              return null;
                            },
                            onSaved: (String? name) {},
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: width * 1,
                    height: 40,
                    margin: EdgeInsets.all(20),
                    padding: EdgeInsets.symmetric(horizontal: width * 0.04, vertical: 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ElevatedButton(
                      child: Text(
                        getTranslated(context, signUp_signUp_button).toString(),
                        style: TextStyle(fontSize: width * 0.045),
                        textAlign: TextAlign.center,
                      ),
                      onPressed: () {
                        if (_formkey.currentState!.validate()) {
                          callApiRegister();
                        } else {
                          print("Unsuccessful");
                        }
                      },
                    ),
                  ),
                  Container(
                    child: Text(
                      getTranslated(context, signUp_text).toString(),
                      style: TextStyle(fontSize: width * 0.03, color: Palette.dark_blue),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: size.height * 0.040),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Text(
                              getTranslated(context, signUp_alreadyAccount).toString(),
                              style: TextStyle(fontSize: width * 0.035, color: Palette.dark_blue),
                            ),
                          ],
                        ),
                        Container(
                          margin: EdgeInsets.only(left: width * 0.009),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacementNamed(context, 'SignIn');
                                },
                                child: Text(
                                  getTranslated(context, signUp_signIn_button).toString(),
                                  style: TextStyle(color: Palette.blue, fontWeight: FontWeight.bold, fontSize: width * 0.035),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<BaseModel<Register>> callApiRegister() async {
    Register response;
    newDateApiPass = DateUtilforpass().formattedDate(DateTime.parse('$_selectedDate'));
    Map<String, dynamic> body = {
      "name": _name.text,
      "email": _email.text,
      "phone": _phone.text,
      "dob": newDateApiPass,
      "gender": _selectGender,
      "password": _password.text,
      "phone_code": _phoneCode.text,
    };
    try {
      response = await RestClient(RetroApi2().dioData2()).registerRequest(body);
      setState(() {
        id = response.data!.id;
        response.data!.verify != 1
            ? Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => PhoneVerification(id: id),
                ),
              )
            : Navigator.pushReplacementNamed(context, "SignIn");
        Fluttertoast.showToast(
          msg: getTranslated(context, signUp_successFully_toast).toString() + " " + '${response.data!.name}',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Palette.blue,
          textColor: Palette.white,
        );
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
      _dob
        ..text = DateFormat('dd-MM-yyyy').format(_selectedDate!)
        ..selection = TextSelection.fromPosition(
          TextPosition(offset: _dob.text.length, affinity: TextAffinity.upstream),
        );
    }
  }
}
