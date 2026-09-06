import 'package:get/get.dart';

import '../../../../models/delivery_order.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/orders_service.dart';
import '../../../../services/rider_service.dart';
import '../../../../utils/distance.dart';

class HomeController extends GetxController {
  final RiderService _riderService = RiderService.to;
  final OrdersService _ordersService = OrdersService.to;
  final AuthService authService = AuthService.to;
  RiderService get riderService => _riderService;

  final RxInt tabIndex = 0.obs;

  final RxList<DeliveryOrder> activeOrders = <DeliveryOrder>[].obs;
  final RxList<DeliveryOrder> availableOrders = <DeliveryOrder>[].obs;
  final RxBool isLoadingAvailable = true.obs;
  final RxnString toggleError = RxnString();

  /// shopId -> ShopLocation, populated on demand so the same shop isn't
  /// re-fetched for every order card in the available-orders feed.
  final RxMap<String, ShopLocation> shopCache = <String, ShopLocation>{}.obs;

  @override
  void onInit() {
    super.onInit();
    activeOrders.bindStream(_ordersService.myActiveOrders());
    _ordersService.availableOrders().listen((orders) {
      availableOrders.value = orders;
      isLoadingAvailable.value = false;
      for (final order in orders) {
        _ensureShopCached(order.shopId);
      }
    });
  }

  Future<void> _ensureShopCached(String shopId) async {
    if (shopCache.containsKey(shopId)) return;
    final shop = await _ordersService.shop(shopId);
    if (shop != null) shopCache[shopId] = shop;
  }

  /// Distance in km from the rider's last known location to a shop, or
  /// null if either location isn't known yet. Display-only — see
  /// docs/architecture/DELIVERY_RADIUS.md for where the real check happens.
  double? distanceToShopKm(String shopId) {
    final riderLat = _riderService.status.value.latitude;
    final riderLon = _riderService.status.value.longitude;
    final shop = shopCache[shopId];
    if (riderLat == null || riderLon == null || shop?.latitude == null || shop?.longitude == null) {
      return null;
    }
    return haversineKm(riderLat, riderLon, shop!.latitude!, shop.longitude!);
  }

  Future<void> toggleOnline(bool goOnline) async {
    toggleError.value = null;
    if (goOnline) {
      final error = await _riderService.goOnline();
      if (error != null) toggleError.value = error;
    } else {
      await _riderService.goOffline();
    }
  }
}
