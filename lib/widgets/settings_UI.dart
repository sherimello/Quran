import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quran/pages/surah_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:url_launcher/url_launcher.dart';

import '../classes/my_sharedpreferences.dart';
import '../hero_transition_handler/custom_rect_tween.dart';
import 'dart:math' as math;

import '../pages/new_surah_page.dart';

class SettingsUI extends StatefulWidget {
  final String tag, surah_id;
  double fontsize_english = 13, fontsize_arab = 13;
  Color theme;
  final void Function()? toggleMenuClicked;

  SettingsUI({
    Key? key,
    this.surah_id = "",
    required this.toggleMenuClicked,
    required this.tag,
    required this.fontsize_english,
    required this.fontsize_arab,
    required this.theme,
  }) : super(key: key);

  @override
  State<SettingsUI> createState() => _SettingsUIState();
}

class _SettingsUIState extends State<SettingsUI> {
  double snack_text_size = 0, snack_text_padding = 0;
  IconData _icon_theme = Icons.brightness_7_sharp;

  bool wordMeaningStatus = false,
      pronunciationStatus = false,
      tafsirStatus = false;

  late final Duration halfDuration;
  bool isArabicFontChanged = false,
      shouldShowFontSizeChangeCard = false,
      shouldShowAboutCard = false;
  double card_padding = 0.0,
      size_container_init = 0,
      aspectRatio = 0,
      englishSize = 0,
      arabicSize = 0;
  late SharedPreferences sharedPreferences;
  Color textColor = Colors.black;
  String selectedLanguage = "";
  MySharedPreferences mySharedPreferences = MySharedPreferences();

  initializeSP() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  saveEnglishFontSize() async {
    // await initializeSP();
    print(widget.fontsize_english);
    try {
      sharedPreferences.setDouble("english_font_size", englishSize);
    } catch (e) {
      initializeSP().whenComplete(() {
        saveEnglishFontSize();
      });
    }
  }

  saveArabicFontSize() {
    try {
      sharedPreferences.setDouble("arabic_font_size", arabicSize);
    } catch (e) {
      initializeSP().whenComplete(() {
        saveEnglishFontSize();
      });
    }
  }

  Future<void> saveThemeState(String theme) async {
    sharedPreferences.setString('theme mode', theme);
  }

  Future<bool> checkWordMeaningStatus() async {
    if (sharedPreferences.containsKey("word meaning")) {
      setState(() {
        wordMeaningStatus = (sharedPreferences.getBool("word meaning"))!;
      });
    }
    return wordMeaningStatus;
  }

  Future<bool> checkTransliterationStatus() async {
    if (sharedPreferences.containsKey("transliteration")) {
      setState(() {
        pronunciationStatus = (sharedPreferences.getBool("transliteration"))!;
      });
    }
    return pronunciationStatus;
  }

  Future<bool> checkTafsirStatus() async {
    if (sharedPreferences.containsKey("tafsir")) {
      setState(() {
        tafsirStatus = (sharedPreferences.getBool("tafsir"))!;
      });
    }
    return tafsirStatus;
  }

