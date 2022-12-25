import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:quran/Theme%20Swtitcher%20Clipper%20Bridge/theme_model.dart';

class ThemeModelInheritedNotifier extends InheritedNotifier<ThemeModel> {
  const ThemeModelInheritedNotifier({
    Key? key,
    required ThemeModel notifier,
    required Widget child,
  }) : super(key: key, notifier: notifier, child: child);

  static ThemeModel of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<ThemeModelInheritedNotifier>()!
        .notifier!;
  }
}