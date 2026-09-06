import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../services/auth_service.dart';
import '../../../routes/app_routes.dart';

class LoginController extends GetxController {
  final AuthService _auth = AuthService.to;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final RxBool isLoading = false.obs;
  final RxnString errorText = RxnString();
  final RxBool obscurePassword = true.obs;

  bool get canSubmit => emailController.text.trim().isNotEmpty && passwordController.text.isNotEmpty;

  Future<void> submit() async {
    final email = emailController.text.trim();
    final password = passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      errorText.value = 'Enter your email and password.';
      return;
    }
    isLoading.value = true;
    errorText.value = null;
    final error = await _auth.login(email: email, password: password);
    isLoading.value = false;
    if (error != null) {
      errorText.value = error;
      return;
    }
    Get.offAllNamed(Routes.home);
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
