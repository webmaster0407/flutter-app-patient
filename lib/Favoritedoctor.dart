import 'package:cached_network_image/cached_network_image.dart';
import 'package:doctro/model/ShowFavoriteDoctor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import '../api/Retrofit_Api.dart';
import '../api/network_api.dart';
import '../doctordetail.dart';
import 'api/base_model.dart';
import 'api/server_error.dart';
import 'const/Palette.dart';
import 'const/app_string.dart';
import 'localization/localization_constant.dart';
import 'model/FavoriteDoctor.dart';

class FavoriteDoctorScreen extends StatefulWidget {
  @override
  _FavoriteDoctorScreenState createState() => _FavoriteDoctorScreenState();
}

class _FavoriteDoctorScreenState extends State<FavoriteDoctorScreen> {
  bool loading = false;

  List<Data> favoriteDoctorList = [];
  int? doctorID = 0;

  @override
  void initState() {
    super.initState();
    callApiFavoriteDoctorList();
  }

  @override
  Widget build(BuildContext context) {
    double width;
    double height;
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return ModalProgressHUD(
      inAsyncCall: loading,
      opacity: 0.5,
      progressIndicator: SpinKitFadingCircle(
        color: Palette.blue,
        size: 50.0,
      ),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              size: 20,
              color: Palette.dark_blue,
            ),
            onPressed: () {
              Navigator.pushReplacementNamed(context, 'Home');
            },
          ),
          centerTitle: true,
          backgroundColor: Palette.white,
          title: Text(
            getTranslated(context, favoriteDoctor_title).toString(),
            style: TextStyle(fontSize: 18, color: Palette.dark_blue, fontWeight: FontWeight.bold),
          ),
        ),
        body: favoriteDoctorList.length != 0
            ? SingleChildScrollView(
                child: InkWell(
                  child: Container(
                    height: height * 0.9,
                    margin: EdgeInsets.only(top: 10),
                    child: ListView(
                      scrollDirection: Axis.vertical,
                      children: [
                        GridView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: favoriteDoctorList.length,
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 5, childAspectRatio: 0.9),
                          itemBuilder: (context, index) {
                            return favoriteDoctorList.length != 0
                                ? Column(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => DoctorDetail(
                                                id: favoriteDoctorList[index].id,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          width: width * 0.45,
                                          child: Card(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10.0),
                                            ),
                                            child: Container(
                                              margin: EdgeInsets.symmetric(vertical: width * 0.01),
                                              child: Column(
                                                children: [
                                                  Stack(
                                                    children: [
                                                      Container(
                                                        width: width * 0.4,
                                                        height: width * 0.4,
                                                        child: Container(
                                                          child: CachedNetworkImage(
                                                            alignment: Alignment.center,
                                                            imageUrl: favoriteDoctorList[index].fullImage!,
                                                            fit: BoxFit.fill,
                                                            placeholder: (context, url) => SpinKitFadingCircle(color: Palette.blue),
                                                            errorWidget: (context, url, error) => Image.asset("assets/images/no_image.jpg"),
                                                          ),
                                                        ),
                                                      ),
                                                      Positioned(
                                                        top: 0,
                                                        right: 0,
                                                        child: Container(
                                                          child: IconButton(
                                                            onPressed: () {
                                                              setState(
                                                                () {
                                                                  doctorID = favoriteDoctorList[index].id;
                                                                  setState(() {
                                                                    callApiFavoriteDoctor();
                                                                  });
                                                                },
                                                              );
                                                            },
                                                            icon: Icon(
                                                              Icons.favorite_outlined,
                                                              size: 25,
                                                              color: Palette.red,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Container(
                                                    margin: EdgeInsets.only(top: width * 0.02),
                                                    child: Column(
                                                      children: [
                                                        Text(
                                                          favoriteDoctorList[index].name!,
                                                          style: TextStyle(fontSize: width * 0.04, color: Palette.dark_blue),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Container(
                                                    child: favoriteDoctorList[index].treatment != null
                                                        ? Text(
                                                            favoriteDoctorList[index].treatment!.name.toString(),
                                                            style: TextStyle(fontSize: width * 0.035, color: Palette.grey),
                                                          )
                                                        : Text(
                                                            getTranslated(context, favoriteDoctor_notAvailable).toString(),
                                                            style: TextStyle(
                                                              fontSize: width * 0.035,
                                                              color: Palette.grey,
                                                            ),
                                                          ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  )
                                : Center(
                                    child: Text(
                                      getTranslated(context, favoriteDoctor_doctorNotAvailable).toString(),
                                    ),
                                  );
                          },
                        )
                      ],
                    ),
                  ),
                ),
              )
            : Container(
                child: Center(
                  child: Text(
                    getTranslated(context, favoriteDoctor_noFavoriteDoctor).toString(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Palette.dark_blue,
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Future<BaseModel<ShowFavoriteDoctor>> callApiFavoriteDoctorList() async {
    ShowFavoriteDoctor response;

    setState(() {
      loading = true;
    });
    try {
      response = await RestClient(RetroApi().dioData()).showFavoriteDoctorRequest();
      setState(() {
        if (response.success == true) {
          loading = false;
          favoriteDoctorList.clear();
          setState(() {
            favoriteDoctorList.addAll(response.data!);
          });
        }
      });
    } catch (error, stacktrace) {
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<BaseModel<FavoriteDoctor>> callApiFavoriteDoctor() async {
    FavoriteDoctor response;

    setState(() {
      loading = true;
    });
    try {
      response = await RestClient(RetroApi().dioData()).favoriteDoctorRequest(doctorID);
      setState(() {
        if (response.success == true) {
          setState(() {
            callApiFavoriteDoctorList();
            Fluttertoast.showToast(
              msg: '${response.msg}',
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
}
