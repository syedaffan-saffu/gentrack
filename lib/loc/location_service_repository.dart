import 'dart:async';
import 'dart:isolate';
import 'dart:math';
import 'dart:ui';

import 'package:background_locator_2/location_dto.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../home/controller/home_controller.dart';


class LocationServiceRepository {
  static final LocationServiceRepository _instance = LocationServiceRepository._();
  var homeController = Get.put(HomeController());
  LocationServiceRepository._();

  factory LocationServiceRepository() {
    return _instance;

  }

  static const String isolateName = 'LocatorIsolate';

  int _count = -1;

  Future<void> init(Map<dynamic, dynamic> params) async {
    //TODO change logs
    print("***********Init callback handler");
    //send data to api
    Future.wait([
    homeController.getInfo(),
      homeController.getId(),
    ]);

    Future.delayed(const Duration(seconds: 12), () {
      homeController.sendDataToApi();
    });
    Future.delayed(const Duration(minutes: 15), () {
      homeController.delCache();
    });
    Future.delayed(const Duration(minutes: 18), () {
      homeController.reInitLocService();
    });

    if (params.containsKey('countInit')) {
      dynamic tmpCount = params['countInit'];
      if (tmpCount is double) {
        _count = tmpCount.toInt();
      } else if (tmpCount is String) {
        _count = int.parse(tmpCount);
      } else if (tmpCount is int) {
        _count = tmpCount;
      } else {
        _count = -2;
      }
    } else {
      _count = 0;
    }
    print("$_count");
    await setLogLabel("start");
    final SendPort? send = IsolateNameServer.lookupPortByName(isolateName);
    send?.send(null);
  }

  Future<void> dispose() async {
    print("***********Dispose callback handler");
    homeController.timer?.cancel();
    homeController.timer1?.cancel();
    print("$_count");
    await setLogLabel("end");
    final SendPort? send = IsolateNameServer.lookupPortByName(isolateName);
    send?.send(null);
  }

  Future<void> callback(LocationDto locationDto) async {
    print('$_count location in dart: ${locationDto.toString()}');
    await setLogPosition(_count, locationDto);
    final SendPort? send = IsolateNameServer.lookupPortByName(isolateName);
    send?.send(locationDto);
    _count++;

  }

  static Future<void> setLogLabel(String label) async {
    final date = DateTime.now();
   /* await FileManager.writeToLogFile(
        '------------\n$label: ${formatDateLog(date)}\n------------\n');*/
  }

  static Future<void> setLogPosition(int count, LocationDto data) async {
    final date = DateTime.now();

   /* await FileManager.writeToLogFile(
        '$count : ${formatDateLog(date)} --> ${formatLog(data)} --- isMocked: ${data.isMocked}\n');*/
  }

  static double dp(double val, int places) {
    num mod = pow(10.0, places);
    return ((val * mod).round().toDouble() / mod);
  }

  static String formatDateLog(DateTime date) {
    return date.hour.toString() +
        ":" +
        date.minute.toString() +
        ":" +
        date.second.toString();
  }

  static String formatLog(LocationDto locationDto) {
    return dp(locationDto.latitude, 4).toString() +
        " " +
        dp(locationDto.longitude, 4).toString();
  }
}