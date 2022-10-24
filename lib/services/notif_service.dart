import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotifService {
  static Future<void> init() async {
    /// Notification
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description: 'This channel is used for important notifications.',
      // description
      importance: Importance.max,
    );
    var initAndroidSetting =
    const AndroidInitializationSettings("@mipmap/ic_launcher");
    var initIosSetting = const IOSInitializationSettings();
    var initSetting = InitializationSettings(
        android: initAndroidSetting, iOS: initIosSetting);
    await FlutterLocalNotificationsPlugin()
        .initialize(initSetting, onSelectNotification: _handleMessage);
    await FlutterLocalNotificationsPlugin()
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  static void _handleMessage(String? message) {}
}
