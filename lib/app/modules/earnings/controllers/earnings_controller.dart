import 'package:get/get.dart';

import '../../../../models/delivery_order.dart';
import '../../../../services/orders_service.dart';
import '../../../../services/rider_service.dart';

class EarningsController extends GetxController {
  final RiderService riderService = RiderService.to;
  final OrdersService _ordersService = OrdersService.to;

  final RxList<DeliveryOrder> history = <DeliveryOrder>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _ordersService.myHistory().listen((orders) {
      history.value = orders;
      isLoading.value = false;
    });
  }
}
