class AppConstants {
  AppConstants._();

  /// Mirrors the Cloud Function default in
  /// Multi-Store-Admin-Panel/functions/index.js — this is only used for
  /// display before the rider taps Accept; the authoritative check happens
  /// server-side in the `acceptDelivery` function, not here.
  static const double defaultDeliveryRadiusKm = 50;

  /// A rider's location is only re-written to Firestore when they've moved
  /// at least this far since the last write, or [locationMaxInterval] has
  /// elapsed — whichever comes first. Keeps the location feed useful
  /// without pinging Firestore (and draining battery) every second while a
  /// rider is stationary. See lib/services/rider_service.dart.
  static const int locationMinMovementMeters = 50;
  static const Duration locationMaxInterval = Duration(minutes: 2);
}
