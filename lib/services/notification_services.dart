import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:todo/models/task.dart';
import 'package:todo/ui/pages/notification_screen.dart';

class NotifyHelper {
  //? Notification plugin
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  //+ Stream listener
  String selectedNotificationPayload = '';
  final BehaviorSubject<String> selectNotificationSubject =
      BehaviorSubject<String>();

  initializationNotification() async {
    //? Time zone initialization for scheduled notification
    tz.initializeTimeZones();

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
      //+ Stream .add?
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
      //- notification details
      task.id!,
      task.title!,
      task.note!,
      //- TZDateTime
      _nextInstanceOfTenAM(
          hour, minutes, task.remind!, task.repeat!, task.date!),
      //- NotificationDetails
      const NotificationDetails(
        android: AndroidNotificationDetails(
            'your channel id', 'your channel name',
            channelDescription: 'your channel description'),
      ),
      //- to avoid doze mode
      androidAllowWhileIdle: true,
      //- compute date GMT
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      //- compare time
      matchDateTimeComponents: DateTimeComponents.time,
      //- arguments
      payload: '${task.title}|${task.note}|${task.startTime}|',
    );
  }

  //? in case of completed and deleted tasks
  deleteNotification(int id) async {
    try {
      await flutterLocalNotificationsPlugin.cancel(id);
      debugPrint('Notification is deleted');
    } catch (e) {
      debugPrint('Cannot delete notification error: $e');
    }
  }

  //? in case of clear all tasks
  deleteAllNotifications() async {
    try {
      await flutterLocalNotificationsPlugin.cancelAll();
      debugPrint('All notifications have been deleted');
    } catch (e) {
      debugPrint('Cannot delete all notifications error: $e');
    }
  }

  //? TZDateTime
  _nextInstanceOfTenAM(
      int hour, int minutes, int remind, String repeat, String date) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);

    var formattedDate = DateFormat.yMd().parse(date);
    //- convert to local date
    final tz.TZDateTime fd = tz.TZDateTime.from(formattedDate,tz.local);

    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, fd.year, fd.month, fd.day, hour, minutes);


    //? Invoke remind
    scheduledDate = _afterRemind(remind, scheduledDate);

    //? Invoke repeat
    if (scheduledDate.isBefore(now)) {
      if (repeat == 'Daily') {
        scheduledDate = tz.TZDateTime(tz.local, now.year, now.month,
            (formattedDate.day) + 1, hour, minutes);
      } else if (repeat == 'Weekly') {
        scheduledDate = tz.TZDateTime(tz.local, now.year, now.month,
            (formattedDate.day) + 7, hour, minutes);
      } else if (repeat == 'Monthly') {
        scheduledDate = tz.TZDateTime(tz.local, now.year,
            (formattedDate.month) + 1, formattedDate.day, hour, minutes);
      }
      scheduledDate = _afterRemind(remind, scheduledDate);
    }



    print('final scheduled date: $scheduledDate');
    return scheduledDate;
  }

  tz.TZDateTime _afterRemind(int remind, tz.TZDateTime scheduledDate) {
    if (remind == 5) {
      scheduledDate = scheduledDate.subtract(const Duration(minutes: 5));
    } else if (remind == 10) {
      scheduledDate = scheduledDate.subtract(const Duration(minutes: 10));
    } else if (remind == 15) {
      scheduledDate = scheduledDate.subtract(const Duration(minutes: 15));
    } else if (remind == 20) {
      scheduledDate = scheduledDate.subtract(const Duration(minutes: 20));
    }
    return scheduledDate;
  }

  //? initialization of timezone flutter_native_timezone
  Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }

  //+ Notification screen action
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
