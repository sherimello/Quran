import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path/path.dart';
import 'package:quran/pages/menu.dart';
import 'package:quran/pages/new_surah_page.dart';
import 'package:quran/pages/options.dart';
import 'package:quran/pages/surah_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:math' as math;

import '../hero_transition_handler/custom_rect_tween.dart';
import '../hero_transition_handler/hero_dialog_route.dart';


class SurahList extends StatefulWidget {

  double eng, ar;

  SurahList({Key? key, required this.eng, required this.ar}) : super(key: key);

  @override
  State<SurahList> createState() => _SurahListState();
}

class _SurahListState extends State<SurahList> with TickerProviderStateMixin{
  late Database database;
  late String path;
  late int sujood_index;
  IconData _icon = Icons.brightness_7_sharp;
  String surah_type = '';
  List<Map> sujood_surah_indices = [],
      sujood_verse_indices = [],
      surah_name_arabic = [],
      surah_name_translated = [];
  List<int>
  selected_surah_sujood_verses = [],
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
  late Animation<Color?> animation, animation2, animation3;
  late AnimationController controller;
  late final AnimationController animationController;
  late final Animation<double> _arrowAnimation;
  var bgColor = Colors.white, color1 = Colors.black, toColor1 = Colors.white, color2 = const Color(0xff1d3f5e), toColor2 = Colors.white,
  color3 = const Color(0xff1d3f5e), toColor3 = Colors.black, defTextColor = Colors.black;
  int darktheme = 0, clicked = 0, shouldReverse = 0;
  late final Duration halfDuration;

  getFontSizes() async{
   SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
   widget.eng = sharedPreferences.getDouble("english_font_size")!;
   widget.ar = sharedPreferences.getDouble("arabic_font_size")!;
  }

