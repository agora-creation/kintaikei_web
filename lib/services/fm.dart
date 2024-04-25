import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:kintaikei_web/common/style.dart';

const key =
    'AAAAC6p3hcc:APA91bG0YMDaZNG_ih4KW49QV9R3EywvLYhtw2hX92YwoxL1TgETyLazkaZM6YUqV4aEVYFYNw5rFWmzuo5FFlf37y8myuTzUjT-MNejUBRsrDdMJ8u0haWqp7KdYy7Lw8rf6gxaeya3';

class FmService {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final _androidChannel = const AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications',
    importance: Importance.defaultImportance,
  );
  final _localNotifications = FlutterLocalNotificationsPlugin();

  void _handleMessage(RemoteMessage? message) {
    if (message == null) return;
  }

  Future initLocalNotifications() async {
    const iOS = DarwinInitializationSettings();
    const android =
        AndroidInitializationSettings('@drawable/notification_icon');
    const settings = InitializationSettings(android: android, iOS: iOS);
    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (payload) {
        final message = RemoteMessage.fromMap(jsonDecode(payload.payload!));
        _handleMessage(message);
      },
    );
    final platform = _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await platform?.createNotificationChannel(_androidChannel);
  }

  Future initPushNotifications() async {
    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    messaging.getInitialMessage().then(_handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification == null) return;
      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannel.id,
            _androidChannel.name,
            channelDescription: _androidChannel.description,
            icon: '@drawable/notification_icon',
            color: kWhiteColor,
          ),
        ),
        payload: jsonEncode(message.toMap()),
      );
    });
  }

  Future initNotifications() async {
    await messaging.requestPermission();
    await initPushNotifications();
    await initLocalNotifications();
  }

  Future<String?> getToken() async {
    return await messaging.getToken();
  }

  void send({
    required String token,
    required String title,
    required String body,
  }) async {
    try {
      http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'key=$key',
        },
        body: jsonEncode({
          'to': token,
          'priority': 'high',
          'notification': {
            'title': title,
            'body': body,
          },
        }),
      );
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }
}

Future _handleBackgroundMessage(RemoteMessage message) async {
  print('Title : ${message.notification?.title}');
  print('Body : ${message.notification?.body}');
  print('Payload : ${message.data}');
}
