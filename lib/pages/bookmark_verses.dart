import 'dart:convert';

import 'package:arabic_numbers/arabic_numbers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quran/pages/bookmark_folders.dart';
import 'package:quran/pages/delete_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../classes/db_helper.dart';
import '../classes/test_class.dart';
import '../hero_transition_handler/custom_rect_tween.dart';
import '../hero_transition_handler/hero_dialog_route.dart';
import 'favorite_verses.dart';
import 'new_surah_page.dart';

class BookmarkVerses extends StatefulWidget {
  final String tag, folder_name, from_where;
  Color theme;
  double eng, ar;

  BookmarkVerses({
    Key? key,
    required this.folder_name,
    required this.tag,
    required this.from_where,
    required this.theme,
    required this.eng,
    required this.ar,
  }) : super(key: key);

  @override
  State<BookmarkVerses> createState() => _BookmarkVersesState();
}

class _BookmarkVersesState extends State<BookmarkVerses> {
  late Database database;
  double snack_text_size = 0, snack_text_padding = 0;
  late String path,
      loadAsset = 'lib/assets/images/search.png',
      messageUpdate = "\nsearch whatever bothers\nor concerns you";
  int len = 0, flag = 0, load = 0;
  bool loadVisibility = true,
      value_progress = true,
      value_nothing_found = false;

  List<Map> verses = [], v = [], translated_verse = [];
  late List<Map> surah_indices = [], verse_indices = [];
  final TextEditingController searchController = TextEditingController();
  String word = "";
  late int sujood_index;
  List<int> selected_surah_sujood_verses = [];
  late List<Map> sujood_surah_indices = [],
      sujood_verse_indices = [],
      surah_name_translated = [],
      surah_name_arabic = [];
  var bgColor = Colors.white,
      color_favorite_and_index = const Color(0xff1d3f5e),
      color_header = const Color(0xff1d3f5e),
      color_container_dark = const Color(0xfff4f4ff),
      color_container_light = Colors.white,
      color_main_text = Colors.black;

  late SharedPreferences sharedPreferences;
  String current_lang = "";

  assignmentForLightMode() {
    bgColor = Colors.white;
    color_favorite_and_index = const Color(0xff1d3f5e);
    color_header = const Color(0xff1d3f5e);
    color_container_dark = const Color(0xfff4f4ff);
    color_container_light = Colors.white;
    color_main_text = Colors.black;
  }

  assignmentForDarkMode() {
    bgColor = Colors.black;
    color_favorite_and_index = Colors.white;
    color_header = Colors.black;
    color_container_dark = Colors.black;
    color_container_light = const Color(0xff252525);
    color_main_text = Colors.white;
  }

