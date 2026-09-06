import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../models/delivery_order.dart';
import '../../../../theme/app_theme.dart';
import '../../../routes/app_routes.dart';
import '../controllers/home_controller.dart';
import 'widgets/order_card.dart';

class DeliveriesView extends GetView<HomeController> {
  const DeliveriesView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {},
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _OnlineToggleHeader()),
            Obx(() {
              final active = controller.activeOrders;
              if (active.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
              return SliverToBoxAdapter(
                child: _Section(
                  title: 'Your active deliveries',
                  child: Column(
                    children: active
                        .map((order) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: OrderCard(
                                order: order,
                                distanceKm: controller.distanceToShopKm(order.shopId),
                                onTap: () => Get.toNamed(Routes.orderDetail, arguments: order.id),
                                trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                              ),
                            ))
                        .toList(),
                  ),
                ),
              );
            }),
            Obx(() {
              final riderStatus = controller.riderService.status.value;
              if (!riderStatus.isOnline) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: _OfflinePrompt(),
                );
              }
              if (controller.isLoadingAvailable.value) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                );
              }
              final available = controller.availableOrders;
              if (available.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyAvailable(),
                );
              }
              return SliverToBoxAdapter(
                child: _Section(
                  title: 'Available nearby',
                  child: Column(
                    children: available.map((DeliveryOrder order) {
                      final shop = controller.shopCache[order.shopId];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: OrderCard(
                          order: order,
                          shopName: shop?.name,
                          distanceKm: controller.distanceToShopKm(order.shopId),
                          onTap: () => Get.toNamed(Routes.orderDetail, arguments: order.id),
                          trailing: FilledButton(
                            style: FilledButton.styleFrom(
                              minimumSize: const Size(0, 34),
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              backgroundColor: AppColors.primary,
                            ),
                            onPressed: () => Get.toNamed(Routes.orderDetail, arguments: order.id),
                            child: const Text('View'),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _OnlineToggleHeader extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Obx(() {
                  final rider = controller.authService.rider.value;
                  final online = controller.riderService.status.value.isOnline;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hi, ${rider?.fullName.split(' ').first ?? 'Rider'}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        online ? 'You\'re online' : 'You\'re offline',
                        style: TextStyle(
                          color: online ? AppColors.success : AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  );
                }),
              ),
              Obx(() {
                final online = controller.riderService.status.value.isOnline;
                final toggling = controller.riderService.isTogglingOnline.value;
                return Switch(
                  value: online,
                  activeColor: AppColors.success,
                  onChanged: toggling ? null : (value) => controller.toggleOnline(value),
                );
              }),
            ],
          ),
          Obx(() {
            final error = controller.toggleError.value;
            if (error == null) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(error, style: const TextStyle(color: AppColors.danger, fontSize: 12)),
            );
          }),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _OfflinePrompt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.power_settings_new_rounded, size: 48, color: AppColors.textSecondary),
            const SizedBox(height: 12),
            const Text(
              'Go online to see nearby deliveries',
              style: TextStyle(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            const Text(
              'Turn on the switch above when you\'re ready to start accepting orders.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyAvailable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inbox_outlined, size: 48, color: AppColors.textSecondary),
            const SizedBox(height: 12),
            const Text('No deliveries nearby right now', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            const Text(
              'We\'ll notify you the moment a new order is ready for pickup.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
