import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:todo/models/task.dart';
import 'package:todo/ui/pages/notification_screen.dart';

class NotifyHelper {
  //? Notification plugin
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  //+ Flag new
  String selectedNotificationPayload = '';
  final BehaviorSubject<String> selectNotificationSubject =
      BehaviorSubject<String>();

  initializationNotification() async {
    //? Time zone initialization for scheduled notification
    tz.initializeTimeZones();
    // tz.setLocalLocation(tz.getLocation(timeZoneName));

    //+ Flag new
    _configureSelectNotificationSubject();
    await _configureLocalTimeZone();

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
      // selectNotification('hello|mohamed|salama');
      //+ Flag new
      selectNotificationSubject.add(payload!);
    });
  }

  //! Remove
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
  scheduledNotification(int hour, int minutes, Task task) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      //+ Flag new
      task.id!,
      task.title!,
      task.note!,
      // tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
      _nextInstanceOfTenAM(hour, minutes),
      const NotificationDetails(
          android: AndroidNotificationDetails(
              'your channel id', 'your channel name',
              channelDescription: 'your channel description')),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      //+ Flag new
      matchDateTimeComponents: DateTimeComponents.time,
      payload: '${task.title}|${task.note}|${task.startTime}|',
    );
  }

  //+ Flag new
  _nextInstanceOfTenAM(int hour, int minutes) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minutes);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  //+ Flag new
  Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }

  //+ Flag new
  void _configureSelectNotificationSubject() {
    selectNotificationSubject.stream.listen((String payload) async {
      debugPrint('My payload is ' + payload);
      await Get.to(() => NotificationScreen(payload: payload));
    });
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
