import 'package:flutter/material.dart';
import 'package:quran/classes/sql_queries.dart';
import 'package:quran/pages/surah_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import 'home.dart';
import 'menu.dart';

class SurahDBInitializer extends StatefulWidget {
  const SurahDBInitializer({
    Key? key,
  }) : super(key: key);

  @override
  State<SurahDBInitializer> createState() => _SurahDBInitializerState();
}

class _SurahDBInitializerState extends State<SurahDBInitializer> {
  late Database database;
  late String path;

  SQLQueries sqlQueries = SQLQueries();

  prepareDB() async {
    await saveFontSizes();
    Database db = await sqlQueries.crazy0();
    await sqlQueries.crazy1(db).whenComplete(() => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Menu(
                  eng: 14.0,
                  ar: 12.0,
                ))));
  }

  saveFontSizes() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setDouble("english_font_size", 17);
    sharedPreferences.setDouble("arabic_font_size", 19);
    sharedPreferences.setDouble("scroll_offset_for_surah_list", 0.0);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    prepareDB();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'lib/assets/images/load.gif',
              width: size.width * .55,
              height: size.width * .55,
            ),
            SizedBox(
              height: size.width * .11,
            ),
            const Text(
              'Preparing Data...',
              style: TextStyle(
                  fontSize: 27,
                  fontFamily: 'varela-round.regular',
                  fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
    );
  }
}
