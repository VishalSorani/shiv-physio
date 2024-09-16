import '/compoments/bottom_navigation_component/bottom_navigation_component_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_swipeable_stack.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'dart:async';
import '/flutter_flow/random_data_util.dart' as random_data;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'social_screen_model.dart';
export 'social_screen_model.dart';

class SocialScreenWidget extends StatefulWidget {
  const SocialScreenWidget({super.key});

  @override
  State<SocialScreenWidget> createState() => _SocialScreenWidgetState();
}

class _SocialScreenWidgetState extends State<SocialScreenWidget> {
  late SocialScreenModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  late StreamSubscription<bool> _keyboardVisibilitySubscription;
  bool _isKeyboardVisible = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SocialScreenModel());

    if (!isWeb) {
      _keyboardVisibilitySubscription =
          KeyboardVisibilityController().onChange.listen((bool visible) {
        safeSetState(() {
          _isKeyboardVisible = visible;
        });
      });
    }
  }

  @override
  void dispose() {
    _model.dispose();

    if (!isWeb) {
      _keyboardVisibilitySubscription.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: Container(
          decoration: const BoxDecoration(),
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            0.0, 0.0, 0.0, 100.0),
                        child: Builder(
                          builder: (context) {
                            final list = List.generate(
                                random_data.randomInteger(5, 5),
                                (index) =>
                                    random_data.randomInteger(10, 10)).toList();

                            return FlutterFlowSwipeableStack(
                              onSwipeFn: (index) {},
                              onLeftSwipe: (index) {},
                              onRightSwipe: (index) {},
                              onUpSwipe: (index) {},
                              onDownSwipe: (index) {},
                              itemBuilder: (context, listIndex) {
                                final listItem = list[listIndex];
                                return Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: Image.network(
                                        'https://picsum.photos/seed/174/600',
                                        width: double.infinity,
                                        height: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Align(
                                      alignment: const AlignmentDirectional(0.0, 1.0),
                                      child: Padding(
                                        padding: const EdgeInsetsDirectional.fromSTEB(
                                            16.0, 0.0, 16.0, 16.0),
                                        child: Container(
                                          width: double.infinity,
                                          height: 100.0,
                                          decoration: const BoxDecoration(),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  Container(
                                                    width: 50.0,
                                                    height: 50.0,
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        colors: [
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primary,
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .accent3
                                                        ],
                                                        stops: const [0.0, 1.0],
                                                        begin:
                                                            const AlignmentDirectional(
                                                                1.0, -1.0),
                                                        end:
                                                            const AlignmentDirectional(
                                                                -1.0, 1.0),
                                                      ),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    alignment:
                                                        const AlignmentDirectional(
                                                            0.0, 0.0),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(2.0),
                                                      child: Container(
                                                        width: 48.0,
                                                        height: 48.0,
                                                        clipBehavior:
                                                            Clip.antiAlias,
                                                        decoration:
                                                            const BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                        child: Image.network(
                                                          'https://picsum.photos/seed/427/600',
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: AutoSizeText(
                                                      listIndex.toString(),
                                                      maxLines: 1,
                                                      minFontSize: 10.0,
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily: 'Inter',
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .primaryBackground,
                                                            letterSpacing: 0.0,
                                                          ),
                                                    ),
                                                  ),
                                                  Builder(
                                                    builder: (context) {
                                                      if (_model.isLiked) {
                                                        return FlutterFlowIconButton(
                                                          borderColor: Colors
                                                              .transparent,
                                                          borderRadius: 30.0,
                                                          buttonSize: 40.0,
                                                          icon: const Icon(
                                                            Icons
                                                                .favorite_outlined,
                                                            color: Color(
                                                                0xFFFF0404),
                                                            size: 24.0,
                                                          ),
                                                          onPressed: () async {
                                                            _model.isLiked =
                                                                true;
                                                            safeSetState(() {});
                                                          },
                                                        );
                                                      } else {
                                                        return FlutterFlowIconButton(
                                                          borderColor: Colors
                                                              .transparent,
                                                          borderRadius: 30.0,
                                                          buttonSize: 40.0,
                                                          icon: Icon(
                                                            Icons
                                                                .favorite_border,
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .primaryBackground,
                                                            size: 24.0,
                                                          ),
                                                          onPressed: () async {
                                                            _model.isLiked =
                                                                false;
                                                            safeSetState(() {});
                                                          },
                                                        );
                                                      }
                                                    },
                                                  ),
                                                ].divide(const SizedBox(width: 16.0)),
                                              ),
                                              Expanded(
                                                child: AutoSizeText(
                                                  'Hello World',
                                                  minFontSize: 10.0,
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium
                                                      .override(
                                                        fontFamily: 'Inter',
                                                        color: FlutterFlowTheme
                                                                .of(context)
                                                            .primaryBackground,
                                                        letterSpacing: 0.0,
                                                      ),
                                                ),
                                              ),
                                            ].divide(const SizedBox(height: 12.0)),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                              itemCount: list.length,
                              controller: _model.swipeableStackController,
                              loop: false,
                              cardDisplayCount: 3,
                              scale: 0.9,
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (!(isWeb
                  ? MediaQuery.viewInsetsOf(context).bottom > 0
                  : _isKeyboardVisible))
                Align(
                  alignment: const AlignmentDirectional(0.0, 1.0),
                  child: wrapWithModel(
                    model: _model.bottomNavigationComponentModel,
                    updateCallback: () => safeSetState(() {}),
                    child: const BottomNavigationComponentWidget(
                      selectedPageIndex: 3,
                      hidden: false,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
