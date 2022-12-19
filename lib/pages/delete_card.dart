import 'package:flutter/material.dart';
import 'package:quran/pages/bookmark_folders.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../hero_transition_handler/custom_rect_tween.dart';

class DeleteCard extends StatefulWidget {

  final String tag, surah_number, verse_number;

  const DeleteCard({Key? key, required this.tag, required this.surah_number, required this.verse_number}) : super(key: key);

  @override
  State<DeleteCard> createState() => _DeleteCardState();
}

class _DeleteCardState extends State<DeleteCard> {

  late Database database;
  late String path;
  late List<Map> favoriteVerse;
  int bookmarkFolderSize = 0;

  Future<void> initiateDB() async {
    // Get a location using getDatabasesPath
    var databasesPath = await getDatabasesPath();
    path = join(databasesPath, 'quran.db');

    database = await openDatabase(path);

    print(database.isOpen);
  }

  deleteFromFavorites() async {
    await initiateDB().whenComplete(() {
      database.rawDelete('DELETE FROM bookmarks WHERE surah_id = ? AND verse_id = ?', [widget.surah_number, widget.verse_number]);
      print('deleted');
    });
  }

  @override
  Widget build(BuildContext context) {

    var size = MediaQuery.of(context).size;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Hero(
          tag: widget.tag,
          createRectTween: (begin, end) {
            return CustomRectTween(begin: begin!, end: end!);
          },
          child: GestureDetector(
            onTap: () async {
              await deleteFromFavorites().whenComplete((){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>
                  BookmarkFolders(tag: widget.tag,)));
              });
            },
            child: Container(
              width: size.width * .21,
              height: size.width * .21,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(17),
                color: const Color(0xff1d3f5e),
              ),
              child: Center(
                child: Icon(Icons.delete, color: Colors.white, size: size.width * .07,),
              ),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(top: 11.0),
          child: Material(
            color: Colors.transparent,
            child: Text(
              'remove verse',
              style: TextStyle(
                color: Color(0xff1d3f5e),
                fontFamily: 'varela-round.regular',
                fontSize: 15,
                fontWeight: FontWeight.bold
              ),
            ),
          ),
        )
      ],
    );
  }
}
