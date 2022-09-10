import 'dart:async';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:quran/pages/surah_DB_initializer.dart';
import 'package:quran/pages/surah_list.dart';
import 'package:sqflite/sqflite.dart';

import 'home.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  late Database database;
  late String path;

  whereToRedirect() async {
    var databasesPath = await getDatabasesPath();
    path = join(databasesPath, 'quran.db');

    bool databaseExists = await databaseFactory.databaseExists(path);
    databaseExists == true
        ? Timer(const Duration(seconds: 1), () {
            Navigator.of(this.context).push(
                MaterialPageRoute(builder: (context) => const SurahList()));
          })
        : Timer(const Duration(seconds: 1), () {
            Navigator.of(this.context)
                .push(MaterialPageRoute(builder: (context) => const SurahDBInitializer()));
          });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    whereToRedirect();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          width: size.width * .51,
          height: size.width * .51,
          color: Colors.white,
          child: Image.asset(
            'lib/assets/images/quran icon.png',
          ),
        ),
      ),
    );
  }
}
