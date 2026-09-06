import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../earnings/views/earnings_view.dart';
import '../../profile/views/profile_view.dart';
import '../controllers/home_controller.dart';
import 'deliveries_view.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          body: IndexedStack(
            index: controller.tabIndex.value,
            children: const [
              DeliveriesView(),
              EarningsView(),
              ProfileView(),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: controller.tabIndex.value,
            onTap: (i) => controller.tabIndex.value = i,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.local_shipping_outlined), label: 'Deliveries'),
              BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_outlined), label: 'Earnings'),
              BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
            ],
          ),
        ));
  }
}
