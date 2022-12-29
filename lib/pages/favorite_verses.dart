import 'package:arabic_numbers/arabic_numbers.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../hero_transition_handler/custom_rect_tween.dart';
import '../hero_transition_handler/hero_dialog_route.dart';
import 'delete_card.dart';
import 'menu.dart';
import 'new_surah_page.dart';

class FavoriteVerses extends StatefulWidget {

  final String tag, from_where;
  final Color theme;
  final double eng, ar;

  const FavoriteVerses({Key? key, required this.tag, required this.from_where, required this.theme, required this.eng, required this.ar}) : super(key: key);

  @override
  State<FavoriteVerses> createState() => _FavoriteVersesState();
}

class _FavoriteVersesState extends State<FavoriteVerses> {
  late Database database;
  late String path, loadAsset = 'lib/assets/images/search.png', messageUpdate = "\nsearch whatever bothers\nor concerns you";
  int len = 0, flag = 0, load = 0;
  bool loadVisibility = true, value_progress = true;

  List<Map> verses = [], v = [], translated_verse = [], tv = [];
  late List<Map> surah_indices = [], verse_indices = [];
  final TextEditingController searchController = TextEditingController();
  String word = "";
  late int sujood_index;
  List<int> selected_surah_sujood_verses = [];
  late List<Map> sujood_surah_indices = [],
      sujood_verse_indices = [], surah_name_translated = [], surah_name_arabic = [];

  ArabicNumbers arabicNumber = ArabicNumbers();
  var bgColor = Colors.white, color_favorite_and_index = const Color(0xff1d3f5e), color_header = const Color(0xff1d3f5e),
      color_container_dark = const Color(0xfff4f4ff), color_container_light = Colors.white, color_main_text = Colors.black;


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

  initializeThemeStarters() async {

    if(widget.theme == Colors.white) {
      assignmentForLightMode();
    }
    else {
      assignmentForDarkMode();
    }

    // SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    // if(sharedPreferences.containsKey('theme mode')) {
    //   if(sharedPreferences.getString('theme mode') == "light") {
    //     assignmentForLightMode();
    //   }
    //   if(sharedPreferences.getString('theme mode') == "dark") {
    //     assignmentForDarkMode();
    //   }
    // }
  }


  @override
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

  Future<void> initiateDB() async {
    // Get a location using getDatabasesPath
    var databasesPath = await getDatabasesPath();
    path = join(databasesPath, 'quran.db');

    database = await openDatabase(path);

    // print(database.isOpen);
  }

  fetchVersesData() async{

    verses = [];
    translated_verse = [];
    sujood_surah_indices = [];
    sujood_verse_indices = [];
    surah_name_translated = [];
    surah_name_arabic = [];


    // translated_verse = await database.rawQuery('SELECT * FROM bookmarks WHERE folder_name = ?', [widget.folder_name])
    // .whenComplete(() async {
    verses = await database.rawQuery('SELECT * FROM favorites').whenComplete(() async {
      sujood_surah_indices = await database.rawQuery('SELECT surah_id FROM sujood_verses').whenComplete(() async {
        sujood_verse_indices = await database.rawQuery('SELECT verse_id FROM sujood_verses');
        surah_name_translated =
        await database.rawQuery('SELECT * FROM surahnames WHERE lang_id = 2');
        surah_name_arabic =
        await database.rawQuery('SELECT * FROM surahnames WHERE lang_id = 1');
      });
    });
    setState(() {
      value_progress = false;
      if (verses.isEmpty) {
        loadAsset = 'lib/assets/images/nothing_found.gif';
        loadVisibility = true;
        messageUpdate = "no matches were found!";
      }
      else {
        loadAsset = "lib/assets/images/search.png";
        loadVisibility = false;
        // translated_verse = translated_verse;
        verses = verses;
        len = verses.length;
      }
    });


  }

  bool isSujoodVerse(int surah, int verse) {
    bool b = false, flag = false;
    for( int i = 0; i < sujood_surah_indices.length; i++) {
      if (sujood_surah_indices[i]["surah_id"] == surah) {
        flag = true;
        break;
      }
    }
    if(flag) {
      for( int i = 0; i < sujood_verse_indices.length; i++) {
        if (sujood_surah_indices[i]["surah_id"] == surah && sujood_verse_indices[i]["verse_id"] == verse) {
          b = true;
          flag = false;
          break;
        }
      }
    }

    return b;

  }


