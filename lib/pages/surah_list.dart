import 'package:arabic_numbers/arabic_numbers.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:quran/pages/surah_page.dart';
import 'package:sqflite/sqflite.dart';

class SurahList extends StatefulWidget {
  const SurahList({Key? key}) : super(key: key);

  @override
  State<SurahList> createState() => _SurahListState();
}

class _SurahListState extends State<SurahList> {
  late Database database;
  late String path;
  String surah_type = '';
  List<Map> surah_name_arabic = [], surah_name_translated = [];
  List<int> verse_numbers = [
        7,
        286,
        200,
        176,
        120,
        165,
        206,
        75,
        127,
        109,
        123,
        111,
        43,
        52,
        99,
        128,
        111,
        110,
        98,
        135,
        112,
        78,
        118,
        64,
        77,
        227,
        93,
        88,
        69,
        60,
        34,
        30,
        73,
        54,
        45,
        83,
        182,
        88,
        75,
        85,
        54,
        53,
        89,
        59,
        37,
        35,
        38,
        29,
        18,
        45,
        60,
        49,
        62,
        55,
        78,
        96,
        29,
        22,
        24,
        13,
        14,
        11,
        11,
        18,
        12,
        12,
        30,
        52,
        52,
        44,
        28,
        28,
        20,
        56,
        40,
        31,
        50,
        40,
        46,
        42,
        29,
        19,
        36,
        25,
        22,
        17,
        19,
        26,
        30,
        20,
        15,
        21,
        11,
        8,
        8,
        19,
        5,
        8,
        8,
        11,
        11,
        8,
        3,
        9,
        5,
        4,
        7,
        3,
        6,
        3,
        5,
        4,
        5,
        6
      ],
      madani_surah = [
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
      ];

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
      surah_name_arabic =
          await database.rawQuery('SELECT * FROM surahnames WHERE lang_id = 1');
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
      backgroundColor: const Color(0xfffff8dd),
      body: Container(
          color: const Color(0xfffff8dd),
          // color: const Color(0xffd7e3fd),
          child: surah_name_arabic.isEmpty
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      // padding: EdgeInsets.all(11),
                      itemCount: 114,
                      cacheExtent: 114,
                      itemBuilder: (BuildContext bcontext, int index) {

                        for (int i = 0; i < madani_surah.length; i++) {
                          if (index + 1 == madani_surah[i]) {
                            surah_type = 'Madani Surah';
                            break;
                          } else {
                            surah_type = 'Makki Surah';
                            // break;
                          }
                        }
                        return GestureDetector(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context)=> SurahPage(surah_id: '${index + 1}')));
                          },
                          child: SizedBox(
                            child: Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  // width: size.width,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.fromLTRB(0, 7, 0, 7),
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.all(1.0),
                                                child: Image.asset(
                                                  'lib/assets/images/indexDesign.png',
                                                  height: size.width * .11,
                                                  width: size.width * .11,
                                                ),
                                              ),
                                              Text(
                                                '${index + 1}',
                                                // arabicNumber.convert(index + 1),
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: const Color(0xff1d3f5e),
                                                  fontSize: size.width * .029,
                                                  // fontWeight: FontWeight.bold,
                                                  fontFamily: 'varela-round.regular'
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Wrap(
                                            direction: Axis.vertical,
                                            crossAxisAlignment:
                                                WrapCrossAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.fromLTRB(
                                                    17, 0, 17, 0),
                                                child: Text(
                                                  surah_name_translated[index]
                                                      ['translation'],
                                                  style: const TextStyle(
                                                      color: Color(0xff1d3f5e),
                                                      // fontSize: 15,
                                                      fontWeight: FontWeight.bold,
                                                      fontFamily:
                                                          'varela-round.regular'),
                                                ),
                                              ),

                                              Padding(
                                                padding: const EdgeInsets.fromLTRB(
                                                    17, 5, 17, 0),
                                                child: Wrap(
                                                  alignment: WrapAlignment.center,
                                                  crossAxisAlignment:
                                                  WrapCrossAlignment.center,
                                                  children: [Text(
                                                    '${surah_name_arabic[index]['translation']}',
                                                    style: const TextStyle(
                                                        color: Colors.black,
                                                        // fontSize: 15,
                                                        // fontWeight: FontWeight.bold,
                                                        fontFamily:
                                                        'Al Qalam Quran Majeed Web Regular'),
                                                  ),
                                                    const Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 5.0, right: 11),
                                                      child: Text('●'),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.all(5.0),
                                                      child: Wrap(
                                                        alignment: WrapAlignment.center,
                                                        crossAxisAlignment:
                                                        WrapCrossAlignment.center,
                                                        children: [
                                                          Image.asset(
                                                            surah_type == 'Makki Surah'
                                                                ? 'lib/assets/images/makkaIcon.png'
                                                                : 'lib/assets/images/madinaIcon.png',
                                                            height: 13,
                                                            width: 13,
                                                          ),
                                                          const SizedBox(
                                                            width: 7,
                                                          ),
                                                          Text(
                                                            surah_type,
                                                            style: const TextStyle(
                                                                color: Color(0xffa69963),
                                                                // fontWeight:
                                                                //     FontWeight.bold,
                                                                fontSize: 11,
                                                                fontFamily:
                                                                'varela-round.regular'),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.only(
                                                          right: 5.0),
                                                      child: Container(
                                                          width: 1,
                                                          height: 15,
                                                          color: const Color(0xffa69963)),
                                                    ),
                                                    Text('${verse_numbers[index]} verses',
                                                        style: const TextStyle(
                                                            color: Color(0xffa69963),
                                                            // fontWeight: FontWeight.bold,
                                                            fontSize: 11,
                                                            fontFamily:
                                                            'varela-round.regular'))
                                                  ],
                                                ),
                                              ),
                                              // Padding(
                                              //   padding: const EdgeInsets.fromLTRB(
                                              //       17, 0, 17, 0),
                                              //   child: Text(
                                              //     '(${surah_name_arabic[index]['translation']})',
                                              //     style: const TextStyle(
                                              //         color: Colors.black,
                                              //         // fontSize: 15,
                                              //         // fontWeight: FontWeight.bold,
                                              //         fontFamily:
                                              //             'Al Qalam Quran Majeed Web Regular'),
                                              //   ),
                                              // ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Divider(
                                      color: Color(0xffa69963),
                                    )
                                  ]),
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
                            ),
                          ),
                        );
                      }),
                )),
    );
  }
}
