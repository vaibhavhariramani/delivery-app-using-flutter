import 'package:cloud_firestore/cloud_firestore.dart';

/// A rider-facing view of one `OnlineOrders/{orderId}` document — only the
/// fields this app actually uses. See docs/architecture/ORDER_LIFECYCLE.md
/// in the master repo for the full field schema and who writes what.
class DeliveryOrder {
  final String id;
  final String shopId;
  final String status;
  final String customerName;
  final String customerPhone;
  final String address;
  final double? customerLatitude;
  final double? customerLongitude;
  final double total;
  final double deliveryCharges;
  final String currencyType;
  final String? riderId;
  final DateTime? placedAt;

  const DeliveryOrder({
    required this.id,
    required this.shopId,
    required this.status,
    required this.customerName,
    required this.customerPhone,
    required this.address,
    this.customerLatitude,
    this.customerLongitude,
    required this.total,
    required this.deliveryCharges,
    required this.currencyType,
    this.riderId,
    this.placedAt,
  });

  factory DeliveryOrder.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return DeliveryOrder(
      id: doc.id,
      shopId: (data['shopId'] ?? '').toString(),
      status: (data['status'] ?? '').toString(),
      customerName: (data['name'] ?? '').toString(),
      customerPhone: (data['phone'] ?? '').toString(),
      address: (data['address'] ?? '').toString(),
      customerLatitude: (data['latitude'] as num?)?.toDouble(),
      customerLongitude: (data['longitude'] as num?)?.toDouble(),
      total: (data['total'] as num?)?.toDouble() ?? 0,
      deliveryCharges: double.tryParse('${data['deliveryCharges'] ?? 0}') ?? 0,
      currencyType: (data['currencyType'] ?? '').toString(),
      riderId: data['riderId']?.toString(),
      placedAt: (data['dateOfOrder'] as Timestamp?)?.toDate(),
    );
  }
}

/// The pickup-side location, from `Shops/{shopId}`. Lat/lng are stored as
/// strings there (inherited schema — see CURRENT_ARCHITECTURE.md), parsed
/// here so the rest of the app only ever deals in doubles.
class ShopLocation {
  final String id;
  final String name;
  final String phone;
  final String address;
  final double? latitude;
  final double? longitude;

  const ShopLocation({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    this.latitude,
    this.longitude,
  });

  factory ShopLocation.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return ShopLocation(
      id: doc.id,
      name: (data['name'] ?? 'Shop').toString(),
      phone: (data['phone_number'] ?? '').toString(),
      address: (data['address'] ?? '').toString(),
      latitude: double.tryParse('${data['latitude'] ?? ''}'),
      longitude: double.tryParse('${data['longitude'] ?? ''}'),
    );
  }
}
