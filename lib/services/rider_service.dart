import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import '../constants/app_constants.dart';
import '../models/rider.dart';
import 'auth_service.dart';

/// Owns a rider's operational state (`Riders/{uid}` — see
/// docs/architecture/MULTI_TENANCY.md): online/offline, live location, and
/// the FCM token new-delivery pushes are sent to.
///
/// Location strategy: writes to Firestore only when the rider has moved at
/// least [AppConstants.locationMinMovementMeters] (enforced by
/// `LocationSettings.distanceFilter`, so the OS itself throttles callbacks —
/// this isn't a naive "write every GPS event" stream), or when
/// [AppConstants.locationMaxInterval] has elapsed with no movement, so a
/// stationary rider's "last seen" doesn't go stale indefinitely. This is
/// deliberately more conservative than writing on every location update,
/// which the original app's design explicitly warned against (battery +
/// Firestore write cost).
class RiderService extends GetxService {
  static RiderService get to => Get.find<RiderService>();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _auth = AuthService.to;

  final Rx<RiderStatus> status = const RiderStatus(isOnline: false).obs;
  final RxBool isTogglingOnline = false.obs;

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _riderDocSub;
  StreamSubscription<Position>? _positionSub;
  Timer? _maxIntervalTimer;
  Position? _lastPosition;
  bool _foregroundListenerAttached = false;

  DocumentReference<Map<String, dynamic>> _riderDoc(String uid) =>
      _firestore.collection('Riders').doc(uid);

  @override
  void onInit() {
    super.onInit();
    ever(_auth.rider, (Rider? rider) {
      _riderDocSub?.cancel();
      if (rider == null) {
        status.value = const RiderStatus(isOnline: false);
        return;
      }
      _riderDocSub = _riderDoc(rider.uid).snapshots().listen((snap) {
        status.value = RiderStatus.fromMap(snap.data());
      });
      registerFcmToken();
    });
  }

  Future<String?> goOnline() async {
    final rider = _auth.rider.value;
    if (rider == null) return 'Sign in first.';

    final permissionError = await _ensureLocationPermission();
    if (permissionError != null) return permissionError;

    isTogglingOnline.value = true;
    try {
      final position = await Geolocator.getCurrentPosition();
      _lastPosition = position;
      await _writeLocation(rider.uid, position, isOnline: true);

      _positionSub?.cancel();
      _positionSub = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: AppConstants.locationMinMovementMeters,
        ),
      ).listen((position) {
        _lastPosition = position;
        _writeLocation(rider.uid, position, isOnline: true);
      });

      _maxIntervalTimer?.cancel();
      _maxIntervalTimer = Timer.periodic(AppConstants.locationMaxInterval, (_) {
        final position = _lastPosition;
        if (position != null) {
          _writeLocation(rider.uid, position, isOnline: true);
        }
      });
      return null;
    } catch (_) {
      return 'Could not get your location. Please try again.';
    } finally {
      isTogglingOnline.value = false;
    }
  }

  Future<void> goOffline() async {
    final rider = _auth.rider.value;
    _positionSub?.cancel();
    _positionSub = null;
    _maxIntervalTimer?.cancel();
    _maxIntervalTimer = null;
    if (rider == null) return;
    await _riderDoc(rider.uid).set({'isOnline': false}, SetOptions(merge: true));
  }

  Future<void> _writeLocation(String uid, Position position, {required bool isOnline}) async {
    await _riderDoc(uid).set({
      'isOnline': isOnline,
      'location': {
        'latitude': position.latitude,
        'longitude': position.longitude,
      },
      'locationUpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<String?> _ensureLocationPermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return 'Turn on location services to go online.';
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      return 'Location permission is required to accept deliveries.';
    }
    return null;
  }

  Future<void> registerFcmToken() async {
    final rider = _auth.rider.value;
    if (rider == null) return;
    try {
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission(alert: true, badge: true, sound: true);
      final token = await messaging.getToken();
      if (token != null) {
        await _riderDoc(rider.uid).set({'fcmToken': token}, SetOptions(merge: true));
      }
      messaging.onTokenRefresh.listen((newToken) {
        _riderDoc(rider.uid).set({'fcmToken': newToken}, SetOptions(merge: true));
      });

      // FCM only auto-displays a system notification banner when the app
      // is backgrounded/terminated — while it's open, a "notification"
      // payload arrives silently unless something shows it. The available-
      // deliveries list itself updates on its own (it's a live Firestore
      // listener), this is purely so an online rider actually notices.
      if (!_foregroundListenerAttached) {
        _foregroundListenerAttached = true;
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          final title = message.notification?.title;
          final body = message.notification?.body;
          if (title == null) return;
          Get.snackbar(
            title,
            body ?? '',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.white,
            colorText: Colors.black87,
            margin: const EdgeInsets.all(12),
            borderRadius: 12,
            icon: const Icon(Icons.local_shipping_outlined),
          );
        });
      }
    } catch (_) {
      // Notifications are a convenience, not a blocker — a rider who
      // denies the permission can still see the in-app "available
      // deliveries" feed.
    }
  }

  Future<void> updateVehicleType(String vehicleType) async {
    final rider = _auth.rider.value;
    if (rider == null) return;
    await _riderDoc(rider.uid).set({'vehicleType': vehicleType}, SetOptions(merge: true));
  }

  @override
  void onClose() {
    _riderDocSub?.cancel();
    _positionSub?.cancel();
    _maxIntervalTimer?.cancel();
    super.onClose();
  }
}
