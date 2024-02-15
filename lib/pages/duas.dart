// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:quran/classes/Dua.dart';
// import 'package:quran/pages/verse_image_preset.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:sqflite/sqflite.dart';
//
// import '../hero_transition_handler/custom_rect_tween.dart';
// import '../hero_transition_handler/hero_dialog_route.dart';
// import 'new_surah_page.dart';
// import 'package:path/path.dart';
//
// class Duas extends StatefulWidget {
//   final String title;
//   final double eng, ar;
//   final Color theme;
//
//   const Duas(
//       {Key? key,
//       required this.title,
//       required this.eng,
//       required this.ar,
//       required this.theme})
//       : super(key: key);
//
//   @override
//   State<Duas> createState() => _DuasState();
// }
//
// class _DuasState extends State<Duas> {
//   List<String> arabic = [];
//   List<String> english = [];
//   List<String> pronunciation = [];
//   List<String> recommendation = [];
//   List<String> surah_num = [];
//   List<String> verse_num = [];
//   List<Map> duas = [];
//   late Database database;
//   late String path;
//   bool noNetworkFlag = false;
//
//   Future<bool> isInternetAvailable() async {
//     final connectivityResult = await (Connectivity().checkConnectivity());
//     if (connectivityResult == ConnectivityResult.mobile) {
//       return true;
//       // I am connected to a mobile network.
//     } else if (connectivityResult == ConnectivityResult.wifi) {
//       return true;
//       // I am connected to a wifi network.
//     }
//     return false;
//   }
//
//   addDuasToDB() async {
//     var databasesPath = await getDatabasesPath();
//     path = join(databasesPath, 'duas.db');
//     // await deleteDatabase(path);
//     database = await openDatabase(path, version: 22,
//         onCreate: (Database db, int version) async {
//       await db.execute(
//           'CREATE TABLE IF NOT EXISTS supplications (arabic NVARCHAR, english NVARCHAR, pronunciation NVARCHAR, recommendation NVARCHAR, surah_id NVARCHAR, verse_id NVARCHAR)');
//     }).whenComplete(() async {
//       await database.transaction((txn) async {
//         for (int i = 0; i < arabic.length; i++) {
//           await txn.rawInsert(
//               'INSERT INTO supplications VALUES (?, ?, ?, ?, ?, ?)', [
//             arabic[i],
//             english[i],
//             pronunciation[i],
//             recommendation[i],
//             surah_num[i],
//             verse_num[i]
//           ]);
//         }
//       });
//     });
//   }
//
//   fetchDuasFromCloud() async {
//     final snapshot = await FirebaseDatabase.instance.ref("quranic duas").get();
//     final Map<dynamic, dynamic> map = snapshot.value as Map<dynamic, dynamic>;
//
//     await database.transaction((txn) async {
//       map.forEach((key, value) async {
//         final dua = Dua.fromMap(value);
//
//         await txn.rawInsert('INSERT INTO duas VALUES (?, ?, ?, ?, ?, ?)', [
//           dua.arabic,
//           dua.english,
//           dua.pronunciation,
//           dua.recommendation,
//           dua.surah,
//           dua.verse
//         ]);
//       });
//     }).whenComplete(() async {
//       duas = await database.rawQuery('SELECT * FROM duas');
//       setState(() {
//         duas = duas;
//       });
//     });
//
//     SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
//     print("total duas: ${duas.length}");
//     sharedPreferences.setInt("duas", duas.length);
//   }
//
//   shouldCloudFetch() async {
//     final snapshot = await FirebaseDatabase.instance.ref("quranic duas").get();
//     SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
//     if (sharedPreferences.getInt("duas") != snapshot.children.length) {
//       print("object innnnnnnnn");
//       await database.rawDelete("DELETE FROM duas").whenComplete(() => fetchDuasFromCloud());
//       // fetchDuasFromCloud();
//     }
//   }
//
//   Future<void> initiateDB() async {
//     var databasesPath = await getDatabasesPath();
//     path = join(databasesPath, 'duas.db');
//     database = await openDatabase(path, version: 1,
//         onCreate: (Database db, int version) async {
//       await db.execute(
//           'CREATE TABLE IF NOT EXISTS duas (arabic NVARCHAR, english NVARCHAR, pronunciation NVARCHAR, recommendation NVARCHAR, surah_id NVARCHAR, verse_id NVARCHAR)');
//     });
//   }
//
//   Future<void> getDuasFromDB() async {
//     duas = await database.rawQuery('SELECT * FROM duas');
//     initializeDuaFetchLogics();
//   }
//
//   initializeDuaFetchLogics() async {
//     if (await isInternetAvailable()) {
//       setState(() => noNetworkFlag = false);
//       shouldCloudFetch();
//     } else {
//       if (duas.isEmpty) setState(() => noNetworkFlag = true);
//     }
//   }
//
//   init() async {
//     await initiateDB().whenComplete(() {
//       getDuasFromDB();
//     });
//   }
//
//   void changeStatusBarColor(int colorCode) {
//     setState(() {
//       SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
//           statusBarColor: Color(colorCode)
//       ));
//     });
//   }
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     changeStatusBarColor(widget.theme == Colors.black ? 0xff000000 : 0xff1d3f5e);
//     init();
//     // initializeDuaFetchLogics();
//     // shouldCloudFetch();
//     // fetchDuasFromCloud();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     AppBar appBar = AppBar();
//     var size = MediaQuery.of(context).size;
//
//     return Container(
//       width: size.width,
//       height: size.height,
//       color: widget.theme == Colors.black ? Colors.black : Colors.white,
//       child: Material(
//         color: Colors.transparent,
//         child: SafeArea(
//           child: Stack(children: [
//             const Center(
//               child: CircularProgressIndicator(
//                 color: Color(0xff1d3f5e),
//               ),
//             ),
//             Visibility(
//               visible: noNetworkFlag,
//               child: Container(
//                 width: double.infinity,
//                 height: double.infinity,
//                 color: widget.theme == Colors.black ? Colors.black : Colors.white,
//                 child: Center(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     mainAxisSize: MainAxisSize.max,
//                     children: [
//                       Opacity(
//                           opacity: .35,
//                           child: Image.asset(
//                             "lib/assets/images/noNetwork.gif",
//                             width: size.width * .35,
//                           )),
//                       Padding(
//                         padding: const EdgeInsets.all(19.0),
//                         child: Text(
//                           "need a stable network connection for the first fetch...",
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                               color: widget.theme == Colors.black ? Colors.white.withOpacity(.75) : Colors.black.withOpacity(.35),
//                               fontSize: size.width * .045,
//                               fontWeight: FontWeight.bold,
//                               fontFamily: "varela-round.regular"),
//                         ),
//                       )
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             Container(
//               color: widget.theme == Colors.black
//                   ? Colors.black
//                   : const Color(0xff1d3f5e),
//               child: Row(
//                 children: [
//                   Opacity(
//                     opacity: .35,
//                     child: Image.asset(
//                       'lib/assets/images/headerDesignL.png',
//                       width: size.width * .25,
//                       height: appBar.preferredSize.height,
//                       fit: BoxFit.fitWidth,
//                     ),
//                   ),
//                   SizedBox(
//                       width: size.width * .5,
//                       height: AppBar().preferredSize.height,
//                       child: Column(
//                           // direction: Axis.vertical,
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           // alignment: WrapAlignment.center,
//                           children: [
//                             Text(
//                                 textAlign: TextAlign.center,
//                                 "supplications (${duas.length})",
//                                 // "${duas.length} du'as for you",
//                                 style: TextStyle(
//                                   height: 0,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.white,
//                                     fontFamily: 'varela-round.regular',
//                                     fontSize: size.width * .051)),
//                           ])),
//                   Opacity(
//                     opacity: .35,
//                     child: Image.asset(
//                       'lib/assets/images/headerDesignR.png',
//                       width: size.width * .25,
//                       height: appBar.preferredSize.height,
//                       fit: BoxFit.fitWidth,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Padding(
//               padding: EdgeInsets.only(top: appBar.preferredSize.height),
//               child: ListView.builder(
//                   physics: const BouncingScrollPhysics(),
//                   itemCount: duas.isEmpty ? 0 : duas.length,
//                   itemBuilder: (BuildContext context, int index) {
//                     return GestureDetector(
//                       onTap: () async {
//                         Navigator.of(context).push(HeroDialogRoute(
//                           builder: (context) => Center(
//                             child: VerseImagePreset(
//                               tag: index.toString(),
//                               verse_english: duas[index]['english'],
//                               verse_arabic: duas[index]['arabic'],
//                               verse_number: duas[index]['verse_id'],
//                               surah_name: "",
//                               surah_number: duas[index]['surah_id'],
//                               theme: widget.theme,
//                             ),
//                           ),
//                         ));
//                         // await Clipboard.setData(const ClipboardData(text: "your text"));
//                       },
//                       child: Container(
//                         decoration: BoxDecoration(
//                             color: index.isEven
//                                 ? widget.theme == Colors.black
//                                     ? Colors.black
//                                     : const Color(0xfff4f4ff)
//                                 : widget.theme == Colors.black
//                                     ? const Color(0xff232323)
//                                     : Colors.white),
//                         child: Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Row(
//                             crossAxisAlignment: CrossAxisAlignment.center,
//                             children: [
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment:
//                                       CrossAxisAlignment.stretch,
//                                   children: [
//                                     Padding(
//                                         padding: const EdgeInsets.all(8.0),
//                                         child: Column(
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.center,
//                                             children: [
//                                               Hero(
//                                                 tag: index.toString(),
//                                                 createRectTween: (begin, end) {
//                                                   return CustomRectTween(
//                                                       begin: begin!, end: end!);
//                                                 },
//                                                 child: Material(
//                                                   color: Colors.transparent,
//                                                   child: Container(
//                                                     decoration: BoxDecoration(
//                                                         borderRadius:
//                                                             BorderRadius
//                                                                 .circular(
//                                                                     size.width *
//                                                                         .07),
//                                                         color: widget.theme ==
//                                                                 Colors.black
//                                                             ? Colors.white
//                                                                 .withOpacity(
//                                                                     .11)
//                                                             : const Color(
//                                                                     0xff1d3f5e)
//                                                                 .withOpacity(
//                                                                     .11)),
//                                                     child: Column(
//                                                       children: [
//                                                         Padding(
//                                                           padding:
//                                                               const EdgeInsets
//                                                                   .all(9.0),
//                                                           child: Text(
//                                                             duas[index]
//                                                                 ['arabic'],
//                                                             // 'k',
//                                                             textDirection:
//                                                                 TextDirection
//                                                                     .rtl,
//                                                             textAlign: TextAlign
//                                                                 .center,
//                                                             textScaleFactor:
//                                                                 size.height /
//                                                                     size.width,
//                                                             style: TextStyle(
//                                                               color: widget.theme == Colors.black ? Colors.white : Colors.black,
//                                                               // wordSpacing: 2,
//                                                               fontFamily:
//                                                                   'Al Majeed Quranic Font_shiped',
//                                                               fontSize:
//                                                                   widget.ar,
//                                                             ),
//                                                           ),
//                                                         ),
//                                                         Padding(
//                                                           padding:
//                                                               const EdgeInsets
//                                                                       .fromLTRB(
//                                                                   13.0,
//                                                                   0,
//                                                                   13.0,
//                                                                   13.0),
//                                                           child: Text(
//                                                             duas[index][
//                                                                 'pronunciation'],
//                                                             // 'k',
//                                                             textAlign: TextAlign
//                                                                 .center,
//                                                             style: TextStyle(
//                                                               color: widget.theme == Colors.black ? Colors.white : Colors.black,
//                                                               // wordSpacing: 2,
//                                                               fontStyle:
//                                                                   FontStyle
//                                                                       .italic,
//                                                               fontFamily:
//                                                                   'varela-round.regular',
//                                                               fontSize:
//                                                                   widget.eng,
//                                                             ),
//                                                           ),
//                                                         ),
//                                                       ],
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ),
//                                             ])),
//                                     const SizedBox(
//                                       height: 11,
//                                     ),
//                                     Padding(
//                                       padding: const EdgeInsets.symmetric(
//                                           horizontal: 17.0),
//                                       child: Text(
//                                         duas[index]['english'],
//                                         textAlign: TextAlign.center,
//                                         style: TextStyle(
//                                             color: widget.theme == Colors.black ? Colors.white : Colors.black,
//                                             fontFamily: 'varela-round.regular',
//                                             fontWeight: FontWeight.bold,
//                                             fontSize: widget.eng),
//                                       ),
//                                     ),
//                                     const SizedBox(
//                                       height: 7,
//                                     ),
//                                     Text(
//                                       duas[index]['verse_id'] == "0"
//                                           ? "[${duas[index]['surah_id']}]"
//                                           : "[Qur'an ${duas[index]['surah_id']}:${duas[index]['verse_id']}]",
//                                       // 'k',
//                                       textAlign: TextAlign.center,
//                                       style: TextStyle(
//                                         color: widget.theme == Colors.black ? Colors.white : Colors.black,
//                                         // wordSpacing: 2,
//                                         fontStyle: FontStyle.italic,
//                                         fontFamily: 'varela-round.regular',
//                                         fontSize: widget.eng,
//                                       ),
//                                     ),
//                                     const SizedBox(
//                                       height: 11,
//                                     ),
//                                     Padding(
//                                       padding: const EdgeInsets.symmetric(
//                                           horizontal: 17.0),
//                                       child: Text.rich(
//                                         TextSpan(children: [
//                                           TextSpan(
//                                             text: "when to read ?",
//                                             style: TextStyle(
//                                                 color: widget.theme ==
//                                                         Colors.black
//                                                     ? Colors.white
//                                                     : const Color(0xff1d3f5e),
//                                                 fontFamily:
//                                                     'varela-round.regular',
//                                                 fontWeight: FontWeight.bold,
//                                                 fontSize: widget.eng + 5),
//                                           )
//                                         ]),
//                                         textAlign: TextAlign.start,
//                                       ),
//                                     ),
//                                     Padding(
//                                       padding: const EdgeInsets.symmetric(
//                                           horizontal: 17.0, vertical: 5),
//                                       child: Text(
//                                         duas[index]['recommendation'],
//                                         textAlign: TextAlign.start,
//                                         style: TextStyle(
//                                             color: widget.theme == Colors.black ? Colors.white : Colors.black,
//                                             fontFamily: 'varela-round.regular',
//                                             fontSize: widget.eng),
//                                       ),
//                                     ),
//                                     Visibility(
//                                       visible: duas[index]['verse_id'] != "0",
//                                       child: Align(
//                                         alignment:
//                                             AlignmentDirectional.centerEnd,
//                                         child: SingleChildScrollView(
//                                           scrollDirection: Axis.horizontal,
//                                           child: Padding(
//                                             padding: const EdgeInsets.only(
//                                                 bottom: 11.0,
//                                                 top: 11,
//                                                 left: 17,
//                                                 right: 17),
//                                             child: GestureDetector(
//                                               onTap: () async {
//                                                 // print((verses[index]['surah_id']).toString());
//                                                 // await fetchSurahSujoodVerses(index + 1);
//                                                 Navigator.of(this.context).push(
//                                                     MaterialPageRoute(
//                                                         builder: (context) =>
//                                                             UpdatedSurahPage(
//                                                               surah_id: (duas[
//                                                                       index]
//                                                                   ['surah_id']),
//                                                               scroll_to: int.parse(duas[index]
//                                                                               [
//                                                                               'verse_id']
//                                                                           .contains(
//                                                                               "-")
//                                                                       ? duas[index]
//                                                                               [
//                                                                               'verse_id']
//                                                                           .substring(
//                                                                               0,
//                                                                               duas[index]['verse_id'].indexOf(
//                                                                                   "-"))
//                                                                       : duas[index]
//                                                                           [
//                                                                           'verse_id']) -
//                                                                   1,
//                                                               should_animate:
//                                                                   true,
//                                                               eng: widget.eng,
//                                                               ar: widget.ar,
//                                                             )));
//                                               },
//                                               child: Container(
//                                                   decoration: BoxDecoration(
//                                                     color:
//                                                         const Color(0xff1d3f5e),
//                                                     borderRadius:
//                                                         BorderRadius.circular(
//                                                             1000),
//                                                     boxShadow: [
//                                                       BoxShadow(
//                                                         color: const Color(
//                                                                 0xff1d3f5e)
//                                                             .withOpacity(0.15),
//                                                         spreadRadius: 3,
//                                                         blurRadius: 19,
//                                                         offset: const Offset(0,
//                                                             0), // changes position of shadow
//                                                       ),
//                                                     ],
//                                                   ),
//                                                   child: const Center(
//                                                     child: Padding(
//                                                       padding:
//                                                           EdgeInsets.symmetric(
//                                                               horizontal: 11.0,
//                                                               vertical: 7),
//                                                       child: Center(
//                                                         child: Text.rich(
//                                                           // textAlign: TextAlign.center,
//                                                           TextSpan(children: [
//                                                             TextSpan(
//                                                                 text:
//                                                                     "show in surah",
//                                                                 style: TextStyle(
//                                                                     fontWeight:
//                                                                         FontWeight
//                                                                             .bold,
//                                                                     fontFamily:
//                                                                         'varela-round.regular',
//                                                                     fontSize:
//                                                                         12,
//                                                                     color: Colors
//                                                                         .white)),
//                                                             WidgetSpan(
//                                                                 alignment:
//                                                                     PlaceholderAlignment
//                                                                         .middle,
//                                                                 child: Padding(
//                                                                   padding: EdgeInsets
//                                                                       .only(
//                                                                           left:
//                                                                               7.0),
//                                                                   child: Icon(
//                                                                     Icons
//                                                                         .open_in_new,
//                                                                     color: Colors
//                                                                         .white,
//                                                                     size: 19,
//                                                                   ),
//                                                                 ))
//                                                           ]),
//                                                         ),
//                                                       ),
//                                                     ),
//                                                   )),
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                     const SizedBox(
//                                       height: 8,
//                                     ),
//                                   ],
//                                 ),
//                               )
//                             ],
//                           ),
//                         ),
//                       ),
//                     );
//                   }),
//             ),
//           ]),
//         ),
//       ),
//     );
//   }
// }

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  const Duas({
    Key? key,
    required this.title,
    required this.eng,
    required this.ar,
    required this.theme,
  }) : super(key: key);

  @override
  State<Duas> createState() => _DuasState();
}

