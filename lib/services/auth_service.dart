import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../models/rider.dart';

/// Rider accounts are provisioned by platform/shop staff (via the Users
/// collection, userType: 'RIDER') — there is no self-registration screen
/// in this app, matching how the original app worked. This service only
/// handles sign-in against an existing account.
class AuthService extends GetxService {
  static AuthService get to => Get.find<AuthService>();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final Rx<User?> firebaseUser = Rx<User?>(null);
  final Rx<Rider?> rider = Rx<Rider?>(null);
  final RxBool isLoading = false.obs;

  /// False until the very first auth-state event (and, if signed in, the
  /// rider-profile load it triggers) has been fully handled. The splash
  /// screen waits on this instead of a fixed delay — the original Delivery
  /// app used a hardcoded 4-second Timer before deciding where to route,
  /// which is both slower than necessary on a fast connection and a race
  /// condition on a slow one.
  final RxBool isReady = false.obs;

  bool get isLoggedIn => firebaseUser.value != null && rider.value != null;

  @override
  void onInit() {
    super.onInit();
    firebaseUser.bindStream(_auth.authStateChanges());
    ever(firebaseUser, _onAuthChanged);
  }

  Future<void> _onAuthChanged(User? user) async {
    if (user == null) {
      rider.value = null;
      isReady.value = true;
      return;
    }
    await _loadRiderProfile(user.uid);
    isReady.value = true;
  }

  Future<void> _loadRiderProfile(String uid) async {
    final snap = await _firestore.collection('Users').doc(uid).get();
    final data = snap.data();
    if (data == null || data['userType'] != 'RIDER') {
      // Signed in with Firebase Auth but not a rider account (or no
      // profile at all) — fail closed rather than showing the rider UI to
      // whoever this is.
      rider.value = null;
      await _auth.signOut();
      return;
    }
    rider.value = Rider.fromMap(uid, data);
  }

  /// Returns null on success, or a user-facing error message on failure.
  Future<String?> login({required String email, required String password}) async {
    isLoading.value = true;
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final uid = credential.user?.uid;
      if (uid == null) return 'Sign in failed. Please try again.';
      await _loadRiderProfile(uid);
      if (rider.value == null) {
        return 'This account is not registered as a delivery rider.';
      }
      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
        case 'invalid-credential':
        case 'wrong-password':
          return 'Incorrect email or password.';
        case 'invalid-email':
          return 'Enter a valid email address.';
        case 'user-disabled':
          return 'This account has been disabled.';
        default:
          return 'Sign in failed (${e.code}). Please try again.';
      }
    } catch (_) {
      return 'Something went wrong. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
