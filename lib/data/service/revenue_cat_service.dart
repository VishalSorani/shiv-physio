// import 'dart:io';

// import 'package:cooksmart/env/env.dart';
// import 'package:cooksmart/services/amplitude/amplitude_service.dart';
// import 'package:flutter/foundation.dart';
// import 'package:get/get.dart';
// import 'package:purchases_flutter/purchases_flutter.dart';

// /// Service responsible for configuring and interacting with RevenueCat.
// ///
// /// This class is part of the data/service layer and should not contain
// /// any UI logic. It exposes a thin wrapper around the RevenueCat SDK so
// /// repositories can implement business rules on top.
// class RevenueCatService {
//   RevenueCatService();

//   bool _isInitialized = false;
//   CustomerInfo? _customerInfo;

//   CustomerInfo? get customerInfo => _customerInfo;

//   /// Configure the RevenueCat SDK.
//   ///
//   /// Uses platform‑specific API keys from `Env` and registers a
//   /// [CustomerInfo] listener so entitlement changes (upgrade/downgrade)
//   /// are reflected immediately in memory.
//   Future<void> initialize() async {
//     if (_isInitialized) return;

//     final String apiKey = Platform.isAndroid
//         ? Env.revenueCatGoogleApiKey
//         : Env.revenueCatAppleApiKey;

//     // Enable debug logs in debug mode only
//     await Purchases.setLogLevel(
//       kDebugMode ? LogLevel.debug : LogLevel.info,
//     );

//     final configuration = PurchasesConfiguration(apiKey);
//     await Purchases.configure(configuration);

//     // Seed initial customer info
//     _customerInfo = await Purchases.getCustomerInfo();

//     // Listen for any upgrade/downgrade or entitlement changes
//     Purchases.addCustomerInfoUpdateListener((customerInfo) {
//       final Map<String, EntitlementInfo> previousActive =
//           _customerInfo?.entitlements.active ?? <String, EntitlementInfo>{};
//       final bool hadActiveEntitlement = previousActive.isNotEmpty;
      
//       _customerInfo = customerInfo;
      
//       final Map<String, EntitlementInfo> currentActive =
//           customerInfo.entitlements.active;
//       final bool hasActiveEntitlementNow = currentActive.isNotEmpty;
      
//       // Track subscription renewal if entitlement was reactivated
//       if (Get.isRegistered<AmplitudeService>() && 
//           !hadActiveEntitlement && 
//           hasActiveEntitlementNow) {
//         AmplitudeService.instance.logEvent(
//           'Subscription Renewed',
//           parameters: {
//             'source': 'customer_info_update',
//           },
//         );
//       }
//     });

//     _isInitialized = true;
//   }

//   /// Refresh [CustomerInfo] from RevenueCat.
//   ///
//   /// Useful after presenting a paywall to ensure we use the latest
//   /// entitlements for access checks and any quota/calculation logic.
//   Future<CustomerInfo> refreshCustomerInfo() async {
//     _customerInfo = await Purchases.getCustomerInfo();
//     return _customerInfo!;
//   }

//   /// Returns `true` if the given entitlement is currently active.
//   bool hasActiveEntitlement(String entitlementId) {
//     final Map<String, EntitlementInfo> active =
//         _customerInfo?.entitlements.active ?? <String, EntitlementInfo>{};
//     return active.containsKey(entitlementId);
//   }

//   /// Returns `true` if the customer has *any* active entitlement.
//   ///
//   /// This is useful when you only care that the user has *some* subscription,
//   /// regardless of the specific entitlement identifier.
//   bool get hasAnyActiveEntitlement {
//     final Map<String, EntitlementInfo> active =
//         _customerInfo?.entitlements.active ?? <String, EntitlementInfo>{};
//     return active.isNotEmpty;
//   }

//   /// Returns the active [EntitlementInfo] for [entitlementId] if present,
//   /// otherwise returns the first active entitlement (if any).
//   EntitlementInfo? getActiveEntitlementInfo(String entitlementId) {
//     final Map<String, EntitlementInfo> active =
//         _customerInfo?.entitlements.active ?? <String, EntitlementInfo>{};

//     if (active.containsKey(entitlementId)) {
//       return active[entitlementId];
//     }

//     if (active.isNotEmpty) {
//       return active.values.first;
//     }

//     return null;
//   }
// }