class _DuasState extends State<Duas> {
  List<Map> duas = [];
  late Database database;
  late String path;
  bool noNetworkFlag = false;

  Future<bool> isInternetAvailable() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi;
  }

  addDuasToDB(List<Dua> duas) async {
    var databasesPath = await getDatabasesPath();
    path = join(databasesPath, 'duas.db');
    database = await openDatabase(path, version: 22,
        onCreate: (Database db, int version) async {
      await db.execute(
          'CREATE TABLE IF NOT EXISTS supplications (arabic NVARCHAR, english NVARCHAR, pronunciation NVARCHAR, recommendation NVARCHAR, surah_id NVARCHAR, verse_id NVARCHAR)');
    }).whenComplete(() async {
      await database.transaction((txn) async {
        for (int i = 0; i < duas.length; i++) {
          await txn.rawInsert(
              'INSERT INTO supplications VALUES (?, ?, ?, ?, ?, ?)', [
            duas[i].arabic,
            duas[i].english,
            duas[i].pronunciation,
            duas[i].recommendation,
            duas[i].surah,
            duas[i].verse
          ]);
        }
      });
    });
  }

  fetchDuasFromCloud() async {
    final snapshot = await FirebaseDatabase.instance.ref("quranic duas").get();
    final Map<dynamic, dynamic> map = snapshot.value as Map<dynamic, dynamic>;

    await database.transaction((txn) async {
      map.forEach((key, value) async {
        final dua = Dua.fromMap(value);

        await txn.rawInsert('INSERT INTO duas VALUES (?, ?, ?, ?, ?, ?)', [
          dua.arabic,
          dua.english,
          dua.pronunciation,
          dua.recommendation,
          dua.surah,
          dua.verse
        ]);
      });
    }).whenComplete(() async {
      duas = await database.rawQuery('SELECT * FROM duas');
      setState(() {
        duas = duas;
      });
    });

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setInt("duas", duas.length);
  }

  shouldCloudFetch() async {
    final snapshot = await FirebaseDatabase.instance.ref("quranic duas").get();
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getInt("duas") != snapshot.children.length) {
      await database
          .rawDelete("DELETE FROM duas")
          .whenComplete(() => fetchDuasFromCloud());
    }
  }

  Future<void> initiateDB() async {
    var databasesPath = await getDatabasesPath();
    path = join(databasesPath, 'duas.db');
    database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute(
          'CREATE TABLE IF NOT EXISTS duas (arabic NVARCHAR, english NVARCHAR, pronunciation NVARCHAR, recommendation NVARCHAR, surah_id NVARCHAR, verse_id NVARCHAR)');
    });
  }

  Future<void> getDuasFromDB() async {
    duas = await database.rawQuery('SELECT * FROM duas');
    initializeDuaFetchLogics();
  }

  initializeDuaFetchLogics() async {
    if (await isInternetAvailable()) {
      setState(() => noNetworkFlag = false);
      shouldCloudFetch();
    } else {
      if (duas.isEmpty) setState(() => noNetworkFlag = true);
    }
  }

  init() async {
    await initiateDB().whenComplete(() {
      getDuasFromDB().whenComplete(() => setState(() => duas = duas.reversed.toList()));
    });
  }

  void changeStatusBarColor(int colorCode) {
    setState(() {
      SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(statusBarColor: Color(colorCode)));
    });
  }

  @override
  void initState() {
    super.initState();
    changeStatusBarColor(
        widget.theme == Colors.black ? 0xff000000 : 0xff1d3f5e);
    init().whenComplete(() => setState(() => duas = duas.reversed.toList()));
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    database.close();
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
            const Center(
              child: CircularProgressIndicator(
                color: Color(0xff1d3f5e),
              ),
            ),
            Visibility(
              visible: noNetworkFlag,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color:
                    widget.theme == Colors.black ? Colors.black : Colors.white,
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Opacity(
                          opacity: .35,
                          child: Image.asset(
                            "lib/assets/images/noNetwork.gif",
                            width: size.width * .35,
                          )),
                      Padding(
                        padding: const EdgeInsets.all(19.0),
                        child: Text(
                          "need a stable network connection for the first fetch...",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: widget.theme == Colors.black
                                  ? Colors.white.withOpacity(.75)
                                  : Colors.black.withOpacity(.35),
                              fontSize: size.width * .045,
                              fontWeight: FontWeight.bold,
                              fontFamily: "varela-round.regular"),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "supplications (${duas.length})",
                          style: TextStyle(
                            height: 0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'varela-round.regular',
                            fontSize: size.width * .051,
                          ),
                        ),
                      ],
                    ),
                  ),
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
                itemCount: duas.isEmpty ? 0 : duas.length,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () async {
                      Navigator.of(context).push(HeroDialogRoute(
                        builder: (context) => Center(
                          child: VerseImagePreset(
                            tag: index.toString(),
                            verse_english: duas[index]['english'],
                            verse_arabic: duas[index]['arabic'],
                            verse_number: duas[index]['verse_id'],
                            surah_name: "",
                            surah_number: duas[index]['surah_id'],
                            theme: widget.theme,
                          ),
                        ),
                      ));
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: index.isEven
                            ? widget.theme == Colors.black
                                ? Colors.black
                                : const Color(0xfff4f4ff)
                            : widget.theme == Colors.black
                                ? const Color(0xff232323)
                                : Colors.white,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
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
                                                    BorderRadius.circular(
                                                        size.width * .07),
                                                color: widget.theme ==
                                                        Colors.black
                                                    ? Colors.white
                                                        .withOpacity(.11)
                                                    : const Color(0xff1d3f5e)
                                                        .withOpacity(.11),
                                              ),
                                              child: Column(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            9.0),
                                                    child: Text(
                                                      duas[index]['arabic'],
                                                      textDirection:
                                                          TextDirection.rtl,
                                                      textAlign:
                                                          TextAlign.center,
                                                      textScaleFactor:
                                                          size.height /
                                                              size.width,
                                                      style: TextStyle(
                                                        color: widget.theme ==
                                                                Colors.black
                                                            ? Colors.white
                                                            : Colors.black,
                                                        fontFamily:
                                                            'Al Majeed Quranic Font_shiped',
                                                        fontSize: widget.ar,
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(
                                                        13.0, 0, 13.0, 13.0),
                                                    child: Text(
                                                      duas[index]
                                                          ['pronunciation'],
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        color: widget.theme ==
                                                                Colors.black
                                                            ? Colors.white
                                                            : Colors.black,
                                                        fontStyle:
                                                            FontStyle.italic,
                                                        fontFamily:
                                                            'varela-round.regular',
                                                        fontSize: widget.eng,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 11,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 17.0),
                                    child: Text(
                                      duas[index]['english'],
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: widget.theme == Colors.black
                                            ? Colors.white
                                            : Colors.black,
                                        fontFamily: 'varela-round.regular',
                                        fontWeight: FontWeight.bold,
                                        fontSize: widget.eng,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 7,
                                  ),
                                  Text(
                                    duas[index]['verse_id'] == "0"
                                        ? "[${duas[index]['surah_id']}]"
                                        : "[Qur'an ${duas[index]['surah_id']}:${duas[index]['verse_id']}]",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: widget.theme == Colors.black
                                          ? Colors.white
                                          : Colors.black,
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
                                            color: widget.theme == Colors.black
                                                ? Colors.white
                                                : const Color(0xff1d3f5e),
                                            fontFamily: 'varela-round.regular',
                                            fontWeight: FontWeight.bold,
                                            fontSize: widget.eng + 5,
                                          ),
                                        )
                                      ]),
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 17.0, vertical: 5),
                                    child: Text(
                                      duas[index]['recommendation'],
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                        color: widget.theme == Colors.black
                                            ? Colors.white
                                            : Colors.black,
                                        fontFamily: 'varela-round.regular',
                                        fontSize: widget.eng,
                                      ),
                                    ),
                                  ),
                                  Visibility(
                                    visible: duas[index]['verse_id'] != "0",
                                    child: Align(
                                      alignment: AlignmentDirectional.centerEnd,
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
                                              Navigator.of(this.context).push(
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      UpdatedSurahPage(
                                                    surah_id: (duas[index]
                                                        ['surah_id']),
                                                    scroll_to: int.parse(duas[
                                                                        index]
                                                                    ['verse_id']
                                                                .contains("-")
                                                            ? duas[index]
                                                                    ['verse_id']
                                                                .substring(
                                                                    0,
                                                                    duas[index][
                                                                            'verse_id']
                                                                        .indexOf(
                                                                            "-"))
                                                            : duas[index]
                                                                ['verse_id']) -
                                                        1,
                                                    should_animate: true,
                                                    eng: widget.eng,
                                                    ar: widget.ar,
                                                    bgColor: widget.theme,
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: const Color(0xff1d3f5e),
                                                borderRadius:
                                                    BorderRadius.circular(1000),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color:
                                                        const Color(0xff1d3f5e)
                                                            .withOpacity(0.15),
                                                    spreadRadius: 3,
                                                    blurRadius: 19,
                                                    offset: const Offset(0, 0),
                                                  ),
                                                ],
                                              ),
                                              child: const Center(
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 11.0,
                                                      vertical: 7),
                                                  child: Center(
                                                    child: Text.rich(
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
                                                                fontSize: 12,
                                                                color: Colors
                                                                    .white)),
                                                        WidgetSpan(
                                                          alignment:
                                                              PlaceholderAlignment
                                                                  .middle,
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    left: 7.0),
                                                            child: Icon(
                                                              Icons.open_in_new,
                                                              color:
                                                                  Colors.white,
                                                              size: 19,
                                                            ),
                                                          ),
                                                        ),
                                                      ]),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
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
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
