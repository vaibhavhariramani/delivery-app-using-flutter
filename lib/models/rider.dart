import 'package:cloud_firestore/cloud_firestore.dart';

/// The rider's identity/role profile, from `Users/{uid}`. Operational data
/// (online status, live location, earnings) lives separately in
/// `Riders/{uid}` — see [RiderStatus] — so a location ping never touches
/// this document. See docs/architecture/MULTI_TENANCY.md in the master
/// repo for why the two are split.
class Rider {
  final String uid;
  final String fullName;
  final String phone;
  final String email;
  final String? photoUrl;

  const Rider({
    required this.uid,
    required this.fullName,
    required this.phone,
    required this.email,
    this.photoUrl,
  });

  factory Rider.fromMap(String uid, Map<String, dynamic> data) {
    return Rider(
      uid: uid,
      fullName: (data['fullname'] ?? data['fullName'] ?? '').toString(),
      phone: (data['phone'] ?? '').toString(),
      email: (data['email'] ?? '').toString(),
      photoUrl: data['photoUrl']?.toString(),
    );
  }
}

/// A rider's operational state, from `Riders/{uid}` — see
/// docs/architecture/MULTI_TENANCY.md. Written by the rider's own device
/// only (firestore.rules: owner + isRider()).
class RiderStatus {
  final bool isOnline;
  final double? latitude;
  final double? longitude;
  final DateTime? locationUpdatedAt;
  final String vehicleType;
  final double totalEarnings;
  final int completedDeliveries;

  const RiderStatus({
    required this.isOnline,
    this.latitude,
    this.longitude,
    this.locationUpdatedAt,
    this.vehicleType = 'Bike',
    this.totalEarnings = 0,
    this.completedDeliveries = 0,
  });

  factory RiderStatus.fromMap(Map<String, dynamic>? data) {
    if (data == null) return const RiderStatus(isOnline: false);
    final location = data['location'] as Map<String, dynamic>?;
    return RiderStatus(
      isOnline: data['isOnline'] == true,
      latitude: (location?['latitude'] as num?)?.toDouble(),
      longitude: (location?['longitude'] as num?)?.toDouble(),
      locationUpdatedAt: (data['locationUpdatedAt'] as Timestamp?)?.toDate(),
      vehicleType: (data['vehicleType'] ?? 'Bike').toString(),
      totalEarnings: (data['totalEarnings'] as num?)?.toDouble() ?? 0,
      completedDeliveries: (data['completedDeliveries'] as num?)?.toInt() ?? 0,
    );
  }
}
