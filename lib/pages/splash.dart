import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:quran/classes/test_class.dart';
import 'package:quran/pages/menu.dart';
import 'package:quran/pages/surah_DB_initializer.dart';
import 'package:quran/pages/surah_list.dart';
import 'package:quran/pages/testing_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../classes/db_helper.dart';
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
  late Database db_en_tafsir,
      db_bn,
      db_transliteration,
      db_bn_tafsir,
      db_words_translations,
      db_en_ar_quran;
  List<Map<String, dynamic>> _verses = [],
      _translated_verse = [],
      _en_tafsir = [],
      _bn_verses = [],
      _transliteration = [],
      _bn_tafsir = [],
      _surah_name_arabic = [],
      _surah_name_english = [],
      _sujood_surah_indices = [],
      _sujood_verse_indices = [],
      _words_translations = [];

  Future<void> fetchData() async {
    _en_tafsir = [...await db_en_tafsir.rawQuery("SELECT * FROM verses")];
    _bn_tafsir = [...await db_bn_tafsir.rawQuery("SELECT * FROM verses")];
    _verses = [
      ...await db_en_ar_quran
          .rawQuery("SELECT * FROM verses WHERE lang_id = 1")
    ];
    _translated_verse = [
      ...await db_en_ar_quran
          .rawQuery("SELECT * FROM verses WHERE lang_id = 2")
    ];
    _bn_verses = [...await db_bn.rawQuery("SELECT * FROM verses")];
    _transliteration = [
      ...await db_transliteration.rawQuery("SELECT * FROM verses")
    ];
    _words_translations = [
      ...await db_words_translations.rawQuery("SELECT * FROM words")
    ];
    _surah_name_arabic = [
      ...await db_en_ar_quran
          .rawQuery("SELECT * FROM surahnames WHERE lang_id = 1")
    ];
    _surah_name_english = [
      ...await db_en_ar_quran
          .rawQuery("SELECT * FROM surahnames WHERE lang_id = 2")
    ];
    _sujood_verse_indices = [
      ...await db_en_ar_quran.rawQuery("SELECT verse_id FROM sujood_verses")
    ];
    _sujood_surah_indices = [
      ...await db_en_ar_quran.rawQuery("SELECT surah_id FROM sujood_verses")
    ];
    setState(() {
      _verses = _verses;
      _translated_verse = _translated_verse;
      _words_translations = _words_translations;
      _transliteration = _transliteration;
      _bn_tafsir = _bn_tafsir;
      _bn_verses = _bn_verses;
      _en_tafsir = _en_tafsir;
      _surah_name_english = _surah_name_english;
      _surah_name_arabic = _surah_name_arabic;
      _sujood_verse_indices = _sujood_verse_indices;
      _sujood_surah_indices = _sujood_surah_indices;
    });
  }

  Future<void> initOtherDBs() async {
    DatabaseHelper databaseHelper = DatabaseHelper.instance;
    db_transliteration =
        await databaseHelper.initDatabase("en_transliteration.db");
    db_en_tafsir = await databaseHelper.initDatabase("en_jalalayn.db");
    db_bn_tafsir = await databaseHelper.initDatabase("bn_tafsirbayaan.db");
    db_bn = await databaseHelper.initDatabase("bn_bayaan.db");
    db_words_translations =
        await databaseHelper.initDatabase("words_translations.db");
    db_en_ar_quran = await databaseHelper.initDatabase("en_ar_quran.db");

    await fetchData();

    TestClass testClass = TestClass(
        _verses,
        _translated_verse,
        _en_tafsir,
        _bn_verses,
        _transliteration,
        _bn_tafsir,
        _words_translations,
        _surah_name_arabic,
        _surah_name_english,
        _sujood_surah_indices,
        _sujood_verse_indices);

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String jsonString = json.encode(testClass.toJson());
    await prefs.setString('testClass', jsonString);
    fetchData().whenComplete(() => Navigator.push(
        this.context,
        MaterialPageRoute(
            builder: (builder) => Menu(
                  eng: eng,
                  ar: ar,
                ))));
  }

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
    path = join(databasesPath, 'en_ar_quran.db');

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
            Navigator.of(this.context).push(
                MaterialPageRoute(builder: (context) => SurahDBInitializer()));
          });
  }

  init() async {
    await initializeThemeStartersAndSizes();
    await initOtherDBs();

    // whereToRedirect();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init();
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
