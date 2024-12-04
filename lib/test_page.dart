import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class TestPage extends StatefulWidget {
  const TestPage({Key? key}) : super(key: key);

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  var latList = [];

void getpacagakeName()async{
  var packageInfo = await PackageInfo.fromPlatform();
  print('packageName: ${packageInfo.packageName}');
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Page'),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(onPressed: (){
              getpacagakeName();
            }, child: Text('getpacagakeName')),
          ],
        ),
      ),
    );
  }
}
