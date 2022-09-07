import 'package:arabic_numbers/arabic_numbers.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SurahPage extends StatefulWidget {
  final String surah_id;

  const SurahPage({Key? key, required this.surah_id}) : super(key: key);

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
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    ArabicNumbers arabicNumber = ArabicNumbers();
    String s = arabicNumber.convert(1);
    print(s);

    return Scaffold(
      backgroundColor:
          verses.length.isOdd ? const Color(0xfff4f4ff) : Colors.white,
      body: ListView.builder(
          itemCount: verses.length,
          itemBuilder: (BuildContext context, int index) {
            print('${size.height / size.width}');
            return Container(
              decoration: BoxDecoration(
                  color: index.isEven ? Color(0xfff4f4ff) : Colors.white),
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
                              height: size.width * .11,
                              width: size.width * .11,
                            ),
                          ),
                          Text.rich(
                            textAlign: TextAlign.center,
                            TextSpan(
                              text: '${index + 1}',
                              style: TextStyle(
                                color: const Color(0xff1d3f5e),
                                fontSize: size.width * .029,
                                fontFamily: 'varela-round.regular',
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text.rich(
                                textDirection: TextDirection.rtl,
                                textAlign: TextAlign.right,
                                textScaleFactor: (size.height / size.width),
                                TextSpan(children: [
                                  TextSpan(
                                    text: verses.isNotEmpty
                                        ? '${verses[index]['text']} '
                                        : '',
                                    // 'k',
                                    style: const TextStyle(
                                      wordSpacing: 3,
                                      fontFamily:
                                          'Al Majeed Quranic Font_shiped',
                                      fontSize: 13,
                                    ),
                                  ),
                                  const TextSpan(
                                    text: '﴿',
                                    style: TextStyle(
                                      wordSpacing: 3,
                                      fontFamily:
                                          'Al Majeed Quranic Font_shiped',
                                      fontSize: 11,
                                    ),
                                  ),
                                  TextSpan(
                                    text: arabicNumber.convert(index + 1),
                                    style: const TextStyle(
                                      wordSpacing: 3,
                                      fontSize: 11,
                                    ),
                                  ),
                                  const TextSpan(
                                    text: '﴾',
                                    style: TextStyle(
                                      wordSpacing: 3,
                                      fontFamily:
                                          'Al Majeed Quranic Font_shiped',
                                      fontSize: 11,
                                    ),
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
    );
  }
}
