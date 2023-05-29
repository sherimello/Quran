import 'package:arabic_numbers/arabic_numbers.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SurahPage extends StatefulWidget {
  final String surah_id, image, surah_name, arabic_name, sujood_index, verse_numbers;

  const SurahPage({Key? key, required this.surah_id, required this.image, required this.surah_name, required this.arabic_name, required this.sujood_index, required this.verse_numbers}) : super(key: key);

  @override
  State<SurahPage> createState() => _SurahPageState();
}

class _SurahPageState extends State<SurahPage> {
  List<Map> verses = [], translated_verse = [];
  late Database database;
  late String path;

  Future<void> initiateDB() async {
    // Get a location using getDatabasesPath
    var databasesPath = await getDatabasesPath();
    path = join(databasesPath, 'quran.db');

    database = await openDatabase(path);

    print(widget.sujood_index);
  }

  fetchVersesData() async {
    // print(widget.verse_numbers);
    verses.clear();
    await initiateDB().whenComplete(() async {
      verses = await database.rawQuery(
          'SELECT text FROM verses WHERE lang_id = 1 AND surah_id = ?',
          [widget.surah_id]);
      translated_verse = await database.rawQuery(
          'SELECT text FROM verses WHERE lang_id = 2 AND surah_id = ?',
          [widget.surah_id]);
    });
  }

  bindVersesData() {
    fetchVersesData().whenComplete(() {
      setState(() {
        verses = verses;
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    bindVersesData();
    print(widget.image);
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    ArabicNumbers arabicNumber = ArabicNumbers();
    String s = arabicNumber.convert(1);
    print(s);

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
                      'Verses: ${verses.length}  ',
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
      body: verses.length.toString() == widget.verse_numbers ? SafeArea(
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
                color: verses.length.isOdd
                    ? const Color(0xfff4f4ff)
                    : const Color(0xfffaf7f7),
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                    itemCount: verses.length,
                    itemBuilder: (BuildContext context, int index) {
                      print('${isPortraitMode() ? size.height / size.width : size.width / size.height}');
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
                                    Material(
                                      color: Colors.transparent,
                                      child: Text.rich(
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
                                                        'KFGQPC Uthmanic Script HAFS Regular',
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
                                                index + 1 == int.parse(widget.sujood_index) ? WidgetSpan(
                                                    alignment: PlaceholderAlignment.bottom,
                                                    child: Image.asset('lib/assets/images/sujoodIcon.png', width: 12, height: 12,)) : WidgetSpan(child: SizedBox())
                                              ])),
                                          const SizedBox(height: 11,),
                                          Text.rich(
                                              textAlign: TextAlign.start,
                                            TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: translated_verse[index]['text'] + ' [${widget.surah_id}:${index + 1}]',
                                                  style: const TextStyle(
                                                      fontFamily: 'varela-round.regular'
                                                  ),
                                                ),
                                                index + 1 == int.parse(widget.sujood_index) ?
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
          ],
        ),
      ) : Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: const Center(
          child: CircularProgressIndicator(
            backgroundColor: Colors.black,
          ),
        ),
      ),
    );
  }
}
