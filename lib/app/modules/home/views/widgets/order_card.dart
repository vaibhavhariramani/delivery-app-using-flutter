import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../constants/order_status.dart';
import '../../../../../models/delivery_order.dart';
import '../../../../../theme/app_theme.dart';

/// One card, reused for the available-orders feed, the active-deliveries
/// list, and the earnings history — the original app hand-rolled this
/// layout three separate times with small drifting differences. [trailing]
/// lets each list show a different call-to-action without forking the
/// whole card.
class OrderCard extends StatelessWidget {
  final DeliveryOrder order;
  final String? shopName;
  final double? distanceKm;
  final Widget? trailing;
  final VoidCallback? onTap;

  const OrderCard({
    super.key,
    required this.order,
    this.shopName,
    this.distanceKm,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      shopName ?? 'Order #${order.id.substring(0, order.id.length.clamp(0, 6))}',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor(order.status).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      OrderStatus.label(order.status),
                      style: TextStyle(
                        color: statusColor(order.status),
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.place_outlined, size: 15, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      order.address.isEmpty ? order.customerName : order.address,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    '${order.currencyType} ${order.total.toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  if (distanceKm != null) ...[
                    const SizedBox(width: 10),
                    const Icon(Icons.directions_outlined, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 2),
                    Text('${distanceKm!.toStringAsFixed(1)} km',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ],
                  if (order.placedAt != null) ...[
                    const SizedBox(width: 10),
                    Text(
                      DateFormat.jm().format(order.placedAt!),
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                  const Spacer(),
                  if (trailing != null) trailing!,
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
