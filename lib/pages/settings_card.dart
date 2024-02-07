import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:quran/classes/my_sharedpreferences.dart';
import 'package:quran/widgets/settings_UI.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';
import 'package:url_launcher/url_launcher.dart';

import '../hero_transition_handler/custom_rect_tween.dart';
import 'dart:math' as math;

class SettingsCard extends StatefulWidget {
  final String tag;
  double fontsize_english = 14,
      fontsize_arab = 14;
  Color theme;

  SettingsCard({Key? key,
    required this.tag,
    required this.fontsize_english,
    required this.fontsize_arab,
    required this.theme})
      : super(key: key);

  @override
  State<SettingsCard> createState() => _SettingsCardState();
}

class _SettingsCardState extends State<SettingsCard>{

  @override
  Widget build(BuildContext context) {

    return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(19.0),
          child: SettingsUI(tag: widget.tag, fontsize_english: widget.fontsize_english, fontsize_arab: widget.fontsize_arab, theme: widget.theme, toggleMenuClicked: (){},),
        ));
  }
}
