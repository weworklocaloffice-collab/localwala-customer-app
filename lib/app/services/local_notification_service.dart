/*
 * WeWorkLocal
 * Hyperlocal Commerce, Delivery & Service Platform
 *
 * Copyright © 2026 WeWorkLocal.
 * All Rights Reserved.
 *
 * Website: https://localwala.tech
 * Email: weworklocal1@gmail.com
 *
 * Proprietary and Confidential.
 *
 * WeWorkLocal is a technology platform that connects
 * customers, vendors, service providers, and delivery
 * partners through a unified digital ecosystem.
 *
 * Core features include local commerce, food delivery,
 * service bookings, referral programs, wallet management,
 * real-time tracking, digital payments, and business
 * management solutions.
 *
 * This source code, including all associated assets,
 * APIs, databases, business logic, designs, and
 * documentation, is proprietary to WeWorkLocal.
 *
 * Unauthorized copying, modification, distribution,
 * publication, resale, reverse engineering, or use of
 * this software without prior written authorization is
 * strictly prohibited.
 */

import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// True while any SupportChatView is mounted. Foreground support pushes
  /// for the open thread are redundant (socket already renders them) and
  /// echoing the user's own just-sent text as a notification reads as broken.
  static bool supportChatOpen = false;

  /// True while any MakePayment screen is mounted. Failure pushes carry the
  /// same message as the on-screen failure modal — suppress foreground echo,
  /// background/killed still notifies with repay nav.
  static bool paymentScreenOpen = false;

  /// App-side nudge for gateway-side declines (no POST exists, so FCM never
  /// can). Fires only for real failures, never user-cancel/timeout.
  /// Tap opens order history where Repay lives.
  static Future<void> notifyGatewayFailure(String shortReason) async {
    await _notificationsPlugin.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: 'Payment failed',
      body: shortReason.isNotEmpty ? shortReason : 'No money was charged. Tap to retry from Orders.',
      notificationDetails: platformDetailsWithAction,
      payload: '{"type":"open_history"}',
    );
  }

  static NotificationDetails get platformDetailsWithAction => const NotificationDetails(
        android: AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          importance: Importance.max,
          priority: Priority.high,
          category: AndroidNotificationCategory.message,
          ticker: 'ticker',
          showWhen: true,
          styleInformation: BigTextStyleInformation(''),
          actions: [
            AndroidNotificationAction('repay_action', 'Repay Now',
                showsUserInterface: true, cancelNotification: true),
          ],
        ),
      );

  // Live payment progress (the tray's answer to Lottie: RemoteViews forbids
  // animated views, so an ongoing indeterminate progress + step text is the
  // enterprise pattern, same as food-delivery live tracking).
  static const int _payProgressId = 9001;

  static Future<void> showPaymentProgress(String step) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.low,
      priority: Priority.low,
      category: AndroidNotificationCategory.progress,
      ticker: 'ticker',
      showWhen: true,
      ongoing: true,
      autoCancel: false,
      showProgress: true,
      indeterminate: true,
    );
    const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);
    await _notificationsPlugin.show(
      id: _payProgressId,
      title: 'Processing payment',
      body: step,
      notificationDetails: platformDetails,
    );
  }

  static Future<void> cancelPaymentProgress() async {
    try {
      await _notificationsPlugin.cancel(id: _payProgressId);
    } catch (_) {}
  }

  /// Routes notification taps. Set from `main.dart` so the service can open a
  /// screen without a BuildContext — it has none of its own.
  static GlobalKey<NavigatorState>? navigatorKey;

  /// Called with payload + tapped action of the notification. Payment pushes
  /// carry `supportType` + `entityId` (support thread) or order `value`
  /// (history detail -> repay bar); anything else falls through to the
  /// generic handler the caller provides. `repay_action` opens the order.
  static void Function(String? payload, String? actionId)? onTap;

  static Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('ic_notification');

    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(requestAlertPermission: true, requestBadgePermission: true, requestSoundPermission: true);

    const InitializationSettings settings = InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _notificationsPlugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        onTap?.call(response.payload, response.actionId);
      },
    );

    const AndroidNotificationChannel channel = AndroidNotificationChannel('high_importance_channel', 'High Importance Notifications', description: 'This channel is used for important notifications.', importance: Importance.max);

    await _notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);
  }

  static void showNotification(RemoteMessage message) {
    // Payment pushes get a Repay action button (system tray can't play
    // Lottie — animation lives in-app on processing/success/failure).
    // Tapping action or body deep-links history detail -> repay bar.
    final isPayment = const {'payment_pending', 'payment_expiring', 'payment_failed'}
        .contains(message.data['category']);
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.message,
      ticker: 'ticker',
      showWhen: true,
      styleInformation: const BigTextStyleInformation(''),
      actions: isPayment
          ? const [
              AndroidNotificationAction('repay_action', 'Repay Now',
                  showsUserInterface: true, cancelNotification: true),
            ]
          : null,
    );

final NotificationDetails platformDetails = NotificationDetails(android: androidDetails, iOS: const DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true));

    // The data map is what routes a tap. Dropping it here (as before) made
    // every notification tap a dead end that could only open the app shell.
    _notificationsPlugin.show(
      id: message.hashCode,
      title: message.notification?.title,
      body: message.notification?.body,
      notificationDetails: platformDetails,
      payload: message.data.isNotEmpty ? jsonEncode(message.data) : null,
    );
  }
}

