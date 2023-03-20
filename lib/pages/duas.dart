import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:quran/classes/Dua.dart';
import 'package:quran/pages/verse_image_preset.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../hero_transition_handler/custom_rect_tween.dart';
import '../hero_transition_handler/hero_dialog_route.dart';
import 'new_surah_page.dart';
import 'package:path/path.dart';

class Duas extends StatefulWidget {
  final String title;
  final double eng, ar;
  final Color theme;

  const Duas(
      {Key? key,
      required this.title,
      required this.eng,
      required this.ar,
      required this.theme})
      : super(key: key);

  @override
  State<Duas> createState() => _DuasState();
}

class _DuasState extends State<Duas> {
  List<String> arabic = [];
  List<String> english = [];
  List<String> pronunciation = [];
  List<String> recommendation = [];
  List<String> surah_num = [];
  List<String> verse_num = [];
  late Database database;

  addDuasToDB() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'quran.db');
    await deleteDatabase(path);
    database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute(
          'CREATE TABLE IF NOT EXISTS duas (arabic NVARCHAR, english NVARCHAR, pronunciation NVARCHAR, when NVARCHAR, surah_id INTEGER UNSIGNED, verse_id INTEGER UNSIGNED)');
    }).whenComplete(() async {
      await database.transaction((txn) async {
        for (int i = 0; i < arabic.length; i++) {
          await txn.rawInsert('INSERT INTO duas VALUES (?, ?, ?, ?, ?, ?)', [
            arabic[i],
            english[i],
            pronunciation[i],
            recommendation[i],
            surah_num[i],
            verse_num[i]
          ]);
        }
      });
    });
  }

  fetchDuasFromCloud() async {
    final snapshot = await FirebaseDatabase.instance.ref("quranic duas").get();
    final Map<dynamic, dynamic> map = snapshot.value as Map<dynamic, dynamic>;

    map.forEach((key, value) {
      final dua = Dua.fromMap(value);
      arabic.add(dua.arabic);
      english.add(dua.english);
      pronunciation.add(dua.pronunciation);
      recommendation.add(dua.recommendation);
      surah_num.add(dua.surah);
      verse_num.add(dua.verse);
    });
    setState(() {
      arabic = arabic;
      english = english;
      pronunciation = pronunciation;
      recommendation = recommendation;
      surah_num = surah_num;
      verse_num = verse_num;
    });
    addDuasToDB();
  }

  shouldCloudFetch() async {
    final snapshot = await FirebaseDatabase.instance.ref("quranic duas").get();
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getInt("duas") != snapshot.children.length) {
      fetchDuasFromCloud();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    shouldCloudFetch();
    // fetchDuasFromCloud();
  }

  @override
  Widget build(BuildContext context) {
    AppBar appBar = AppBar();
    var size = MediaQuery.of(context).size;

    return Container(
      width: size.width,
      height: size.height,
      color: widget.theme == Colors.black ? Colors.black : Colors.white,
      child: Material(
        color: Colors.transparent,
        child: SafeArea(
          child: Stack(children: [
            Container(
              color: widget.theme == Colors.black
                  ? Colors.black
                  : const Color(0xff1d3f5e),
              child: Row(
                children: [
                  Opacity(
                    opacity: .35,
                    child: Image.asset(
                      'lib/assets/images/headerDesignL.png',
                      width: size.width * .25,
                      height: appBar.preferredSize.height,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                  SizedBox(
                      width: size.width * .5,
                      height: AppBar().preferredSize.height,
                      child: Column(
                          // direction: Axis.vertical,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          // alignment: WrapAlignment.center,
                          children: [
                            Text(
                                textAlign: TextAlign.center,
                                "${arabic.length} du'as for you",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontFamily: 'varela-round.regular',
                                    fontSize: 13)),
                          ])),
                  Opacity(
                    opacity: .35,
                    child: Image.asset(
                      'lib/assets/images/headerDesignR.png',
                      width: size.width * .25,
                      height: appBar.preferredSize.height,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: appBar.preferredSize.height),
              child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: verse_num.isEmpty ? 0 : verse_num.length,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () async {
                        Navigator.of(context).push(HeroDialogRoute(
                          builder: (context) => Center(
                            child: VerseImagePreset(
                              tag: index.toString(),
                              verse_english: english[index],
                              verse_arabic: arabic[index],
                              verse_number: verse_num[index],
                              surah_name: "",
                              surah_number: surah_num[index],
                              theme: widget.theme,
                            ),
                          ),
                        ));
                        // await Clipboard.setData(const ClipboardData(text: "your text"));
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: index.isEven
                                ? widget.theme == Colors.black
                                    ? Colors.black
                                    : const Color(0xfff4f4ff)
                                : widget.theme == Colors.black
                                    ? const Color(0xff232323)
                                    : Colors.white),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Hero(
                                                tag: index.toString(),
                                                createRectTween: (begin, end) {
                                                  return CustomRectTween(
                                                      begin: begin!, end: end!);
                                                },
                                                child: Material(
                                                  color: Colors.transparent,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                    size.width *
                                                                        .07),
                                                        color: widget.theme ==
                                                                Colors.black
                                                            ? Colors.white
                                                                .withOpacity(
                                                                    .11)
                                                            : const Color(
                                                                    0xff1d3f5e)
                                                                .withOpacity(
                                                                    .11)),
                                                    child: Column(
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(9.0),
                                                          child: Text(
                                                            arabic[index],
                                                            // 'k',
                                                            textDirection:
                                                                TextDirection
                                                                    .rtl,
                                                            textAlign: TextAlign
                                                                .center,
                                                            textScaleFactor:
                                                                size.height /
                                                                    size.width,
                                                            style: TextStyle(
                                                              // wordSpacing: 2,
                                                              fontFamily:
                                                                  'Al Majeed Quranic Font_shiped',
                                                              fontSize:
                                                                  widget.ar,
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .fromLTRB(
                                                                  13.0,
                                                                  0,
                                                                  13.0,
                                                                  13.0),
                                                          child: Text(
                                                            pronunciation[
                                                                index],
                                                            // 'k',
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              // wordSpacing: 2,
                                                              fontStyle:
                                                                  FontStyle
                                                                      .italic,
                                                              fontFamily:
                                                                  'varela-round.regular',
                                                              fontSize:
                                                                  widget.eng,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ])),
                                    const SizedBox(
                                      height: 11,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 17.0),
                                      child: Text(
                                        english[index],
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontFamily: 'varela-round.regular',
                                            fontWeight: FontWeight.bold,
                                            fontSize: widget.eng),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 7,
                                    ),
                                    Text(
                                      verse_num[index] == "0"
                                          ? "[${surah_num[index]}]"
                                          : "[Qur'an ${surah_num[index]}:${verse_num[index]}]",
                                      // 'k',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        // wordSpacing: 2,
                                        fontStyle: FontStyle.italic,
                                        fontFamily: 'varela-round.regular',
                                        fontSize: widget.eng,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 11,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 17.0),
                                      child: Text.rich(
                                        TextSpan(children: [
                                          TextSpan(
                                            text: "when to read ?",
                                            style: TextStyle(
                                                color: widget.theme ==
                                                        Colors.black
                                                    ? Colors.white
                                                    : const Color(0xff1d3f5e),
                                                fontFamily:
                                                    'varela-round.regular',
                                                fontWeight: FontWeight.bold,
                                                fontSize: widget.eng + 5),
                                          )
                                        ]),
                                        textAlign: TextAlign.start,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 17.0, vertical: 5),
                                      child: Text(
                                        recommendation[index],
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            fontFamily: 'varela-round.regular',
                                            fontSize: widget.eng),
                                      ),
                                    ),
                                    Visibility(
                                      visible: verse_num[index] != "0",
                                      child: Align(
                                        alignment:
                                            AlignmentDirectional.centerEnd,
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 11.0,
                                                top: 11,
                                                left: 17,
                                                right: 17),
                                            child: GestureDetector(
                                              onTap: () async {
                                                // print((verses[index]['surah_id']).toString());
                                                // await fetchSurahSujoodVerses(index + 1);
                                                Navigator.of(this.context).push(
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            UpdatedSurahPage(
                                                              surah_id:
                                                                  (surah_num[
                                                                      index]),
                                                              scroll_to: int.parse(verse_num[
                                                                              index]
                                                                          .contains(
                                                                              "-")
                                                                      ? verse_num[index].substring(
                                                                          0,
                                                                          verse_num[index].indexOf(
                                                                              "-"))
                                                                      : verse_num[
                                                                          index]) -
                                                                  1,
                                                              should_animate:
                                                                  true,
                                                              eng: widget.eng,
                                                              ar: widget.ar,
                                                            )));
                                              },
                                              child: Container(
                                                  decoration: BoxDecoration(
                                                    color:
                                                        const Color(0xff1d3f5e),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            1000),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: const Color(
                                                                0xff1d3f5e)
                                                            .withOpacity(0.15),
                                                        spreadRadius: 3,
                                                        blurRadius: 19,
                                                        offset: const Offset(0,
                                                            0), // changes position of shadow
                                                      ),
                                                    ],
                                                  ),
                                                  child: const Center(
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 11.0,
                                                              vertical: 7),
                                                      child: Center(
                                                        child: Text.rich(
                                                          // textAlign: TextAlign.center,
                                                          TextSpan(children: [
                                                            TextSpan(
                                                                text:
                                                                    "show in surah",
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontFamily:
                                                                        'varela-round.regular',
                                                                    fontSize:
                                                                        12,
                                                                    color: Colors
                                                                        .white)),
                                                            WidgetSpan(
                                                                alignment:
                                                                    PlaceholderAlignment
                                                                        .middle,
                                                                child: Padding(
                                                                  padding: EdgeInsets
                                                                      .only(
                                                                          left:
                                                                              7.0),
                                                                  child: Icon(
                                                                    Icons
                                                                        .open_in_new,
                                                                    color: Colors
                                                                        .white,
                                                                    size: 19,
                                                                  ),
                                                                ))
                                                          ]),
                                                        ),
                                                      ),
                                                    ),
                                                  )),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
            ),
          ]),
        ),
      ),
    );
  }
}
