import 'dart:ui';

import 'package:flutter/material.dart';

/// {@template hero_dialog_route}
/// Custom [PageRoute] that creates an overlay dialog (popup effect).
///
/// Best used with a [Hero] animation.
/// {@endtemplate}
class HeroDialogRoute<T> extends PageRoute<T> {
  /// {@macro hero_dialog_route}
  HeroDialogRoute({
    required WidgetBuilder builder,
    this.bgColor = const Color(0x95000000),
    // required RouteSettings settings,
    bool fullscreenDialog = false,
  })  : _builder = builder,

        // super(settings: settings, fullscreenDialog: fullscreenDialog);
        super(fullscreenDialog: fullscreenDialog);

  final WidgetBuilder _builder;
  final Color bgColor;

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds:571);

  @override
  bool get maintainState => true;

  @override
  Color get barrierColor => bgColor;

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return child;
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return _builder(context);
  }

  @override
  String get barrierLabel => 'Popup dialog open';
}
