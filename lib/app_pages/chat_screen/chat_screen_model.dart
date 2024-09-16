import '/compoments/bottom_navigation_component/bottom_navigation_component_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'chat_screen_widget.dart' show ChatScreenWidget;
import 'package:flutter/material.dart';

class ChatScreenModel extends FlutterFlowModel<ChatScreenWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for TabBar widget.
  TabController? tabBarController;
  int get tabBarCurrentIndex =>
      tabBarController != null ? tabBarController!.index : 0;

  // Model for BottomNavigationComponent component.
  late BottomNavigationComponentModel bottomNavigationComponentModel;

  @override
  void initState(BuildContext context) {
    bottomNavigationComponentModel =
        createModel(context, () => BottomNavigationComponentModel());
  }

  @override
  void dispose() {
    tabBarController?.dispose();
    bottomNavigationComponentModel.dispose();
  }
}