  @override
  void initState() {
    themeLogics();
    super.initState();
    animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 200),);
    // _addStatusListener();

    _arrowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeInOut),
    );
    halfDuration = Duration(
        milliseconds: animationController.duration!.inMilliseconds ~/ 2);
    fetchSurahName();
  }

  void changeStatusBarColor(int colorCode) {
    setState(() {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          statusBarColor: Color(colorCode)
      ));
    });
  }

  assignmentForLightMode() {
    darktheme = 0;
    color1 = Colors.black;
    toColor1 = Colors.white;
    color2 = const Color(0xff1d3f5e);
    toColor2 = Colors.white;
    color3 = const Color(0xff1d3f5e);
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
    bgColor = Colors.black;
    defTextColor = Colors.white;
  }

  initializeThemeStarters() async {

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if(sharedPreferences.containsKey('theme mode')) {
      if(sharedPreferences.getString('theme mode') == "light") {
        changeStatusBarColor(0xff1d3f5e);
        assignmentForLightMode();
      }
      if(sharedPreferences.getString('theme mode') == "dark") {
        changeStatusBarColor(0xff000000);
        assignmentForDarkMode();
      }
    }
  }

  Future<void> themeLogics() async {

    await initializeThemeStarters().whenComplete((){
      controller =
          AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
      animation =
      ColorTween(begin: color1, end: toColor1).animate(controller)
        ..addListener(() {
          setState(() {
            // The state that has changed here is the animation object’s value.
          });
        });
      animation2 =
      ColorTween(begin: color2, end: toColor2).animate(controller)
        ..addListener(() {
          setState(() {
            // The state that has changed here is the animation object’s value.
          });
        });
      animation3 =
      ColorTween(begin: color3, end: toColor3).animate(controller)
        ..addListener(() {
          setState(() {
            // The state that has changed here is the animation object’s value.
          });
        });
    });
  }

  void animateColor() {
    if(controller.isCompleted) {
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
    path = join(databasesPath, 'quran.db');

    database = await openDatabase(path);

    print(database.isOpen);
  }

  Future<void> fetchVersesData(String surah_id) async {
    // print(widget.verse_numbers);
    // verses.clear();
    await initiateDB().whenComplete(() async {
      verses = await database.rawQuery(
          'SELECT text FROM verses WHERE lang_id = 1 AND surah_id = ?',
          [surah_id]);
      translated_verse = await database.rawQuery(
          'SELECT text FROM verses WHERE lang_id = 2 AND surah_id = ?',
          [surah_id]);
    });
    setState(() {
      verses = verses;
      translated_verse = translated_verse;
    });
  }

  fetchSurahName() {
    initiateDB().whenComplete(() async {
      surah_name_arabic.clear();
      surah_name_translated.clear();
      surah_name_arabic =
          await database.rawQuery('SELECT * FROM surahnames WHERE lang_id = 1');
      surah_name_translated =
          await database.rawQuery('SELECT * FROM surahnames WHERE lang_id = 2');
      sujood_surah_indices = await database.rawQuery('SELECT surah_id FROM sujood_verses');
      sujood_verse_indices = await database.rawQuery('SELECT verse_id FROM sujood_verses');
      setState(() {
        // surahs.add(surah_name_arabic_temp);
        surah_name_arabic = surah_name_arabic;
        surah_name_translated = surah_name_translated;
      });
    });
  }

  Future<void> fetchSurahSujoodVerses(int surah_id) async {
    selected_surah_sujood_verses = [];
    for(int i = 0; i < sujood_surah_indices.length; i++) {
      if(sujood_surah_indices[i]['surah_id'] == surah_id) {
        selected_surah_sujood_verses.add(sujood_verse_indices[i]['verse_id']);
      }
    }
  }

  int getSujoodSurahIndex(int id) {
    for(int i = 0; i < sujood_surah_indices.length; i++) {
      if(sujood_surah_indices[i]['surah_id'] == id) {
        // sujood_surah_indices.removeAt(i);
        return i;
      }
    }
    return -1;
  }

  int getSujoodVerseIndex(int id) {
    for(int i = 0; i < sujood_verse_indices.length; i++) {
      if(sujood_verse_indices[i]['surah_id'] == id) {
        sujood_verse_indices.removeAt(i);
        return i;
      }
    }
    return -1;
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

    bool isPortraitMode() {
      return size.height > size.width ? true : false;
    }

    // ArabicNumbers arabicNumber = ArabicNumbers();

    Future<bool> showExitPopup() async {
      return await showDialog( //show confirm dialogue
        //the return value will be from "Yes" or "No" options
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(31)
          ),
          title: const Text('Exit App',
          style: TextStyle(
            fontFamily: 'varela-round.regular'
          ),),
          content: const Text('Do you want to exit?',
            style: TextStyle(
                fontFamily: 'varela-round.regular'
            ),),
          actions:[
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
                //return false when click on "NO"
                child: const Text('No',

                  style: TextStyle(
                      fontFamily: 'varela-round.regular'
                  ),),
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
                onPressed: () => SystemChannels.platform.invokeMethod('SystemNavigator.pop'),
                //return true when click on "Yes"
                child: const Text('Yes',

      style: TextStyle(
      fontFamily: 'varela-round.regular'
      ),),
              ),
            ),
          ],
        ),
      )??false; //if showDialouge had returned null, then return false
    }

    Future<bool> backToMenu() async{
      return await Navigator.push(context, MaterialPageRoute(builder: (context)=>Menu(eng: widget.eng, ar: widget.ar,))) ?? false;
    }

    saveThemeState(String theme) async {
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      sharedPreferences.setString('theme mode', theme);
    }

    return ThemeSwitchingArea(
      child: WillPopScope(
        onWillPop: backToMenu,
        child: Scaffold(
          floatingActionButton: ThemeSwitcher(
            builder: (context) => FloatingActionButton(
              backgroundColor: const Color(0xff1d3f5e),
                child: AnimatedBuilder(
                    animation: animationController,
                    builder: (BuildContext context, Widget? child) {
                      return Transform.rotate(
                        angle: _arrowAnimation.value * 2.0 * math.pi,
                        child: child,
                      );
                    },
                    child: Icon(_icon, color: const Color(0xffffffff),)),
                onPressed: ()
                async {
                  setState(() {
                    if(_icon == Icons.brightness_7_sharp) {
                      _icon = Icons.brightness_4_outlined;
                    }
                    else {
                      _icon = Icons.brightness_7_sharp;
                    }
                  });
                  animationController.isCompleted ? animationController.reverse() :
                  animationController.forward();

                  clicked = 1;

                  darktheme == 0 ?
                  {
                    // assignmentForDarkMode(),
                    setState(() {
                      bgColor = Colors.black;
                    }),
                    ThemeSwitcher.of(context).changeTheme(
                      theme: ThemeData(
                        brightness: Brightness.dark,
                      ),
                    ),


                    await Future.delayed(const Duration(milliseconds: 500), () {
                      animateColor();
                    }),

                    darktheme = 1,
                    saveThemeState("dark"),
                  }
                      :
                  {
                    // assignmentForLightMode(),
                    setState(() {
                      bgColor = Colors.white;
                    }),
                    ThemeSwitcher.of(context).changeTheme(
                        isReversed: true,
                        theme: ThemeData(
                          brightness: Brightness.light,
                        )),
                    await Future.delayed(const Duration(milliseconds: 500), () {
                      animateColor();
                    }),
                    darktheme = 0,
                    saveThemeState("light"),
                  };

                }
            ),
          ),
          backgroundColor: clicked == 1 ? animation3.value! : color3,
          appBar: AppBar(
            backgroundColor: clicked == 1 ? animation3.value! : color3,
            titleSpacing: 0,
            automaticallyImplyLeading: false,
            centerTitle: true,
            title: Hero(
              tag: "options",
              createRectTween: (begin, end) {
                return CustomRectTween(begin: begin!, end: end!);
              },
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: size.width,
                  height: appBar.preferredSize.height,
                  color: clicked == 1 ? animation3.value! : color3,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 11.0),
                    child: Stack(
                      children: [
                        Positioned(
                          left: 0,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: Text.rich(
                              TextSpan(
                                  children: [
                                    WidgetSpan(
                                      alignment: PlaceholderAlignment.middle,
                                      child: Padding(
                                        padding: const EdgeInsets.only(right: 11.0),
                                        child: Container(
                                            width: appBar.preferredSize.height -
                                                appBar.preferredSize.height * .35,
                                            height: appBar.preferredSize.height -
                                                appBar.preferredSize.height * .35,
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(1000),
                                                color: Colors.white.withOpacity(.5)),
                                            child: Padding(
                                              padding: const EdgeInsets.all(2.0),
                                              child: Image.asset('lib/assets/images/quran icon.png'),
                                            )),
                                      ),),

                                    const TextSpan(
                                      text: 'Qur\'an',
                                      style: TextStyle(
                                          fontFamily: 'Bismillah Script',
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.5,
                                          color: Colors.white,
                                          fontSize: 21),
                                    ),
                                  ]
                              ),
                            ),
                          )
                        ),
                        Positioned(
                          top: 0,
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                              onTap: () async {
                                await getFontSizes().whenComplete((){
                                  Navigator.of(context).push(HeroDialogRoute(
                                    bgColor: bgColor.withOpacity(0.85),
                                    builder: (context) => Options(tag: "options", theme: bgColor, eng: widget.eng, ar: widget.ar,),
                                  ));
                                });
                              },
                              child: const Icon(Icons.more_vert, color: Colors.white,)),
                        )
                        ]
                        )
                  ),
                ),
              ),
            ),
            // backgroundColor: const Color(0x001d3f5e),
            elevation: 0,
          ),
          // backgroundColor: const Color(0xfffaf7f7),
          body: Container(
              color: bgColor,
              // color: const Color(0xffd7e3fd),
              child: surah_name_arabic.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          // padding: EdgeInsets.all(11),
                          itemCount: surah_name_translated.isNotEmpty ? 114 : 0,
                          cacheExtent: surah_name_translated.isNotEmpty ? 114 : 0,
                          itemBuilder: (BuildContext bcontext, int index) {
                            // sujood_surah_indices.clear();

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
                            return GestureDetector(
                              onTap: () async {
                                sujood_index = getSujoodSurahIndex(index + 1);
                                await fetchSurahSujoodVerses(index + 1);
                                await getFontSizes();
                                fetchVersesData('${index + 1}').whenComplete(() {
                                  print("index: $index");
                                  print("\nvnums: ${verse_numbers[index]}");
                                  Navigator.push(
                                      context,
                                      PageTransition(
                                        type: PageTransitionType.fade,
                                          child: UpdatedSurahPage(
                                            sujoodVerses: selected_surah_sujood_verses,
                                            surah_id: '${index + 1}',
                                            image: madani_surah
                                                .contains(index + 1)
                                                ? 'lib/assets/images/madinaWhiteIcon.png'
                                                : 'lib/assets/images/makkaWhiteIcon.png',
                                            surah_name: surah_name_translated[
                                            index]['translation']
                                                .toString()
                                                .substring(
                                                0,
                                                surah_name_translated[index]
                                                ['translation']
                                                    .toString()
                                                    .indexOf(':')),
                                            arabic_name: surah_name_arabic[index]
                                            ['translation'],
                                            // sujood_index: sujood_index != -1 ? sujood_verse_indices[sujood_index]['verse_id'].toString() : sujood_index.toString(),
                                            verse_numbers: verse_numbers[index].toString(),
                                            verses: verses,
                                            translated_verse: translated_verse, eng: widget.eng, ar: widget.ar,
                                          )
                                      )
                                  );
                                });
                              },
                              child: Card(
                                elevation: 0,
                                margin: const EdgeInsets.all(0),
                                color: Colors.transparent,
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    // width: size.width,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.all(3.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.fromLTRB(
                                                            0, 7, 0, 7),
                                                    child: Stack(
                                                      alignment: Alignment.center,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets.all(
                                                                  1.0),
                                                          child: Image.asset(
                                                            'lib/assets/images/indexDesign.png',
                                                            height: isPortraitMode()
                                                                ? size.width * .10
                                                                : size.height * .10,
                                                            width: isPortraitMode()
                                                                ? size.width * .10
                                                                : size.height * .10,
                                                            color: animation2.value,
                                                          ),
                                                        ),
                                                        Text(
                                                          '${index + 1}',
                                                          // arabicNumber.convert(index + 1),
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                              color: animation2.value,
                                                              fontSize:
                                                                  isPortraitMode()
                                                                      ? size.width *
                                                                          .029
                                                                      : size.height *
                                                                          .029,
                                                              // fontWeight: FontWeight.bold,
                                                              fontFamily:
                                                                  'varela-round.regular'),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Wrap(
                                                      direction: Axis.vertical,
                                                      crossAxisAlignment:
                                                          WrapCrossAlignment.start,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                          const EdgeInsets.only(right: 11.0, left: 11),
                                                          child: Text.rich(
                                                              textDirection: TextDirection.rtl,
                                                              textAlign: TextAlign.center,
                                                              TextSpan(children: [
                                                                TextSpan(
                                                                  text: '﴿  ',
                                                                  style: TextStyle(
                                                                    wordSpacing: 3,
                                                                    fontWeight: FontWeight.bold,
                                                                    fontFamily:
                                                                    'Al Majeed Quranic Font_shiped',
                                                                    fontSize: 17,
                                                                    color: animation.value
                                                                  ),
                                                                ),
                                                                TextSpan(
                                                                  text:
                                                                  '${surah_name_arabic[index]['translation']}',
                                                                  style: TextStyle(
                                                                      color: animation.value,
                                                                      fontSize: 17,
                                                                      fontWeight: FontWeight.bold,
                                                                      fontFamily: 'Diwanltr'),
                                                                ),
                                                                TextSpan(
                                                                  text: '  ﴾',
                                                                  style: TextStyle(
                                                                    wordSpacing: 3,
                                                                    fontWeight: FontWeight.bold,
                                                                    fontFamily:
                                                                    'Al Majeed Quranic Font_shiped',
                                                                    fontSize: 17,
                                                                    color: animation.value,
                                                                  ),
                                                                ),
                                                                TextSpan(
                                                                  text: surah_name_translated.isNotEmpty ? "    ${surah_name_translated[
                                                                  index]
                                                                  ['translation']
                                                                      .toString()
                                                                      .substring(
                                                                      0,
                                                                      surah_name_translated[
                                                                      index]
                                                                      [
                                                                      'translation']
                                                                          .toString()
                                                                          .indexOf(
                                                                          ':'))}" : "",
                                                                  style: TextStyle(
                                                                      color: animation2.value,
                                                                      fontSize: 15,
                                                                      fontWeight:
                                                                      FontWeight.bold,
                                                                      fontFamily:
                                                                      'varela-round.regular'),
                                                                ),
                                                              ])),
                                                        ),
                                                        Padding(
                                                          padding: const EdgeInsets
                                                                  .fromLTRB(
                                                              11, 5, 17, 0),
                                                          child: Text(
                                                            '${surah_name_translated[index]['translation'].toString().substring(surah_name_translated[index]['translation'].toString().indexOf(':') + 2)} ●',
                                                            style: TextStyle(
                                                                color: animation2.value,
                                                                fontSize: 13,
                                                                // fontWeight: FontWeight.bold,
                                                                fontFamily:
                                                                    'varela-round.regular'),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding: const EdgeInsets
                                                                  .fromLTRB(
                                                              11, 5, 17, 0),
                                                          child: Wrap(
                                                            alignment: WrapAlignment
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
                                                                  Image.asset(
                                                                    surah_type ==
                                                                                'Makki Surah' ||
                                                                            surah_type ==
                                                                                'Makki Surah (?)'
                                                                        ? 'lib/assets/images/makkaIcon.png'
                                                                        : 'lib/assets/images/madinaIcon.png',
                                                                    height: 13,
                                                                    width: 13,
                                                                    color: animation.value,
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 7,
                                                                  ),
                                                                  Text(
                                                                    surah_type,
                                                                    style: const TextStyle(
                                                                        color: Color(0xffa69963),
                                                                        // fontWeight:
                                                                        //     FontWeight.bold,
                                                                        fontSize: 13,
                                                                        fontFamily: 'varela-round.regular'),
                                                                  ),
                                                                ],
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .symmetric(
                                                                        horizontal:
                                                                            5.0),
                                                                child: Container(
                                                                    width: 1,
                                                                    height: 15,
                                                                    color: const Color(
                                                                        0xffa69963)),
                                                              ),
                                                              Text(
                                                                  '${verse_numbers[index]} verses',
                                                                  style:
                                                                      const TextStyle(
                                                                          color: Color(
                                                                              0xffa69963),
                                                                          // fontWeight: FontWeight.bold,
                                                                          fontSize:
                                                                              13,
                                                                          fontFamily:
                                                                              'varela-round.regular')),
                                                            ],
                                                          ),
                                                        ),
                                                        sujood_index != -1
                                                            ? Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        left: 11,
                                                                        top: 5),
                                                                child: Wrap(
                                                                  alignment:
                                                                      WrapAlignment
                                                                          .center,
                                                                  crossAxisAlignment:
                                                                      WrapCrossAlignment
                                                                          .center,
                                                                  children: [
                                                                    Image.asset(
                                                                      'lib/assets/images/sujoodIcon.png',
                                                                      height: 13,
                                                                      width: 13,
                                                                    ),
                                                                    const SizedBox(
                                                                      width: 7,
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
                                          ),
                                        ],
                                      ),
                                      const Divider(
                                        color: Color(0xffdad4b7),
                                      )
                                    ]),
                              ),
                            );
                          }),
                    )),
        ),
      ),
    );
  }
}
