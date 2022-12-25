import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:quran/Theme%20Swtitcher%20Clipper%20Bridge/theme_switcher_circle_clipper.dart';
import 'package:quran/Theme%20Swtitcher%20Clipper%20Bridge/theme_switcher_clipper.dart';
import 'dart:ui' as ui;

class ThemeModel extends ChangeNotifier {
  ThemeData _theme;

  late GlobalKey switcherGlobalKey;
  ui.Image? image;
  final previewContainer = GlobalKey();

  Timer? timer;
  ThemeSwitcherClipper clipper = const ThemeSwitcherCircleClipper();
  final AnimationController controller;

  ThemeModel({
    required ThemeData startTheme,
    required this.controller,
  }) : _theme = startTheme;

  ThemeData get theme => _theme;
  ThemeData? oldTheme;

  bool isReversed = false;
  late Offset switcherOffset;

  void changeTheme({
    required ThemeData theme,
    required GlobalKey key,
    ThemeSwitcherClipper? clipper,
    required bool isReversed,
  }) async {
    if (controller.isAnimating) {
      return;
    }

    if (clipper != null) {
      this.clipper = clipper;
    }
    this.isReversed = isReversed;

    oldTheme = _theme;
    _theme = theme;
    switcherOffset = _getSwitcherCoordinates(key);
    await _saveScreenshot();

    if (isReversed) {
      await controller.reverse(from: 1.0);
    } else {
      await controller.forward(from: 0.0);
    }
  }

  Future<void> _saveScreenshot() async {
    final boundary = previewContainer.currentContext!.findRenderObject()
    as RenderRepaintBoundary;
    image = await boundary.toImage(pixelRatio: ui.window.devicePixelRatio);
    notifyListeners();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Offset _getSwitcherCoordinates(
      GlobalKey<State<StatefulWidget>> switcherGlobalKey) {
    final renderObject =
    switcherGlobalKey.currentContext!.findRenderObject()! as RenderBox;
    final size = renderObject.size;
    return renderObject
        .localToGlobal(Offset.zero)
        .translate(size.width / 2, size.height / 2);
  }
}