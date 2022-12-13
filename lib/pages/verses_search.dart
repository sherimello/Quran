import 'package:arabic_numbers/arabic_numbers.dart';
import 'package:flutter/material.dart';

import 'package:dictionaryx/dictionary_reduced_sa.dart';
import 'package:quran/pages/new_surah_page.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class VersesSearch extends StatefulWidget {
  const VersesSearch({Key? key}) : super(key: key);

  @override
  State<VersesSearch> createState() => _VersesSearchState();
}



class _VersesSearchState extends State<VersesSearch> {

  late AutoScrollController autoScrollController;

  @override
  void initState() {
    super.initState();
    autoScrollController = AutoScrollController(
        axis: Axis.vertical);
    // scrollController.createScrollPosition(const BouncingScrollPhysics(), context, ScrollPosition())
    // initiateDB().whenComplete(() => fetchVersesData("fear"));
  }

  Future _scrollToIndex() async {
    await autoScrollController.scrollToIndex(6, preferPosition: AutoScrollPosition.begin);
  }

  late Database database;
  late String path, loadAsset = 'lib/assets/images/search.png', messageUpdate = "\nsearch whatever bothers\nor concerns you";
  int len = 0, flag = 0, load = 0;
  bool loadVisibility = true;

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
          backgroundColor: const Color(0xfff4f4ff),
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
                      // height: 13 * 3.5,
                      width: 13*4.1,
                      // width: size.width * .35 - 29,
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
                        // child: Text(
                        //   'search',
                        //   style: TextStyle(
                        //       fontWeight: FontWeight.bold,
                        //       fontFamily: 'varela-round.regular',
                        //       color: Color(0xff1d3f5e),
                        //       fontSize: 13
                        //   ),
                        // ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          body: SafeArea(
            child: Container(
              // width: size.width,
              // height: size.height - AppBar().preferredSize.height * 1.5,
              color:
              verses.isEmpty ? const Color(0xfff4f4ff) :
              verses.length.isOdd
                  ? const Color(0xfff4f4ff)
                  : const Color(0xfffaf7f7),
              child: Visibility(
                visible: !loadVisibility,
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  controller: autoScrollController,
                    physics: const BouncingScrollPhysics(),
                    itemCount: verses.isNotEmpty ? verses.length : 0,
                    itemBuilder: (BuildContext context, int index) {
                      // setState(() {
                      //   flag = 0;
                      // });
                      print('${isPortraitMode() ? size.height / size.width : size.width / size.height}');
                      // return Padding(
                      //   padding: const EdgeInsets.all(8.0),
                      //   child: Container(
                      //     width: size.width,
                      //     height: 155,
                      //     color: Colors.black,
                      //   ),
                      // );
                      return AutoScrollTag(
                        controller: autoScrollController,
                        index: index,
                        key: ValueKey(index),
                        child: Container(
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
                                                        ? '${verses[index]['text']}  '
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
                                                        .convert(translated_verse[index]['verse_id'])}:${arabicNumber
                                                        .convert(translated_verse[index]['surah_id'])}",
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
                                                  isSujoodVerse(translated_verse[index]['surah_id'], translated_verse[index]['verse_id']) ? WidgetSpan(
                                                      alignment: PlaceholderAlignment.bottom,
                                                      child: Image.asset('lib/assets/images/sujoodIcon.png', width: 12, height: 12,)) : WidgetSpan(child: SizedBox())
                                                ])),
                                            const SizedBox(height: 11,),
                                            Text.rich(
                                                textAlign: TextAlign.start,
                                                TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text: translated_verse[index]['text'] + ' [${translated_verse[index]['surah_id']}:${translated_verse[index]['verse_id']}]',
                                                        style: const TextStyle(
                                                            fontFamily: 'varela-round.regular'
                                                        ),
                                                      ),
                                                      isSujoodVerse(translated_verse[index]['surah_id'], translated_verse[index]['verse_id']) ?
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
                                                      await fetchSurahSujoodVerses(index + 1);
                                                      Navigator.of(this.context)
                                                          .push(MaterialPageRoute(builder: (context) => UpdatedSurahPage(surah_id: translated_verse[index]['surah_id'].toString(), scroll_to: translated_verse[index]['verse_id']-1,)));
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
                  opacity: 0.51,
                  child: Image.asset(loadAsset, width: size.width * .41, height: size.width * .31, fit: BoxFit.contain, color: const Color(0xff1d3f5e),)),
               AnimatedDefaultTextStyle(
                   textAlign: TextAlign.center,
                   style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                // fontStyle: FontStyle.italic,
                fontFamily: 'varela-round.regular',
                color: const Color(0xff1d3f5e).withOpacity(.51)
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
