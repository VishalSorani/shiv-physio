import 'package:flutter/material.dart';

/// A base widget that provides common functionality to all widgets
abstract class BaseWidget extends StatelessWidget {
  /// Creates a base widget with an optional key
  const BaseWidget({super.key});

  /// The padding to apply to the widget
  EdgeInsetsGeometry? get padding => null;

  /// The margin to apply to the widget
  EdgeInsetsGeometry? get margin => null;

  /// The background color of the widget
  Color? get backgroundColor => null;

  /// The border radius of the widget
  BorderRadiusGeometry? get borderRadius => null;

  /// The border of the widget
  BoxBorder? get border => null;

  /// The width of the widget
  double? get width => null;

  /// The height of the widget
  double? get height => null;

  /// The main content of the widget
  Widget buildContent(BuildContext context);

  @override
  Widget build(BuildContext context) {
    Widget content = buildContent(context);

    // Apply padding if specified
    if (padding != null) {
      content = Padding(padding: padding!, child: content);
    }

    // Wrap with container for other decorations
    if (margin != null ||
        backgroundColor != null ||
        borderRadius != null ||
        border != null ||
        width != null ||
        height != null) {
      content = Container(
        margin: margin,
        padding: null, // Padding is already applied above
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: borderRadius,
          border: border,
        ),
        child: content,
      );
    }

    return content;
  }
}

/// A base stateful widget that provides common functionality
abstract class BaseStatefulWidget extends StatefulWidget {
  const BaseStatefulWidget({super.key});
}

/// Base state for stateful widgets with common functionality
abstract class BaseState<T extends BaseStatefulWidget> extends State<T> {
  /// Whether the widget is currently loading
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Set the loading state
  void setLoading(bool value) {
    if (mounted) {
      setState(() {
        _isLoading = value;
      });
    }
  }

  /// Show a loading overlay
  Widget buildWithLoading({
    required Widget child,
    Widget? loadingWidget,
  }) {
    return Stack(
      children: [
        child,
        if (_isLoading)
          Container(
            color: Colors.black54,
            child: Center(
              child: loadingWidget ??
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
            ),
          ),
      ],
    );
  }
}
