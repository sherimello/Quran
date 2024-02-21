import 'dart:convert';

import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path/path.dart';
import 'package:quran/assets/network%20operations/user_data.dart';
import 'package:quran/classes/db_helper.dart';
import 'package:quran/classes/test_class.dart';
import 'package:quran/pages/menu.dart';
import 'package:quran/pages/new_surah_page.dart';
import 'package:quran/pages/options.dart';
import 'package:quran/pages/settings_card.dart';
import 'package:quran/pages/surah_page.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:math' as math;

import '../classes/my_sharedpreferences.dart';
import '../hero_transition_handler/custom_rect_tween.dart';
import '../hero_transition_handler/hero_dialog_route.dart';
import '../widgets/update_prompt.dart';

class SurahList extends StatefulWidget {
  double eng, ar;
  bool shouldAnimate;

  SurahList({
    Key? key,
    required this.eng,
    required this.ar,
    this.shouldAnimate = false,
  }) : super(key: key);

  @override
  State<SurahList> createState() => _SurahListState();
}

class _SurahListState extends State<SurahList> with TickerProviderStateMixin {
  late Database database;
  late String path;
  late int sujood_index;
  IconData _icon = Icons.brightness_7_sharp;
  String surah_type = '';
  List<Map> sujood_surah_indices = [],
      sujood_verse_indices = [],
      surah_name_arabic = [],
      surah_name_translated = [];
  List<int> selected_surah_sujood_verses = [],
      verse_numbers = [
        7,
        286,
        200,
        176,
        120,
        165,
        206,
        75,
        127,
        109,
        123,
        111,
        43,
        52,
        99,
        128,
        111,
        110,
        98,
        135,
        112,
        78,
        118,
        64,
        77,
        227,
        93,
        88,
        69,
        60,
        34,
        30,
        73,
        54,
        45,
        83,
        182,
        88,
        75,
        85,
        54,
        53,
        89,
        59,
        37,
        35,
        38,
        29,
        18,
        45,
        60,
        49,
        62,
        55,
        78,
        96,
        29,
        22,
        24,
        13,
        14,
        11,
        11,
        18,
        12,
        12,
        30,
        52,
        52,
        44,
        28,
        28,
        20,
        56,
        40,
        31,
        50,
        40,
        46,
        42,
        29,
        19,
        36,
        25,
        22,
        17,
        19,
        26,
        30,
        20,
        15,
        21,
        11,
        8,
        8,
        19,
        5,
        8,
        8,
        11,
        11,
        8,
        3,
        9,
        5,
        4,
        7,
        3,
        6,
        3,
        5,
        4,
        5,
        6
      ],
      madani_surah = [
        2,
        3,
        4,
        5,
        8,
        9,
        13,
        22,
        24,
        33,
        47,
        48,
        49,
        55,
        57,
        58,
        59,
        60,
        61,
        62,
        63,
        64,
        65,
        66,
        76,
        98,
        99,
        110
      ],
      disputed_types = [
        1,
        13,
        16,
        22,
        29,
        47,
        55,
        61,
        64,
        76,
        80,
        83,
        89,
        92,
        97,
        98,
        99,
        110,
        112,
        113
      ];
  List<Map> verses = [], translated_verse = [];
  late Animation<Color?> animation, animation2, animation3, animation4;
  late AnimationController controller;
  late final AnimationController animationController;
  late final Animation<double> _arrowAnimation;
  var bgColor = Colors.white,
      color1 = Colors.black,
      toColor1 = Colors.white,
      color2 = const Color(0xff1d3f5e),
      toColor2 = Colors.white,
      color3 = const Color(0xff1d3f5e),
      toColor3 = Colors.black,
      color4 = const Color(0xffffffff),
      toColor4 = const Color(0xff1d3f5e),
      defTextColor = Colors.black;
  int darktheme = 0, clicked = 0, shouldReverse = 0;
  late final Duration halfDuration;
  late AutoScrollController autoScrollController;
  bool showRipples = true;
  late ScrollController scrollController;
  double scrollOffset = 0.0;
  late final FirebaseAuth _auth;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  UserCredential? userCredential;
  bool themeSwitchingInProgress = true;

  bool signedIn = false;
  String profile_picture_url = "";

