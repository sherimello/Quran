import 'package:flutter/material.dart';
import 'package:quran/assets/network%20operations/user_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../classes/db_helper.dart';
import '../hero_transition_handler/custom_rect_tween.dart';

class Bookmarks extends StatefulWidget {

  final String tag, verse_arabic, verse_english, surah_id, verse_id;
  final Color theme;

  const Bookmarks({Key? key, required this.tag, required this.verse_arabic, required this.verse_english, required this.surah_id, required this.verse_id, required this.theme}) : super(key: key);

  @override
  State<Bookmarks> createState() => _BookmarksState();
}

class _BookmarksState extends State<Bookmarks> {

  late Database database1;
  late String path, message = "";
  late List<Map> bookmarkFolders;
  int bookmarkFolderSize = 0;
  double snack_text_size = 0, snack_text_padding = 0;
  var bgColor = Colors.white, color_favorite_and_index = const Color(0xff1d3f5e), color_main_text = Colors.black;


  assignmentForLightMode() {
    bgColor = Colors.white;
    color_favorite_and_index = const Color(0xff1d3f5e);
    color_main_text = Colors.black;
  }

  assignmentForDarkMode() {
    bgColor = Colors.black;
    color_favorite_and_index = Colors.white;
    color_main_text = Colors.white;
  }

  initializeThemeStarters() async {

    if(widget.theme == Colors.white) {
      assignmentForLightMode();
    }
    else {
      assignmentForDarkMode();
    }
  }

