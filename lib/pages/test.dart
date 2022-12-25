import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:arabic_numbers/arabic_numbers.dart';

import '../Theme Swtitcher Clipper Bridge/theme_model_inherited_notifier.dart';
import '../Theme Swtitcher Clipper Bridge/theme_switcher_clipper_bridge.dart';


class Test extends StatefulWidget {
  const Test({Key? key}) : super(key: key);

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {

  late List<Map> verses = [], v = [], translated_verse = [], tv = [];
  late Database database;
  late String path;
  int len = 0, flag = 0;

  List<Map> surah_indices = [], verse_indices = [];
  final TextEditingController searchController = TextEditingController();
  String word = "";
  late int sujood_index;
  List<Map> sujood_surah_indices = [],
      sujood_verse_indices = [];

  ArabicNumbers arabicNumber = ArabicNumbers();

  Future<void> initiateDB() async {
    // Get a location using getDatabasesPath
    var databasesPath = await getDatabasesPath();
    path = join(databasesPath, 'quran.db');

    database = await openDatabase(path);

    print(database.isOpen);
  }

  Future<void> fetchVersesData(String filter) async{

    // await initiateDB();

    translated_verse = await database.query(
        "verses",
        where: "lang_id = 2 AND text LIKE ?",
        whereArgs: ['%$filter%']
    );
    verses = await database.query(
        "verses",
        where: "lang_id = 1 AND text LIKE ?",
        whereArgs: ['%$filter%']
    );
    sujood_surah_indices = await database.rawQuery('SELECT surah_id FROM sujood_verses');
    sujood_verse_indices = await database.rawQuery('SELECT verse_id FROM sujood_verses');

    surah_indices = await database.query(
        "verses",
        columns: ["surah_id"],
        where: "lang_id = 2 AND text LIKE ?",
        whereArgs: ['%$filter%']
    );
    verse_indices = await database.query(
        "verses",
        columns: ["verse_id"],
        where: "lang_id = 2 AND text LIKE ?",
        whereArgs: ['%$filter%']
    );

    setState(() {
      translated_verse = translated_verse;
      verses = verses;
      len = verses.length;
    });

  }

  Future<void> getData(String filter) async {
    await initiateDB().whenComplete(() async=> await fetchVersesData(filter));
  }


  final _globalKey = GlobalKey();
  Widget child = SafeArea(child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisAlignment: MainAxisAlignment.center,
    children: const [
    Text(
      'hello world'
    )
  ],));
  @override
  Widget build(BuildContext context) {
    final model = ThemeModelInheritedNotifier.of(context);
    // Widget resChild;
    Widget child;
    if (model.oldTheme == null || model.oldTheme == model.theme) {
      child = _getPage(model.theme);
    } else {
      late final Widget firstWidget, animWidget;
      if (model.isReversed) {
        firstWidget = _getPage(model.theme);
        animWidget = RawImage(image: model.image);
      } else {
        firstWidget = RawImage(image: model.image);
        animWidget = _getPage(model.theme);
      }
      child = Stack(
        children: [
          Container(
            key: ValueKey('ThemeSwitchingAreaFirstChild'),
            child: firstWidget,
          ),
          AnimatedBuilder(
            key: ValueKey('ThemeSwitchingAreaSecondChild'),
            animation: model.controller,
            child: animWidget,
            builder: (_, child) {
              return ClipPath(
                clipper: ThemeSwitcherClipperBridge(
                  clipper: model.clipper,
                  offset: model.switcherOffset,
                  sizeRate: model.controller.value,
                ),
                child: child,
              );
            },
          ),
        ],
      );
    }

    return Material(child: child);
  }

  Widget _getPage(ThemeData brandTheme) {
    return Theme(
      key: _globalKey,
      data: brandTheme,
      child: child,
    );
  }
}
