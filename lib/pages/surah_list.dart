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
    var appBar = AppBar();

    bool isPortraitMode() {
      return size.height > size.width ? true : false;
    }

    ArabicNumbers arabicNumber = ArabicNumbers();
    return Scaffold(
      appBar: AppBar(
        // titleSpacing: 7,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 11.0),
              child: Container(
                  width: appBar.preferredSize.height -
                      appBar.preferredSize.height * .35,
                  height: appBar.preferredSize.height -
                      appBar.preferredSize.height * .35,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(1000),
                      color: Colors.white.withOpacity(.5)),
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Image.asset('lib/assets/images/quran icon.png'),
                  )),
            ),
            const Text(
              'Applied Qur\'an',
              style: TextStyle(
                  fontFamily: 'varela-round.regular',
                  fontWeight: FontWeight.bold,
                  fontSize: 15),
            ),
          ],
        ),
        backgroundColor: const Color(0xff1d3f5e),
        elevation: 0,
        // leading: Padding(
        //   padding: const EdgeInsets.all(11.0),
        //   child: Container(
        //       decoration: BoxDecoration(
        //         borderRadius: BorderRadius.circular(1000),
        //         color: Colors.white.withOpacity(.5)
        //       ),
        //       child: Padding(
        //         padding: const EdgeInsets.all(2.0),
        //         child: Image.asset('lib/assets/images/quran icon.png'),
        //       )),
        // ),
      ),
      backgroundColor: const Color(0xfffaf7f7),
      body: Container(
          color: const Color(0xfffaf7f7),
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
                            disputed_types.contains(index + 1)
                                ? surah_type = 'Madani Surah (?)'
                                : surah_type = 'Madani Surah';
                            break;
                          } else {
                            disputed_types.contains(index + 1)
                                ? surah_type = 'Makki Surah (?)'
                                : surah_type = 'Makki Surah';
                            // break;
                          }
                        }
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SurahPage(
                                          surah_id: '${index + 1}',
                                          image: madani_surah
                                                  .contains(index + 1)
                                              ? 'lib/assets/images/madinaWhiteIcon.png'
                                              : 'lib/assets/images/makkaWhiteIcon.png',
                                          surah_name:
                                          surah_name_translated[
                                          index]
                                          ['translation']
                                              .toString()
                                              .substring(
                                              0,
                                              surah_name_translated[
                                              index]
                                              [
                                              'translation']
                                                  .toString()
                                                  .indexOf(
                                                  ':')), arabic_name: surah_name_arabic[index]['translation'],
                                        )));
                          },
                          child: Card(
                            elevation: 0,
                            margin: const EdgeInsets.all(0),
                            color: Colors.transparent,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                // width: size.width,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(3.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        0, 7, 0, 7),
                                                child: Stack(
                                                  alignment: Alignment.center,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              1.0),
                                                      child: Image.asset(
                                                        'lib/assets/images/indexDesign.png',
                                                        height:
                                                            isPortraitMode() ? size.width * .10 : size.height * .10,
                                                        width: isPortraitMode() ? size.width * .10 : size.height * .10,
                                                      ),
                                                    ),
                                                    Text(
                                                      '${index + 1}',
                                                      // arabicNumber.convert(index + 1),
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          color: const Color(
                                                              0xff1d3f5e),
                                                          fontSize:
                                                              isPortraitMode() ? size.width * .029 : size.height * .029,
                                                          // fontWeight: FontWeight.bold,
                                                          fontFamily:
                                                              'varela-round.regular'),
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
                                                      padding: const EdgeInsets
                                                              .fromLTRB(
                                                          11, 0, 17, 0),
                                                      child: Text(
                                                        surah_name_translated[
                                                                    index]
                                                                ['translation']
                                                            .toString()
                                                            .substring(
                                                                0,
                                                                surah_name_translated[
                                                                            index]
                                                                        [
                                                                        'translation']
                                                                    .toString()
                                                                    .indexOf(
                                                                        ':')),
                                                        style: const TextStyle(
                                                            color: Color(
                                                                0xff1d3f5e),
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontFamily:
                                                                'varela-round.regular'),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                              .fromLTRB(
                                                          11, 5, 17, 0),
                                                      child: Text(
                                                        '${surah_name_translated[index]['translation'].toString().substring(surah_name_translated[index]['translation'].toString().indexOf(':') + 2)} ●',
                                                        style: const TextStyle(
                                                            color: Color(
                                                                0xff1d3f5e),
                                                            fontSize: 13,
                                                            // fontWeight: FontWeight.bold,
                                                            fontFamily:
                                                                'varela-round.regular'),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                              .fromLTRB(
                                                          11, 5, 17, 0),
                                                      child: Wrap(
                                                        alignment: WrapAlignment
                                                            .center,
                                                        crossAxisAlignment:
                                                            WrapCrossAlignment
                                                                .center,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(.0),
                                                            child: Wrap(
                                                              alignment:
                                                                  WrapAlignment
                                                                      .center,
                                                              crossAxisAlignment:
                                                                  WrapCrossAlignment
                                                                      .center,
                                                              children: [
                                                                Image.asset(
                                                                  surah_type ==
                                                                          'Makki Surah' || surah_type == 'Makki Surah (?)'
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
                                                                      fontSize: 13,
                                                                      fontFamily: 'varela-round.regular'),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        5.0),
                                                            child: Container(
                                                                width: 1,
                                                                height: 15,
                                                                color: const Color(
                                                                    0xffa69963)),
                                                          ),
                                                          Text(
                                                              '${verse_numbers[index]} verses',
                                                              style:
                                                                  const TextStyle(
                                                                      color: Color(
                                                                          0xffa69963),
                                                                      // fontWeight: FontWeight.bold,
                                                                      fontSize:
                                                                          13,
                                                                      fontFamily:
                                                                          'varela-round.regular'))
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 11.0),
                                        child: Text.rich(
                                            textDirection: TextDirection.rtl,
                                            TextSpan(children: [
                                              const TextSpan(
                                                text: '﴿  ',
                                                style: TextStyle(
                                                  wordSpacing: 3,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      'Al Majeed Quranic Font_shiped',
                                                  fontSize: 17,
                                                ),
                                              ),
                                              TextSpan(
                                                text:
                                                    '${surah_name_arabic[index]['translation']}',
                                                style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 17,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: 'Diwanltr'),
                                              ),
                                              const TextSpan(
                                                text: '  ﴾',
                                                style: TextStyle(
                                                  wordSpacing: 3,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      'Al Majeed Quranic Font_shiped',
                                                  fontSize: 17,
                                                ),
                                              ),
                                            ])),
                                      )
                                    ],
                                  ),
                                  const Divider(
                                    color: Color(0xffdad4b7),
                                  )
                                ]),
                          ),
                        );
                      }),
                )),
    );
  }
}
