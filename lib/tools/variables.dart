import 'dart:ui';
import 'dart:io' show File, Platform, stdout;
import 'package:flutter/material.dart';

import 'dart:convert';
class MyColors{
  static const Color red = Color(0xffBF1744);
  static const Color darkBlue = Color(0xff0433BF);
  static const Color grey = Color(0xff434A59);
  static const Color deadBlue = Color(0xff558ED9);
  static const Color skyBlueDead = Color(0xffA7C8F2);
  static const Color black = Color(0xff151515);

}

class Constants{
  static String hostname = Platform.localHostname;
}

class Tools{
  static Radius radiusSize = Radius.circular(30);


  // static Future<File> downloadFile(String url, String filename) async {
  //   http.Client client = new http.Client();
  //   var req = await client.get(Uri.parse(url));
  //   var bytes = req.bodyBytes;
  //   String dir = './images';
  //   File file = new File('$dir/$filename');
  //   await file.writeAsBytes(bytes);
  //   return file;
  // }

  static getDeviceWidth(BuildContext context){
    return MediaQuery. of(context). size. width;
  }
  static getDeviceHeight(BuildContext context){
    return MediaQuery. of(context). size. height;
  }
  static Future<void> statefulDialog({
    required BuildContext context,
    required Widget Function(BuildContext,void Function(void Function())) builder,
    required Future<bool> Function() onPop
  }) async {

    return showDialog<void>(

      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: onPop,
          child: Container(
              alignment: Alignment.center,
              color: Colors.transparent,
              height: getDeviceHeight(context),
              width: getDeviceWidth(context),
              child: SingleChildScrollView(child: StatefulBuilder(builder: builder))
          ),
        );
      },
    );
  }




}
