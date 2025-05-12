import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseApi {

  // function to initialize notifications
    Future<void> initNotifications() async {
      // You may set the permission requests to "provisional" which allows the user to choose what type
// of notifications they would like to receive once the user receives a notification.
      final notificationSettings = await FirebaseMessaging.instance.requestPermission(provisional: true);

// For apple platforms, ensure the APNS token is available before making any FCM plugin API calls
      final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      if (apnsToken != null) {
        // APNS token is available, make FCM plugin API requests...
      }
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        // APNS token is available, make FCM plugin API requests...
        print("token la: $fcmToken");
      }
      FirebaseMessaging.instance.onTokenRefresh
          .listen((fcmToken) {
        // TODO: If necessary send token to application server.

        // Note: This callback is fired at each app startup and whenever a new
        // token is generated.
      })
          .onError((err) {
        // Error getting token.
      });
    }
}