/// Canonical `OnlineOrders.status` values, shared conceptually across all
/// three Local Bazaar apps (Admin, Client, Delivery) — see
/// docs/architecture/ORDER_LIFECYCLE.md in the master repo for the full
/// state machine. Each app keeps its own copy of this file since they're
/// independent Flutter projects, but the string values must stay identical.
class OrderStatus {
  OrderStatus._();

  static const String placed = 'placed';
  static const String confirmed = 'confirmed';
  static const String preparing = 'preparing';
  static const String readyForPickup = 'ready_for_pickup';
  static const String riderAssigned = 'rider_assigned';
  static const String pickedUp = 'picked_up';
  static const String outForDelivery = 'out_for_delivery';
  static const String delivered = 'delivered';
  static const String cancelled = 'cancelled';

  /// 'out_for_delivery' -> 'Out For Delivery'
  static String label(String value) {
    return value
        .split('_')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }
}
