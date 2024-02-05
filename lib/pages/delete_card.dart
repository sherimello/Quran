import 'package:flutter/material.dart';
import 'package:quran/assets/network%20operations/user_data.dart';
import 'package:quran/pages/bookmark_folders.dart';
import 'package:quran/pages/favorite_verses.dart';
import 'package:quran/pages/surah_list.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../hero_transition_handler/custom_rect_tween.dart';
import '../hero_transition_handler/hero_dialog_route.dart';
import 'menu.dart';

class DeleteCard extends StatefulWidget {

  final String tag, what_to_delete, from_where;
  String folder_name, surah_number, verse_number;

  DeleteCard({Key? key, required this.tag, this.surah_number = "", this.verse_number = "", required this.what_to_delete, required this.from_where, this.folder_name = ""}) : super(key: key);

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

  startDeletion() async {

    if(widget.what_to_delete == "folder") {
      await initiateDB().whenComplete(() {
        database.rawDelete('DELETE FROM bookmark_folders WHERE folder_name = ?', [widget.folder_name])
        .whenComplete(() {
          database.rawDelete('DELETE FROM bookmarks WHERE folder_name = ?', [widget.folder_name]);
        });
        print('deleted');
      });
    }
    else {
      widget.what_to_delete == "bookmarks" ?
      {
        await initiateDB().whenComplete(() {
          database.rawDelete('DELETE FROM bookmarks WHERE folder_name = ? AND surah_id = ? AND verse_id = ?', [widget.folder_name, widget.surah_number, widget.verse_number]);
          print('deleted');
        }).whenComplete(() => UserData().removeBookmarkFromServer("${widget.surah_number}:${widget.verse_number}", widget.folder_name))
      } :
      {
        await initiateDB().whenComplete(() {
          database.rawDelete('DELETE FROM favorites WHERE surah_id = ? AND verse_id = ?', [widget.surah_number, widget.verse_number]);
          print('deleted');
        })
      };
    }
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
              await startDeletion().whenComplete((){

                Navigator.pop(context);

                // if(widget.what_to_delete == "folder") {
                //   widget.from_where == "menu" ?
                //   Navigator.of(context).push(HeroDialogRoute(
                //     bgColor: Colors.white.withOpacity(0.85),
                //     builder: (context) => const Menu(),
                //   )) :
                //   Navigator.of(context).push(HeroDialogRoute(
                //     bgColor: Colors.white.withOpacity(0.85),
                //     builder: (context) => const SurahList(),
                //   ));
                // }
                // else {
                //   widget.what_to_delete == "bookmarks" ?
                //   widget.from_where == "menu" ?
                //   Navigator.of(context).pop():
                //   Navigator.of(context).push(HeroDialogRoute(
                //     bgColor: Colors.white.withOpacity(0.85),
                //     builder: (context) => const SurahList(),
                //   ))
                //       : widget.from_where == "menu" ?
                //   Navigator.push(context, MaterialPageRoute(builder: (context)=>
                //       FavoriteVerses(tag: widget.tag, from_where: widget.from_where,)))
                //       :
                //   Navigator.push(context, MaterialPageRoute(builder: (context)=>
                //   const SurahList()));
                // }
              });
            },
            child: Container(
              width: size.width * .21,
              height: size.width * .21,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(17),
                border: Border.all(color: Colors.white, width: 1.5),
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
