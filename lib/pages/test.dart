import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:arabic_numbers/arabic_numbers.dart';


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


  @override
  Widget build(BuildContext context) {
    setState((){
      verses = verses;
    });

    verses = verses;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: GestureDetector(
          onTap: () async {
            await getData("fear");
          },
          child: Container(
            width: 100,
            height: 100,
            color: Colors.green,
            child: Center(
              child: Text(
              translated_verse.length > 0 ? translated_verse.length.toString() : ""
          ),
            ),

          ),
        ),
      )
    );
  }
}
