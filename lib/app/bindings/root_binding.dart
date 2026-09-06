import 'package:get/get.dart';

import '../../services/auth_service.dart';
import '../../services/orders_service.dart';
import '../../services/rider_service.dart';

/// App-wide singletons, put once at startup — mirrors the Client app's
/// RootBinding pattern (lib/main.dart there) rather than re-registering a
/// service per module that needs it.
class RootBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthService(), permanent: true);
    Get.put(RiderService(), permanent: true);
    Get.put(OrdersService(), permanent: true);
  }
}
