import 'package:arabic_numbers/arabic_numbers.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../hero_transition_handler/custom_rect_tween.dart';
import 'new_surah_page.dart';

class FavoriteVerses extends StatefulWidget {

  final String tag;

  const FavoriteVerses({Key? key, required this.tag}) : super(key: key);

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

  Future<void> initiateDB() async {
    // Get a location using getDatabasesPath
    var databasesPath = await getDatabasesPath();
    path = join(databasesPath, 'quran.db');

    database = await openDatabase(path);

    print(database.isOpen);
  }

  fetchVersesData() async{

    verses = [];
    translated_verse = [];

    // translated_verse = await database.rawQuery('SELECT * FROM bookmarks WHERE folder_name = ?', [widget.folder_name])
    // .whenComplete(() async {
    verses = await database.rawQuery('SELECT * FROM favorites').whenComplete(() async {
      sujood_surah_indices = await database.rawQuery('SELECT surah_id FROM sujood_verses').whenComplete(() async {
        sujood_verse_indices = await database.rawQuery('SELECT verse_id FROM sujood_verses');
        surah_name_translated =
        await database.rawQuery('SELECT * FROM surahnames WHERE lang_id = 2');
        surah_name_arabic =
        await database.rawQuery('SELECT * FROM surahnames WHERE lang_id = 1');
        sujood_verse_indices = await database.rawQuery('SELECT verse_id FROM sujood_verses');
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

  Future<void> fetchSurahSujoodVerses(int surah_id) async {
    selected_surah_sujood_verses = [];
    for(int i = 0; i < sujood_surah_indices.length; i++) {
      if(sujood_surah_indices[i]['surah_id'] == surah_id) {
        selected_surah_sujood_verses.add(sujood_verse_indices[i]['verse_id']);
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {

    var size = MediaQuery.of(context).size;

    bool isPortraitMode() {
      return size.height > size.width ? true : false;
    }

    return Stack(
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
                verses.isEmpty ? const Color(0xfff4f4ff) :
                verses.length.isOdd
                    ? const Color(0xfff4f4ff)
                    : const Color(0xfffaf7f7),
                child: Visibility(
                  visible: !loadVisibility,
                  child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      physics: const BouncingScrollPhysics(),
                      itemCount: verses.isNotEmpty ? verses.length : 0,
                      itemBuilder: (BuildContext context, int index) {
                        // print('${isPortraitMode() ? size.height / size.width : size.width / size.height}');
                        return Container(
                          decoration: BoxDecoration(
                              color: index.isEven
                                  ? const Color(0xfff4f4ff)
                                  : Colors.white),
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
                                        ),
                                      ),
                                      Text.rich(
                                        textAlign: TextAlign.center,
                                        TextSpan(
                                          text: '${index + 1}',
                                          style: TextStyle(
                                            color: const Color(0xff1d3f5e),
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
                                                    style: const TextStyle(
                                                      wordSpacing: 2,
                                                      fontFamily:
                                                      'Al Majeed Quranic Font_shiped',
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                  const TextSpan(
                                                    text: '﴿  ',
                                                    style: TextStyle(
                                                      wordSpacing: 3,
                                                      fontWeight: FontWeight.bold,
                                                      fontFamily:
                                                      'Al Majeed Quranic Font_shiped',
                                                      fontSize: 07,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: "${arabicNumber
                                                        .convert(verses[index]['verse_id'])}:${arabicNumber
                                                        .convert(verses[index]['surah_id'])}",
                                                    style: const TextStyle(
                                                        wordSpacing: 3,
                                                        fontSize: 07,
                                                        fontWeight: FontWeight.bold
                                                    ),
                                                  ),
                                                  const TextSpan(
                                                    text: '  ﴾        ',
                                                    style: TextStyle(
                                                        wordSpacing: 3,
                                                        fontFamily:
                                                        'Al Majeed Quranic Font_shiped',
                                                        fontSize: 07,
                                                        fontWeight: FontWeight.bold),
                                                  ),
                                                  isSujoodVerse(verses[index]['surah_id'], verses[index]['verse_id']) ? WidgetSpan(
                                                      alignment: PlaceholderAlignment.bottom,
                                                      child: Image.asset('lib/assets/images/sujoodIcon.png', width: 12, height: 12,)) : const WidgetSpan(child: SizedBox())
                                                ])),
                                            const SizedBox(height: 11,),
                                            Text.rich(
                                                textAlign: TextAlign.start,
                                                TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text: verses[index]['english'] + ' [${verses[index]['surah_id']}:${verses[index]['verse_id']}]',
                                                        style: const TextStyle(
                                                            fontFamily: 'varela-round.regular'
                                                        ),
                                                      ),
                                                      isSujoodVerse(verses[index]['surah_id'], verses[index]['verse_id']) ?
                                                      const TextSpan(
                                                          text: '\n\nverse of prostration ***',
                                                          style: TextStyle(
                                                              color: Color(0xff518050),
                                                              fontWeight: FontWeight.bold,
                                                              fontFamily: 'varela-round.regular',
                                                              fontSize: 15
                                                          )
                                                      ): const TextSpan()
                                                    ]
                                                )),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.only(bottom: 11.0, top: 22),
                                                  child: GestureDetector(
                                                    onTap: () async {
                                                      print((verses[index]['surah_id']).toString());
                                                      await fetchSurahSujoodVerses(index + 1);
                                                      Navigator.of(this.context)
                                                          .push(MaterialPageRoute(builder: (context) => UpdatedSurahPage(surah_id: (verses[index]['surah_id']).toString(), scroll_to: verses[index]['verse_id']-1,)));
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
                        );
                      }
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
