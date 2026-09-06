import 'package:flutter_test/flutter_test.dart';
import 'package:local_bazaar_delivery/constants/order_status.dart';

// A full widget/integration test suite needs Firebase mocked (every screen
// in this app reads AuthService/RiderService/OrdersService, all backed by
// live Firebase SDKs) — that's tracked as future work, not done here.
// This at least keeps a real, passing test in the repo instead of the
// previous template counter-app test, which referenced a widget class that
// no longer exists after this rewrite.
void main() {
  group('OrderStatus.label', () {
    test('single word', () {
      expect(OrderStatus.label(OrderStatus.placed), 'Placed');
    });

    test('multi-word snake_case', () {
      expect(OrderStatus.label(OrderStatus.outForDelivery), 'Out For Delivery');
      expect(OrderStatus.label(OrderStatus.readyForPickup), 'Ready For Pickup');
      expect(OrderStatus.label(OrderStatus.riderAssigned), 'Rider Assigned');
    });
  });
}
