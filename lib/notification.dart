import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService({void Function(String?)? onSelectNotification}) {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    initializationSettings =
        const InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: onSelectNotification,
    );
  }

  late final InitializationSettings initializationSettings;
  late final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
  static const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('launcher_icon');

  Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    final nowString = DateTime.now().toIso8601String();
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'channel-id-$nowString',
      'channel-name-$nowString',
      channelDescription: 'channel-description-$nowString',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: nowString,
    );
  }
}
