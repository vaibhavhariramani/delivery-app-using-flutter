import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../constants/order_status.dart';
import '../../../../models/delivery_order.dart';
import '../../../../services/orders_service.dart';

class OrderDetailController extends GetxController {
  final OrdersService _ordersService = OrdersService.to;
  final String orderId;

  OrderDetailController(this.orderId);

  final Rx<DeliveryOrder?> order = Rx<DeliveryOrder?>(null);
  final Rx<ShopLocation?> shop = Rx<ShopLocation?>(null);
  final RxBool isLoadingShop = true.obs;
  final RxBool isBusy = false.obs;
  final RxnString actionError = RxnString();

  @override
  void onInit() {
    super.onInit();
    order.bindStream(_ordersService.order(orderId));
    ever(order, (DeliveryOrder? o) {
      if (o != null && shop.value == null) {
        _loadShop(o.shopId);
      }
    });
  }

  Future<void> _loadShop(String shopId) async {
    isLoadingShop.value = true;
    shop.value = await _ordersService.shop(shopId);
    isLoadingShop.value = false;
  }

  Future<void> accept() async {
    isBusy.value = true;
    actionError.value = null;
    final error = await _ordersService.acceptDelivery(orderId);
    isBusy.value = false;
    if (error != null) actionError.value = error;
  }

  Future<void> confirmPickup() async {
    isBusy.value = true;
    await _ordersService.markPickedUp(orderId);
    await _ordersService.markOutForDelivery(orderId);
    isBusy.value = false;
  }

  Future<void> confirmDelivered() async {
    final current = order.value;
    if (current == null) return;
    isBusy.value = true;
    await _ordersService.markDelivered(orderId, earningAmount: current.deliveryCharges);
    isBusy.value = false;
    Get.back();
  }

  Future<void> navigateToShop() async {
    final s = shop.value;
    if (s?.latitude == null || s?.longitude == null) return;
    await _openMaps(s!.latitude!, s.longitude!, label: s.name);
  }

  Future<void> navigateToCustomer() async {
    final o = order.value;
    if (o?.customerLatitude == null || o?.customerLongitude == null) return;
    await _openMaps(o!.customerLatitude!, o.customerLongitude!, label: o.customerName);
  }

  Future<void> _openMaps(double lat, double lon, {required String label}) async {
    final uri = Uri.parse('geo:$lat,$lon?q=$lat,$lon(${Uri.encodeComponent(label)})');
    final fallback = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lon');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      await launchUrl(fallback, mode: LaunchMode.externalApplication);
    }
  }

  /// Which primary action to show for the order's current status — one
  /// button, not a maze of state, matching how a rider actually moves
  /// through a delivery.
  String get primaryActionLabel {
    switch (order.value?.status) {
      case OrderStatus.readyForPickup:
        return 'Accept delivery';
      case OrderStatus.riderAssigned:
        return 'Confirm pickup';
      case OrderStatus.pickedUp:
      case OrderStatus.outForDelivery:
        return 'Confirm delivery';
      default:
        return '';
    }
  }

  Future<void> runPrimaryAction() async {
    switch (order.value?.status) {
      case OrderStatus.readyForPickup:
        await accept();
        break;
      case OrderStatus.riderAssigned:
        await confirmPickup();
        break;
      case OrderStatus.pickedUp:
      case OrderStatus.outForDelivery:
        await confirmDelivered();
        break;
    }
  }
}
