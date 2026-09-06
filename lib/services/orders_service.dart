import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:get/get.dart';

import '../constants/order_status.dart';
import '../models/delivery_order.dart';
import 'auth_service.dart';

class OrdersService extends GetxService {
  static OrdersService get to => Get.find<OrdersService>();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  /// Orders ready for a rider to claim — not yet assigned to anyone.
  /// Client-side this is a plain, unfiltered feed (capped at 50); the
  /// radius filtering shown to the rider happens in the UI layer using the
  /// rider's own last known location (see RiderService), and the
  /// authoritative distance check happens server-side when they actually
  /// tap Accept (see docs/architecture/DELIVERY_RADIUS.md) — the two are
  /// deliberately not the same check, since this feed is just a
  /// convenience list, not a security boundary.
  Stream<List<DeliveryOrder>> availableOrders() {
    return _firestore
        .collection('OnlineOrders')
        .where('status', isEqualTo: OrderStatus.readyForPickup)
        .orderBy('dateOfOrder', descending: false)
        .limit(50)
        .snapshots()
        .map((snap) => snap.docs
            .map(DeliveryOrder.fromDoc)
            .where((order) => order.riderId == null || order.riderId!.isEmpty)
            .toList());
  }

  /// This rider's in-progress deliveries.
  Stream<List<DeliveryOrder>> myActiveOrders() {
    final uid = AuthService.to.rider.value?.uid;
    if (uid == null) return Stream.value(const []);
    return _firestore
        .collection('OnlineOrders')
        .where('riderId', isEqualTo: uid)
        .where('status', whereIn: [
          OrderStatus.riderAssigned,
          OrderStatus.pickedUp,
          OrderStatus.outForDelivery,
        ])
        .snapshots()
        .map((snap) => snap.docs.map(DeliveryOrder.fromDoc).toList());
  }

  /// This rider's completed deliveries, most recent first.
  Stream<List<DeliveryOrder>> myHistory({int limit = 50}) {
    final uid = AuthService.to.rider.value?.uid;
    if (uid == null) return Stream.value(const []);
    return _firestore
        .collection('OnlineOrders')
        .where('riderId', isEqualTo: uid)
        .where('status', isEqualTo: OrderStatus.delivered)
        .orderBy('dateOfOrder', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map(DeliveryOrder.fromDoc).toList());
  }

  Stream<DeliveryOrder?> order(String orderId) {
    return _firestore
        .collection('OnlineOrders')
        .doc(orderId)
        .snapshots()
        .map((doc) => doc.exists ? DeliveryOrder.fromDoc(doc) : null);
  }

  Future<ShopLocation?> shop(String shopId) async {
    final doc = await _firestore.collection('Shops').doc(shopId).get();
    if (!doc.exists) return null;
    return ShopLocation.fromDoc(doc);
  }

  /// Returns null on success, or a user-facing error message. The actual
  /// assignment + radius check happens server-side — see
  /// docs/architecture/DELIVERY_RADIUS.md.
  Future<String?> acceptDelivery(String orderId) async {
    try {
      await _functions.httpsCallable('acceptDelivery').call({'orderId': orderId});
      return null;
    } on FirebaseFunctionsException catch (e) {
      return e.message ?? 'Could not accept this delivery.';
    } catch (_) {
      return 'Could not accept this delivery. Please try again.';
    }
  }

  Future<void> markPickedUp(String orderId) {
    return _firestore.collection('OnlineOrders').doc(orderId).update({
      'status': OrderStatus.pickedUp,
      'pickedUpAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> markOutForDelivery(String orderId) {
    return _firestore.collection('OnlineOrders').doc(orderId).update({
      'status': OrderStatus.outForDelivery,
    });
  }

  /// [earningAmount] is the delivery fee credited to the rider for this
  /// delivery (the order's own `deliveryCharges` — see
  /// docs/architecture/ORDER_LIFECYCLE.md). Updates the order and the
  /// rider's running totals (`Riders/{uid}.totalEarnings`/
  /// `completedDeliveries`) in one batch so they can't drift apart if the
  /// app is killed mid-write.
  Future<void> markDelivered(String orderId, {required double earningAmount}) {
    final uid = AuthService.to.rider.value?.uid;
    final batch = _firestore.batch();
    batch.update(_firestore.collection('OnlineOrders').doc(orderId), {
      'status': OrderStatus.delivered,
      'deliveredAt': FieldValue.serverTimestamp(),
      'DateOfDelivery': FieldValue.serverTimestamp(),
    });
    if (uid != null) {
      batch.set(
        _firestore.collection('Riders').doc(uid),
        {
          'totalEarnings': FieldValue.increment(earningAmount),
          'completedDeliveries': FieldValue.increment(1),
        },
        SetOptions(merge: true),
      );
    }
    return batch.commit();
  }
}
