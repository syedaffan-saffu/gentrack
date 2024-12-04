import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:testing_app/form/formpage.dart';
import 'package:testing_app/home/controller/home_controller.dart';
import 'package:testing_app/locpage/loc_page.dart';
import 'package:testing_app/utils/app_images.dart';

import '../../utils/network/controller/network_controller.dart';
import '../controller/gps_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var homeController = Get.put(HomeController());
  var gpsController = Get.put(GpsController());
  final NetworkController networkController = Get.find<NetworkController>();

  // var isConnected = false;

  @override
  void initState() {
    Future.wait([
      homeController.requestPermission(),
      homeController.initPlatformState(),
      gpsController.gpsEnable(),
      homeController.getInfo(),
      homeController.getId(),
    ]);
    Future.delayed(const Duration(seconds: 10), () {
      homeController.startLocationService();
      debugPrint('--------------> start <----------------');
    });
    startNetworkChange();
    Future.delayed(const Duration(seconds: 30), () {
      homeController.deleteCacheDir();
      debugPrint('--------------> delete the cache <----------------');
    });

    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    homeController.subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: homeController.onBackPressed,
      child: Scaffold(
        body: Container(
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(AppImages.MAIN_BG_IMAGE),
              fit: BoxFit.fill,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Obx(() {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    child: Container(
                      width: 220.h,
                      height: 30.h,
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(top: 270.w, left: 10.w),
                      padding: const EdgeInsets.only(left: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Device ID: ',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                          Text(
                            homeController.deviceId.value,
                            overflow: TextOverflow.clip,
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Clipboard.setData(ClipboardData(
                                  text: homeController.deviceId.value));
                              BotToast.showText(text: 'Copied');
                            },
                            icon: const Icon(
                              Icons.copy,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                Obx(() {
                  return Text(
                    'Version: ${homeController.versionId.value}',
                    style: TextStyle(color: Colors.black, fontSize: 16.sp),
                  );
                }),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 7.w),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Obx(() {
                        return SizedBox(
                          width: 30.w,
                          height: 32.h,
                          child: homeController.isLocationOn.isTrue
                              ? Image.asset(AppImages.LOCATION_ON_ICON)
                              : Image.asset(AppImages.LOCATION_OFF_ICON),
                        );
                      }),
                      Obx(() {
                        return SizedBox(
                          height: 35.h,
                          child: homeController.isConnected.isTrue
                              ? Image.asset(AppImages.INTERNET_ON_ICON)
                              : Image.asset(AppImages.INTERNET_OFF_ICON),
                        );
                      }),
                      IconButton(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => const FormScreen()
                                //  LocPage(
                                //   latlng: LatLng(25.5279312, 69.0830238),
                                // ),
                                ));
                          },
                          icon: Icon(Icons.person)),
                      IconButton(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => LocPage(
                                latlng: LatLng(25.5279312, 69.0830238),
                              ),
                            ));
                          },
                          icon: Icon(Icons.map))
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

/*  showGetdialog() {
    Get.defaultDialog(
        barrierDismissible: false,
        title: 'No Internet',
        middleText: 'Please check your internet connection',
        textConfirm: 'Ok',
        confirmTextColor: Colors.white,
        onConfirm: () {
          Get.back();
          checkInternet();
        });
  }*/

  startNetworkChange() {
    homeController.subscription =
        Connectivity().onConnectivityChanged.listen((event) async {
      homeController.checkInternet();
    });
  }
}
