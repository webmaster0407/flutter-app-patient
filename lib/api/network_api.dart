import 'package:doctro/model/AddAddress.dart';
import 'package:doctro/model/Appointments.dart';
import 'package:doctro/model/Banner.dart';
import 'package:doctro/model/BookMedicine.dart';
import 'package:doctro/model/CancelAppointment.dart';
import 'package:doctro/model/DeleteAddress.dart';
import 'package:doctro/model/DetailSetting.dart';
import 'package:doctro/model/DisplayOffer.dart';
import 'package:doctro/model/Docterdetail.dart';
import 'package:doctro/model/FavoriteDoctor.dart';
import 'package:doctro/model/ForgotPassword.dart';
import 'package:doctro/model/HealthTip.dart';
import 'package:doctro/model/HealthTipDetail.dart';
import 'package:doctro/model/MedicineOrderDetail.dart';
import 'package:doctro/model/MedicineOrderModel.dart';
import 'package:doctro/model/Medicinedetails.dart';
import 'package:doctro/model/Notification.dart';
import 'package:doctro/model/PharamaciesDetails.dart';
import 'package:doctro/model/ResendOtp.dart';
import 'package:doctro/model/Review.dart';
import 'package:doctro/model/ShowAddress.dart';
import 'package:doctro/model/ShowFavoriteDoctor.dart';
import 'package:doctro/model/Timeslot.dart';
import 'package:doctro/model/TreatmentWishDoctor.dart';
import 'package:doctro/model/Treatments.dart';
import 'package:doctro/model/UpdateProfile.dart';
import 'package:doctro/model/UpdateUserImage.dart';
import 'package:doctro/model/UserDetail.dart';
import 'package:doctro/model/apply_offer.dart';
import 'package:doctro/model/changepassword.dart';
import 'package:doctro/model/hospitals.dart';
import 'package:doctro/model/pharamacies.dart';
import 'package:doctro/model/prescription.dart';
import 'package:doctro/model/register.dart';
import 'package:doctro/model/show_video_call_history_model.dart';
import 'package:doctro/model/video_call_model.dart';
import 'package:retrofit/retrofit.dart';
import 'package:doctro/model/login.dart';
import 'package:dio/dio.dart';
import 'package:doctro/model/doctors.dart';
import 'package:doctro/model/bookappointments.dart';
import 'package:doctro/model/Checkotp.dart';
import 'package:retrofit/http.dart';

import 'apis.dart';

part 'network_api.g.dart';

@RestApi(baseUrl: Apis.baseUrl)

abstract class RestClient {
  factory RestClient(Dio dio,{String? baseUrl}) = _RestClient;

  @POST(Apis.login)
  Future<Login> loginRequest(@Body() body);

  @POST(Apis.register)
  Future<Register> registerRequest(@Body() body);

  @POST(Apis.doctors_list)
  Future<Doctors> doctorList(@Body() body);

  @GET(Apis.hospitals_list)
  Future<Hospitals> hospitalList ();

  @GET(Apis.doctor_detail)
  Future<Doctordetails> doctorDetailRequest(@Path() int? id);

  @GET(Apis.healthTip)
  Future<HealthTip> healthTipRequest();

  @GET(Apis.healthTip_detail)
  Future<HealthTipDetails> healthTipDetailRequest(@Path() int? id);

  @GET(Apis.treatment_list)
  Future<Treatments> treatmentsRequest();

  @GET(Apis.book_appointment_list)
  Future<Appointments> appointmentsRequest();

  @GET(Apis.medicine_detail)
    Future<Medicinedetails> medicineDetails(@Path() int? id);

  @POST(Apis.user_book_appointment)
  Future<Bookappointments> bookAppointment(@Body() body);

  @POST(Apis.check_otp)
  Future<Checkotp> checkOtp(@Body() body);

  @POST(Apis.timeSlot)
  Future<Timeslot> timeslot(@Body() body);

  @POST(Apis.add_address)
  Future<AddAddress> addAddressRequest(@Body() body);

  @GET(Apis.show_address)
  Future<ShowAddress> showAddressRequest();

  @GET(Apis.delete_address)
  Future<DeleteAddress> deleteAddressRequest(@Path() int? id);

  @GET(Apis.user_detail)
  Future<UserDetail> userDetailRequest();

  @GET(Apis.setting)
  Future<DetailSetting> settingRequest();

  @GET(Apis.all_pharamacy)
  Future<Pharamacy> pharamacyRequest();

  @GET(Apis.pharamacy_detail)
  Future<PharamaciesDetails> pharmacyDetailRequest(@Path() int? id);

  @POST(Apis.book_medicine)
  Future<BookMedicine> bookMedicineRequest(@Body() body);

  @POST(Apis.add_review)
  Future<ReviewAppointment> addReviewRequest(@Body() body);

  @POST(Apis.cancel_appointment)
  Future<CancelAppointment> cancelAppointmentRequest(@Body() body);

  @GET(Apis.medicine_order_list)
  Future<MedicineOrderModel> medicineOrderRequest();

  @POST(Apis.update_profile)
  Future<UpdateProfile> updateProfileRequest(@Body() body);

  @GET(Apis.medicine_order_detail)
  Future<MedicineOrderDetails>  medicineOrderDetailRequest(@Path() int? id);

  @GET(Apis.offer)
  Future<DisplayOffer> displayOfferRequest();

  @POST(Apis.treatmentWise_doctor)
  Future<TreatmentWishDoctor> treatmentWishDoctorRequest(@Path() int? id,@Body() body);

  @POST(Apis.update_image)
  Future<UpdateUserImage> updateUserImageRequest(@Body() body);

  @GET(Apis.user_notification)
  Future<UserNotification> notificationRequest();

  @GET(Apis.banner)
    Future<Banners> bannerRequest();

  @GET(Apis.add_favorite_doctor)
  Future<FavoriteDoctor> favoriteDoctorRequest(@Path() int? id);

  @GET(Apis.show_favorite_doctor)
  Future<ShowFavoriteDoctor> showFavoriteDoctorRequest();

  @POST(Apis.forgot_password)
  Future<ForgotPassword> forgotPasswordRequest(@Body() body);

  @POST(Apis.apply_offer)
  Future<ApplyOffer> applyOfferRequest(@Body() body);

  @POST(Apis.change_password)
  Future<ChangePasswords> changePasswordRequest(@Body() body);

  @GET(Apis.resend_otp)
  Future<ResendOtp> resendOtpRequest(@Path() int? id);

  @GET(Apis.prescription)
  Future<PrescriptionModel> prescriptionRequest(@Path() int? id);

  @POST(Apis.videoCallToken)
  Future<VideoCallModel> videoCallRequest(@Body() body);

  @GET(Apis.ShowVideoCallHistory)
  Future<ShowVideoCallHistoryModel> showVideoCallHistoryRequest();
}


