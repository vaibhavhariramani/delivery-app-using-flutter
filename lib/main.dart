import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'app/bindings/root_binding.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';

/// Must be a top-level function (not a method) — this is how the platform
/// wakes the app to hand it a push notification while it's backgrounded or
/// fully closed.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await GetStorage.init();
  runApp(const LocalBazaarDeliveryApp());
}

class LocalBazaarDeliveryApp extends StatelessWidget {
  const LocalBazaarDeliveryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Local Bazaar Delivery',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialBinding: RootBinding(),
      initialRoute: Routes.splash,
      getPages: AppPages.pages,
    );
  }
}
