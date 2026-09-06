import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../constants/order_status.dart';
import '../../../../theme/app_theme.dart';
import '../controllers/order_detail_controller.dart';

class OrderDetailView extends GetView<OrderDetailController> {
  const OrderDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Delivery details')),
      body: Obx(() {
        final order = controller.order.value;
        if (order == null) {
          return const Center(child: CircularProgressIndicator());
        }
        final shop = controller.shop.value;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor(order.status).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                OrderStatus.label(order.status),
                style: TextStyle(color: statusColor(order.status), fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 16),
            _LocationCard(
              icon: Icons.storefront_outlined,
              title: 'Pickup',
              name: shop?.name ?? 'Loading shop…',
              subtitle: shop?.address ?? '',
              phone: shop?.phone,
              onNavigate: shop?.latitude != null ? controller.navigateToShop : null,
            ),
            const SizedBox(height: 12),
            _LocationCard(
              icon: Icons.person_pin_circle_outlined,
              title: 'Drop-off',
              name: order.customerName,
              subtitle: order.address,
              phone: order.customerPhone,
              onNavigate: order.customerLatitude != null ? controller.navigateToCustomer : null,
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Order summary', style: TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 10),
                    _SummaryRow('Order total', '${order.currencyType} ${order.total.toStringAsFixed(0)}'),
                    _SummaryRow(
                      'Your delivery fee',
                      '${order.currencyType} ${order.deliveryCharges.toStringAsFixed(0)}',
                      emphasize: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Obx(() {
              final error = controller.actionError.value;
              if (error == null) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(error, style: const TextStyle(color: AppColors.danger)),
              );
            }),
            if (controller.primaryActionLabel.isNotEmpty)
              Obx(() => ElevatedButton(
                    onPressed: controller.isBusy.value ? null : controller.runPrimaryAction,
                    child: controller.isBusy.value
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                          )
                        : Text(controller.primaryActionLabel),
                  )),
          ],
        );
      }),
    );
  }
}

class _LocationCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String name;
  final String subtitle;
  final String? phone;
  final VoidCallback? onNavigate;

  const _LocationCard({
    required this.icon,
    required this.title,
    required this.name,
    required this.subtitle,
    this.phone,
    this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  if (subtitle.isNotEmpty)
                    Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  if (phone != null && phone!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(phone!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    ),
                ],
              ),
            ),
            if (onNavigate != null)
              IconButton(
                onPressed: onNavigate,
                icon: const Icon(Icons.directions_outlined),
                color: AppColors.primary,
                tooltip: 'Navigate',
              ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasize;
  const _SummaryRow(this.label, this.value, {this.emphasize = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Text(
            value,
            style: TextStyle(
              fontWeight: emphasize ? FontWeight.w800 : FontWeight.w600,
              color: emphasize ? AppColors.success : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
