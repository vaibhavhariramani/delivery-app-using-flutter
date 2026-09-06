import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../services/auth_service.dart';
import '../../../../theme/app_theme.dart';
import '../../../routes/app_routes.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService auth = AuthService.to;
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Obx(() {
          if (auth.isReady.value) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Get.offAllNamed(auth.isLoggedIn ? Routes.home : Routes.login);
            });
          }
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.local_shipping_rounded, color: Colors.white, size: 56),
              SizedBox(height: 16),
              Text(
                'Local Bazaar Delivery',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 24),
              SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
              ),
            ],
          );
        }),
      ),
    );
  }
}
