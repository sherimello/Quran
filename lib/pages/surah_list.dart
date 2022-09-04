import 'package:arabic_numbers/arabic_numbers.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SurahList extends StatefulWidget {
  const SurahList({Key? key}) : super(key: key);

  @override
  State<SurahList> createState() => _SurahListState();
}

class _SurahListState extends State<SurahList> {
  late Database database;
  late String path;
  List<Map> surah_name_arabic = [], surah_name_translated = [];

  @override
  void initState() {
    super.initState();
    fetchSurahName();
  }

  Future<void> initiateDB() async {
    // Get a location using getDatabasesPath
    var databasesPath = await getDatabasesPath();
    path = join(databasesPath, 'quran.db');

    database = await openDatabase(path);

    print(database.isOpen);
  }

  fetchSurahName() {
    initiateDB().whenComplete(() async {
      surah_name_arabic.clear();
      surah_name_translated.clear();
      surah_name_arabic = await database.rawQuery('SELECT * FROM surahnames WHERE lang_id = 1');
      surah_name_translated =
          await database.rawQuery('SELECT * FROM surahnames WHERE lang_id = 2');
      setState(() {
        // surahs.add(surah_name_arabic_temp);
        surah_name_arabic = surah_name_arabic;
        surah_name_translated = surah_name_translated;
      });
      print(surah_name_translated[1]['translation']);
    });
  }

  List<BoxShadow> boxShadow(double blurRadius, double offset1, double offset2,
      Color colorBottom, Color colorTop) {
    return [
      BoxShadow(
        blurRadius: blurRadius,
        offset: Offset(offset1, offset2),
        color: colorBottom.withOpacity(.5),
      ),
      BoxShadow(
        blurRadius: blurRadius,
        offset: Offset(-offset1, -offset2),
        color: colorTop,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    ArabicNumbers arabicNumber = ArabicNumbers();
    return Scaffold(
      body: Container(
          color: const Color(0xffffffff),
          // color: const Color(0xffd7e3fd),
          child: surah_name_arabic.isEmpty ? const Center(
            child: CircularProgressIndicator(),
          ) : Padding(
            padding: const EdgeInsets.all(5.0),
            child: ListView.builder(
                // padding: EdgeInsets.all(11),
                itemCount: 114,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xff1d3f5e),
                          borderRadius: BorderRadius.circular(17)
                        ),
                        width: size.width,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(padding: const EdgeInsets.all(7),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Image.asset('lib/assets/images/index image.png',
                                      height: size.width * .09,
                                    ),
                                    Text(arabicNumber.convert(index + 1),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: const Color(0xff1d3f5e),
                                          fontSize: size.width * .035,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'varela-round.regular'
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Wrap(
                                direction: Axis.vertical,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Padding(padding: const EdgeInsets.fromLTRB(11,11,11,5),
                                  child: Text(
                                    surah_name_translated[index]['translation'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold
                                    ),
                                  ),
                                  ),
                                  Padding(padding: const EdgeInsets.fromLTRB(11,0,11,11),
                                    child: Text(
                                      surah_name_arabic[index]['translation'],
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      // child: Column(
                      //
                      //     crossAxisAlignment: CrossAxisAlignment.center,
                      //     children: [
                      //       Stack(
                      //         alignment: Alignment.center,
                      //         children: [
                      //           Image.asset(
                      //             'lib/assets/images/indexPattern.png',
                      //             width: size.width * .17,
                      //             height: size.width * .17,
                      //           ),
                      //           Center(
                      //             child: Text(
                      //               '${index + 1}',
                      //               style: TextStyle(
                      //                   color: Colors.white,
                      //                   fontSize: size.width * .04),
                      //             ),
                      //           )
                      //         ],
                      //       ),
                      //       const SizedBox(
                      //         height: 11,
                      //       ),
                      //       Text(
                      //         surah_name_arabic.isEmpty ? "" : surah_name_arabic[index]['translation'],
                      //         style: const TextStyle(
                      //             fontFamily: 'varela-round.regular',
                      //             fontWeight: FontWeight.bold,
                      //             fontSize: 17),
                      //       ),
                      //       const SizedBox(
                      //         height: 11,
                      //       ),
                      //       Text(
                      //         surah_name_translated.isEmpty ? "" : surah_name_translated[index]['translation'],
                      //         style: const TextStyle(
                      //             fontFamily: 'varela-round.regular',
                      //             fontWeight: FontWeight.bold,
                      //             fontSize: 17),
                      //       ),
                      //       const SizedBox(
                      //         height: 11,
                      //       ),
                      //       Image.asset('lib/assets/images/divider.png',
                      //       )
                      //     ])
                  );
                }),
          )),
    );
  }
}
