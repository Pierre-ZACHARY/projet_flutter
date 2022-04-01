import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {

  static void initialize() {
    // for ios and web
    FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((event) {
      print('A new onMessage event was published!');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
    });
  }

  static Future<String?> getToken() async {
    return FirebaseMessaging.instance.getToken(vapidKey: "BMQnckf4JO9QaNXzK6cwd6MYF2JvKWNh9z9_GrqpOc7K56GtqXuNxglEeDIzZl0owInpyFQdgwXXXBs3ttIjvjM");
  }

}