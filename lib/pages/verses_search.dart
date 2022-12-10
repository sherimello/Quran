import 'package:arabic_numbers/arabic_numbers.dart';
import 'package:flutter/material.dart';

import 'package:dictionaryx/dictionary_reduced_sa.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';


class VersesSearch extends StatefulWidget {
  const VersesSearch({Key? key}) : super(key: key);

  @override
  State<VersesSearch> createState() => _VersesSearchState();
}



class _VersesSearchState extends State<VersesSearch> {

  @override
  void initState() {
    super.initState();
    // initiateDB().whenComplete(() => fetchVersesData("fear"));
  }

  late Database database;
  late String path;
  int len = 0, flag = 0;

  List<Map> verses = [], v = [], translated_verse = [], tv = [];
  late List<Map> surah_indices = [], verse_indices = [];
  final TextEditingController searchController = TextEditingController();
  String word = "";
  late int sujood_index;
  late List<Map> sujood_surah_indices = [],
      sujood_verse_indices = [];

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
          sujood_verse_indices = await database.rawQuery('SELECT verse_id FROM sujood_verses').whenComplete(() async {
            surah_indices = await database.query(
                "verses",
                columns: ["surah_id"],
                where: "lang_id = 2 AND text LIKE ?",
                whereArgs: ['%$filter%']
            ).whenComplete(() async {
              verse_indices = await database.query(
                  "verses",
                  columns: ["verse_id"],
                  where: "lang_id = 2 AND text LIKE ?",
                  whereArgs: ['%$filter%']
              );
            });
          });
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
      translated_verse = translated_verse;
      verses = verses;
      len = verses.length;
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
        if (sujood_verse_indices[i]["verse_id"] == verse) {
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
        contentPadding: const EdgeInsets.all(13),
        isDense: true,
          alignLabelWithHint: true,
          border: InputBorder.none,
          icon: Icon(Icons.search, color: Colors.white.withOpacity(0.5),),
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

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: AppBar().preferredSize.height * 1.5,
        titleSpacing: 0,
        elevation: 0,
        backgroundColor: Colors.white,
        title: Padding(
          padding: const EdgeInsets.all(11.0),
          child: Row(
            children: [
              Container(
                width: size.width * .65,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(1000),
                    color: const Color(0xff1d3f5e)
                ),
                child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 11.0),
                    child: searchBar
                ),
              ),
              const SizedBox(
                width: 7,
              ),
              InkWell(
                onTap: () async {
                  word = searchController.text;
                  await getData(word);

                },

                child: Container(
                  height: 13 * 3.5,
                  width: size.width * .35 - 29,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(1000),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xff1d3f5e).withOpacity(0.1),
                        spreadRadius: 7,
                        blurRadius: 11,
                        offset: const Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'search',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'varela-round.regular',
                          color: Color(0xff1d3f5e),
                          fontSize: 13
                      ),
                    ),
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
          verses.isEmpty ? Colors.white :
          verses.length.isOdd
              ? const Color(0xfff4f4ff)
              : const Color(0xfffaf7f7),
          child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: verse_indices.isNotEmpty ? verse_indices.length : 0,
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
                                            text: arabicNumber
                                                .convert(index + 1),
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
                                        ))
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
