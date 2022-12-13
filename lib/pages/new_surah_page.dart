import 'package:arabic_numbers/arabic_numbers.dart';
import 'package:flutter/material.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class UpdatedSurahPage extends StatefulWidget {
  String surah_id, image, surah_name, arabic_name, verse_numbers;
  int scroll_to;
  List<int> sujoodVerses;
  List<Map> verses, translated_verse;

  // const UpdatedSurahPage({Key? key, required this.surah_id, required this.image, required this.surah_name, required this.arabic_name, required this.sujood_index, required this.verse_numbers, required this.verses, required this.translated_verse}) : super(key: key);
  UpdatedSurahPage({Key? key, required this.surah_id, this.image = "", this.surah_name = "", this.arabic_name = "", this.verse_numbers = "", this.verses = const [], this.translated_verse = const [], this.scroll_to = 0, this.sujoodVerses = const []}) : super(key: key);

  @override
  State<UpdatedSurahPage> createState() => _UpdatedSurahPageState();
}

class _UpdatedSurahPageState extends State<UpdatedSurahPage> {

  late AutoScrollController autoScrollController;
  List<int> madani_surah = [
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
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if(widget.image == "") {
      for (int i = 0; i < madani_surah.length; i++) {
        if (widget.surah_id == madani_surah[i].toString()) {
          widget.image = 'lib/assets/images/madinaWhiteIcon.png';
          break;
        } else {
          widget.image = 'lib/assets/images/makkaWhiteIcon.png';
          break;
        }
      }

      startFetches();

    }

    autoScrollController = AutoScrollController(
        axis: Axis.vertical,
    );

    _scrollToIndex();
  }

  void startFetches(){
    initiateDB().whenComplete(() async {
      await fetchVersesData(widget.surah_id);
      await fetchSurahSujoodVerses(int.parse(widget.surah_id));

    });
  }

  late Database database;
  late String path;
  List<Map> sujood_surah_indices = [],
      sujood_verse_indices = [], surah_name_arabic = [], surah_name_translated = [];

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
      widget.verses = await database.rawQuery(
          'SELECT text FROM verses WHERE lang_id = 1 AND surah_id = ?',
          [widget.surah_id]);
      widget.translated_verse = await database.rawQuery(
          'SELECT text FROM verses WHERE lang_id = 2 AND surah_id = ?',
          [widget.surah_id]);
      surah_name_arabic =
      await database.rawQuery('SELECT * FROM surahnames WHERE lang_id = 1 AND surah_id = ?', [widget.surah_id]);
      surah_name_translated =
      await database.rawQuery('SELECT * FROM surahnames WHERE lang_id = 2 AND surah_id = ?', [widget.surah_id]);
      sujood_surah_indices = await database.rawQuery('SELECT surah_id FROM sujood_verses');
      sujood_verse_indices = await database.rawQuery('SELECT verse_id FROM sujood_verses');
    });
    setState(() {
      widget.verses = widget.verses;
      widget.translated_verse = widget.translated_verse;
      widget.surah_name = surah_name_translated[0]['translation'];
      widget.arabic_name = surah_name_arabic[0]['translation'];
    });
  }

  Future<void> fetchSurahSujoodVerses(int surah_id) async {
    widget.sujoodVerses = [];
    for(int i = 0; i < sujood_surah_indices.length; i++) {
      if( widget.sujoodVerses[i] == surah_id) {
        widget.sujoodVerses.add(sujood_verse_indices[i]['verse_id']);
      }
    }
  }

  Future _scrollToIndex() async {
    await autoScrollController.scrollToIndex(widget.scroll_to, preferPosition: AutoScrollPosition.begin);
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    ArabicNumbers arabicNumber = ArabicNumbers();
    bool isPortraitMode() {
      return size.height > size.width ? true : false;
    }

    return Scaffold(
      backgroundColor: const Color(0xff1d3f5e),
      appBar: AppBar(
        backgroundColor: const Color(0xff1d3f5e),
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        elevation: 0,
        centerTitle: true,
        title: Row(
          children: [
            Image.asset('lib/assets/images/headerDesignL.png', width: size.width * .25, fit: BoxFit.fitHeight,),
            SizedBox(
              width: size.width * .5,
              height: AppBar().preferredSize.height,
              child: Column(
                // direction: Axis.vertical,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                // alignment: WrapAlignment.center,
                children: [Text.rich(
                    textAlign: TextAlign.center,
                    TextSpan(
                        children: [
                          WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: Image.asset(widget.image, height: 13, width: 13,)),
                          TextSpan(
                              text: '  ${widget.surah_name}  ',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'varela-round.regular',
                                  fontSize: 13
                              )
                          ),
                          TextSpan(
                            text:
                            widget.arabic_name,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Diwanltr'),
                          ),
                        ]
                    )
                ),
                  Text(
                      'Verses: ${widget.verses.length}  ',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'varela-round.regular',
                          fontSize: 11
                      )
                  ),
                ],
              ),
            ),
            Image.asset('lib/assets/images/headerDesignR.png', width: size.width * .25, fit: BoxFit.fitHeight,),
          ],
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              width: size.width,
              color: const Color(0xfff4f4ff),
              height: AppBar().preferredSize.height,
              padding: const EdgeInsets.all(0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      'k',
                      textAlign: TextAlign.center,
                      // textScaleFactor: ,
                      style: TextStyle(
                          inherit: false,
                          color: Colors.black,
                          fontFamily: '110_Besmellah',
                          fontStyle: FontStyle.normal,
                          fontSize: 30,
                          height: isPortraitMode() ? size.height / size.width : size.width / size.height
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: widget.surah_id == '1' || widget.surah_id == '9'? const EdgeInsets.all(0) : EdgeInsets.only(top: AppBar().preferredSize.height),
              child: Container(
                color: widget.verses.length.isOdd
                    ? const Color(0xfff4f4ff)
                    : const Color(0xfffaf7f7),
                child: ListView.builder(
                  controller: autoScrollController,
                    scrollDirection: Axis.vertical,
                    physics: const BouncingScrollPhysics(),
                    itemCount: widget.verses.length,
                    itemBuilder: (BuildContext context, int index) {
                      print('${isPortraitMode() ? size.height / size.width : size.width / size.height}');
                      return AutoScrollTag(
                        key: ValueKey(index),
                        index: index,
                        controller: autoScrollController,
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
                                                    text: widget.verses.isNotEmpty
                                                        ? '${widget.verses[index]['text']}  '
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
                                                  widget.sujoodVerses.contains(index + 1) ? WidgetSpan(
                                                      alignment: PlaceholderAlignment.bottom,
                                                      child: Image.asset('lib/assets/images/sujoodIcon.png', width: 12, height: 12,)) : WidgetSpan(child: SizedBox())
                                                ])),
                                            const SizedBox(height: 11,),
                                            Text.rich(
                                                textAlign: TextAlign.start,
                                                TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text: widget.translated_verse[index]['text'] + ' [${widget.surah_id}:${index + 1}]',
                                                        style: const TextStyle(
                                                            fontFamily: 'varela-round.regular'
                                                        ),
                                                      ),
                                                      widget.sujoodVerses.contains(index + 1) ?
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
                        ),
                      );
                    }
                ),
              ),
            ),
          ],
        ),
      )
    );
  }
}
