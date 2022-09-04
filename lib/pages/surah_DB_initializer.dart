import 'package:flutter/material.dart';
import 'package:quran/classes/sql_queries.dart';
import 'package:sqflite/sqflite.dart';

import 'home.dart';

class SurahDBInitializer extends StatefulWidget {
  const SurahDBInitializer({Key? key}) : super(key: key);

  @override
  State<SurahDBInitializer> createState() => _SurahDBInitializerState();
}

class _SurahDBInitializerState extends State<SurahDBInitializer> {
  late Database database;
  late String path;

  SQLQueries sqlQueries = SQLQueries();

  prepareDB() async {
    sqlQueries.crazy1(await sqlQueries.crazy0()).whenComplete(() => Navigator.push(context, MaterialPageRoute(builder: (context)=>const Home())));
    // sqlQueries.test1(await sqlQueries.test0()).whenComplete(() async => sqlQueries.test11(await sqlQueries.test00()).whenComplete(() async => sqlQueries.test111(await sqlQueries.test000())));
    // sqlQueries.test11(await sqlQueries.test00());
    // sqlQueries.test111(await sqlQueries.test000());
    // sqlQueries.insertSurahNameData().whenComplete(() => sqlQueries.insertVersesData());
    // sqlQueries.insertLanguageData();
    // sqlQueries.insertSurahNameData();
    // sqlQueries.insertLanguageData().whenComplete(() => sqlQueries.insertSurahNameData()).whenComplete(() => sqlQueries.insertVersesData());
    // sqlQueries.insertSurahNameData();
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
