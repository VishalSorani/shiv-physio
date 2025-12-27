import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'base_controller.dart';

/// A base screen widget that provides common functionality
class BaseScreen extends StatelessWidget {
  /// The main content of the screen
  final Widget child;

  /// Whether to show a loading indicator
  final bool isLoading;

  final bool showLoading;

  const BaseScreen({
    super.key,
    required this.child,
    this.isLoading = false,
    this.showLoading = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = child;

    // Add loading overlay if needed
    if (isLoading && showLoading) {
      content = Stack(
        children: [
          content,
          Container(
            color: Colors.black54,
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
        ],
      );
    }

    return content;
  }
}

/// A base screen that works with BaseController for common state management
abstract class BaseScreenView<T extends BaseController> extends GetView<T> {
  const BaseScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: GetBuilder<T>(
        id: BaseController.baseScreenId,
        builder: (controller) {
          // Add comprehensive null check for controller
          // ignore: unnecessary_null_comparison
          if (controller == null) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return BaseScreen(
            isLoading: controller.isLoading,
            showLoading: controller.showLoading,
            child: buildView(context),
          );
        },
      ),
    );
  }

  /// Implement this method to provide the main content of the screen
  Widget buildView(BuildContext context);
}
