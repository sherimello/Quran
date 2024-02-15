import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quran/pages/bookmark_folders.dart';
import 'package:quran/pages/daily_videos.dart';
import 'package:quran/pages/duas.dart';
import 'package:quran/pages/new_surah_page.dart';
import 'package:quran/pages/surah_list.dart';
import 'package:quran/pages/verses_search.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../hero_transition_handler/custom_rect_tween.dart';
import '../hero_transition_handler/hero_dialog_route.dart';
import 'favorite_verses.dart';

class Menu extends StatefulWidget {
  double eng, ar;

  Menu({
    Key? key,
    required this.eng,
    required this.ar,
  }) : super(key: key);

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  bool value_last_read_exists = false;
  String verse_id = "", surah_id = "", theme = "light";
  var bgColor = Colors.white, textColor = Colors.black;
  int flag = 0;
  AudioPlayer audioPlayer = AudioPlayer();

  assignmentForLightMode() {
    setState(() {
      bgColor = Colors.white;
      textColor = Colors.black;
    });
  }

  assignmentForDarkMode() {
    setState(() {
      bgColor = Colors.black;
      textColor = Colors.white;
    });
  }

  void changeStatusBarColor(int colorCode) {
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  }

  initializeThemeStarters() async {
    // print(await getSynonyms("love"));
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.containsKey('english_font_size')) {
      widget.eng = sharedPreferences.getDouble("english_font_size")!;
    }
    if (sharedPreferences.containsKey('arabic_font_size')) {
      widget.ar = sharedPreferences.getDouble("arabic_font_size")!;
    }
    if (sharedPreferences.containsKey('theme mode')) {
      if (sharedPreferences.getString('theme mode') == "light") {
        theme = "light";
        changeStatusBarColor(0xff1d3f5e);
        assignmentForLightMode();
      }
      if (sharedPreferences.getString('theme mode') == "dark") {
        theme = "dark";
        changeStatusBarColor(0xff000000);
        assignmentForDarkMode();
      }
    }
  }

  Future<void> lastReadExists() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      value_last_read_exists = sharedPreferences.containsKey('verse_id');
      if (value_last_read_exists) {
        verse_id = sharedPreferences.getString('verse_id')!;
        surah_id = sharedPreferences.getString('surah_id')!;
      }
    });
  }

  @override
  void initState() {
    initializeThemeStarters();
    super.initState();
    lastReadExists();
  }

  @override
  Widget build(BuildContext context) {
    lastReadExists();

    var size = MediaQuery.of(context).size;

    Future<bool> showExitPopup() async {
      return await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(31)),
              title: const Text(
                'Exit App',
                style: TextStyle(fontFamily: 'varela-round.regular'),
              ),
              content: const Text(
                'Do you want to exit?',
                style: TextStyle(fontFamily: 'varela-round.regular'),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 11.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: const Color(0xff1d3f5e),
                      elevation: 7,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(31), // <-- Radius
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text(
                      'No',
                      style: TextStyle(fontFamily: 'varela-round.regular'),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 11.0, bottom: 11),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: const Color(0xff1d3f5e),
                      elevation: 7,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(31), // <-- Radius
                      ),
                    ),
                    onPressed: () => SystemChannels.platform
                        .invokeMethod('SystemNavigator.pop'),
                    //return true when click on "Yes"
                    child: const Text(
                      'Yes',
                      style: TextStyle(fontFamily: 'varela-round.regular'),
                    ),
                  ),
                ),
              ],
            ),
          ) ??
          false; //if showDialouge had returned null, then return false
    }

    return WillPopScope(
      onWillPop: showExitPopup,
      child: Material(
        color: Colors.transparent,
        child: Scaffold(
          backgroundColor: bgColor,
          body: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: AppBar().preferredSize.height * 2,
                ),
                Hero(
                    tag: "animate",
                    createRectTween: (begin, end) {
                      return CustomRectTween(begin: begin!, end: end!);
                    },
                    child: Image.asset(
                      'lib/assets/images/quran icon.png',
                      width: size.width * 0.15,
                      height: size.height * 0.15,
                    )),
                SizedBox(
                  height: AppBar().preferredSize.height * .21,
                ),
                Text(
                  'The Book',
                  // 'Qur\'an',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Bismillah Script',
                    fontSize: size.width * .079,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: textColor,
                  ),
                ),
                Text(
                  '(search anniething)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'varela-round.regular',
                      fontWeight: FontWeight.bold,
                      height: 1,
                      color: textColor),
                ),
                SizedBox(
                  height: AppBar().preferredSize.height * 1.5,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width * .13),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SurahList(
                                    eng: widget.eng,
                                    ar: widget.ar,
                                  )));
                    },
                    child: Container(
                      width: size.width,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: const Color(0xff1d3f5e).withOpacity(1)),
                      // width: size.width * .1,
                      // height: size.width * .075,
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Center(
                          child: Row(
                            children: [
                              Container(
                                width: size.width * .085,
                                height: size.width * .085,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(1000),
                                    color: Colors.white),
                                child: const Center(
                                  child: Icon(
                                    Icons.menu_book_outlined,
                                    color: Color(0xffa69963),
                                    size: 19,
                                  ),
                                ),
                              ),
                              Text(
                                "  read Qur'an ",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    height: 0,
                                    color: Colors.white,
                                    fontFamily: 'varela-round.regular',
                                    fontSize: size.width * .035,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: size.width * .13, vertical: 7),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => VersesSearch(
                                    theme: theme,
                                    eng: widget.eng,
                                    ar: widget.ar,
                                  )));
                    },
                    child: Container(
                      width: size.width,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: const Color(0xff1d3f5e).withOpacity(1)),
                      // width: size.width * .1,
                      // height: size.width * .075,
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Center(
                          child: Row(
                            children: [
                              Container(
                                width: size.width * .085,
                                height: size.width * .085,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(1000),
                                    color: Colors.white),
                                child: const Center(
                                  child: Icon(
                                    Icons.manage_search,
                                    color: Color(0xffa69963),
                                    size: 19,
                                  ),
                                ),
                              ),
                              Text(
                                "  search in Qur'an ",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    height: 0,
                                    color: Colors.white,
                                    fontFamily: 'varela-round.regular',
                                    fontSize: size.width * .035,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: size.width * .13, vertical: 0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(HeroDialogRoute(
                        bgColor: bgColor.withOpacity(0.85),
                        builder: (context) => Center(
                            child: BookmarkFolders(
                          tag: "animate",
                          from_where: "menu",
                          theme: bgColor,
                          eng: widget.eng,
                          ar: widget.ar,
                        )),
                      ));
                    },
                    child: Container(
                      width: size.width,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: const Color(0xff1d3f5e).withOpacity(1)),
                      // width: size.width * .1,
                      // height: size.width * .075,
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Center(
                          child: Row(
                            children: [
                              Container(
                                width: size.width * .085,
                                height: size.width * .085,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(1000),
                                    color: Colors.white),
                                child: const Center(
                                  child: Icon(
                                    Icons.bookmark,
                                    color: Color(0xffa69963),
                                    size: 19,
                                  ),
                                ),
                              ),
                              Text(
                                "  bookmark folders ",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    height: 0,
                                    color: Colors.white,
                                    fontFamily: 'varela-round.regular',
                                    fontSize: size.width * .035,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: size.width * .13, vertical: 7),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(HeroDialogRoute(
                        bgColor: bgColor.withOpacity(0.85),
                        builder: (context) => Center(
                            child: FavoriteVerses(
                          tag: "animate",
                          from_where: "menu",
                          theme: bgColor,
                          eng: widget.eng,
                          ar: widget.ar,
                        )),
                      ));
                    },
                    child: Container(
                      width: size.width,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: const Color(0xff1d3f5e).withOpacity(1)),
                      // width: size.width * .1,
                      // height: size.width * .075,
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Center(
                          child: Row(
                            children: [
                              Container(
                                width: size.width * .085,
                                height: size.width * .085,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(1000),
                                    color: Colors.white),
                                child: const Center(
                                  child: Icon(
                                    Icons.favorite_rounded,
                                    color: Color(0xffa69963),
                                    size: 19,
                                  ),
                                ),
                              ),
                              Text(
                                "  favorite verses ",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    height: 0,
                                    color: Colors.white,
                                    fontFamily: 'varela-round.regular',
                                    fontSize: size.width * .035,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: value_last_read_exists ? true : false,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                        size.width * .13, 0, size.width * .13, 7),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(HeroDialogRoute(
                          bgColor: bgColor.withOpacity(0.85),
                          builder: (context) => Center(
                              child: UpdatedSurahPage(
                            surah_id: surah_id,
                            scroll_to: (int.parse(verse_id) - 1),
                            should_animate: true,
                            eng: widget.eng,
                            ar: widget.ar,
                            bgColor: bgColor,
                          )),
                        ));
                      },
                      child: Container(
                        width: size.width,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: const Color(0xff1d3f5e).withOpacity(1)),
                        // width: size.width * .1,
                        // height: size.width * .075,
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Center(
                            child: Row(
                              children: [
                                Container(
                                  width: size.width * .085,
                                  height: size.width * .085,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(1000),
                                      color: Colors.white),
                                  child: const Center(
                                    child: Icon(
                                      Icons.timer,
                                      color: Color(0xffa69963),
                                      size: 19,
                                    ),
                                  ),
                                ),
                                Text(
                                  "  last read ",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      height: 0,
                                      color: Colors.white,
                                      fontFamily: 'varela-round.regular',
                                      fontSize: size.width * .035,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: true,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: size.width * .13, vertical: 0),
                    child: GestureDetector(
                      onTap: () async {
                        Navigator.of(context).push(HeroDialogRoute(
                          bgColor: bgColor.withOpacity(0.85),
                          builder: (context) => Center(
                              child: Duas(
                            title: "test",
                            eng: widget.eng,
                            ar: widget.ar,
                            theme: bgColor,
                          )),
                        ));
                      },
                      child: Container(
                          width: size.width,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: const Color(0xff1d3f5e).withOpacity(1)),
                          // width: size.width * .1,
                          // height: size.width * .075,
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Center(
                              child: Row(
                                children: [
                                  Container(
                                    width: size.width * .085,
                                    height: size.width * .085,
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(1000),
                                        color: Colors.white),
                                    child: const Center(
                                      child: Icon(
                                        Icons.mosque_rounded,
                                        color: Color(0xffa69963),
                                        size: 19,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    "  du'as (supplications) ",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        height: 0,
                                        color: Colors.white,
                                        fontFamily: 'varela-round.regular',
                                        fontSize: size.width * .035,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          )),
                    ),
                  ),
                ),
                Visibility(
                  visible: true,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: size.width * .13, vertical: 7),
                    child: GestureDetector(
                      onTap: () async {
                        Navigator.of(context).push(HeroDialogRoute(
                          bgColor: bgColor.withOpacity(0.85),
                          builder: (context) =>
                              Center(child: DailyDuas(theme: bgColor)),
                        ));
                        // setState(() {
                        //   if (flag == 1) {
                        //     flag = 0;
                        //   } else {
                        //     flag = 1;
                        //   }
                        // });
                        // if (flag == 0) {
                        //   audioPlayer.pause();
                        //   return;
                        // }
                        // final Directory? appDocDir =
                        //     await getExternalStorageDirectory();
                        // var appDocPath = appDocDir?.path;
                        // var file = File("${appDocPath!}/2.mp3");
                        // await file.exists() ? print("yes") : print("no");
                        // audioPlayer.play(DeviceFileSource(file.path));
                      },
                      child: Container(
                        width: size.width,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: const Color(0xff1d3f5e).withOpacity(1)),
                        // width: size.width * .1,
                        // height: size.width * .075,
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Center(
                            child: Row(
                              children: [
                                Container(
                                  width: size.width * .085,
                                  height: size.width * .085,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(1000),
                                      color: Colors.white),
                                  child: const Center(
                                    child: Icon(
                                      Icons.video_collection,
                                      color: Color(0xffa69963),
                                      size: 19,
                                    ),
                                  ),
                                ),
                                Text(
                                  "  daily videos ",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      height: 0,
                                      color: Colors.white,
                                      fontFamily: 'varela-round.regular',
                                      fontSize: size.width * .035,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: size.width * .5,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
