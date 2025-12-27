// import 'dart:async';

// import 'package:shiv_physio_app/data/service/navigation_service/navigation_import.dart';
// import 'package:shiv_physio_app/data/service/navigation_service/navigation_service.dart';

// /// Service responsible for handling incoming universal links / app links
// /// and routing them into the existing GetX navigation layer.
// class DeepLinkService {
//   final NavigationService _navigationService;

//   Uri? _initialUri;

//   DeepLinkService({
//     required NavigationService navigationService,
//     AppLinks? appLinks,
//   }) : _navigationService = navigationService,
//        _appLinks = appLinks ?? AppLinks();

//   /// Initialize deep link handling.
//   ///
//   /// - Captures the initial link that opened the app.
//   /// - (For now) only handles deep links that launch the app from a cold start.
//   Future<void> init() async {
//     try {
//       // Capture app launch from a deep link.
//       _initialUri = await _appLinks.getInitialLink();
//       if (_initialUri != null) {
//         // ignore: avoid_print
//         print('DeepLinkService captured initial URI: $_initialUri');
//       }
//     } catch (e) {
//       // ignore: avoid_print
//       print('DeepLinkService init failed: $e');
//     }
//   }

//   /// Returns and clears the initial URI, if any.
//   Uri? takeInitialUri() {
//     final uri = _initialUri;
//     _initialUri = null;
//     return uri;
//   }

//   /// Public entry point so controllers can delegate deep-link handling.
//   void handleUri(Uri uri) => _handleUri(uri);

//   /// Core router that maps an incoming [uri] to an in‑app route.
//   void _handleUri(Uri uri) {
//     // ignore: avoid_print
//     print('DeepLinkService received URI: $uri');

//     // TODO: Implement deep link handling
//     return;
//   }

//   /// Dispose deep link listeners.
//   Future<void> dispose() async {
//     // No-op for now (we only use getInitialLink).
//   }
// }
