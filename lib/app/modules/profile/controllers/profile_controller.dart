import 'package:get/get.dart';

import '../../../../services/auth_service.dart';
import '../../../../services/rider_service.dart';
import '../../../routes/app_routes.dart';

class ProfileController extends GetxController {
  final AuthService authService = AuthService.to;
  final RiderService riderService = RiderService.to;

  static const List<String> vehicleTypes = ['Bike', 'Scooter', 'Car', 'Bicycle'];

  Future<void> updateVehicleType(String vehicleType) {
    return riderService.updateVehicleType(vehicleType);
  }

  Future<void> logout() async {
    await riderService.goOffline();
    await authService.logout();
    Get.offAllNamed(Routes.login);
  }
}
