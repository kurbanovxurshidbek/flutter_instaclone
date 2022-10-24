import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:instaclone/services/prefs_service.dart';
import 'package:platform_device_id/platform_device_id.dart';

class Utils {

  static Future<void> showLocalNotification(String title, String body) async {
    var android = const AndroidNotificationDetails("channelId", "channelName",
        channelDescription: "channelDescription");
    var iOS = const IOSNotificationDetails();
    var platform = NotificationDetails(android: android, iOS: iOS);

    int id = Random().nextInt((pow(2, 31) - 1).toInt());
    await FlutterLocalNotificationsPlugin().show(id, title, body, platform);
  }

  static void fireToast(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  static Future<Map<String, String>> deviceParams() async {
    Map<String, String> params = {};
    var getDeviceId = await PlatformDeviceId.getDeviceId;
    String fcmToken = await Prefs.loadFCM();

    if (Platform.isIOS) {
      params.addAll({
        'device_id': getDeviceId!,
        'device_type': "I",
        'device_token': fcmToken,
      });
    } else {
      params.addAll({
        'device_id': getDeviceId!,
        'device_type': "A",
        'device_token': fcmToken,
      });
    }
    return params;
  }

  static String currentDate() {
    DateTime now = DateTime.now();

    String convertedDateTime =
        "${now.year.toString()}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString()}:${now.minute.toString()}";
    return convertedDateTime;
  }

  static Future<bool> dialogCommon(
      BuildContext context, String title, String message, bool isSingle) async {
    return await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              !isSingle
                  ? MaterialButton(
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                      child: Text("Cancel"),
                    )
                  : SizedBox.shrink(),
              MaterialButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: Text("Confirm"),
              ),
            ],
          );
        });
  }
}
