import 'package:arabic_numbers/arabic_numbers.dart';
import 'package:flutter/material.dart';

import 'package:dictionaryx/dictionary_reduced_sa.dart';
import 'package:quran/pages/new_surah_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class VersesSearch extends StatefulWidget {

  final String theme;
  final double eng, ar;

  const VersesSearch({Key? key, required this.theme, required this.eng, required this.ar}) : super(key: key);

  @override
  State<VersesSearch> createState() => _VersesSearchState();
}


class _VersesSearchState extends State<VersesSearch> {

  late AutoScrollController autoScrollController;
  var bgColor = Colors.white, color_favorite_and_index = const Color(0xff1d3f5e), color_header = const Color(0xff1d3f5e),
      color_container_dark = const Color(0xfff4f4ff), color_container_light = Colors.white, color_main_text = Colors.black;

  late Database database;
  late String path, loadAsset = 'lib/assets/images/search.png', messageUpdate = "\nsearch whatever bothers\nor concerns you";
  int len = 0, flag = 0, load = 0, searched_word_index_in_surah = 0;
  bool loadVisibility = true;

  List<Map> verses = [], v = [], translated_verse = [], tv = [];
  late List<Map> surah_indices = [], verse_indices = [];
  final TextEditingController searchController = TextEditingController();
  String word = "", string1 = "",string2 = "", string3 = "", translated_v = "";
  late int sujood_index;
  List<int> selected_surah_sujood_verses = [];
  late List<Map> sujood_surah_indices = [],
      sujood_verse_indices = [], surah_name_translated = [], surah_name_arabic = [];

