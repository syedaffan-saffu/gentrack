import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';
import 'package:testing_app/loc/location_callback_handler.dart';

class GpsController extends GetxController {
  Location location = Location();

  Future<void> gpsEnable() async {
    bool ison = await location.serviceEnabled();
    if (!ison) {
      //if defvice is off
      bool isturnedon = await location.requestService();
      homeController.timer?.cancel();
      homeController.isLocationOn.value = false;
      if (isturnedon) {
        debugPrint("GPS device is turned ON");
      } else {
        homeController.timer?.cancel();
        homeController.isLocationOn.value = false;
        debugPrint("GPS Device is still OFF");
      }
    }
  }
}
