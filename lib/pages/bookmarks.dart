import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../hero_transition_handler/custom_rect_tween.dart';

class Bookmarks extends StatefulWidget {

  final String tag, verse_arabic, verse_english, surah_id, verse_id;

  const Bookmarks({Key? key, required this.tag, required this.verse_arabic, required this.verse_english, required this.surah_id, required this.verse_id}) : super(key: key);

  @override
  State<Bookmarks> createState() => _BookmarksState();
}

class _BookmarksState extends State<Bookmarks> {

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

  Future<void> addBookmarkFolder(String folder_name) async {
      await database1.transaction((txn) async {
        await txn.rawInsert(
            'INSERT INTO bookmark_folders VALUES (?)', [folder_name]
        );
      });
  }
  Future<void> addToBookmark(String folder_name) async {
      await database1.transaction((txn) async {
        await txn.rawInsert(
            'INSERT INTO bookmarks VALUES (?, ?, ?, ?, ?)', [folder_name, widget.verse_arabic, widget.verse_english, widget.surah_id, widget.verse_id]
        );
      });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchBookmarkFolders();
  }
  final TextEditingController folderController = TextEditingController();
  @override
  Widget build(BuildContext context) {

    var size = MediaQuery.of(context).size;

    TextField searchBar = TextField(
      controller: folderController,
      textAlign: TextAlign.start,
      style: const TextStyle(
          fontStyle: FontStyle.italic,
          height: 1.5,
          fontSize: 13,
          color: Colors.white
      ),
      cursorColor: Colors.white,
      decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 13),
          isDense: true,
          alignLabelWithHint: true,
          border: InputBorder.none,
          icon: Icon(Icons.folder_copy, color: Colors.white.withOpacity(0.5),),
          iconColor: Colors.white.withOpacity(0.5),
          hintText: 'folder name...',
          hintStyle: TextStyle(
              height: 1.5,
              color: Colors.white.withOpacity(0.5),
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
              fontFamily: 'Rounded_Elegance'
          )
      ),
    );

    return SafeArea(
      child: Center(
        child: Hero(
          tag: widget.tag,
          createRectTween: (begin, end) {
            return CustomRectTween(begin: begin!, end: end!);
          },
          child: Container(
            height: size.height * .71,
            width: size.width - 38,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(31),
                color: Colors.white
                // color: const Color(0xff1d3f5e)
            ),
            child: Padding(
              padding: const EdgeInsets.all(11.0),
              child: Material(
                color: Colors.transparent,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        height: 21,
                      ),
                      Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: EdgeInsets.only(left: size.width * .087),
                            child: const Text('create a folder:',
                            style: TextStyle(
                              fontFamily: 'varela-round.regular',
                              fontWeight: FontWeight.bold
                            ),
                            ),
                          )),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 7.0, horizontal: size.width * .087),
                        child: Stack(
                          alignment: Alignment.centerRight,
                          children: [
                            Container(
                              width: size.width * 1,
                              // width: size.width * .65,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(1000),
                                  color: const Color(0xff1d3f5e)
                              ),
                              child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 19.0),
                                  child: searchBar
                              ),
                            ),
                            const SizedBox(
                              width: 7,
                            ),
                            InkWell(
                              onTap: () async {
                                folderController.text.isNotEmpty ? !alreadyExists() ?
                                {
                                await addBookmarkFolder(folderController.text),
                                await fetchBookmarkFolders(),
                                } :
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                content: Text('folder already exists'),
                                )) : ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                  content: Text('empty name not allowed'),
                                ));
                              },

                              child: Container(
                                height: 13 * 4.1,
                                // height: 13 * 3.5,
                                width: 13*4.1,
                                // width: size.width * .35 - 29,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(1000),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xff1d3f5e).withOpacity(0.1),
                                      spreadRadius: 7,
                                      blurRadius: 11,
                                      offset: const Offset(0, 0), // changes position of shadow
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Icon(Icons.add_task_sharp, color: Color(0xff1d3f5e),),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: size.width * .087),
                        child: const Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '***create folder(s) and/or click on one to add your bookmark. the "',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontFamily: 'varela-round.regular',
                                    color: Color(0xff1d3f5e),
                                    fontStyle: FontStyle.italic
                                ),
                              ),
                              TextSpan(
                                text: 'default',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontFamily: 'varela-round.regular',
                                    color: Color(0xff000000),
                                    fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                              TextSpan(
                                text: '" bookmark folder has been made for you.\n',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontFamily: 'varela-round.regular',
                                    color: Color(0xff1d3f5e),
                                    fontStyle: FontStyle.italic
                                ),
                              )
                            ]
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: EdgeInsets.only(left: size.width * .087, top: 11),
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
                                          fontWeight: FontWeight.bold
                                      )
                                  ),
                                  TextSpan(
                                      text: '(${bookmarkFolderSize.toString()})',
                                      style: const TextStyle(
                                          fontFamily: 'varela-round.regular',
                                          fontSize: 13
                                      )
                                  ),
                                  const TextSpan(
                                      text: ' :',
                                      style: TextStyle(
                                          fontFamily: 'varela-round.regular',
                                          fontWeight: FontWeight.bold
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

                                    await addToBookmark(bookmarkFolders[i]['folder_name']).whenComplete(() {
                                      ScaffoldMessenger.of(context).showSnackBar( SnackBar(
                                        content: Text('verse added to ${bookmarkFolders[i]['folder_name']}'),
                                      ));
                                      Navigator.pop(context);
                                    });

                                  },
                                  child: Container(
                                    width: size.width,
                                    decoration: BoxDecoration(
                                        color: const Color(0xff1d3f5e).withOpacity(.11),
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
        ),
      ),
    );
  }

  bool alreadyExists() {
    for(int i = 0; i < bookmarkFolderSize; i++) {
      if (bookmarkFolders[i]['folder_name'] == folderController.text) { return true;
    }
    }
    return false;
  }
}