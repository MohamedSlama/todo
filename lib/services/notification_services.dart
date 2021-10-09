import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:todo/ui/pages/notification_screen.dart';

class NotifyHelper {
  //? Notification plugin
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  initializationNotification() async {
    //? Time zone initialization for scheduled notification
    tz.initializeTimeZones();
    // tz.setLocalLocation(tz.getLocation(timeZoneName));

    /*
    TODO initialize notification settings
    + case platform is android:
      - initialize app icon name
    +case platform is ios:
      - request notification settings
      - note: onDidReceiveLocalNotification is for older ios versions
    */
    final platformInitializationSettings = Platform.isAndroid
        ? const AndroidInitializationSettings('appicon')
        : IOSInitializationSettings(
            requestSoundPermission: true,
            requestBadgePermission: true,
            requestAlertPermission: true,
            onDidReceiveLocalNotification: onDidReceiveLocalNotification,
          );

    //? invoking platform notification settings
    final InitializationSettings initializationSettings = Platform.isAndroid
        ? InitializationSettings(
            android:
                platformInitializationSettings as AndroidInitializationSettings)
        : InitializationSettings(
            iOS: platformInitializationSettings as IOSInitializationSettings);

    //? Clicking notification widget goto notification screen!!
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String? payload) async {
      //? For testing we send constant values
      // selectNotification(payload!);
      selectNotification('hello|mohamed|salama');
    });
  }

  //? Notification screen
  void selectNotification(String payload) async {
    // debugPrint('notification payload: $payload');
    await Get.to(NotificationScreen(payload: payload));
  }

//? Older ios versions
  Future onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) async {
    Get.dialog(Text(body!));
  }

  //? Notification widget
  displayNotification({required String title, required String body}) async {
    //? Android notification channel and ios notification details
    var platformNotificationDetails = Platform.isAndroid
        ? const AndroidNotificationDetails(
            'your channel id', 'your channel name',
            channelDescription: 'your channel description',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker')
        : const IOSNotificationDetails();

    //? Invoke platformNotificationDetails to platformChannelSpecifics
    NotificationDetails platformChannelSpecifics = Platform.isAndroid
        ? NotificationDetails(
            android: platformNotificationDetails as AndroidNotificationDetails)
        : NotificationDetails(
            iOS: platformNotificationDetails as IOSNotificationDetails);

    //? Display notification of title and body
    await flutterLocalNotificationsPlugin.show(
        0, title, body, platformChannelSpecifics,
        payload: 'Default_Sound');
  }

  //? Scheduled notification
  scheduledNotification() async {
    //? This is a dummy notification for testing purpose
    //TODO should invoke task parameter
    await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'scheduled title',
        'scheduled body',
        tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
        const NotificationDetails(
            android: AndroidNotificationDetails(
                'your channel id', 'your channel name',
                channelDescription: 'your channel description')),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
  }

//! Under testing i think is duplicated
//? Request notification permission for IOS platform
// requestIOSPermission() {
//   flutterLocalNotificationsPlugin
//       .resolvePlatformSpecificImplementation<
//           IOSFlutterLocalNotificationsPlugin>()
//       ?.requestPermissions(sound: true, alert: true, badge: true);
// }
}
