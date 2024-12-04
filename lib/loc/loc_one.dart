import 'dart:isolate';

import 'package:background_locator_2/background_locator.dart';
import 'package:background_locator_2/location_dto.dart';
import 'package:background_locator_2/settings/android_settings.dart';
import 'package:background_locator_2/settings/ios_settings.dart';
import 'package:background_locator_2/settings/locator_settings.dart';
import 'package:flutter/material.dart';

import 'location_callback_handler.dart';

var lat = 0.0;
var long = 0.0;
class LocOne extends StatefulWidget {
  const LocOne({Key? key}) : super(key: key);

  @override
  State<LocOne> createState() => _LocOneState();
}

class _LocOneState extends State<LocOne> {
  static const String _isolateName = "LocatorIsolate";
  ReceivePort port = ReceivePort();

  String logStr = '';
  bool isRunning = false;
  LocationDto? lastLocation;
  Future<void> updateLatlongInBackground({LocationDto? locationDto})async{
    if(locationDto != null){
      setState(() {
        lat = locationDto.latitude;
        long = locationDto.longitude;
      });
      debugPrint('>>>>>>>>>>> $lat, $long <<<<<<<<<<<<<<');
      /*await BackgroundLocator.updateNotificationText(
          title: "new location received",
          msg: "${DateTime.now()}",
          bigMsg: "${locationDto.latitude}, ${locationDto.longitude}");*/
    }else{
      print('location is null');
    }

  }
  Future<void> initPlatformState() async {
    print('Initializing...');
    await BackgroundLocator.initialize();
  }

  @override
  void initState() {
    /*IsolateNameServer.registerPortWithName(port.sendPort, _isolateName);
    port.listen((dynamic data) {
      // do something with data
    });*/
    initPlatformState();
   // Future.wait([initPlatformState(),updateLatlongInBackground()]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              //elevated  button
              child: SizedBox(
                width: 150,
                height: 50,
                child: ElevatedButton(
                  child: const Text('GO'),
                  onPressed: (){
                    startLocationService();
                  },
                ),
              ),
            ),
            SizedBox(height: 20,),
            Center(
              //elevated  button
              child: SizedBox(
                width: 150,
                height: 50,
                child: ElevatedButton(
                  child: const Text('Stop'),
                  onPressed: (){
                   //stop service
                    stopLocationService();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void startLocationService(){
    Map<String, dynamic> data = {'countInit': 1};
    BackgroundLocator.registerLocationUpdate(LocationCallbackHandler.callback,
        initCallback: LocationCallbackHandler.initCallback,
        initDataCallback: data,
        disposeCallback: LocationCallbackHandler.disposeCallback,
        autoStop: false,
        iosSettings: const IOSSettings(
            accuracy: LocationAccuracy.NAVIGATION, distanceFilter: 0),
        androidSettings: const AndroidSettings(
            accuracy: LocationAccuracy.NAVIGATION,
            interval: 5,
            distanceFilter: 0,
            androidNotificationSettings: AndroidNotificationSettings(
                notificationChannelName: 'Location tracking',
                notificationTitle: 'Start Location Tracking',
                notificationMsg: 'Track location in background',
                notificationBigMsg:
                'Update the location in background',
                notificationIcon: '',
                notificationIconColor: Colors.grey,
                notificationTapCallback:
                LocationCallbackHandler.notificationCallback)));
  }

  void stopLocationService () {
    BackgroundLocator.unRegisterLocationUpdate();
  }

}
