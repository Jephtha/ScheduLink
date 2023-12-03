import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:schedulink/model/notification.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  var notifyToken = FirebaseMessaging.instance.getToken();

  // Initialize FlutterLocalNotificationsPlugin
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final StreamController<NotificationItem> didReceiveLocalNotificationStream =
      StreamController<NotificationItem>.broadcast();
  final StreamController<String?> selectNotificationStream =
      StreamController<String?>.broadcast();

  // Initialize FirebaseMessaging
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // Request notification permissions
  Future<void> requestPermission() async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()!
        .requestNotificationsPermission();
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('Notification permission granted.');
    } else {
      print('User declined or has not accepted permission.');
    }
  }

  // Initialize device settings
  Future<void> initializeNotifications() async {
    var initializationSettingsAndroid =
        AndroidInitializationSettings('ic_launcher');
    var initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      onDidReceiveLocalNotification:
          (int id, String? title, String? body, String? deadlineDate) async {
        didReceiveLocalNotificationStream.add(
          NotificationItem(
            id: '${DateTime.now().year}${DateTime.now().month}${DateTime.now().day}',
            title: title!,
            description: body!,
            deadlineDate: DateTime.parse(deadlineDate!),
          ),
        );
      },
    );
    ;
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse:
            (NotificationResponse notificationResponse) async {
      final String? payload = notificationResponse.payload;
      if (notificationResponse.payload != null) {
        debugPrint('notification payload: $payload');
      }
    });
    requestPermission();
  }

  // Schedule notifications
  Future<void> scheduleNotification(NotificationItem notification) async {
    try {
      AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails('${notification.id}', notification.title,
              channelDescription: notification.description,
              importance: Importance.max,
              priority: Priority.high,
              showWhen: false,
              icon: "ic_launcher");
      //var iOSPlatformChannelSpecifics = DarwinNotificationDetails();
      var platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

      int id = int.parse(notification.id.replaceAll(RegExp(r'[^0-9]'), ''));
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        notification.title,
        notification.description,
        tz.TZDateTime.from(notification.deadlineDate, tz.local),
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      print('Notification scheduled successfully.');
    } catch (e) {
      print('Error scheduling notification: $e');
    }
  }

  Future<void> display(RemoteMessage message) async {
    // To display the notification in device
    try {
      print(message.notification!.android!.sound);
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      NotificationDetails notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
            message.notification!.android!.sound ?? "Channel Id",
            message.notification!.android!.sound ?? "Main Channel",
            groupKey: "gfg",
            color: Colors.green,
            importance: Importance.max,
            sound: RawResourceAndroidNotificationSound(
                message.notification!.android!.sound ?? "gfg"),

            // different sound for
            // different notification
            playSound: true,
            priority: Priority.high),
      );
      await flutterLocalNotificationsPlugin.show(
          id,
          message.notification?.title,
          message.notification?.body,
          notificationDetails,
          payload: message.data['route']);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  retrievePendingNotifications() async =>
      await flutterLocalNotificationsPlugin.pendingNotificationRequests();
  retrieveActiveNotifications() async =>
      await flutterLocalNotificationsPlugin.getActiveNotifications();
  cancelAll() async => await flutterLocalNotificationsPlugin.cancelAll();
  cancel(id) async => await flutterLocalNotificationsPlugin.cancel(id);
}
