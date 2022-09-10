import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:quran/pages/surah_list.dart';
import 'package:sqflite/sqflite.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Database database;
  late String path,
      language1 = "",
      language2 = "",
      language3 = "",
      language4 = "";

  Future<void> initiateSurahDB() async {
    // Get a location using getDatabasesPath
    var databasesPath = await getDatabasesPath();
    path = join(databasesPath, 'quran.db');

    database = await openDatabase(path);

    verses = await database.rawQuery('SELECT * FROM verses WHERE surah_id = 1');

    print(verses[0]['text']);
  }

  Future<void> initiateDB() async {
    var databasesPath = await getDatabasesPath();
    path = join(databasesPath, 'quran.db');

    database = await openDatabase(path);
    print(database.isOpen);
  }

  Future<void> insertLanguageData() async {
    await database.transaction((txn) async {
      await txn.rawInsert(
        'INSERT INTO languages VALUES(1, \'AR\', \'Arabic\', \'العربية\')',
      );
      await txn.rawInsert(
        'INSERT INTO languages VALUES(2, \'EN\', \'English\', \'English\')',
      );
      await txn.rawInsert(
        'INSERT INTO languages VALUES(3, \'FR\', \'French\', \'Français\')',
      );
      await txn.rawInsert(
        'INSERT INTO languages VALUES(4, \'IT\', \'Italian\', \'Italiano\')',
      );
    });
  }

  bindLanguageDataToUI() {
    setState(() {
      language1 = languages[0]['name'];
      language2 = languages[1]['name'];
      language3 = languages[2]['name'];
      language4 = languages[3]['name'];
    });
  }

  List<Map> languages = [], verses = [];

  fetchLanguageData() async {
    await initiateDB()
        .whenComplete(() => insertLanguageData().whenComplete(() async {
              languages = await database.rawQuery('SELECT * FROM languages');
              print(languages[3]['name']);
            }).whenComplete(() => bindLanguageDataToUI()));
    // initiateSurahDB();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchLanguageData();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          height: size.height,
          width: size.width,
          color: Colors.white,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  height: size.width * .11,
                ),
                Image.asset(
                  'lib/assets/images/quran icon.png',
                  width: size.width * .77,
                  height: size.width * .77,
                ),
                SizedBox(
                  height: size.width * .21,
                ),
                const Text(
                  'choose language',
                  style: TextStyle(
                    fontFamily: 'varela-round.regular',
                    fontSize: 31,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(
                  height: 31,
                ),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(1000),
                      color: const Color(0xff1d3f5e)),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(19, 06, 19, 06),
                    child: Text(
                      language1,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        // fontFamily: 'Al Majeed Quranic Font_shiped',
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xffeceae8),
                        // height: size.width/size.height
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 21,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SurahList()));
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(1000),
                        color: const Color(0xff1d3f5e)),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(19, 11, 19, 11),
                      child: Text(
                        language2,
                        style: const TextStyle(
                          fontFamily: 'Rounded_Elegance',
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xffeceae8),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 21,
                ),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(1000),
                      color: const Color(0xff1d3f5e)),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(19, 11, 19, 11),
                    child: Text(
                      language3,
                      style: const TextStyle(
                        fontFamily: 'Rounded_Elegance',
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xffeceae8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(1000),
                      color: const Color(0xff1d3f5e)),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(19, 11, 19, 11),
                    child: Text(
                      language4,
                      style: const TextStyle(
                        fontFamily: 'Rounded_Elegance',
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xffeceae8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
