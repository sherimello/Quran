import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';
import 'package:url_launcher/url_launcher.dart';

import '../hero_transition_handler/custom_rect_tween.dart';
import 'dart:math' as math;

class SettingsCard extends StatefulWidget {
  final String tag;
  double fontsize_english = 14, fontsize_arab = 14;
  Color theme;

  SettingsCard(
      {Key? key,
      required this.tag,
      required this.fontsize_english,
      required this.fontsize_arab,
      required this.theme})
      : super(key: key);

  @override
  State<SettingsCard> createState() => _SettingsCardState();
}

class _SettingsCardState extends State<SettingsCard>
    with SingleTickerProviderStateMixin {
  double snack_text_size = 0, snack_text_padding = 0;
  IconData _icon = Icons.brightness_7_sharp;

  late Animation<double> animation;

  late final AnimationController animationController;

  late final Animation<double> _arrowAnimation;
  late final Duration halfDuration;
  bool isArabicFontChanged = false,
      shouldShowFontSizeChangeCard = false,
      shouldShowAboutCard = false;
  double card_padding = 0.0,
      size_container_init = 0,
      aspectRatio = 0,
      englishSize = 0,
      arabicSize = 0;
  int en_counter = 1, ar_counter = 0;
  late SharedPreferences sharedPreferences;
  Color textColor = Colors.black;

  initializeSP() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  saveEnglishFontSize() {
    try {
      sharedPreferences.setDouble("english_font_size", widget.fontsize_english);
    } catch (e) {
      initializeSP().whenComplete(() {
        saveEnglishFontSize();
      });
    }
  }

  saveArabicFontSize() {
    try {
      sharedPreferences.setDouble("arabic_font_size", widget.fontsize_arab);
    } catch (e) {
      initializeSP().whenComplete(() {
        saveEnglishFontSize();
      });
    }
  }

  saveThemeState(String theme) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString('theme mode', theme);
  }

  @override
  void initState() {
    super.initState();
    widget.theme == Colors.white
        ? setState(() {
            _icon = Icons.brightness_7_sharp;
            textColor = Colors.black;
          })
        : setState(() {
            _icon = Icons.brightness_4_outlined;
            textColor = Colors.white;
          });
    initializeSP();
    englishSize = widget.fontsize_english;
    arabicSize = widget.fontsize_arab;
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    // _addStatusListener();

    _arrowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeInOut),
    );

    halfDuration = Duration(
        milliseconds: animationController.duration!.inMilliseconds ~/ 2);
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    AppBar appBar = AppBar();

    bool isPortraitMode() {
      return size.height > size.width ? true : false;
    }

    aspectRatio = isPortraitMode()
        ? (size.height / size.width)
        : (size.width / size.height);
    // size_container_init = 101.0 + (size.width * .1) * 2 + widget.fontsize_english;

    return SafeArea(
        child: Padding(
      padding: const EdgeInsets.all(19.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Hero(
            tag: widget.tag,
            createRectTween: (begin, end) {
              return CustomRectTween(begin: begin!, end: end!);
            },
            child: AnimatedContainer(
              curve: Curves.easeOut,
              duration: const Duration(milliseconds: 250),
              width: size.width - 38,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(31),
                  color: const Color(0xff1d3f5e)),
              child: Padding(
                padding: const EdgeInsets.all(19.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(21),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Material(
                          color: Colors.transparent,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 11.0),
                                    child: Container(
                                        width: appBar.preferredSize.height -
                                            appBar.preferredSize.height * .35,
                                        //175 + appBar.preferredSize.height - appBar.preferredSize.height * .35
                                        height: appBar.preferredSize.height -
                                            appBar.preferredSize.height * .35,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(1000),
                                            color:
                                                Colors.white.withOpacity(.5)),
                                        child: Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: Image.asset(
                                              'lib/assets/images/quran icon.png'),
                                        )),
                                  ),
                                  const Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Qur\'an',
                                        style: TextStyle(
                                            fontFamily: 'Bismillah Script',
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.5,
                                            color: Colors.white,
                                            fontSize: 21),
                                      ),
                                    ],
                                  ),
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: GestureDetector(
                                          onTap: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Icon(
                                            Icons.cancel_rounded,
                                            color: Colors.white,
                                          )),
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(
                                height: 21,
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    shouldShowFontSizeChangeCard =
                                        !shouldShowFontSizeChangeCard;
                                    if (shouldShowFontSizeChangeCard) {
                                      if (!isArabicFontChanged) {
                                        size_container_init = 101.0 +
                                            (size.width * .1) * 2 +
                                            (widget.fontsize_english);
                                      } else {
                                        size_container_init = 101.0 +
                                            (size.width * .1) * 2 +
                                            (widget.fontsize_arab + 1) *
                                                aspectRatio;
                                      }
                                    } else {
                                      size_container_init = 0;
                                    }
                                  });
                                  // Navigator.of(context).push(HeroDialogRoute(
                                  //   bgColor: Colors.transparent,
                                  //   builder: (context) => BookmarkFolders(tag: widget.tag, from_where: "surah list"),
                                  // ));
                                },
                                child: const Text.rich(TextSpan(
                                    style: TextStyle(
                                        fontFamily: 'varela-round.regular',
                                        fontSize: 21,
                                        color: Colors.white,
                                        height: 1,
                                        fontWeight: FontWeight.bold),
                                    children: [
                                      WidgetSpan(
                                          alignment:
                                              PlaceholderAlignment.middle,
                                          child: Icon(
                                            Icons.format_size,
                                            color: Colors.white,
                                          )),
                                      TextSpan(text: '  change font size(s)'),
                                    ])),
                              ),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 350),
                                height: shouldShowFontSizeChangeCard ? 17 : 0,
                              ),
                              AnimatedContainer(
                                height: size_container_init,
                                curve: Curves.linearToEaseOut,
                                duration: const Duration(milliseconds: 350),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(21),
                                    color: widget.theme == Colors.white
                                        ? Colors.white.withOpacity(.21)
                                        : Colors.black.withOpacity(.21)),
                                child: Padding(
                                  padding: const EdgeInsets.all(19),
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.vertical,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "english (${widget.fontsize_english} px):",
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontFamily:
                                                    "varela-round.regular",
                                                // fontSize: shouldShowFontSizeChangeCard ? 14 : 0
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 11,
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  en_counter >= 1
                                                      ? en_counter -= 1
                                                      : en_counter = 0;
                                                  if (isArabicFontChanged) {
                                                    isArabicFontChanged = false;
                                                  }
                                                  size_container_init = 101.0 +
                                                      (size.width * .1 * 2) +
                                                      widget.fontsize_english;

                                                  if (widget.fontsize_english >
                                                      13) {
                                                    widget.fontsize_english -=
                                                        1;
                                                    saveEnglishFontSize();
                                                  }
                                                });
                                              },
                                              child: Container(
                                                width: size.width * .1,
                                                height: size.width * .1,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            11),
                                                    color: Colors.white),
                                                child: const Icon(
                                                  Icons.minimize_rounded,
                                                  color: Color(0xff1d3f5e),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 11,
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  en_counter <= 7
                                                      ? en_counter += 1
                                                      : en_counter = 0;
                                                  if (isArabicFontChanged) {
                                                    isArabicFontChanged = false;
                                                  }
                                                  size_container_init = 101.0 +
                                                      (size.width * .1) * 2 +
                                                      widget.fontsize_english;

                                                  if (widget.fontsize_english <
                                                      17) {
                                                    widget.fontsize_english++;
                                                    saveEnglishFontSize();
                                                  }
                                                });
                                              },
                                              child: Container(
                                                width: size.width * .1,
                                                height: size.width * .1,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            11),
                                                    color: Colors.white),
                                                child: const Icon(
                                                  Icons.add,
                                                  color: Color(0xff1d3f5e),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 11,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "arabic (${widget.fontsize_arab} px):",
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontFamily:
                                                    "varela-round.regular",
                                                // fontSize: shouldShowFontSizeChangeCard ? 14 : 0,
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 11,
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  isArabicFontChanged = true;
                                                  if (widget.fontsize_arab >
                                                      13) {
                                                    widget.fontsize_arab -= 1;
                                                    saveArabicFontSize();
                                                  }
                                                  size_container_init = 101.0 +
                                                      (size.width * .1) * 2 +
                                                      widget.fontsize_arab *
                                                          aspectRatio;
                                                });
                                              },
                                              child: Container(
                                                width: size.width * .1,
                                                height: size.width * .1,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            11),
                                                    color: Colors.white),
                                                child: const Icon(
                                                  Icons.minimize_rounded,
                                                  color: Color(0xff1d3f5e),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 11,
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  isArabicFontChanged = true;
                                                  if (widget.fontsize_arab <
                                                      21) {
                                                    widget.fontsize_arab++;
                                                    saveArabicFontSize();
                                                  }
                                                  size_container_init = 101.0 +
                                                      (size.width * .1) * 2 +
                                                      widget.fontsize_arab *
                                                          aspectRatio;
                                                });
                                              },
                                              child: Container(
                                                width: size.width * .1,
                                                height: size.width * .1,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            11),
                                                    color: Colors.white),
                                                child: const Icon(
                                                  Icons.add,
                                                  color: Color(0xff1d3f5e),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 17,
                                        ),
                                        AnimatedContainer(
                                          curve: Curves.easeOut,
                                          duration:
                                              const Duration(milliseconds: 250),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(21),
                                            color: Colors.white,
                                          ),
                                          width: size.width - 70,
                                          // height: 19,
                                          child: Padding(
                                            padding: const EdgeInsets.all(17),
                                            child: Stack(
                                              children: [
                                                Visibility(
                                                  visible: isArabicFontChanged,
                                                  child: Center(
                                                    child: Text(
                                                      "بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ",
                                                      textScaleFactor:
                                                          aspectRatio,
                                                      textAlign:
                                                          TextAlign.center,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        //101 + size.width * .1 * 2
                                                        height: 1,
                                                        fontFamily: 'Al_Mushaf',
                                                        color: Colors.black,
                                                        fontSize: widget
                                                            .fontsize_arab,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Visibility(
                                                  visible: !isArabicFontChanged,
                                                  child: Center(
                                                    child: Text(
                                                      'In the name of Allah, the Entirely Merciful, the Especially Merciful.',
                                                      textAlign:
                                                          TextAlign.center,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        //101 + size.width * .1 * 2
                                                        height: 1,
                                                        fontFamily:
                                                            'varela-round.regular',
                                                        color: Colors.black,
                                                        fontSize: widget
                                                            .fontsize_english,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 17,
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (_icon == Icons.brightness_7_sharp) {
                                      saveThemeState("dark");
                                      widget.theme = Colors.black;
                                      textColor = Colors.white;
                                      _icon = Icons.brightness_4_outlined;
                                    } else {
                                      saveThemeState("light");
                                      widget.theme = Colors.white;
                                      textColor = Colors.black;
                                      _icon = Icons.brightness_7_sharp;
                                    }
                                  });
                                  animationController.isCompleted
                                      ? animationController.reverse()
                                      : animationController.forward();
                                  // Navigator.of(context).push(HeroDialogRoute(
                                  //   bgColor: Colors.white.withOpacity(0.85),
                                  //   builder: (context) => Center(child: FavoriteVerses(tag: widget.tag, from_where: "surah list",)),
                                  // ));
                                },
                                child: Text.rich(TextSpan(
                                    style: const TextStyle(
                                        fontFamily: 'varela-round.regular',
                                        fontSize: 21,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                    children: [
                                      WidgetSpan(
                                          alignment:
                                              PlaceholderAlignment.middle,
                                          child: AnimatedBuilder(
                                              animation: animationController,
                                              builder: (BuildContext context,
                                                  Widget? child) {
                                                return Transform.rotate(
                                                  angle: _arrowAnimation.value *
                                                      2.0 *
                                                      math.pi,
                                                  child: child,
                                                );
                                              },
                                              child: Icon(
                                                _icon,
                                                color: Colors.white,
                                              ))),
                                      TextSpan(
                                          text:
                                              _icon == Icons.brightness_7_sharp
                                                  ? '  dark mode: OFF'
                                                  : '  dark mode: ON'),
                                    ])),
                              ),
                              const SizedBox(
                                height: 17,
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    shouldShowAboutCard = !shouldShowAboutCard;
                                  });
                                  //   builder: (context) => Center(child: FavoriteVerses(tag: widget.tag, from_where: "surah list",)),
                                  // ));
                                },
                                child: const Text.rich(TextSpan(
                                    style: TextStyle(
                                        fontFamily: 'varela-round.regular',
                                        fontSize: 21,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                    children: [
                                      WidgetSpan(
                                          alignment:
                                              PlaceholderAlignment.middle,
                                          child: Icon(
                                            Icons.info,
                                            color: Colors.white,
                                          )),
                                      TextSpan(text: '  about'),
                                    ])),
                              ),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 350),
                                height: shouldShowAboutCard ? 36 : 0,
                              ),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 550),
                                curve: Curves.linearToEaseOut,
                                width: size.width,
                                height: shouldShowAboutCard
                                    ? size.height -
                                        (57 + appBar.preferredSize.height)
                                    : 0,
                                decoration: BoxDecoration(
                                    color: widget.theme == Colors.white
                                        ? Colors.white
                                        : Colors.black,
                                    borderRadius: BorderRadius.circular(21)),
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(
                                            top: appBar.preferredSize.height,
                                            bottom: 21.0),
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            RippleAnimation(
                                                color: Colors.grey,
                                                repeat: true,
                                                ripplesCount: 7,
                                                minRadius: size.width * .11,
                                                // duration: const Duration(milliseconds: 3500),
                                                child: Center(
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            1000),
                                                    child: Image.asset(
                                                      'lib/assets/images/dev picture.png',
                                                      width: size.width * .25,
                                                      height: size.width * .25,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ))
                                          ],
                                        ),
                                      ),
                                      Text.rich(
                                        TextSpan(
                                          children: [
                                            TextSpan(
                                              text: 'reach me at:\n',
                                              style: TextStyle(
                                                  fontFamily:
                                                      "varela-round.regular",
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 19,
                                                  color: textColor),
                                            ),
                                            const WidgetSpan(
                                                alignment:
                                                    PlaceholderAlignment.middle,
                                                child: Icon(
                                                  Icons.open_in_new,
                                                  color: Colors.blue,
                                                  size: 14,
                                                )),
                                            TextSpan(
                                              text:
                                                  ' uchiha.sherimello@gmail.com',
                                              style: const TextStyle(
                                                color: Colors.blue,
                                                fontFamily:
                                                    "varela-round.regular",
                                                fontWeight: FontWeight.bold,
                                              ),
                                              recognizer: TapGestureRecognizer()
                                                ..onTap = () async {
                                                  final url = Uri(
                                                    scheme: 'mailto',
                                                    path:
                                                        'uchiha.sherimello@gmail.com',
                                                  );
                                                  if (!await launchUrl(url)) {
                                                    throw 'Could not launch $url';
                                                  }
                                                },
                                            ),
                                          ],
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 11.0),
                                        child: Text(
                                          "\nالسَّلَامُ عَلَيْكُمْ وَرَحْمَةُ ٱللَّهِ وَبَرَكاتُهُ",
                                          style: TextStyle(
                                              wordSpacing: 2,
                                              fontFamily: 'Al_Mushaf',
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                              color: textColor),
                                          textScaleFactor: aspectRatio,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 11.0),
                                        child: Text.rich(
                                          TextSpan(
                                              style:
                                                  TextStyle(color: textColor),
                                              children: const [
                                                TextSpan(
                                                  text:
                                                      "\nthis app is intended to be a Sadaqatul Jariyah ",
                                                  style: TextStyle(
                                                    fontFamily:
                                                        'varela-round.regular',
                                                  ),
                                                ),
                                                TextSpan(
                                                  text:
                                                      "(long-term kindness that accrues ongoing reward from ALLAH (SWT)) ",
                                                  style: TextStyle(
                                                      fontFamily:
                                                          'varela-round.regular',
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                TextSpan(
                                                  text:
                                                      "for everyone associated in the making of it.  we will make it opensource with the very first stable release (",
                                                  style: TextStyle(
                                                    fontFamily:
                                                        'varela-round.regular',
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: "إن شاء الله",
                                                  style: TextStyle(
                                                      wordSpacing: 2,
                                                      fontFamily:
                                                          'Al Majeed Quranic Font_shiped',
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                TextSpan(
                                                    text:
                                                        "). none of the users' personal data are stored in our servers without encryption. even we won't be able to decrypt those data. keep us in your prayers.\n"),
                                              ]),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Text(
                                        "مَعَ ٱلسَّلَامَة",
                                        style: TextStyle(
                                            wordSpacing: 2,
                                            fontFamily:
                                                'Al Majeed Quranic Font_shiped',
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: textColor),
                                        textScaleFactor: aspectRatio,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // const SizedBox(
                              //   height: 0,
                              // ),
                              AnimatedContainer(
                                curve: Curves.linearToEaseOut,
                                duration: const Duration(milliseconds: 350),
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(11),
                                      topRight: Radius.circular(11),
                                      bottomLeft: Radius.circular(21),
                                      bottomRight: Radius.circular(21)),
                                  color: Colors.white,
                                ),
                                width: size.width - 60,
                                height: snack_text_padding,
                                child: AnimatedDefaultTextStyle(
                                    duration:
                                        const Duration(milliseconds: 1000),
                                    style: TextStyle(
                                        height: 1,
                                        color: const Color(0xff1d3f5e),
                                        fontFamily: 'varela-round.regular',
                                        fontSize: snack_text_size,
                                        fontWeight: FontWeight.bold),
                                    child: Center(
                                      child: Text(
                                        'under development...',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            height: 1,
                                            color: const Color(0xff1d3f5e),
                                            fontFamily: 'varela-round.regular',
                                            fontSize: snack_text_size,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    )),
                              ),
                              const SizedBox(
                                height: 17,
                              ),
                              // Text(
                              //   "languages",
                              //   textAlign: TextAlign.center,
                              //   style: TextStyle(
                              //       height: 1,
                              //       color: const Color(0xffffffff),
                              //       fontFamily: 'varela-round.regular',
                              //       fontSize: size.width * .035,
                              //       fontWeight: FontWeight.bold),
                              // ),
                              // const SizedBox(
                              //   height: 11,
                              // ),
                              // Row(
                              //   mainAxisAlignment: MainAxisAlignment.center,
                              //   children: [
                              //     AnimatedContainer(
                              //       duration: const Duration(milliseconds: 500),
                              //       decoration: BoxDecoration(
                              //           borderRadius:
                              //               BorderRadius.circular(100),
                              //           color: Colors.black),
                              //       // width: size.width * .1,
                              //       // height: size.width * .075,
                              //       child: Padding(
                              //         padding: const EdgeInsets.all(9.0),
                              //         child: Center(
                              //           child: Row(
                              //             children: [
                              //               Container(
                              //                 width: size.width * .065,
                              //                 height: size.width * .065,
                              //                 decoration: BoxDecoration(
                              //                     borderRadius:
                              //                         BorderRadius.circular(
                              //                             1000),
                              //                     color: Colors.white),
                              //                 child: Center(
                              //                     child: Text(
                              //                   "B",
                              //                   textAlign: TextAlign.center,
                              //                   style: TextStyle(
                              //                       height: 0,
                              //                       color:
                              //                           const Color(0xff1d3f5e),
                              //                       fontFamily:
                              //                           'varela-round.regular',
                              //                       fontSize: size.width * .035,
                              //                       fontWeight:
                              //                           FontWeight.bold),
                              //                 )),
                              //               ),
                              //               Text(
                              //                 " bangla ",
                              //                 textAlign: TextAlign.center,
                              //                 style: TextStyle(
                              //                     height: 0,
                              //                     color: Colors.white,
                              //                     fontFamily:
                              //                         'varela-round.regular',
                              //                     fontSize: size.width * .035,
                              //                     fontWeight: FontWeight.bold),
                              //               ),
                              //             ],
                              //           ),
                              //         ),
                              //       ),
                              //     ),
                              //     const SizedBox(
                              //       width: 9,
                              //     ),
                              //     AnimatedContainer(
                              //       duration: const Duration(milliseconds: 500),
                              //       decoration: BoxDecoration(
                              //           borderRadius:
                              //               BorderRadius.circular(100),
                              //           color: Colors.white.withOpacity(.25)),
                              //       // width: size.width * .1,
                              //       // height: size.width * .075,
                              //       child: Padding(
                              //         padding: const EdgeInsets.all(9.0),
                              //         child: Center(
                              //           child: Row(
                              //             children: [
                              //               Container(
                              //                 width: size.width * .065,
                              //                 height: size.width * .065,
                              //                 decoration: BoxDecoration(
                              //                     borderRadius:
                              //                         BorderRadius.circular(
                              //                             1000),
                              //                     color: Colors.black),
                              //                 child: Center(
                              //                     child: Text(
                              //                   "E",
                              //                   textAlign: TextAlign.center,
                              //                   style: TextStyle(
                              //                       height: 0,
                              //                       color: Colors.white,
                              //                       fontFamily:
                              //                           'varela-round.regular',
                              //                       fontSize: size.width * .035,
                              //                       fontWeight:
                              //                           FontWeight.bold),
                              //                 )),
                              //               ),
                              //               Text(
                              //                 " bangla ",
                              //                 textAlign: TextAlign.center,
                              //                 style: TextStyle(
                              //                     height: 0,
                              //                     color: Colors.white,
                              //                     fontFamily:
                              //                         'varela-round.regular',
                              //                     fontSize: size.width * .035,
                              //                     fontWeight: FontWeight.bold),
                              //               ),
                              //             ],
                              //           ),
                              //         ),
                              //       ),
                              //     ),
                              //   ],
                              // )
                              // const SizedBox(height: 11,),
                              // SizedBox(
                              //   height: snack_text_size > 0 ? snack_text_size - 2 : snack_text_size,
                              // ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ));
  }
}
