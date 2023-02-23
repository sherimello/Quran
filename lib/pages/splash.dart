import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:quran/pages/menu.dart';
import 'package:quran/pages/surah_DB_initializer.dart';
import 'package:quran/pages/surah_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  var bgColor = Colors.white;
  double eng = 14, ar = 14;

  initializeThemeStartersAndSizes() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.containsKey('english_font_size')) {
      eng = sharedPreferences.getDouble("english_font_size")!;
    }
    if (sharedPreferences.containsKey('arabic_font_size')) {
      ar = sharedPreferences.getDouble("arabic_font_size")!;
    }

    if (sharedPreferences.containsKey('theme mode')) {
      if (sharedPreferences.getString('theme mode') == "light") {
        bgColor = Colors.white;
      }
      if (sharedPreferences.getString('theme mode') == "dark") {
        bgColor = Colors.black;
      }
    }
  }

  whereToRedirect() async {
    var databasesPath = await getDatabasesPath();
    path = join(databasesPath, 'quran.db');

    bool databaseExists = await databaseFactory.databaseExists(path);
    databaseExists == true
        ? Timer(const Duration(seconds: 1), () {
            Navigator.of(this.context).push(MaterialPageRoute(
                builder: (context) => Menu(
                      eng: eng,
                      ar: ar,
                    )));
          })
        : Timer(const Duration(seconds: 1), () {
            Navigator.of(this.context).push(MaterialPageRoute(
                builder: (context) => const SurahDBInitializer()));
          });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initializeThemeStartersAndSizes();
    whereToRedirect();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: Image.asset(
          'lib/assets/images/quran icon.png',
          width: size.width * .51,
          height: size.width * .51,
        ),
      ),
    );
  }
}