  Future<void> initiateDB() async {
    // Get a location using getDatabasesPath
    // var databasesPath = await getDatabasesPath();
    // path = join(databasesPath, 'en_ar_quran.db');
    //
    // database1 = await openDatabase(path);
    DatabaseHelper databaseHelper = DatabaseHelper.instance;

    database1 = await databaseHelper.initDatabase('en_ar_quran.db');

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
    initializeThemeStarters();
    fetchBookmarkFolders();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    database1.close();
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
          child: Stack(
            children: [
              Container(
                height: size.height * .71,
                width: size.width - 38,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(31),
                    color: bgColor,
                    border: Border.all(color: bgColor == Colors.black ? Colors.blueGrey : Colors.transparent, width: 1.5)
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
                                child: Text('create a folder:',
                                style: TextStyle(
                                  fontFamily: 'varela-round.regular',
                                  fontWeight: FontWeight.bold,
                                  color: color_main_text
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
                                      color: const Color(0xff1d3f5e),
                                      border: Border.all(color: bgColor == Colors.black ? Colors.blueGrey : Colors.transparent, width: 1.5)
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
                                        {
                                          message = "folder already exists",
                                          setState(() {
                                            snack_text_size = 13;
                                            snack_text_padding = 39;
                                          }),
                                          Future.delayed(const Duration(seconds: 3), () {
                                            if(mounted) {
                                              setState(() {
                                              snack_text_size = 0;
                                              snack_text_padding = 0;
                                            });
                                            }
                                          }),
                                        } : {
                                      message = "folder name empty",
                                      if(mounted)
                                      setState(() {
                                        snack_text_size = 13;
                                        snack_text_padding = 41;
                                      }),
                                      Future.delayed(const Duration(seconds: 3), () {
                                        setState(() {
                                          snack_text_size = 0;
                                          snack_text_padding = 0;
                                        });
                                      }),
                                    };
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
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: '***create folder(s) and/or click on one to add your bookmark. the "',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontFamily: 'varela-round.regular',
                                        color: color_favorite_and_index,
                                        fontStyle: FontStyle.italic
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'default',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontFamily: 'varela-round.regular',
                                        color: color_main_text,
                                        fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight.bold
                                    ),
                                  ),
                                  TextSpan(
                                    text: '" bookmark folder has been made for you.\n',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontFamily: 'varela-round.regular',
                                        color: color_favorite_and_index,
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
                                      TextSpan(
                                        text: ' bookmark folder ',
                                          style: TextStyle(
                                              fontFamily: 'varela-round.regular',
                                              fontWeight: FontWeight.bold,
                                            color: color_main_text
                                          )
                                      ),
                                      TextSpan(
                                          text: '(${bookmarkFolderSize.toString()})',
                                          style: TextStyle(
                                              fontFamily: 'varela-round.regular',
                                              fontSize: 13,
                                            color: color_main_text
                                          )
                                      ),
                                      TextSpan(
                                          text: ' :',
                                          style: TextStyle(
                                              fontFamily: 'varela-round.regular',
                                              fontWeight: FontWeight.bold,
                                            color: color_main_text
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
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: bookmarkFolderSize,
                              itemBuilder: (BuildContext context, int index) {
                            return Padding(
                              padding: EdgeInsets.symmetric(horizontal: size.width * .087, vertical: 3.5),
                              child: GestureDetector(
                                onTap: () async{

                                  await addToBookmark(bookmarkFolders[index]['folder_name']);
                                  await UserData().addTheNewlyAddedBookmarkToServer("${widget.surah_id}:${widget.verse_id}", "${bookmarkFolders[index]['folder_name']}").whenComplete(() {
                                    setState(() {
                                      message = 'verse added to "${bookmarkFolders[index]['folder_name']}"';
                                      snack_text_size = 13;
                                      snack_text_padding = 41;

                                    });
                                    Future.delayed(const Duration(seconds: 3), () {
                                      setState(() {
                                        snack_text_size = 0;
                                        snack_text_padding = 0;
                                      });
                                    });
                                    // ScaffoldMessenger.of(context).showSnackBar( SnackBar(
                                    //   content: Text('verse added to ${bookmarkFolders[i]['folder_name']}'),
                                    // ));
                                    // Navigator.pop(context);
                                  });

                                },
                                child: Container(
                                  width: size.width,
                                  decoration: BoxDecoration(
                                      color: color_main_text.withOpacity(.21),
                                      borderRadius: BorderRadius.circular(11)
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(11.0),
                                    child: Text.rich(
                                        TextSpan(
                                            children: [
                                              WidgetSpan(
                                                  alignment: PlaceholderAlignment.middle,
                                                  child: Icon(
                                                      Icons.bookmark,
                                                    color: color_main_text,
                                                  )),
                                              TextSpan(
                                                  text: '  ${bookmarkFolders[index]['folder_name']} ',

                                                  style: TextStyle(
                                                      fontFamily: 'varela-round.regular',
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 17,
                                                    color: color_main_text
                                                  )
                                              ),
                                            ]
                                        )
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                          // Column(
                          //   children: [
                          //
                          //       for(int i = 0; i<bookmarkFolderSize; i++)
                          //         Padding(
                          //           padding: EdgeInsets.symmetric(horizontal: size.width * .087, vertical: 3.5),
                          //           child: GestureDetector(
                          //             onTap: () async{
                          //
                          //               await addToBookmark(bookmarkFolders[i]['folder_name']).whenComplete(() {
                          //                 setState(() {
                          //                   message = 'verse added to "${bookmarkFolders[i]['folder_name']}"';
                          //                     snack_text_size = 13;
                          //                     snack_text_padding = 41;
                          //
                          //                 });
                          //                 Future.delayed(const Duration(seconds: 3), () {
                          //                   setState(() {
                          //                     snack_text_size = 0;
                          //                     snack_text_padding = 0;
                          //                   });
                          //                 });
                          //                 // ScaffoldMessenger.of(context).showSnackBar( SnackBar(
                          //                 //   content: Text('verse added to ${bookmarkFolders[i]['folder_name']}'),
                          //                 // ));
                          //                 // Navigator.pop(context);
                          //               });
                          //
                          //             },
                          //             child: Container(
                          //               width: size.width,
                          //               decoration: BoxDecoration(
                          //                   color: const Color(0xff1d3f5e).withOpacity(.11),
                          //                   borderRadius: BorderRadius.circular(11)
                          //               ),
                          //               child: Padding(
                          //                 padding: const EdgeInsets.all(11.0),
                          //                 child: Text.rich(
                          //                     TextSpan(
                          //                         children: [
                          //                           const WidgetSpan(
                          //                               alignment: PlaceholderAlignment.middle,
                          //                               child: Icon(
                          //                                   Icons.bookmark
                          //                               )),
                          //                           TextSpan(
                          //                               text: '  ${bookmarkFolders[i]['folder_name']} ',
                          //
                          //                               style: const TextStyle(
                          //                                   fontFamily: 'varela-round.regular',
                          //                                   fontWeight: FontWeight.bold,
                          //                                   fontSize: 17
                          //                               )
                          //                           ),
                          //                         ]
                          //                     )
                          //                 ),
                          //               ),
                          //             ),
                          //           ),
                          //         ),
                          //   ],
                          // ),
                          const SizedBox(
                            height: 21,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: AnimatedContainer(
                  curve: Curves.easeOut,
                  duration: const Duration(milliseconds: 250),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(11), topRight: Radius.circular(11),
                        bottomLeft: Radius.circular(31), bottomRight: Radius.circular(31)),
                    color: Color(0xff1d3f5e),
                  ),
                  width: size.width - 60,
                  height: snack_text_padding,
                  child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 1000),
                      style: TextStyle(
                          height: 1,
                          color: const Color(0xffffffff),
                          fontFamily: 'varela-round.regular',
                          fontSize: snack_text_size,
                          fontWeight: FontWeight.bold
                      ),
                      child: Center(
                        child: Text(
                          message,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              height: 1,
                              color: const Color(0xffffffff),
                              fontFamily: 'varela-round.regular',
                              fontSize: snack_text_size,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      )

                  ),
                ),
              ),
            ],
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
