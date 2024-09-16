import '/compoments/bottom_navigation_component/bottom_navigation_component_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'social_screen_widget.dart' show SocialScreenWidget;
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

class SocialScreenModel extends FlutterFlowModel<SocialScreenWidget> {
  ///  Local state fields for this page.

  bool isLiked = false;

  ///  State fields for stateful widgets in this page.

  // State field(s) for SwipeableStack widget.
  late CardSwiperController swipeableStackController;
  // Model for BottomNavigationComponent component.
  late BottomNavigationComponentModel bottomNavigationComponentModel;

  @override
  void initState(BuildContext context) {
    swipeableStackController = CardSwiperController();
    bottomNavigationComponentModel =
        createModel(context, () => BottomNavigationComponentModel());
  }

  @override
  void dispose() {
    bottomNavigationComponentModel.dispose();
  }
}