  checkIfUserSignedIn() async {
    // _auth = FirebaseAuth.instance;
    // Future.wait([initFirebase()]);
    await initFirebase();
    if (_auth.currentUser != null) {
      setState(() {
        signedIn = true;
        profile_picture_url = _auth.currentUser!.photoURL.toString();
      });
    } else {
      setState(() {
        signedIn = false;
      });
    }
  }

  setSignInStatus(bool flag) {
    setState(() {
      signedIn = flag;
    });
  }

  Future _scrollToIndex() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.containsKey("scroll_offset_for_surah_list")) {
      scrollOffset =
          sharedPreferences.getDouble("scroll_offset_for_surah_list")!;
      if (scrollController.hasClients) {
        scrollController.jumpTo(scrollOffset);
        return;
      } else {
        Future.delayed(const Duration(milliseconds: 100), _scrollToIndex);
        // _scrollToIndex();
        return;
      }
    }
  }

  getFontSizes() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    widget.eng = sharedPreferences.getDouble("english_font_size")!;
    widget.ar = sharedPreferences.getDouble("arabic_font_size")!;
  }

  bool isThemeInit = false;

  late TestClass dataClass;

  Future<void> initData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonString = prefs.getString('testClass')!;

    // Decode the JSON string
    Map<String, dynamic> decoded = jsonDecode(jsonString);

    // Create an instance of TestClass from the decoded JSON
    dataClass = TestClass.fromJson(decoded);
    // print(dataClass.surah_name_arabic);
  }

  Future<void> initFirebase() async {
    Firebase.initializeApp();
    _auth = FirebaseAuth.instance;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollController = ScrollController();
      _scrollToIndex();
    });

    Future.wait([
    themeLogics().then((_) {
      animationController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 355),
      );
      setState(() => isThemeInit = true);
      checkIfUserSignedIn();
      initData().then((_) {
        fetchSurahName().then((_) {

        });
      });
    })
    ]);

    // Future.wait([
    //   initializeThemeStarters(),
    //   initiateDB(),
    //   initData(),
    //   fetchSurahName(),
    // ]).then((_) {
    //   themeLogics().then((_) {
    //     animationController = AnimationController(
    //       vsync: this,
    //       duration: const Duration(milliseconds: 355),
    //     );
    //   });
    //   checkIfUserSignedIn();
    // });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    animationController.dispose();
    // autoScrollController.dispose();
    controller.dispose();
    scrollController.dispose();
  }

  void changeStatusBarColor(int colorCode) {
    setState(() {
      SystemChrome.setSystemUIOverlayStyle(
          const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    });
  }

  assignmentForLightMode() {
    darktheme = 0;
    color1 = Colors.black;
    toColor1 = Colors.white;
    color2 = const Color(0xff1d3f5e);
    toColor2 = Colors.white;
    color3 = const Color(0xff1d3f5e);
    color4 = const Color(0xff1d3f5e);
    toColor4 = const Color(0xffffffff);
    toColor3 = Colors.black;
    bgColor = Colors.white;
    defTextColor = Colors.black;
  }

  assignmentForDarkMode() {
    darktheme = 1;
    color1 = Colors.white;
    toColor1 = Colors.black;
    color2 = Colors.white;
    toColor2 = const Color(0xff1d3f5e);
    color3 = Colors.black;
    toColor3 = const Color(0xff1d3f5e);
    color4 = const Color(0xffffffff);
    toColor4 = const Color(0xff1d3f5e);
    bgColor = Colors.black;
    defTextColor = Colors.white;
  }

  String getSurahTypeImage(int index) {
    String img = "";
    madani_surah.contains(index + 1)
        ? img = 'lib/assets/images/madinaWhiteIcon.png'
        : img = 'lib/assets/images/makkaWhiteIcon.png';

    return img;
  }

  Future<void> initializeThemeStarters() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.containsKey('theme mode')) {
      if (sharedPreferences.getString('theme mode') == "light") {
        changeStatusBarColor(0xff1d3f5e);
        assignmentForLightMode();
      }
      if (sharedPreferences.getString('theme mode') == "dark") {
        changeStatusBarColor(0xff000000);
        assignmentForDarkMode();
      }
    }
  }

  bool colorAnimationLoaded = false;

  Future<void> themeLogics() async {
    await initializeThemeStarters().whenComplete(() {
      controller = AnimationController(
          duration: const Duration(milliseconds: 500), vsync: this);
      animation = ColorTween(begin: color1, end: toColor1).animate(controller)
        ..addListener(() {
          setState(() {
            // The state that has changed here is the animation object’s value.
          });
        });
      animation2 = ColorTween(begin: color2, end: toColor2).animate(controller)
        ..addListener(() {
          setState(() {
            colorAnimationLoaded = true;
            // The state that has changed here is the animation object’s value.
          });
        });
      animation3 = ColorTween(begin: color3, end: toColor3).animate(controller)
        ..addListener(() {
          setState(() {
            // The state that has changed here is the animation object’s value.
            // The state that has changed here is the animation object’s value.
          });
        });
      animation4 = ColorTween(begin: color4, end: toColor4).animate(controller)
        ..addListener(() {
          setState(() {
            // The state that has changed here is the animation object’s value.
          });
        });
    });
  }

  void animateColor() {
    if (controller.isCompleted) {
      controller.reverse();
      shouldReverse = 1;
    } else {
      controller.forward();
      shouldReverse = 0;
    }
  }

  Future<void> initiateDB() async {
    // Get a location using getDatabasesPath
    var databasesPath = await getDatabasesPath();
    path = join(databasesPath, 'en_ar_quran.db');

    database = await openDatabase(path);

    print(database.isOpen);
  }

  checkForUpdates() async {
    // Future<Database> db = DatabaseHelper.instance.initDatabase("kathir_db.db");

    // List<Map<String, dynamic>> tafsir =
    //     await DatabaseHelper.instance.fetchData("bn_bayaan.db");
    // print(tafsir);
    // List<String> tableNames =
    // tafsir.map((table) => table['name'] as String).toList();
    // for (String entry in tableNames) {
    //   String verse = entry;
    //
    //   // Do something with the values, e.g., print them
    //   print('Verse: $verse');
    // }

    var snapshot = await FirebaseDatabase.instance
        .ref('current version')
        .child("version code")
        .get();

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;
    print(version);

    if (snapshot.value.toString() != version) {
      snapshot = await FirebaseDatabase.instance
          .ref('current version')
          .child("url")
          .get()
          .whenComplete(() {
        Navigator.of(this.context).push(HeroDialogRoute(
          builder: (context) => Center(
            child: UpdatePrompt(
              url: snapshot.value.toString(),
              title: 'NEW UPDATE FOUND',
              content: 'wanna stay up to date?',
              negativeButtonText: 'cancel',
            ),
          ),
        ));
      });
    }
    // }
  }

  // Future<void> fetchVersesData(String surahId) async {
  //   // print(widget.verse_numbers);
  //   // verses.clear();
  //   await initiateDB().whenComplete(() async {
  //     verses = await database.rawQuery(
  //         'SELECT text FROM verses WHERE lang_id = 1 AND surah_id = ?',
  //         [surahId]);
  //     translated_verse = await database.rawQuery(
  //         'SELECT text FROM verses WHERE lang_id = 2 AND surah_id = ?',
  //         [surahId]);
  //   });
  //   setState(() {
  //     verses = verses;
  //     translated_verse = translated_verse;
  //   });
  // }

  Future fetchSurahName() async {
    initiateDB().whenComplete(() async {
      surah_name_arabic.clear();
      surah_name_translated.clear();
      surah_name_arabic = dataClass.surah_name_arabic;
      surah_name_translated = dataClass.surah_name_english;
      sujood_surah_indices = dataClass.sujood_surah_indices;
      sujood_verse_indices = dataClass.sujood_verse_indices;
      if (mounted) {
        setState(() {
          // surahs.add(surah_name_arabic_temp);
          surah_name_arabic = surah_name_arabic;
          surah_name_translated = surah_name_translated;
        });
      }
      // print(surah_name_translated);
    });
  }

  Future<void> fetchSurahSujoodVerses(int surahId) async {
    selected_surah_sujood_verses = [];
    for (int i = 0; i < sujood_surah_indices.length; i++) {
      if (sujood_surah_indices[i]['surah_id'] == surahId) {
        selected_surah_sujood_verses.add(sujood_verse_indices[i]['verse_id']);
      }
    }
  }

  int getSujoodSurahIndex(int id) {
    for (int i = 0; i < sujood_surah_indices.length; i++) {
      if (sujood_surah_indices[i]['surah_id'] == id) {
        // sujood_surah_indices.removeAt(i);
        return i;
      }
    }
    return -1;
  }

  int getSujoodVerseIndex(int id) {
    for (int i = 0; i < sujood_verse_indices.length; i++) {
      if (sujood_verse_indices[i]['surah_id'] == id) {
        sujood_verse_indices.removeAt(i);
        return i;
      }
    }
    return -1;
  }

  void getSurahTypeAndSujoodIndex(int index) {
    for (int i = 0; i < madani_surah.length; i++) {
      if (index + 1 == madani_surah[i]) {
        disputed_types.contains(index + 1)
            ? surah_type = 'Madani Surah (?)'
            : surah_type = 'Madani Surah';
        break;
      } else {
        disputed_types.contains(index + 1)
            ? surah_type = 'Makki Surah (?)'
            : surah_type = 'Makki Surah';
        // break;
      }
      sujood_index = getSujoodSurahIndex(index + 1);
    }
  }

  List<BoxShadow> boxShadow(double blurRadius, double offset1, double offset2,
      Color colorBottom, Color colorTop) {
    return [
      BoxShadow(
        blurRadius: blurRadius,
        offset: Offset(offset1, offset2),
        color: colorBottom.withOpacity(.5),
      ),
      BoxShadow(
        blurRadius: blurRadius,
        offset: Offset(-offset1, -offset2),
        color: colorTop,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var appBar = AppBar();

    Future<bool> showLogInPopup() async {
      return await showDialog(
            //show confirm dialogue
            //the return value will be from "Yes" or "No" options
            context: context,
            builder: (context) => AlertDialog(
              title: const Text(
                'Sign Out',
                style: TextStyle(
                    fontFamily: "Rounded_Elegance",
                    fontWeight: FontWeight.bold),
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(31)),
              content: const Text(
                'Do you want to sign out? All the currently restored data will be retained but the newly added bookmarks, favorites and other user specific data will not be backed up.',
                style: TextStyle(
                    fontFamily: "Rounded_Elegance",
                    fontWeight: FontWeight.normal),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        const Color(0xff1d3f5e)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            100), // Adjust the radius as needed
                      ),
                    ),
                  ),
                  //return false when click on "NO"
                  child: const Text(
                    'No',
                    style: TextStyle(
                        fontFamily: "Rounded_Elegance",
                        fontWeight: FontWeight.bold),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pop(false);
                    UserData().handleSignOut(_auth);
                    setState(() {
                      signedIn = false;
                    });
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        const Color(0xff1d3f5e)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            100), // Adjust the radius as needed
                      ),
                    ),
                  ),
                  //return true when click on "Yes"
                  child: const Text(
                    'Yes',
                    style: TextStyle(
                        fontFamily: "Rounded_Elegance",
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ) ??
          false; //if showDialouge had returned null, then return false
    }

    bool isPortraitMode() {
      return size.height > size.width ? true : false;
    }

    Future<bool> backToMenu() async {
      return await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Menu(
                        eng: widget.eng,
                        ar: widget.ar,
                      ))) ??
          false;
    }

    saveThemeState(String theme) async {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      sharedPreferences.setString('theme mode', theme);
    }

    return ThemeSwitchingArea(
      child: WillPopScope(
        onWillPop: backToMenu,
        child: Scaffold(
          floatingActionButton: ThemeSwitcher(
            builder: (context) => FloatingActionButton(
                backgroundColor: !colorAnimationLoaded
                    ? bgColor == Colors.black
                        ? Colors.white
                        : const Color(0xff1d3f5e)
                    : animation2.value,
                child: Icon(
                  _icon,
                  color: bgColor,
                ),
                onPressed: () async {
                  if (!themeSwitchingInProgress) {
                    setState(() {
                      widget.shouldAnimate = false;
                      if (_icon == Icons.brightness_7_sharp) {
                        _icon = Icons.brightness_4_outlined;
                      } else {
                        // changeStatusBarColor(0xff1d3f5e);
                        _icon = Icons.brightness_7_sharp;
                      }
                      themeSwitchingInProgress = true;
                    });
                  }
                  animationController.isCompleted
                      ? animationController.reverse()
                      : animationController.forward();

                  clicked = 1;

                  darktheme == 0
                      ? {
                          bgColor = Colors.black,
                          ThemeSwitcher.of(context).changeTheme(
                            theme: ThemeData(
                              brightness: Brightness.dark,
                            ),
                          ),
                          await Future.delayed(
                              const Duration(milliseconds: 500), () {
                            animateColor();
                          }),
                          darktheme = 1,
                          saveThemeState("dark"),
                        }
                      : {
                          bgColor = Colors.white,
                          ThemeSwitcher.of(context).changeTheme(
                              isReversed: true,
                              theme: ThemeData(
                                brightness: Brightness.light,
                              )),
                          await Future.delayed(
                              const Duration(milliseconds: 500), () {
                            animateColor();
                          }),
                          darktheme = 0,
                          saveThemeState("light"),
                        };
                }),
          ),
          backgroundColor: bgColor,
          // backgroundColor: clicked == 1 ? animation3.value! : color3,
          body: Stack(
            children: [
              Padding(
                padding:
                    EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                child: Container(
                  width: size.width,
                  height: AppBar().preferredSize.height,
                  decoration: BoxDecoration(
                    color: bgColor,
                  ),
                  child: Hero(
                    tag: "options",
                    createRectTween: (begin, end) {
                      return CustomRectTween(begin: begin!, end: end!);
                    },
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        width: size.width,
                        height: appBar.preferredSize.height,
                        color: Colors.transparent,
                        // color: clicked == 1 ? animation3.value! : color3,
                        child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 11.0),
                            child: Stack(children: [
                              Positioned(
                                  left: 0,
                                  top: 0,
                                  bottom: 0,
                                  child: Center(
                                    child: Text.rich(
                                      TextSpan(children: [
                                        WidgetSpan(
                                          alignment:
                                              PlaceholderAlignment.middle,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                right: 11.0),
                                            child: Container(
                                                width: appBar
                                                        .preferredSize.height -
                                                    appBar.preferredSize.height *
                                                        .35,
                                                height: appBar
                                                        .preferredSize.height -
                                                    appBar.preferredSize
                                                            .height *
                                                        .35,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            1000),
                                                    color: Colors.white
                                                        .withOpacity(.5)),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(2.0),
                                                  child: Image.asset(
                                                      'lib/assets/images/quran icon.png'),
                                                )),
                                          ),
                                        ),
                                        TextSpan(
                                          text: 'The Book',
                                          // 'Qur\'an',
                                          style: TextStyle(
                                              fontFamily: 'Bismillah Script',
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1.5,
                                              color: isThemeInit
                                                  ? animation.value
                                                  : Colors.transparent,
                                              fontSize: 21),
                                        ),
                                      ]),
                                    ),
                                  )),
                              Positioned(
                                top: 0,
                                bottom: 0,
                                right: 0,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    GestureDetector(
                                      onTap: () => signedIn
                                          ? showLogInPopup()
                                          : UserData()
                                              .handleSignIn()
                                              .then((value) {
                                              setSignInStatus(true);
                                              setState(() {
                                                profile_picture_url = value!
                                                    .user!.photoURL
                                                    .toString();
                                              });
                                            }),
                                      child: Container(
                                        width: size.width * .065,
                                        height: size.width * .065,
                                        // width: appBar.preferredSize.height -
                                        //     appBar.preferredSize.height * .35,
                                        // height: appBar.preferredSize.height -
                                        //     appBar.preferredSize.height * .35,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(1000),
                                            color: signedIn && isThemeInit
                                                ? animation.value
                                                : Colors.transparent),
                                        child: Center(
                                          child: signedIn
                                              ? Padding(
                                                  padding:
                                                      const EdgeInsets.all(2.0),
                                                  child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              1000),
                                                      child: Image.network(
                                                          profile_picture_url)),
                                                )
                                              : Icon(
                                                  Icons.person_pin,
                                                  color: isThemeInit
                                                      ? animation.value
                                                      : Colors.transparent,
                                                  size: appBar.preferredSize
                                                          .height -
                                                      appBar.preferredSize
                                                              .height *
                                                          .39,
                                                ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 11,
                                    ),
                                    GestureDetector(
                                        onTap: () async {
                                          SharedPreferences sharedPreferences =
                                              await SharedPreferences
                                                  .getInstance();
                                          sharedPreferences.setDouble(
                                              "scroll_offset_for_surah_list",
                                              scrollController.offset);
                                          await getFontSizes().whenComplete(() {
                                            Navigator.of(context)
                                                .push(HeroDialogRoute(
                                              fullscreenDialog: true,
                                              bgColor:
                                                  bgColor.withOpacity(0.85),
                                              builder: (b) => SettingsCard(
                                                tag: "options",
                                                theme: bgColor,
                                                fontsize_english: widget.eng,
                                                fontsize_arab: widget.ar,
                                              ),
                                            ))
                                                .then((value) async {
                                              setState(() {
                                                scrollOffset =
                                                    sharedPreferences.getDouble(
                                                        "scroll_offset_for_surah_list")!;
                                                scrollController
                                                    .jumpTo(scrollOffset);
                                              });

                                              //       setState(() {
                                              //         _scrollToIndex();
                                              // });
                                              await themeLogics()
                                                  .whenComplete(() {
                                                Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (builder) =>
                                                            SurahList(
                                                              eng: widget.eng,
                                                              ar: widget.ar,
                                                            )));

                                                // scrollOffset =
                                                // sharedPreferences.getDouble("scroll_offset_for_surah_list")!;
                                                // autoScrollController.jumpTo(scrollOffset);
                                                print("kkk");
                                                // _scrollToIndex();
                                                if (darktheme == 0) {
                                                  try {
                                                    ThemeSwitcher.of(context)
                                                        .changeTheme(
                                                      theme: ThemeData(
                                                        brightness:
                                                            Brightness.light,
                                                      ),
                                                    );
                                                  } catch (e) {
                                                    print(e);
                                                  }
                                                } else {
                                                  try {
                                                    ThemeSwitcher.of(context)
                                                        .changeTheme(
                                                      theme: ThemeData(
                                                        brightness:
                                                            Brightness.dark,
                                                      ),
                                                    );
                                                  } catch (e) {
                                                    print(e);
                                                  }
                                                }
                                              });
                                            });
                                          });
                                        },
                                        child: Icon(
                                          Icons.settings,
                                          color: isThemeInit
                                              ? animation.value
                                              : Colors.transparent,
                                          size: size.width * .065,
                                        )),
                                  ],
                                ),
                              )
                            ])),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    top: AppBar().preferredSize.height +
                        MediaQuery.of(context).padding.top),
                child: Container(
                    color: bgColor,
                    child: surah_name_arabic.isEmpty
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : ListView.builder(
                            controller: scrollController,
                            scrollDirection: Axis.vertical,
                            padding: EdgeInsets.zero,
                            itemCount:
                                surah_name_translated.isNotEmpty ? 114 : 0,
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            cacheExtent:
                                surah_name_translated.isNotEmpty ? 114 : 0,
                            itemBuilder: (BuildContext bcontext, int index) {
                              getSurahTypeAndSujoodIndex(index);
                              return GestureDetector(
                                onTap: () async {
                                  SharedPreferences sharedPreferences =
                                      await SharedPreferences.getInstance();
                                  sharedPreferences.setDouble(
                                      "scroll_offset_for_surah_list",
                                      scrollController.offset);
                                  sujood_index = getSujoodSurahIndex(index + 1);
                                  await fetchSurahSujoodVerses(index + 1);
                                  await getFontSizes().whenComplete(() {
                                    Navigator.push(
                                        context,
                                        PageTransition(
                                            type: PageTransitionType.fade,
                                            child: UpdatedSurahPage(
                                              bgColor: bgColor,
                                              sujoodVerses:
                                                  selected_surah_sujood_verses,
                                              surah_id: '${index + 1}',
                                              image: getSurahTypeImage(index),
                                              surah_name: surah_name_translated[
                                                      index]['translation']
                                                  .toString()
                                                  .substring(
                                                      0,
                                                      surah_name_translated[
                                                                  index]
                                                              ['translation']
                                                          .toString()
                                                          .indexOf(':')),
                                              arabic_name:
                                                  surah_name_arabic[index]
                                                      ['translation'],
                                              // sujood_index: sujood_index != -1 ? sujood_verse_indices[sujood_index]['verse_id'].toString() : sujood_index.toString(),
                                              verse_numbers:
                                                  verse_numbers[index]
                                                      .toString(),
                                              // verses: verses,
                                              // translated_verse:
                                              //     translated_verse,
                                              eng: widget.eng,
                                              ar: widget.ar,
                                            ))).then((value) {
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (builder) => SurahList(
                                                    eng: widget.eng,
                                                    ar: widget.ar,
                                                  )));
                                    });
                                  });
                                },
                                child: ClipRRect(
                                  child: Stack(
                                    children: [
                                      Card(
                                        elevation: 0,
                                        margin: const EdgeInsets.all(0),
                                        color: Colors.transparent,
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            // width: size.width,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  Expanded(
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .fromLTRB(11,
                                                                  11, 11, 11),
                                                          child: Stack(
                                                            alignment: Alignment
                                                                .center,
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        1.0),
                                                                child: Opacity(
                                                                  opacity: .5,
                                                                  child: Image
                                                                      .asset(
                                                                    'lib/assets/images/indexDesign.png',
                                                                    height: isPortraitMode()
                                                                        ? size.width *
                                                                            .125
                                                                        : size.height *
                                                                            .125,
                                                                    width: isPortraitMode()
                                                                        ? size.width *
                                                                            .125
                                                                        : size.height *
                                                                            .125,
                                                                    color: animation2
                                                                        .value,
                                                                  ),
                                                                ),
                                                              ),
                                                              Text(
                                                                "${index + 1}"
                                                                            .length ==
                                                                        1
                                                                    ? '00${index + 1}'
                                                                    : "${index + 1}".length ==
                                                                            2
                                                                        ? '0${index + 1}'
                                                                        : '${index + 1}',
                                                                // arabicNumber.convert(index + 1),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style:
                                                                    TextStyle(
                                                                        height:
                                                                            0,
                                                                        color: animation2
                                                                            .value,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontSize: isPortraitMode()
                                                                            ? size.width *
                                                                                .031
                                                                            : size.height *
                                                                                .031,
                                                                        // fontWeight: FontWeight.bold,
                                                                        fontFamily:
                                                                            'varela-round.regular'),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: Wrap(
                                                            direction:
                                                                Axis.vertical,
                                                            crossAxisAlignment:
                                                                WrapCrossAlignment
                                                                    .start,
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        right:
                                                                            11.0,
                                                                        left:
                                                                            11),
                                                                child:
                                                                    Text.rich(
                                                                        textDirection:
                                                                            TextDirection
                                                                                .rtl,
                                                                        textAlign:
                                                                            TextAlign
                                                                                .center,
                                                                        TextSpan(
                                                                            children: [
                                                                              TextSpan(
                                                                                text: '﴿  ',
                                                                                style: TextStyle(height: 0, wordSpacing: 3, fontWeight: FontWeight.bold, fontFamily: 'Al Majeed Quranic Font_shiped', fontSize: size.width * .041, color: isThemeInit ? animation.value : Colors.transparent),
                                                                              ),
                                                                              TextSpan(
                                                                                text: '${surah_name_arabic[index]['translation']}',
                                                                                style: TextStyle(height: 0, color: isThemeInit ? animation.value : Colors.transparent, fontSize: size.width * .041, fontWeight: FontWeight.bold, fontFamily: 'Diwanltr'),
                                                                              ),
                                                                              TextSpan(
                                                                                text: '  ﴾',
                                                                                style: TextStyle(
                                                                                  height: 0,
                                                                                  wordSpacing: 3,
                                                                                  fontWeight: FontWeight.bold,
                                                                                  fontFamily: 'Al Majeed Quranic Font_shiped',
                                                                                  fontSize: size.width * .041,
                                                                                  color: isThemeInit ? animation.value : Colors.transparent,
                                                                                ),
                                                                              ),
                                                                              TextSpan(
                                                                                text: surah_name_translated.isNotEmpty ? "    ${surah_name_translated[index]['translation'].toString().substring(0, surah_name_translated[index]['translation'].toString().indexOf(':'))}" : "",
                                                                                style: TextStyle(height: 0, color: animation2.value, fontSize: size.width * .041, fontWeight: FontWeight.bold, fontFamily: 'Rounded_Elegance'),
                                                                              ),
                                                                            ])),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .fromLTRB(
                                                                        11,
                                                                        5,
                                                                        17,
                                                                        0),
                                                                child: Text(
                                                                  '${surah_name_translated[index]['translation'].toString().substring(surah_name_translated[index]['translation'].toString().indexOf(':') + 2)} ●',
                                                                  style: TextStyle(
                                                                      height: 0,
                                                                      color: animation2
                                                                          .value,
                                                                      fontSize:
                                                                          size.width *
                                                                              .035,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontFamily:
                                                                          'Rounded_Elegance'),
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .fromLTRB(
                                                                        11,
                                                                        5,
                                                                        17,
                                                                        0),
                                                                child: Wrap(
                                                                  alignment:
                                                                      WrapAlignment
                                                                          .center,
                                                                  crossAxisAlignment:
                                                                      WrapCrossAlignment
                                                                          .center,
                                                                  children: [
                                                                    Wrap(
                                                                      alignment:
                                                                          WrapAlignment
                                                                              .center,
                                                                      crossAxisAlignment:
                                                                          WrapCrossAlignment
                                                                              .center,
                                                                      children: [
                                                                        Container(
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color:
                                                                                const Color(0xffa69963),
                                                                            borderRadius:
                                                                                BorderRadius.circular(1000),
                                                                          ),
                                                                          child:
                                                                              Padding(
                                                                            padding: const EdgeInsets.fromLTRB(
                                                                                11,
                                                                                4,
                                                                                4,
                                                                                4),
                                                                            child:
                                                                                Row(
                                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                              children: [
                                                                                Image.asset(
                                                                                  surah_type == 'Makki Surah' || surah_type == 'Makki Surah (?)' ? 'lib/assets/images/makkaIcon.png' : 'lib/assets/images/madinaIcon.png',
                                                                                  height: 19,
                                                                                  width: 19,
                                                                                  color: animation4.value,
                                                                                ),
                                                                                Text(
                                                                                  "  $surah_type",
                                                                                  style: TextStyle(
                                                                                      height: 0,
                                                                                      // color: const Color(0xffffffff),
                                                                                      color: animation4.value,
                                                                                      fontWeight: FontWeight.bold,
                                                                                      fontSize: size.width * .035,
                                                                                      fontFamily: 'Rounded_Elegance'),
                                                                                ),
                                                                                const SizedBox(
                                                                                  width: 11,
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    // Padding(
                                                                    //   padding: const EdgeInsets
                                                                    //       .symmetric(
                                                                    //       horizontal:
                                                                    //           5.0),
                                                                    //   child: Container(
                                                                    //       width:
                                                                    //           2,
                                                                    //       height:
                                                                    //           15,
                                                                    //       color:
                                                                    //           const Color(0xffa69963)),
                                                                    // ),
                                                                    Text(
                                                                      '  ${verse_numbers[index]} verses',
                                                                      style: TextStyle(
                                                                          height:
                                                                              0,
                                                                          color: const Color(
                                                                              0xffa69963),
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          fontSize: size.width *
                                                                              .035,
                                                                          fontFamily:
                                                                              'Rounded_Elegance'),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              sujood_index != -1
                                                                  ? Padding(
                                                                      padding: const EdgeInsets
                                                                          .only(
                                                                          left:
                                                                              11,
                                                                          top:
                                                                              5),
                                                                      child:
                                                                          Wrap(
                                                                        alignment:
                                                                            WrapAlignment.center,
                                                                        crossAxisAlignment:
                                                                            WrapCrossAlignment.center,
                                                                        children: [
                                                                          Image
                                                                              .asset(
                                                                            'lib/assets/images/sujoodIcon.png',
                                                                            height:
                                                                                13,
                                                                            width:
                                                                                13,
                                                                          ),
                                                                          const SizedBox(
                                                                            width:
                                                                                7,
                                                                          ),
                                                                          const Text(
                                                                            'contains verse(s) of prostration.',
                                                                            style: TextStyle(
                                                                                color: Color(0xff518050),
                                                                                // fontWeight:
                                                                                //     FontWeight.bold,
                                                                                fontSize: 13,
                                                                                fontWeight: FontWeight.bold,
                                                                                fontFamily: 'varela-round.regular'),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    )
                                                                  : const SizedBox()
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const Divider(
                                                color: Color(0x65dad4b7),
                                              )
                                            ]),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            })),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