  Future<void> saveWordMeaningState(bool status) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool('word meaning', status);
  }

  Future<void> saveTransliterationState(bool status) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool('transliteration', status);
  }

  Future<void> saveTafsirState(bool status) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool('tafsir', status);
  }

  init() async {
    // sharedPreferences = await SharedPreferences.getInstance();

    setState(() {
      englishSize = widget.fontsize_english;
      arabicSize = widget.fontsize_arab;
    });

    selectedLanguage = await (mySharedPreferences.getStringValue("lang"));
    if (selectedLanguage == "") {
      setState(() {
        selectedLanguage = "eng";
      });
    }
    widget.theme == Colors.white
        ? setState(() {
            _icon_theme = Icons.brightness_7_sharp;
            textColor = Colors.black;
          })
        : setState(() {
            _icon_theme = Icons.brightness_4_outlined;
            textColor = Colors.white;
          });
    await initializeSP();
    checkWordMeaningStatus();
    checkTransliterationStatus();
    checkTafsirStatus();
    // englishSize = widget.fontsize_english;
    // arabicSize = widget.fontsize_arab;
    // _addStatusListener();
  }

  Future<bool> showWarningPopup() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(31)),
            title: const Text(
              'caution!',
              style: TextStyle(fontFamily: 'varela-round.regular'),
            ),
            content: const Text(
              'this may lead to inaccurate pronunciation(s). it is highly discouraged to use this feature or solely rely upon it.',
              style: TextStyle(fontFamily: 'varela-round.regular'),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(bottom: 11.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: const Color(0xff1d3f5e),
                    elevation: 7,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(31), // <-- Radius
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text(
                    'keep it off',
                    style: TextStyle(fontFamily: 'varela-round.regular'),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 11.0, bottom: 11),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: const Color(0xff1d3f5e),
                    elevation: 7,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(31), // <-- Radius
                    ),
                  ),
                  onPressed: () {
                    saveTransliterationState(true);
                    setState(() {
                      pronunciationStatus = true;
                    });

                    Navigator.of(context).pop(false);
                  },
                  //return true when click on "Yes"
                  child: const Text(
                    'continue',
                    style: TextStyle(fontFamily: 'varela-round.regular'),
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false; //if showDialouge had returned null, then return false
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void dispose() {
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

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Hero(
          tag: widget.tag,
          createRectTween: (begin, end) {
            return CustomRectTween(begin: begin!, end: end!);
          },
          child: SingleChildScrollView(
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
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 11.0),
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
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
                                            onTap: (widget.surah_id == "")
                                                ? () {
                                                    Navigator.of(context).pop();
                                                    // Navigator.of(context)
                                                    //     .pushReplacement(
                                                    //         MaterialPageRoute(
                                                    //             builder:
                                                    //                 (builder) =>
                                                    //                     SurahList(
                                                    //                       eng: widget
                                                    //                           .fontsize_english,
                                                    //                       ar: widget
                                                    //                           .fontsize_arab,
                                                    //                     )));
                                                  }
                                                : widget.toggleMenuClicked,
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
                                              englishSize;
                                        } else {
                                          size_container_init = 101.0 +
                                              (size.width * .1) * 2 +
                                              (englishSize + 1) * aspectRatio;
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
                                                "english (${englishSize} px):",
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
                                                    if (isArabicFontChanged) {
                                                      isArabicFontChanged =
                                                          false;
                                                    }
                                                    if (englishSize > 13) {
                                                      englishSize -= 1;
                                                    }
                                                    size_container_init =
                                                        101.0 +
                                                            (size.width *
                                                                .1 *
                                                                2) +
                                                            englishSize;
                                                  });
                                                  saveEnglishFontSize();
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
                                                    if (isArabicFontChanged) {
                                                      isArabicFontChanged =
                                                          false;
                                                    }
                                                    if (englishSize < 17) {
                                                      setState(() {
                                                        englishSize =
                                                            englishSize + 1;
                                                      });
                                                      saveEnglishFontSize();
                                                    }
                                                    size_container_init =
                                                        101.0 +
                                                            (size.width * .1) *
                                                                2 +
                                                            englishSize;
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
                                                "arabic (${arabicSize} px):",
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
                                                    if (arabicSize > 13) {
                                                      arabicSize -= 1;
                                                      saveArabicFontSize();
                                                    }
                                                    size_container_init =
                                                        101.0 +
                                                            (size.width * .1) *
                                                                2 +
                                                            arabicSize *
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
                                                    if (arabicSize < 21) {
                                                      arabicSize += 1;
                                                      saveArabicFontSize();
                                                    }
                                                    size_container_init =
                                                        101.0 +
                                                            (size.width * .1) *
                                                                2 +
                                                            arabicSize *
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
                                            duration: const Duration(
                                                milliseconds: 250),
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
                                                    visible:
                                                        isArabicFontChanged,
                                                    child: Center(
                                                      child: Text(
                                                        "بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ",
                                                        textScaleFactor:
                                                            aspectRatio,
                                                        textAlign:
                                                            TextAlign.center,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          //101 + size.width * .1 * 2
                                                          height: 1,
                                                          fontFamily:
                                                              'Al Majeed Quranic Font_shiped',
                                                          color: Colors.black,
                                                          fontSize: arabicSize,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Visibility(
                                                    visible:
                                                        !isArabicFontChanged,
                                                    child: Center(
                                                      child: Text(
                                                        'In the name of Allah, the Entirely Merciful, the Especially Merciful.',
                                                        textAlign:
                                                            TextAlign.center,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          //101 + size.width * .1 * 2
                                                          height: 1,
                                                          fontFamily:
                                                              'varela-round.regular',
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: englishSize,
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
                                    if (_icon_theme ==
                                        Icons.brightness_7_sharp) {
                                      saveThemeState("dark").whenComplete(() {
                                        setState(() {
                                          widget.theme = Colors.black;
                                          textColor = Colors.white;
                                          _icon_theme =
                                              Icons.brightness_4_outlined;
                                        });
                                      });
                                    } else {
                                      saveThemeState("light").whenComplete(() {
                                        setState(() {
                                          widget.theme = Colors.white;
                                          textColor = Colors.black;
                                          _icon_theme =
                                              Icons.brightness_7_sharp;
                                        });
                                      });
                                    }
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
                                            child: Icon(
                                              _icon_theme,
                                              color: Colors.white,
                                            )),
                                        TextSpan(
                                            text: _icon_theme ==
                                                    Icons.brightness_7_sharp
                                                ? '  dark mode: OFF'
                                                : '  dark mode: ON'),
                                      ])),
                                ),

                                const SizedBox(
                                  height: 17,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    if (wordMeaningStatus) {
                                      saveWordMeaningState(false)
                                          .whenComplete(() => setState(() {
                                                wordMeaningStatus = false;
                                              }));
                                    } else {
                                      saveWordMeaningState(true)
                                          .whenComplete(() => setState(() {
                                                wordMeaningStatus = true;
                                              }));
                                    }
                                  },
                                  child: Text.rich(TextSpan(
                                      style: const TextStyle(
                                          fontFamily: 'varela-round.regular',
                                          fontSize: 21,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                      children: [
                                        const WidgetSpan(
                                            alignment:
                                                PlaceholderAlignment.middle,
                                            child: Icon(
                                              Icons.translate,
                                              color: Colors.white,
                                            )),
                                        TextSpan(
                                            text: !wordMeaningStatus
                                                ? '  word meanings: OFF'
                                                : '  word meanings: ON'),
                                      ])),
                                ),

                                Visibility(
                                  visible: selectedLanguage != "ben",
                                  child: const SizedBox(
                                    height: 17,
                                  ),
                                ),
                                Visibility(
                                  visible: selectedLanguage != "ben",
                                  child: GestureDetector(
                                    onTap: () {
                                      if (pronunciationStatus) {
                                        saveTransliterationState(false)
                                            .whenComplete(() => setState(() {
                                                  pronunciationStatus = false;
                                                }));
                                      } else {
                                        showWarningPopup();
                                      }
                                    },
                                    child: Text.rich(TextSpan(
                                        style: const TextStyle(
                                            fontFamily: 'varela-round.regular',
                                            fontSize: 21,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                        children: [
                                          const WidgetSpan(
                                              alignment:
                                                  PlaceholderAlignment.middle,
                                              child: Icon(
                                                Icons.abc,
                                                color: Colors.white,
                                              )),
                                          TextSpan(
                                              text: !pronunciationStatus
                                                  ? '  pronunciation: OFF'
                                                  : '  pronunciation: ON'),
                                        ])),
                                  ),
                                ),

                                const SizedBox(
                                  height: 17,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    if (tafsirStatus) {
                                      saveTafsirState(false).whenComplete(() =>
                                          setState(() => tafsirStatus = false));
                                    } else {
                                      saveTafsirState(true).whenComplete(() =>
                                          setState(() => tafsirStatus = true));
                                    }
                                  },
                                  child: Text.rich(TextSpan(
                                      style: const TextStyle(
                                          fontFamily: 'varela-round.regular',
                                          fontSize: 21,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                      children: [
                                        const WidgetSpan(
                                            alignment:
                                                PlaceholderAlignment.middle,
                                            child: Icon(
                                              Icons.menu_book_outlined,
                                              color: Colors.white,
                                            )),
                                        TextSpan(
                                            text: !tafsirStatus
                                                ? '  tafsir: OFF'
                                                : '  tafsir: ON'),
                                      ])),
                                ),
                                SizedBox(
                                  height: widget.surah_id == "" ? 17 : 0,
                                ),
                                Visibility(
                                  visible: widget.surah_id == "",
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        shouldShowAboutCard =
                                            !shouldShowAboutCard;
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
                                                        height:
                                                            size.width * .25,
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
                                                      PlaceholderAlignment
                                                          .middle,
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
                                                recognizer:
                                                    TapGestureRecognizer()
                                                      ..onTap = () async {
                                                        final url = Uri(
                                                          scheme: 'mailto',
                                                          path:
                                                              'uchiha.sherimello@gmail.com',
                                                        );
                                                        if (!await launchUrl(
                                                            url)) {
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
                                      color: Colors.white),
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
                                              fontFamily:
                                                  'varela-round.regular',
                                              fontSize: snack_text_size,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      )),
                                ),
                                const SizedBox(
                                  height: 35,
                                ),
                                Text(
                                  "translation languages",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      height: 1,
                                      color: const Color(0xffffffff),
                                      fontFamily: 'varela-round.regular',
                                      fontSize: size.width * .035,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(
                                  height: 11,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedLanguage = "ben";
                                        });
                                        mySharedPreferences.setStringValue(
                                            "lang", "ben");
                                      },
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 500),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(100),
                                            color: selectedLanguage == "ben"
                                                ? Colors.black
                                                : Colors.white
                                                    .withOpacity(.35)),
                                        // width: size.width * .1,
                                        // height: size.width * .075,
                                        child: Padding(
                                          padding: const EdgeInsets.all(9.0),
                                          child: Center(
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: size.width * .065,
                                                  height: size.width * .065,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              1000),
                                                      color: selectedLanguage ==
                                                              "ben"
                                                          ? Colors.white
                                                          : Colors.black),
                                                  child: Center(
                                                      child: Text(
                                                    "B",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        height: 0,
                                                        color:
                                                            selectedLanguage ==
                                                                    "ben"
                                                                ? const Color(
                                                                    0xff1d3f5e)
                                                                : Colors.white,
                                                        fontFamily:
                                                            'varela-round.regular',
                                                        fontSize:
                                                            size.width * .035,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  )),
                                                ),
                                                Text(
                                                  " bangla ",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      height: 0,
                                                      color: Colors.white,
                                                      fontFamily:
                                                          'varela-round.regular',
                                                      fontSize:
                                                          size.width * .035,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 9,
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedLanguage = "eng";
                                        });
                                        mySharedPreferences.setStringValue(
                                            "lang", "eng");
                                      },
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 500),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(100),
                                            color: selectedLanguage == "eng"
                                                ? Colors.black
                                                : Colors.white
                                                    .withOpacity(.25)),
                                        // width: size.width * .1,
                                        // height: size.width * .075,
                                        child: Padding(
                                          padding: const EdgeInsets.all(9.0),
                                          child: Center(
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: size.width * .065,
                                                  height: size.width * .065,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              1000),
                                                      color: selectedLanguage ==
                                                              "eng"
                                                          ? Colors.white
                                                          : Colors.black),
                                                  child: Center(
                                                      child: Text(
                                                    "E",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        height: 0,
                                                        color:
                                                            selectedLanguage ==
                                                                    "eng"
                                                                ? const Color(
                                                                    0xff1d3f5e)
                                                                : Colors.white,
                                                        fontFamily:
                                                            'varela-round.regular',
                                                        fontSize:
                                                            size.width * .035,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  )),
                                                ),
                                                Text(
                                                  " english ",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      height: 0,
                                                      color: Colors.white,
                                                      fontFamily:
                                                          'varela-round.regular',
                                                      fontSize:
                                                          size.width * .035,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 11,
                                ),
                                SizedBox(
                                  height: snack_text_size > 0
                                      ? snack_text_size - 2
                                      : snack_text_size,
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
