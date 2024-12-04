import 'dart:async';

import 'package:background_locator_2/location_dto.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:testing_app/home/controller/home_controller.dart';

import 'location_service_repository.dart';

var homeController = Get.put(HomeController());
class LocationCallbackHandler {

  static Future<void> initCallback(Map<dynamic, dynamic> params) async {
    LocationServiceRepository myLocationCallbackRepository =
    LocationServiceRepository();
    await myLocationCallbackRepository.init(params);
  }

  static Future<void> disposeCallback() async {
    LocationServiceRepository myLocationCallbackRepository =
    LocationServiceRepository();
    await myLocationCallbackRepository.dispose();
  }

  static Future<void> callback(LocationDto locationDto) async {
    LocationServiceRepository myLocationCallbackRepository =
    LocationServiceRepository();
    latitude = locationDto.latitude;
    longitude = locationDto.longitude;
    homeController.lat.value = locationDto.latitude;
    homeController.long.value = locationDto.longitude;
   // debugPrint('hehe>>>>>>>>>>>>> $latitute: $longitude');
    await myLocationCallbackRepository.callback(locationDto);
  }

  static Future<void> notificationCallback() async {
    print('***notificationCallback');
  }
}