  ArabicNumbers arabicNumber = ArabicNumbers();


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

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if(sharedPreferences.containsKey('theme mode')) {
      if(sharedPreferences.getString('theme mode') == "light") {
        assignmentForLightMode();
      }
      if(sharedPreferences.getString('theme mode') == "dark") {
        assignmentForDarkMode();
      }
    }
  }

  @override
  void initState() {
    if(widget.theme == "light") {
      assignmentForLightMode();
    }
    else {
      assignmentForDarkMode();
    }
    // initializeThemeStarters();
    super.initState();
    autoScrollController = AutoScrollController(
        axis: Axis.vertical);
    // scrollController.createScrollPosition(const BouncingScrollPhysics(), context, ScrollPosition())
    // initiateDB().whenComplete(() => fetchVersesData("fear"));
  }

  Future<void> initiateDB() async {
    // Get a location using getDatabasesPath
    var databasesPath = await getDatabasesPath();
    path = join(databasesPath, 'quran.db');

    database = await openDatabase(path);

    print(database.isOpen);
  }

   fetchVersesData(String filter) async{

    verses = [];
    translated_verse = [];

    translated_verse = await database.query(
        "verses",
        where: "lang_id = 2 AND text LIKE ?",
        whereArgs: ['%$filter%']
    ).whenComplete(() async {
      verses = await database.query(
          "verses",
          where: "lang_id = 1 AND text LIKE ?",
          whereArgs: ['%$filter%',],
        orderBy: 'lang_id',
      ).whenComplete(() async {
        sujood_surah_indices = await database.rawQuery('SELECT surah_id FROM sujood_verses').whenComplete(() async {
          sujood_verse_indices = await database.rawQuery('SELECT verse_id FROM sujood_verses');
          surah_name_translated =
          await database.rawQuery('SELECT * FROM surahnames WHERE lang_id = 2');
          surah_name_arabic =
          await database.rawQuery('SELECT * FROM surahnames WHERE lang_id = 1');
          sujood_verse_indices = await database.rawQuery('SELECT verse_id FROM sujood_verses');
        });
      });
    });

    for(int i = 0; i < translated_verse.length; i++) {
      verses += await database.query(
        "verses",
        where: "lang_id = 1 AND surah_id = ? AND verse_id = ?",
        whereArgs: [translated_verse[i]['surah_id'], translated_verse[i]['verse_id']],
      );
    }

    setState(() {
      if (verses.isEmpty) {
        loadAsset = 'lib/assets/images/nothing_found.gif';
        loadVisibility = true;
        messageUpdate = "no matches were found!";
      }
      else {
        loadAsset = "lib/assets/images/search.png";
        loadVisibility = false;
        translated_verse = translated_verse;
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


  Future<void> getData(String filter) async {
    await initiateDB().whenComplete(() async=> await fetchVersesData(filter));
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
  void dispose() {
    // Clean up the controller when the widget is disposed.
    searchController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {

    setState(() {
      translated_verse = translated_verse;
      verses = verses;
      len = verses.length;
    });

    var size = MediaQuery.of(context).size;

    bool isPortraitMode() {
      return size.height > size.width ? true : false;
    }

    TextField searchBar = TextField(
      controller: searchController,
      textAlign: TextAlign.start,
      style: const TextStyle(
        fontStyle: FontStyle.italic,
        height: 1.5,
          fontSize: 13,
          color: Colors.white
      ),
      cursorColor: Colors.white,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 13),
        isDense: true,
          alignLabelWithHint: true,
          border: InputBorder.none,
          icon: Icon(Icons.manage_search_sharp, color: Colors.white.withOpacity(0.5),),
          iconColor: Colors.white.withOpacity(0.5),
          hintText: 'keyword...',
          hintStyle: TextStyle(
            height: 1.5,
              color: Colors.white.withOpacity(0.5),
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
              fontFamily: 'Rounded_Elegance'
          )
      ),
    );

    return Stack(
      children: [
        Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            toolbarHeight: AppBar().preferredSize.height * 1.5,
            automaticallyImplyLeading: false,
            titleSpacing: 0,
            elevation: 0,
            backgroundColor: Colors.transparent,
            title: Padding(
              padding: EdgeInsets.symmetric(vertical: 11.0, horizontal: size.width * .087),
              child: Stack(
                alignment: Alignment.centerRight,
                children: [
                  Container(
                    width: size.width * 1,
                    // width: size.width * .65,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(1000),
                        color: const Color(0xff1d3f5e)
                    ),
                    child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 19.0),
                        child: searchBar
                    ),
                  ),
                  const SizedBox(
                    width: 7,
                  ),
                  InkWell(
                    onTap: () async {
                      setState((){
                        messageUpdate = "\nfinding matches for \"${searchController.text}\"";
                        loadAsset = "lib/assets/images/loading.gif";
                        loadVisibility = true;
                      });
                      word = searchController.text;
                      await getData(word);

                    },

                    child: Container(
                      height: 13 * 4.1,
                      width: 13*4.1,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(1000),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xff1d3f5e).withOpacity(0.1),
                            spreadRadius: 7,
                            blurRadius: 11,
                            offset: const Offset(0, 0), // changes position of shadow
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(Icons.search, color: Color(0xff1d3f5e),),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          body: SafeArea(
            child: Container(
              color:
              verses.isEmpty ? bgColor :
              verses.length.isOdd
                  ? color_container_dark
                  : color_container_light,
              child: Visibility(
                visible: !loadVisibility,
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  controller: autoScrollController,
                    physics: const BouncingScrollPhysics(),
                    itemCount: translated_verse.isNotEmpty ? translated_verse.length : 0,
                    itemBuilder: (BuildContext context, int index) {

                      translated_v = translated_verse[index]['text'].toString();
                      searched_word_index_in_surah = translated_v.toLowerCase().indexOf(word.trim().toLowerCase());

                    // if(translated_v.indexOf(word) > 0) {
                      print(translated_v.indexOf(word));
                      string1 = translated_v.substring(0, searched_word_index_in_surah);
                      string2 = translated_v.substring(searched_word_index_in_surah, searched_word_index_in_surah + word.length);
                      string3 = translated_v.substring(searched_word_index_in_surah + word.length);
                    // }
                    // else {
                    //   string1 = translated_v.substring(searched_word_index_in_surah) + 1, word.length);
                    //   string2 = translated_v.substring(word.length);
                    //   string3 = '$string2 [${translated_verse[index]['surah_id']}:${translated_verse[index]['verse_id']}';
                    // }
                      print('${isPortraitMode() ? size.height / size.width : size.width / size.height}');
                      return Container(
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
                                                      ? '${verses[index]['text']}  '
                                                      : '',
                                                  // 'k',
                                                  style: TextStyle(
                                                    wordSpacing: 2,
                                                    fontFamily:
                                                    'Al Majeed Quranic Font_shiped',
                                                    fontSize: widget.ar,
                                                    color: color_main_text,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: '﴿  ',
                                                  style: TextStyle(
                                                    wordSpacing: 3,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily:
                                                    'Al Majeed Quranic Font_shiped',
                                                    fontSize: widget.ar - 5,
                                                    color: color_main_text,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: "${arabicNumber
                                                      .convert(translated_verse[index]['verse_id'])}:${arabicNumber
                                                      .convert(translated_verse[index]['surah_id'])}",
                                                  style: TextStyle(
                                                      wordSpacing: 3,
                                                    fontSize: widget.ar - 5,
                                                      fontWeight: FontWeight.bold,
                                                    color: color_main_text,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: '  ﴾        ',
                                                  style: TextStyle(
                                                      wordSpacing: 3,
                                                      fontFamily:
                                                      'Al Majeed Quranic Font_shiped',
                                                    fontSize: widget.ar - 5,
                                                      fontWeight: FontWeight.bold,
                                                    color: color_main_text,),
                                                ),
                                                isSujoodVerse(translated_verse[index]['surah_id'], translated_verse[index]['verse_id']) ? WidgetSpan(
                                                    alignment: PlaceholderAlignment.bottom,
                                                    child: Image.asset('lib/assets/images/sujoodIcon.png', width: 12, height: 12,)) : const WidgetSpan(child: SizedBox())
                                              ])),
                                          const SizedBox(height: 11,),
                                          Text.rich(
                                              textAlign: TextAlign.start,
                                              TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text: string1,
                                                      style: TextStyle(
                                                          fontFamily: 'varela-round.regular',
                                                        color: color_main_text,
                                                        fontSize: widget.eng
                                                      ),
                                                    ),
                                                    TextSpan(
                                                      text: string2,
                                                      style: TextStyle(
                                                          fontFamily: 'varela-round.regular',
                                                        color: Colors.red,
                                                        fontWeight: FontWeight.bold,
                                                        // fontStyle: FontStyle.italic,
                                                          fontSize: widget.eng
                                                      ),
                                                    ),
                                                    TextSpan(
                                                      text: string3,
                                                      style: TextStyle(
                                                          fontFamily: 'varela-round.regular',
                                                        color: color_main_text,
                                                        fontSize: widget.eng
                                                      ),
                                                    ),
                                                    TextSpan(
                                                      text: ' [${translated_verse[index]['surah_id']}:${translated_verse[index]['verse_id']}]',
                                                      style: TextStyle(
                                                          fontFamily: 'Rounded_Elegance',
                                                        fontWeight: FontWeight.bold,
                                                        color: color_favorite_and_index,
                                                        fontSize: widget.eng
                                                      ),
                                                    ),
                                                    isSujoodVerse(translated_verse[index]['surah_id'], translated_verse[index]['verse_id']) ?
                                                    TextSpan(
                                                        text: '\n\nverse of prostration ***',
                                                        style: TextStyle(
                                                            color: const Color(0xff518050),
                                                            fontWeight: FontWeight.bold,
                                                            fontFamily: 'varela-round.regular',
                                                            fontSize: widget.eng
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
                                                    await fetchSurahSujoodVerses(index + 1);
                                                    Navigator.of(this.context)
                                                        .push(MaterialPageRoute(builder: (context) => UpdatedSurahPage(surah_id: translated_verse[index]['surah_id'].toString(), scroll_to: translated_verse[index]['verse_id']-1, should_animate: true, eng: widget.eng, ar: widget.ar,)));
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
                                                            textAlign: TextAlign.center,
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
        Visibility(
          visible: loadVisibility,
          child: Center(child: Visibility(visible: loadVisibility, child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Opacity(
                  opacity: 1,
                  child: Image.asset(loadAsset, width: size.width * .41, height: size.width * .31, fit: BoxFit.contain, color: const Color(0xff1d3f5e),)),
               AnimatedDefaultTextStyle(
                   textAlign: TextAlign.center,
                   style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                // fontStyle: FontStyle.italic,
                fontFamily: 'varela-round.regular',
                color: const Color(0xff1d3f5e).withOpacity(1)
              ), duration: const Duration(milliseconds: 350), child: Text(
                messageUpdate
              ))
            ],
          ))),
        ),
// hjkg
      ],
    );
  }

  String message = "";
  String getString(String key) {
    setState(() {
      verses = verses;
      translated_verse = translated_verse;
    });
    // await fetchVersesData(key);
    for(int index = 0; index < translated_verse.length; index++) {
      message += translated_verse[index]["text"] + '\n';
    }
    setState(() {
      message = message;
    });
    print(message);
    return message;
  }

  String getSynonyms(String word) {
    var dReducedSA = DictionaryReducedSA();

    String synonyms = "";
    if(word.isEmpty) {
      return synonyms;}
    else {
    var entry = dReducedSA.getEntry(word);
    // print(entry.word); // meeting
    // print(entry.synonyms); // [Assemble, Contact, Adjoin, Forgather, See]
    // print(entry.antonyms); // [diverge]
    for(String s in entry.synonyms) {
    synonyms += '\n$s';
    }
    return synonyms;
    }
  }
}