  Future<void> getData() async {
    await initiateDB().whenComplete(() async=> await fetchVersesData());
  }

  // Future<void> fetchSurahSujoodVerses(int surah_id) async {
  //   selected_surah_sujood_verses = [];
  //   for(int i = 0; i < sujood_surah_indices.length; i++) {
  //     if(sujood_surah_indices[i]['surah_id'] == surah_id) {
  //       selected_surah_sujood_verses.add(sujood_verse_indices[i]['verse_id']);
  //     }
  //   }
  // }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initializeThemeStarters();
    getData();
  }

  @override
  Widget build(BuildContext context) {

    // setState(() {
    //   getData();
    // });

    var size = MediaQuery.of(context).size;

    bool isPortraitMode() {
      return size.height > size.width ? true : false;
    }

    Future <bool> goToMenu() async{
      // if(widget.from_where == "menu") {
      //   return await Navigator.of(context).push(HeroDialogRoute(
      //     bgColor: Colors.white.withOpacity(0.0),
      //     builder: (context) => const Center(child: Menu()),
      //   )) ?? false;
      // }
      Navigator.pop(context);
      return false;
    }

    return WillPopScope(
      onWillPop: goToMenu,
      child: Stack(
        children: [
          Center(
            child: Visibility(
              visible: value_progress,
              child: const CircularProgressIndicator(
                color: Color(0xff1d3f5e),
              ),
            ),
          ),
          SafeArea(
            child: Hero(
              tag: widget.tag,
              createRectTween: (begin, end) {
                return CustomRectTween(begin: begin!, end: end!);
              },
              child: Material(
                color: Colors.transparent,
                child: Container(
                  height: size.height,
                  width: size.width,
                  color:
                  verses.isEmpty ? bgColor :
                  verses.length.isOdd
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
                            onTap: () {
                              Navigator.of(context).push(HeroDialogRoute(
                                bgColor: bgColor.withOpacity(0.85),
                                builder: (context) => Center(child: DeleteCard(tag: widget.tag, surah_number: verses[index]['surah_id'].toString(), verse_number: verses[index]['verse_id'].toString(), what_to_delete: "favorites", from_where:  widget.from_where,)),
                              )).then((value) => fetchVersesData());
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  color: index.isEven
                                      ? color_container_dark
                                      : color_container_light),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(0, 7, 0, 7),
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(1.0),
                                            child: Image.asset(
                                              'lib/assets/images/surahIndex.png',
                                              height: isPortraitMode() ? size.width * .10 : size.height * .10,
                                              width: isPortraitMode() ? size.width * .10 : size.height * .10,
                                              color: color_favorite_and_index,
                                            ),
                                          ),
                                          Text.rich(
                                            textAlign: TextAlign.center,
                                            TextSpan(
                                              text: '${index + 1}',
                                              style: TextStyle(
                                                color: color_favorite_and_index,
                                                fontSize: isPortraitMode() ? size.width * .023 : size.height * .023,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'varela-round.regular',
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
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                Text.rich(
                                                    textDirection: TextDirection.rtl,
                                                    textAlign: TextAlign.right,
                                                    textScaleFactor:
                                                    (isPortraitMode() ? size.height / size.width : size.width / size.height),
                                                    TextSpan(children: [
                                                      TextSpan(
                                                        text: verses.isNotEmpty
                                                            ? '${verses[index]['arabic']}  '
                                                            : '',
                                                        // 'k',
                                                        style: TextStyle(
                                                          color: color_main_text,
                                                          wordSpacing: 2,
                                                          fontFamily:
                                                          'Al Majeed Quranic Font_shiped',
                                                          fontSize: widget.ar,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text: '﴿  ',
                                                        style: TextStyle(
                                                          color: color_main_text,
                                                          wordSpacing: 3,
                                                          fontWeight: FontWeight.bold,
                                                          fontFamily:
                                                          'Al Majeed Quranic Font_shiped',
                                                          fontSize: widget.ar - 5,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text: verses.isNotEmpty ? "${arabicNumber
                                                            .convert(verses[index]['verse_id'])}:${arabicNumber
                                                            .convert(verses[index]['surah_id'])}" : "",
                                                        style: TextStyle(
                                                          color: color_main_text,
                                                            wordSpacing: 3,
                                                            fontSize: widget.ar - 5,
                                                            fontWeight: FontWeight.bold
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text: '  ﴾        ',
                                                        style: TextStyle(
                                                          color: color_main_text,
                                                            wordSpacing: 3,
                                                            fontFamily:
                                                            'Al Majeed Quranic Font_shiped',
                                                            fontSize: widget.ar - 5,
                                                            fontWeight: FontWeight.bold),
                                                      ),
                                                      verses.isNotEmpty && isSujoodVerse(verses[index]['surah_id'], verses[index]['verse_id']) ? WidgetSpan(
                                                          alignment: PlaceholderAlignment.bottom,
                                                          child: Image.asset('lib/assets/images/sujoodIcon.png', width: 12, height: 12,)) : const WidgetSpan(child: SizedBox())
                                                    ])),
                                                const SizedBox(height: 11,),
                                                Text.rich(
                                                    textAlign: TextAlign.start,
                                                    TextSpan(
                                                        children: [
                                                          TextSpan(
                                                            text: verses.isNotEmpty ? verses[index]['english'] + ' [${verses[index]['surah_id']}:${verses[index]['verse_id']}]' : "",
                                                            style: TextStyle(
                                                                fontFamily: 'varela-round.regular',
                                                              color: color_main_text,
                                                              fontSize: widget.eng
                                                            ),
                                                          ),
                                                          verses.isNotEmpty && isSujoodVerse(verses[index]['surah_id'], verses[index]['verse_id']) ?
                                                          TextSpan(
                                                              text: '\n\nverse of prostration ***',
                                                              style: TextStyle(
                                                                  color: Color(0xff518050),
                                                                  fontWeight: FontWeight.bold,
                                                                  fontFamily: 'varela-round.regular',
                                                                  fontSize: widget.eng
                                                              )
                                                          ): const TextSpan()
                                                        ]
                                                    )),
                                                Stack(
                                                  children: [
                                                    SingleChildScrollView(
                                                      scrollDirection: Axis.horizontal,
                                                      child: Padding(
                                                        padding: const EdgeInsets.only(bottom: 11.0, top: 22),
                                                        child: GestureDetector(
                                                          onTap: () async {
                                                            // print((verses[index]['surah_id']).toString());
                                                            // await fetchSurahSujoodVerses(index + 1);
                                                            Navigator.of(this.context)
                                                                .push(MaterialPageRoute(builder: (context) => UpdatedSurahPage(surah_id: (verses[index]['surah_id']).toString(), scroll_to: verses[index]['verse_id']-1, should_animate: true, eng: widget.eng, ar: widget.ar,)));
                                                          },
                                                          child: Container(
                                                            // width: size.width,
                                                            // height: AppBar().preferredSize.height * .67,
                                                              decoration: BoxDecoration(
                                                                color: const Color(0xff1d3f5e),
                                                                borderRadius: BorderRadius.circular(1000),
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                    color: const Color(0xff1d3f5e).withOpacity(0.15),
                                                                    spreadRadius: 3,
                                                                    blurRadius: 19,
                                                                    offset: const Offset(0,0), // changes position of shadow
                                                                  ),
                                                                ],
                                                              ),
                                                              child: const Center(
                                                                child: Padding(
                                                                  padding: EdgeInsets.symmetric(horizontal: 11.0, vertical: 7),
                                                                  child: Center(
                                                                    child: Text.rich(
                                                                      // textAlign: TextAlign.center,
                                                                      TextSpan(
                                                                          children: [
                                                                            TextSpan(
                                                                                text: "show in surah",
                                                                                style: TextStyle(
                                                                                    fontWeight: FontWeight.bold,
                                                                                    fontFamily: 'varela-round.regular',
                                                                                    fontSize: 12,
                                                                                    color: Colors.white
                                                                                )
                                                                            ),
                                                                            WidgetSpan(
                                                                                alignment: PlaceholderAlignment.middle,
                                                                                child: Padding(
                                                                                  padding: EdgeInsets.only(left: 7.0),
                                                                                  child: Icon(Icons.open_in_new, color: Colors.white, size: 19,),
                                                                                ))
                                                                          ]
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              )
                                                          ),
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
                        }
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
