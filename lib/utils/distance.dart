import 'dart:math' as math;

/// Great-circle distance in kilometers. Used here only for display and for
/// filtering the "available nearby deliveries" feed client-side — the
/// authoritative check that actually gates accepting a delivery runs
/// server-side in the `acceptDelivery` Cloud Function (see
/// docs/architecture/DELIVERY_RADIUS.md), since a client-side-only check
/// could be bypassed by a modified app.
double haversineKm(double lat1, double lon1, double lat2, double lon2) {
  const double earthRadiusKm = 6371;
  final double dLat = _toRadians(lat2 - lat1);
  final double dLon = _toRadians(lon2 - lon1);
  final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(_toRadians(lat1)) *
          math.cos(_toRadians(lat2)) *
          math.sin(dLon / 2) *
          math.sin(dLon / 2);
  final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  return earthRadiusKm * c;
}

double _toRadians(double degrees) => degrees * (math.pi / 180);
