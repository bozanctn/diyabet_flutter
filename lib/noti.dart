import 'package:flutter_local_notifications/flutter_local_notifications.dart';
class Noti{
  static Future initialize(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async  {
    var androidInitialize = new AndroidInitializationSettings('mipmap/ic_launcher.png');
    var IOSInitialize = new DarwinInitializationSettings();
    var initializationSettings = new InitializationSettings(android: androidInitialize,
    iOS: IOSInitialize);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  static Future showBigTextNotification({var id = 0, required String title, required String body,
var payload, required FlutterLocalNotificationsPlugin fln
  }) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        new AndroidNotificationDetails(
          'you_name-whatever_you_want',
          'channel_name',

          playSound: true,
          sound: RawResourceAndroidNotificationSound('notification'),
          importance: Importance.max,
          priority: Priority.high,
        );

      var not = NotificationDetails(android: androidPlatformChannelSpecifics,
      iOS: DarwinNotificationDetails()
      );
      await fln.show(0, title, body,not);

  }


}