  Future<bool> initializeThemeStarters() async {
    print("hollar");
    // print(await getSynonyms("love"));
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.containsKey('english_font_size')) {
      widget.eng = sharedPreferences.getDouble("english_font_size")!;
    }
    if (sharedPreferences.containsKey('arabic_font_size')) {
      widget.ar = sharedPreferences.getDouble("arabic_font_size")!;
    }
    if (sharedPreferences.containsKey('theme mode')) {
      if (sharedPreferences.getString('theme mode') == "light") {
        widget.theme = Colors.white;
        assignmentForLightMode();
        changeStatusBarColor(0xff1d3f5e);
      }
      if (sharedPreferences.getString('theme mode') == "dark") {
        widget.theme = Colors.black;
        assignmentForDarkMode();
        changeStatusBarColor(0xff000000);
      }
    }
    return Future.value(true);
  }

  void changeStatusBarColor(int colorCode) {
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  }

  ArabicNumbers arabicNumber = ArabicNumbers();

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Future<void> initiateDB() async {
    // Get a location using getDatabasesPath
    // var databasesPath = await getDatabasesPath();
    // path = join(databasesPath, 'en_ar_quran.db');

    DatabaseHelper databaseHelper = DatabaseHelper.instance;

    database = await databaseHelper.initDatabase('en_ar_quran.db');

    print(database.isOpen);
  }


  Future<TestClass> initData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonString = prefs.getString('testClass')!;

    // Decode the JSON string
    Map<String, dynamic> decoded = jsonDecode(jsonString);

    // Create an instance of TestClass from the decoded JSON
    return TestClass.fromJson(decoded);
  }

  fetchVersesData() async {
    // translated_verse = await database.rawQuery('SELECT * FROM bookmarks WHERE folder_name = ?', [widget.folder_name])
    // .whenComplete(() async {
    verses = await database.rawQuery(
        'SELECT * FROM bookmarks WHERE folder_name = ?', [widget.folder_name]);

    if (current_lang == "ben") {
      translated_verse.clear();
      final TestClass dataClass = await initData();
      for (int i = 0; i < verses.length; i++) {
        translated_verse.add(dataClass.bn_verses.firstWhere(
                (element) =>
            element['sura'] == verses[i]['surah_id'] &&
                element['ayah'] == verses[i]['verse_id'],
            orElse: () => {}));
      }
      print(translated_verse);
    }

    sujood_surah_indices = await database
        .rawQuery('SELECT surah_id FROM sujood_verses')
        .whenComplete(() async {
      sujood_verse_indices =
          await database.rawQuery('SELECT verse_id FROM sujood_verses');
      surah_name_translated =
          await database.rawQuery('SELECT * FROM surahnames WHERE lang_id = 2');
      surah_name_arabic =
          await database.rawQuery('SELECT * FROM surahnames WHERE lang_id = 1');
      sujood_verse_indices =
          await database.rawQuery('SELECT verse_id FROM sujood_verses');
    });
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        value_progress = false;
      });
    });
    setState(() {
      // value_progress = false;
      if (verses.isEmpty) {
        setState(() {
          snack_text_size = 13;
          snack_text_padding = 45;
        });
        Future.delayed(const Duration(seconds: 3), () {
          setState(() {
            snack_text_size = 0;
            snack_text_padding = 0;
          });
        });
        loadAsset = 'lib/assets/images/nothing_found.gif';
        loadVisibility = true;
        messageUpdate = "no matches were found!";
        value_nothing_found = true;
      } else {
        loadAsset = "lib/assets/images/search.png";
        loadVisibility = false;
        // translated_verse = translated_verse;
        verses = verses;
        len = verses.length;
        value_nothing_found = false;
      }
    });
  }

  bool isSujoodVerse(int surah, int verse) {
    bool b = false, flag = false;
    for (int i = 0; i < sujood_surah_indices.length; i++) {
      if (sujood_surah_indices[i]["surah_id"] == surah) {
        flag = true;
        break;
      }
    }
    if (flag) {
      for (int i = 0; i < sujood_verse_indices.length; i++) {
        if (sujood_surah_indices[i]["surah_id"] == surah &&
            sujood_verse_indices[i]["verse_id"] == verse) {
          b = true;
          flag = false;
          break;
        }
      }
    }

    return b;
  }

  Future<void> saveWordMeaningState(bool status) async {
    // SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    // sharedPreferences.setBool('word meaning', status);
  }

  Future<void> getData() async {
    await initiateDB().whenComplete(
        () async => await fetchVersesData().whenComplete(() => setState(() {
              verses = verses.reversed.toList();
              translated_verse = translated_verse.reversed.toList();
            })));
  }

  Future<void> fetchSurahSujoodVerses(int surah_id) async {
    selected_surah_sujood_verses = [];
    for (int i = 0; i < sujood_surah_indices.length; i++) {
      if (sujood_surah_indices[i]['surah_id'] == surah_id) {
        selected_surah_sujood_verses.add(sujood_verse_indices[i]['verse_id']);
      }
    }
  }

  checkLanguage() async {
    if (sharedPreferences.containsKey("lang")) {
      current_lang = ((sharedPreferences.getString("lang")))!;
    } else {
      current_lang = "eng";
    }

    if (mounted) {
      setState(() {
        current_lang = current_lang;
      });
    }
  }

  Future<void> initSharedPref() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initSharedPref().whenComplete(() {
      checkLanguage();
      initializeThemeStarters();
      getData();
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    database.close();
  }

  @override
  Widget build(BuildContext context) {
    Future<bool> goToFoldersList() async {
      // if(widget.from_where == "menu") {
      //   return await Navigator.of(context).push(HeroDialogRoute(
      //     bgColor: bgColor.withOpacity(0.85),
      //     builder: (context) => Center(child: BookmarkFolders(tag: widget.tag, from_where: widget.from_where)),
      //   )) ?? false;
      // }
      Navigator.pop(context);
      return false;
    }

    var size = MediaQuery.of(context).size;

    bool isPortraitMode() {
      return size.height > size.width ? true : false;
    }

    setState(() {
      verses = verses;
    });

    return WillPopScope(
      onWillPop: goToFoldersList,
      child: Stack(
        children: [
          Hero(
            tag: widget.tag,
            createRectTween: (begin, end) {
              return CustomRectTween(begin: begin!, end: end!);
            },
            child: Material(
              color: widget.theme,
              child: Container(
                height: size.height,
                width: size.width,
                color: verses.isEmpty
                    ? bgColor
                    : verses.length.isOdd
                        ? color_container_dark
                        : color_container_light,
                child: Visibility(
                  visible: !loadVisibility,
                  child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      physics: const BouncingScrollPhysics(),
                      itemCount: verses.isNotEmpty ? verses.length : 0,
                      itemBuilder: (BuildContext context, int index) {
                        // print('${isPortraitMode() ? size.height / size.width : size.width / size.height}');
                        return GestureDetector(
                          onTap: () async {
                            await Navigator.of(context)
                                .push(HeroDialogRoute(
                                  bgColor: bgColor.withOpacity(0.85),
                                  builder: (context) => Center(
                                      child: DeleteCard(
                                    tag: widget.tag,
                                    surah_number:
                                        verses[index]['surah_id'].toString(),
                                    verse_number:
                                        verses[index]['verse_id'].toString(),
                                    what_to_delete: "bookmarks",
                                    from_where: widget.from_where,
                                    folder_name: widget.folder_name,
                                  )),
                                ))
                                .then((value) => fetchVersesData());
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: index.isEven
                                  ? color_container_dark
                                  : color_container_light,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 7, 0, 7),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(1.0),
                                          child: Opacity(
                                            opacity: .5,
                                            child: Image.asset(
                                              'lib/assets/images/surahIndex.png',
                                              height: isPortraitMode()
                                                  ? size.width * .125
                                                  : size.height * .125,
                                              width: isPortraitMode()
                                                  ? size.width * .125
                                                  : size.height * .125,
                                              color: color_favorite_and_index,
                                            ),
                                          ),
                                        ),
                                        Text.rich(
                                          textAlign: TextAlign.center,
                                          TextSpan(
                                            text: "${index + 1}".length == 1
                                                ? '00${index + 1}'
                                                : "${index + 1}".length == 2
                                                    ? '0${index + 1}'
                                                    : '${index + 1}',
                                            style: TextStyle(
                                              color: color_favorite_and_index,
                                              fontSize: isPortraitMode()
                                                  ? size.width * .031
                                                  : size.height * .031,
                                              fontWeight: FontWeight.bold,
                                              fontFamily:
                                                  'varela-round.regular',
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text.rich(
                                                  textDirection:
                                                      TextDirection.rtl,
                                                  textAlign: TextAlign.right,
                                                  textScaleFactor:
                                                      (isPortraitMode()
                                                          ? size.height /
                                                              size.width
                                                          : size.width /
                                                              size.height),
                                                  TextSpan(
                                                      style: TextStyle(
                                                          // wordSpacing: 2,
                                                          fontFamily:
                                                              'Al_Mushaf',
                                                          fontSize: widget.ar,
                                                          color:
                                                              color_main_text),
                                                      children: [
                                                        TextSpan(
                                                          text: verses
                                                                  .isNotEmpty
                                                              ? '${verses[index]['arabic']}  '
                                                              : '',
                                                          // 'k',
                                                          style: TextStyle(
                                                              // wordSpacing: 2,
                                                              fontFamily:
                                                                  'Al Majeed Quranic Font_shiped',
                                                              fontSize:
                                                                  widget.ar,
                                                              color:
                                                                  color_main_text),
                                                        ),
                                                        TextSpan(
                                                          text: '﴿  ',
                                                          style: TextStyle(
                                                              wordSpacing: 3,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontFamily:
                                                                  'Al Majeed Quranic Font_shiped',
                                                              fontSize:
                                                                  widget.ar - 5,
                                                              color:
                                                                  color_main_text),
                                                        ),
                                                        TextSpan(
                                                          text: verses
                                                                  .isNotEmpty
                                                              ? "${arabicNumber.convert(verses[index]['verse_id'])}  :  ${arabicNumber.convert(verses[index]['surah_id'])}"
                                                              : "",
                                                          style: TextStyle(
                                                            wordSpacing: 3,
                                                            fontSize:
                                                                widget.ar - 5,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                color_main_text,
                                                          ),
                                                        ),
                                                        TextSpan(
                                                          text: '  ﴾        ',
                                                          style: TextStyle(
                                                              wordSpacing: 3,
                                                              fontFamily:
                                                                  'Al Majeed Quranic Font_shiped',
                                                              fontSize:
                                                                  widget.ar - 5,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  color_main_text),
                                                        ),
                                                        verses.isNotEmpty &&
                                                                isSujoodVerse(
                                                                    verses[index]
                                                                        [
                                                                        'surah_id'],
                                                                    verses[index]
                                                                        [
                                                                        'verse_id'])
                                                            ? WidgetSpan(
                                                                alignment:
                                                                    PlaceholderAlignment
                                                                        .bottom,
                                                                child:
                                                                    Image.asset(
                                                                  'lib/assets/images/sujoodIcon.png',
                                                                  width: 12,
                                                                  height: 12,
                                                                ))
                                                            : const WidgetSpan(
                                                                child:
                                                                    SizedBox())
                                                      ])),
                                              const SizedBox(
                                                height: 11,
                                              ),
                                              Text.rich(
                                                  textAlign: TextAlign.start,
                                                  TextSpan(children: [
                                                    TextSpan(
                                                      text: verses.isNotEmpty
                                                          ? current_lang == "eng" ?
                                                      verses[index]
                                                                  ['english'] +
                                                              ' [${verses[index]['surah_id']}:${verses[index]['verse_id']}]' :
                                                      translated_verse[index]
                                                      ['text'] +
                                                          ' [${verses[index]['surah_id']}:${verses[index]['verse_id']}]'
                                                          : "",
                                                      style: TextStyle(
                                                          fontFamily:
                                                              'varela-round.regular',
                                                          color:
                                                              color_main_text,
                                                          fontSize: widget.eng),
                                                    ),
                                                    verses.isNotEmpty &&
                                                            isSujoodVerse(
                                                                verses[index][
                                                                    'surah_id'],
                                                                verses[index][
                                                                    'verse_id'])
                                                        ? TextSpan(
                                                            text:
                                                                '\n\nverse of prostration ***',
                                                            style: TextStyle(
                                                                color: Color(
                                                                    0xff518050),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontFamily:
                                                                    'varela-round.regular',
                                                                fontSize:
                                                                    widget.eng))
                                                        : const TextSpan()
                                                  ])),
                                              Stack(
                                                children: [
                                                  SingleChildScrollView(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 11.0,
                                                              top: 22),
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          // print((verses[index]['surah_id']).toString());
                                                          saveWordMeaningState(
                                                                  false)
                                                              .whenComplete(() => fetchSurahSujoodVerses(
                                                                      index + 1)
                                                                  .whenComplete(() => Navigator
                                                                          .of(this
                                                                              .context)
                                                                      .push(MaterialPageRoute(
                                                                          builder: (context) => UpdatedSurahPage(
                                                                                surah_id: (verses[index]['surah_id']).toString(),
                                                                                scroll_to: verses[index]['verse_id'] - 1,
                                                                                should_animate: true,
                                                                                eng: widget.eng,
                                                                                ar: widget.ar,
                                                                                bgColor: bgColor,
                                                                                fun: () async {
                                                                                  setState(() {
                                                                                    initializeThemeStarters();
                                                                                  });
                                                                                  return Future.value(true);
                                                                                },
                                                                              )))));
                                                        },
                                                        child: Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              color: const Color(
                                                                  0xff1d3f5e),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          1000),
                                                              boxShadow: [
                                                                BoxShadow(
                                                                  color: const Color(
                                                                          0xff1d3f5e)
                                                                      .withOpacity(
                                                                          0.15),
                                                                  spreadRadius:
                                                                      3,
                                                                  blurRadius:
                                                                      19,
                                                                  offset: const Offset(
                                                                      0,
                                                                      0), // changes position of shadow
                                                                ),
                                                              ],
                                                            ),
                                                            child: const Center(
                                                              child: Padding(
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                        horizontal:
                                                                            11.0,
                                                                        vertical:
                                                                            7),
                                                                child: Center(
                                                                  child:
                                                                      Text.rich(
                                                                    // textAlign: TextAlign.center,
                                                                    TextSpan(
                                                                        children: [
                                                                          TextSpan(
                                                                              text: "show in surah",
                                                                              style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'varela-round.regular', fontSize: 12, color: Colors.white)),
                                                                          WidgetSpan(
                                                                              alignment: PlaceholderAlignment.middle,
                                                                              child: Padding(
                                                                                padding: EdgeInsets.only(left: 7.0),
                                                                                child: Icon(
                                                                                  Icons.open_in_new,
                                                                                  color: Colors.white,
                                                                                  size: 19,
                                                                                ),
                                                                              ))
                                                                        ]),
                                                                  ),
                                                                ),
                                                              ),
                                                            )),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                ),
              ),
            ),
          ),
          Center(
            child: Visibility(
                visible: value_nothing_found,
                child: Image.asset('lib/assets/images/nothing_found.gif',
                    color: const Color(0xff1d3f5e),
                    width: size.width * .67,
                    height: size.width * .67)),
          ),
          Center(
            child: Visibility(
              visible: value_progress,
              child: const CircularProgressIndicator(
                color: Color(0xff1d3f5e),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedContainer(
              curve: Curves.easeOut,
              duration: const Duration(milliseconds: 250),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(21),
                  topRight: Radius.circular(21),
                ),
                color: Color(0xff1d3f5e),
              ),
              width: size.width - 60,
              height: snack_text_padding,
              child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 1000),
                  style: TextStyle(
                      height: 1,
                      color: const Color(0xffffffff),
                      fontFamily: 'varela-round.regular',
                      fontSize: snack_text_size,
                      fontWeight: FontWeight.bold),
                  child: Center(
                    child: Text(
                      "nothing added to \"${widget.folder_name}\" yet",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          height: 1,
                          color: const Color(0xffffffff),
                          fontFamily: 'varela-round.regular',
                          fontSize: snack_text_size,
                          fontWeight: FontWeight.bold),
                    ),
                  )),
            ),
          ),
        ],
      ),
    );
  }
}
