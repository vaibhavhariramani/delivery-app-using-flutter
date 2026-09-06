# Local Bazaar Delivery

A GetX-based Flutter app for Local Bazaar delivery riders: go online, see nearby deliveries, accept one, navigate to the shop and customer, confirm pickup/delivery, and track earnings.

Part of the [Local Bazaar](https://github.com/vaibhavhariramani/local-bazaar) platform — shares one Firebase project with the Admin panel and Client app. See that repo's `docs/architecture/` for the cross-app data model and order lifecycle this app participates in.

## What's actually implemented

Every item below is real, working code — not aspirational. (An earlier version of this README claimed FCM alerts and turn-by-turn navigation that didn't exist in code at all; this one only lists what's true today.)

- **Sign in** — email/password against an existing rider account (`Users/{uid}.userType == 'RIDER'`). No self-registration; rider accounts are provisioned by shop/platform staff.
- **Online/offline toggle** — going online starts sharing location (`Riders/{uid}`, movement-threshold + max-interval throttled, see `lib/services/rider_service.dart`) and surfaces you in the nearby-deliveries feed and push notifications.
- **Available deliveries feed** — orders that are `ready_for_pickup` and unclaimed, with live distance from your last known location.
- **Accept a delivery** — calls the `acceptDelivery` Cloud Function, which authoritatively checks you're within the platform's delivery radius (default 50km) before assigning the order to you — this isn't just a client-side check. See `docs/architecture/DELIVERY_RADIUS.md` in the master repo.
- **Pickup / delivery confirmation** — advances the order through `rider_assigned → picked_up → out_for_delivery → delivered`.
- **Navigate** — opens the shop's or customer's location in the device's default maps app (Google Maps / Apple Maps) rather than a custom in-app map — more reliable than reimplementing turn-by-turn.
- **Earnings** — running total and completed-delivery count (`Riders/{uid}.totalEarnings`/`completedDeliveries`, incremented atomically alongside the delivery-confirmation write), plus delivery history.
- **Real push notifications** — the `notifyNearbyRidersOnReadyForPickup` Cloud Function actually sends FCM to online, in-radius riders when a new order becomes available (foreground messages surface as an in-app banner; background/terminated get a system notification).
- **Profile** — rider info, vehicle type, log out.

## Not yet built

- Cancellation flow (no app can cancel an order yet, in any of the three apps).
- Per-shop delivery radius override (currently platform-wide only).
- Multiple simultaneous active deliveries UX (the data model supports it; the UI hasn't been stress-tested for a rider juggling more than one).

## Architecture

GetX, structured the same way as the Admin panel and Client app:

```
lib/
  app/
    bindings/        # RootBinding — app-wide service registration
    modules/         # splash, auth, home (+ deliveries/earnings/profile tabs), order_detail
    routes/
  constants/         # order_status.dart, app_constants.dart
  models/            # Rider, RiderStatus, DeliveryOrder, ShopLocation
  services/          # AuthService, RiderService, OrdersService — GetxService singletons
  theme/
```

## Firebase

Targets the shared Local Bazaar project (`vaibhav-s-ecommerce-app`) — see `docs/firebase/` in the master repo for setup. Firestore security rules live in the Admin panel's repo (`firestore.rules`), since that's the single source of truth for the shared project's access control.

## Running locally

```bash
flutter pub get
flutter run
```

Requires a `Users/{uid}` document with `userType: 'RIDER'` to sign in as — there's no in-app way to create one (by design; see "Sign in" above).
