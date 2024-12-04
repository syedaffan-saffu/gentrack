import 'dart:async';

import 'package:background_locator_2/background_locator.dart';
import 'package:background_locator_2/location_dto.dart';
import 'package:background_locator_2/settings/android_settings.dart';
import 'package:background_locator_2/settings/ios_settings.dart';
import 'package:background_locator_2/settings/locator_settings.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:platform_device_id/platform_device_id.dart';

import '../../loc/location_callback_handler.dart';

var latitude = 0.0;
var longitude = 0.0;
LocationDto? locationDto;

class HomeController extends GetxController {
  late ConnectivityResult result;
  late StreamSubscription subscription;
  var deviceId = '22'.obs;
  var versionId = '44'.obs;
  RxBool isLocationOn = false.obs;
  RxBool isConnected = false.obs;
  List latLongList = [];
  var lat = 0.0.obs;
  var long = 0.0.obs;

  // var status =  Permission.location.status;
  var baseUrl =
      'https://gentecbspro.com/MobileApp/CoreAPI/api/values/InsertData';
  var dio = Dio();
  var response;
  Timer? timer, timer1,locTimer;

  // DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  //Check network connection
  checkInternet() async {
    homeController.result = await Connectivity().checkConnectivity();
    if (homeController.result != ConnectivityResult.none) {
      isConnected.value = true;
      timer1?.cancel();
      debugPrint('>>>>>>> Connected to the world <<<<<<<<<');
    } else {
      isConnected.value = false;
      timer1 = Timer.periodic(const Duration(seconds: 4), (timer) {
        latLongList.addAll({
          latitude,
          longitude,
        });
        for (var element in latLongList) {
          Future.delayed(const Duration(seconds: 5), () {
            debugPrint('>>>>>>>>>>>>> $element');
          });
        }
        debugPrint('adding the latlng after 5 sec ${latLongList.length}');
      });
      debugPrint('--------------> Disconnected <----------------');
      //showGetdialog();
    }
    // setState(() {});
  }

  //getting the loc permission
  Future<void> requestPermission() async {
    PermissionStatus status = await Permission.location.request();
    status = await Permission.locationAlways.request();
    if (status == PermissionStatus.denied) {
      timer?.cancel();
      debugPrint('>>>>>>> denied permission');
      /*Future.delayed(const Duration(seconds: 2), ()async {
        await openAppSettings();
      });*/
      isLocationOn.value = false;
      debugPrint('Permission is denied');
    } else if (status == PermissionStatus.permanentlyDenied) {
      timer?.cancel();
      isLocationOn.value = false;
      debugPrint('Permission is permanently denied');
      await openAppSettings();
    } else if (status == PermissionStatus.granted) {
      isLocationOn.value = true;
      debugPrint('Permission is granted.......');
    } else {
      debugPrint('Permission is granted');
    }
  }

  /*//getting the device id
  Future<AndroidDeviceInfo> getInfo() async {
    return await deviceInfo.androidInfo;
  }*/

  Future<void> getId() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    versionId.value = packageInfo.version;
    /*getInfo().then((value) {
      deviceId.value = value.id;
      versionId.value = packageInfo.version;
      // versionId.value = value.version.release;
      debugPrint(">>>>>>> id: $deviceId >>>>>>> version: $versionId");
    });*/
  }

  Future<void> getInfo() async {
    String? deviceID;
    try {
      deviceID = await PlatformDeviceId.getDeviceId;
      deviceId.value = deviceID!;
      debugPrint("deviceId->${deviceId.value}");
    } on PlatformException {
      deviceID = 'Failed to get deviceId.';
    }
  }

  Future<void> sendLatLong() async {
    try {
      response = await dio.post(
        baseUrl,
        data: {
          "SPNAME": "CRM_DataEntryGeolocationSP",
          "ReportQueryParameters": [
            "@nType",
            "@nsType",
            "@GPFormId",
            "@UserId",
            "@Latitude",
            "@Longitude",
            "@DocumentNo",
            "@Event"
          ],
          "ReportQueryValue": [
            "1",
            "2",
            "36",
            "${deviceId.value}",
            "$latitude",
            "$longitude",
            "${deviceId.value}",
            "${versionId.value}"
          ]
        },
      );
      print('>>>>>>>>> ${response.data}');
    } on DioError catch (e) {
      print('error >>>>>>>> ${e.response}');
    }
  }

  //initializing the background location
  Future<void> initPlatformState() async {
    print('Initializing...');
    await BackgroundLocator.initialize();
  }

  //getting the location data in background
  void startLocationService() {
    Map<String, dynamic> data = {'countInit': 1};

    BackgroundLocator.registerLocationUpdate(LocationCallbackHandler.callback,
        initCallback: LocationCallbackHandler.initCallback,
        initDataCallback: data,
        disposeCallback: LocationCallbackHandler.disposeCallback,
        autoStop: false,
        iosSettings: const IOSSettings(
            accuracy: LocationAccuracy.NAVIGATION, distanceFilter: 2),
        androidSettings: const AndroidSettings(
            accuracy: LocationAccuracy.NAVIGATION,
            interval: 5,
            distanceFilter: 0,
            wakeLockTime: 60,
            androidNotificationSettings: AndroidNotificationSettings(
                notificationChannelName: 'Location tracking',
                notificationTitle: 'Start Location Tracking',
                notificationMsg: 'Track location in background',
                notificationBigMsg: 'Update the location in background',
                notificationIcon: '',
                notificationIconColor: Colors.grey,
                notificationTapCallback:
                    LocationCallbackHandler.notificationCallback)));
  }

  Future<bool> onBackPressed() async {
    return await Get.defaultDialog(
      title: 'Are you sure?',
      middleText: 'Do you want to exit an App',
      textConfirm: 'Yes',
      textCancel: 'No',
      barrierDismissible: false,
      confirmTextColor: Colors.white,
      onConfirm: () {
        // stopLocationService();
        timer?.cancel();
        debugPrint('Location service stopped');
        Future.delayed(
          const Duration(seconds: 1),
          () {
            SystemNavigator.pop();
          },
        );
        Get.back(result: true);
      },
      onCancel: () => Get.back(result: false),
    );
  }

  //stop the service
  void stopLocationService() async {
    await BackgroundLocator.unRegisterLocationUpdate();
  }

  sendDataToApi() {
    timer = Timer.periodic(const Duration(minutes: 1), (t) {
      debugPrint('>>>>>> hit api again <<<<<<');
      sendLatLong();
    });
  }

  Future<void> deleteCacheDir() async {
    final cacheDir = await getTemporaryDirectory();
    if (cacheDir.existsSync()) {
      cacheDir.deleteSync(recursive: true);
    }
    final appDir = await getApplicationSupportDirectory();
    if (appDir.existsSync()) {
      appDir.deleteSync(recursive: true);
    }
  }

  delCache() {
    timer = Timer.periodic(const Duration(minutes: 15), (t) {
      debugPrint('>>>>>> del the cache <<<<<<');
      deleteCacheDir();
    });
  }

  void reInitLocService()async{
    locTimer = Timer.periodic(const Duration(minutes: 19), (t) {
      debugPrint('>>>>>> reInit the service <<<<<<');
      stopLocationService();
      Future.delayed(const Duration(seconds: 6), () {
        startLocationService();
      });
    });
  }
}
