import 'package:flutter/material.dart';
import 'package:quran/pages/bookmark_verses.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../hero_transition_handler/custom_rect_tween.dart';
import '../hero_transition_handler/hero_dialog_route.dart';
import 'menu.dart';

class BookmarkFolders extends StatefulWidget {

  final String tag, from_where;

  const BookmarkFolders({Key? key, required this.tag, required this.from_where}) : super(key: key);

  @override
  State<BookmarkFolders> createState() => _BookmarkFoldersState();
}

class _BookmarkFoldersState extends State<BookmarkFolders> {

  late Database database1;
  late String path;
  late List<Map> bookmarkFolders;
  int bookmarkFolderSize = 0;

  Future<void> initiateDB() async {
    // Get a location using getDatabasesPath
    var databasesPath = await getDatabasesPath();
    path = join(databasesPath, 'quran.db');

    database1 = await openDatabase(path);

    print(database1.isOpen);
  }

  Future<void> fetchBookmarkFolders() async {
    // print(widget.verse_numbers);
    // verses.clear();

    await initiateDB().whenComplete(() async {
      bookmarkFolders = await database1.rawQuery(
          'SELECT folder_name FROM bookmark_folders');
      setState(() {
        bookmarkFolders = bookmarkFolders;
        bookmarkFolderSize = bookmarkFolders.length;
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchBookmarkFolders();
  }

  @override
  Widget build(BuildContext context) {


    Future <bool> goToMenu() async{
      return await Navigator.of(context).push(HeroDialogRoute(
        bgColor: Colors.white.withOpacity(0.0),
        builder: (context) => const Center(child: Menu()),
      )) ?? false;
    }

    var size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: goToMenu,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 19.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: widget.tag,
                createRectTween: (begin, end) {
                  return CustomRectTween(begin: begin!, end: end!);
                },
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: size.width - 38,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(31),
                        color: const Color(0xff1d3f5e)
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // const SizedBox(height: 21,),
                          Align(
                              alignment: Alignment.topLeft,
                              child: Padding(
                                padding: EdgeInsets.only(left: size.width * .087, top: 21),
                                child: Text.rich(
                                  TextSpan(
                                      children: [
                                        // WidgetSpan(
                                        //     alignment: PlaceholderAlignment.middle,
                                        //     child: Icon(Icons.folder_special_rounded, color: Color(0xff1d3f5e),)),
                                        const TextSpan(
                                            text: ' bookmark folder ',
                                            style: TextStyle(
                                                fontFamily: 'varela-round.regular',
                                                fontWeight: FontWeight.bold,
                                              color: Colors.white
                                            )
                                        ),
                                        TextSpan(
                                            text: '(${bookmarkFolderSize.toString()})',
                                            style: const TextStyle(
                                                fontFamily: 'varela-round.regular',
                                                fontSize: 13,
                                              color: Colors.white
                                            )
                                        ),
                                        const TextSpan(
                                            text: ' :',
                                            style: TextStyle(
                                                fontFamily: 'varela-round.regular',
                                                fontWeight: FontWeight.bold,
                                              color: Colors.white
                                            )
                                        ),
                                      ]
                                  )
                                  ,
                                ),
                              )),
                          const SizedBox(
                            height: 11,
                          ),
                          Column(
                            children: [

                              for(int i = 0; i<bookmarkFolderSize; i++)
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: size.width * .087, vertical: 3.5),
                                  child: GestureDetector(
                                    onTap: () async{
                                      Navigator.of(context).push(HeroDialogRoute(
                                        builder: (context) => Center(
                                          child: BookmarkVerses(tag: widget.tag, folder_name: bookmarkFolders[i]['folder_name'], from_where: widget.from_where),
                                        ),
                                      ));
                                      // await addToBookmark(bookmarkFolders[i]['folder_name']).whenComplete(() {
                                      //   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                      //     content: Text('folder already exists'),
                                      //   ));
                                      //   Navigator.pop(context);
                                      // });

                                    },
                                    child: Container(
                                      width: size.width,
                                      decoration: BoxDecoration(
                                          color: const Color(0xffffffff).withOpacity(1),
                                          borderRadius: BorderRadius.circular(11)
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(11.0),
                                        child: Text.rich(
                                            TextSpan(
                                                children: [
                                                  const WidgetSpan(
                                                      alignment: PlaceholderAlignment.middle,
                                                      child: Icon(
                                                          Icons.bookmark
                                                      )),
                                                  TextSpan(
                                                      text: '  ${bookmarkFolders[i]['folder_name']} ',

                                                      style: const TextStyle(
                                                          fontFamily: 'varela-round.regular',
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 17
                                                      )
                                                  ),
                                                ]
                                            )
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(
                            height: 21,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
