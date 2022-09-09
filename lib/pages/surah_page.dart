import 'package:arabic_numbers/arabic_numbers.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SurahPage extends StatefulWidget {
  final String surah_id, image, surah_name, arabic_name;

  const SurahPage({Key? key, required this.surah_id, required this.image, required this.surah_name, required this.arabic_name}) : super(key: key);

  @override
  State<SurahPage> createState() => _SurahPageState();
}

class _SurahPageState extends State<SurahPage> {
  List<Map> verses = [];
  late Database database;
  late String path;

  Future<void> initiateDB() async {
    // Get a location using getDatabasesPath
    var databasesPath = await getDatabasesPath();
    path = join(databasesPath, 'quran.db');

    database = await openDatabase(path);

    print(database.isOpen);
  }

  fetchVersesData() async {
    verses.clear();
    await initiateDB().whenComplete(() async {
      verses = await database.rawQuery(
          'SELECT text FROM verses WHERE lang_id = 1 AND surah_id = ?',
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
      body: SafeArea(
        child: Container(
          color: verses.length.isOdd
              ? const Color(0xfff4f4ff)
              : const Color(0xfffaf7f7),
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
              itemCount: verses.length,
              itemBuilder: (BuildContext context, int index) {
                print('${size.height / size.width}');
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
                                  height: size.width * .10,
                                  width: size.width * .10,
                                ),
                              ),
                              Text.rich(
                                textAlign: TextAlign.center,
                                TextSpan(
                                  text: '${index + 1}',
                                  style: TextStyle(
                                    color: const Color(0xff1d3f5e),
                                    fontSize: size.width * .023,
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
                                child: Text.rich(
                                    textDirection: TextDirection.rtl,
                                    textAlign: TextAlign.right,
                                    textScaleFactor:
                                        (size.height / size.width),
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
                                        text: '﴿',
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
                                        text: '﴾',
                                        style: TextStyle(
                                            wordSpacing: 3,
                                            fontFamily:
                                                'Al Majeed Quranic Font_shiped',
                                            fontSize: 07,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ])),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
        ),
      ),
    );
  }
}
