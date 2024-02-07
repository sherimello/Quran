import 'dart:async';

import 'package:arabic_numbers/arabic_numbers.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:csv/csv.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:quran/classes/my_sharedpreferences.dart';
import 'package:quran/pages/settings_card.dart';
import 'package:quran/pages/verse_options_card.dart';
import 'package:quran/widgets/settings_UI.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'dart:io';

import '../classes/db_helper.dart';
import '../hero_transition_handler/custom_rect_tween.dart';
import '../hero_transition_handler/hero_dialog_route.dart';

class UpdatedSurahPage extends StatefulWidget {
  String surah_id, image, surah_name, arabic_name, verse_numbers, lang;
  bool should_animate;
  int scroll_to;
  List<int> sujoodVerses;
  var bgColor;
  List<Map> verses, translated_verse;
  double eng, ar;

  UpdatedSurahPage(
      {Key? key,
      required this.surah_id,
      this.bgColor = Colors.white,
      this.image = "",
      this.surah_name = "",
      this.arabic_name = "",
      this.verse_numbers = "",
      this.verses = const [],
      this.translated_verse = const [],
      this.scroll_to = 0,
      this.sujoodVerses = const [],
      this.should_animate = false,
      this.lang = "eng",
      required this.eng,
      required this.ar})
      : super(key: key);

  @override
  State<UpdatedSurahPage> createState() => _UpdatedSurahPageState();
}

class _UpdatedSurahPageState extends State<UpdatedSurahPage> {
  late AutoScrollController autoScrollController;
  bool scrolled_to_destination = false;

  bool downloadTapped = false;
  bool _menuClicked = false;
  double progress = 0.0;
  var count = 0;
  var len = 0;
  List<Map<String, dynamic>> data = [];
  bool show_tafsir = false;
  String tafsir = "";
  late int tafsirIndex = -1;
  String current_lang = "", lang_img = "lib/assets/images/eng.png";

  List<int> madani_surah = [
        2,
        3,
        4,
        5,
        8,
        9,
        13,
        22,
        24,
        33,
        47,
        48,
        49,
        55,
        57,
        58,
        59,
        60,
        61,
        62,
        63,
        64,
        65,
        66,
        76,
        98,
        99,
        110
      ],
      disputed_types = [
        1,
        13,
        16,
        22,
        29,
        47,
        55,
        61,
        64,
        76,
        80,
        83,
        89,
        92,
        97,
        98,
        99,
        110,
        112,
        113
      ];

  var bgColor = Colors.white,
      color_favorite_and_index = const Color(0xff1d3f5e),
      color_header = const Color(0xff1d3f5e),
      color_container_dark = const Color(0xfff4f4ff),
      color_container_light = Colors.white,
      color_main_text = Colors.black;

  late Database database;
  late String path;
  List<Map> sujood_surah_indices = [],
      sujood_verse_indices = [],
      surah_name_arabic = [],
      surah_name_translated = [],
      favorite_verses = [];

  var yt = YoutubeExplode();
  bool audioExists = false, playingAudio = false, stopClicked = false;
  String audioLength = "00:00:00", currentTime = "00:00:00";
  AudioPlayer audioPlayer = AudioPlayer();

  IconData play_pause_icon = Icons.pause_circle_filled_rounded;

  assignmentForLightMode() {
    bgColor = Colors.white;
    color_favorite_and_index = const Color(0xff1d3f5e);
    color_header = const Color(0xff1d3f5e);
    color_container_dark = const Color(0xfff4f4ff);
    color_container_light = Colors.white;
    color_main_text = Colors.black;
  }

  void changeStatusBarColor(int colorCode) {
    setState(() {
      SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(statusBarColor: Color(colorCode)));
    });
  }

  assignmentForDarkMode() {
    bgColor = Colors.black;
    color_favorite_and_index = Colors.white;
    color_header = Colors.black;
    color_container_dark = Colors.black;
    color_container_light = const Color(0xff252525);
    color_main_text = Colors.white;
  }

  initializeThemeStarters() async {
    if (widget.bgColor == Colors.white) {
      changeStatusBarColor(0xff1d3f5e);
      assignmentForLightMode();
    } else {
      changeStatusBarColor(0xff000000);
      assignmentForDarkMode();
    }
  }

  playAudio() async {
    final Directory? appDocDir = await getExternalStorageDirectory();
    var appDocPath = appDocDir?.path;

    var file = File("${appDocPath!}/${widget.surah_id}.mp3");
    audioPlayer.play(DeviceFileSource(file.path));

    audioPlayer.onPlayerStateChanged.listen((status) {
      if (audioPlayer.state == PlayerState.completed) {
        setState(() {
          stopClicked = true;
          play_pause_icon = Icons.play_arrow_rounded;
          currentTime = "00:00:00";
        });
      } else if (status == PlayerState.playing) {
        setState(() {
          play_pause_icon = Icons.pause_circle_filled_rounded;
        });
      } else if (status == PlayerState.paused) {
        setState(() {
          play_pause_icon = Icons.play_circle_fill_rounded;
        });
      }
    });

    audioPlayer.onPositionChanged.listen((event) {
      if (event.inSeconds != 0) {
        // var duration = event.inMilliseconds; //get the duration of audio
        // progress = (event.inMilliseconds / duration)*100; // get the current position in percent

        int secs = event.inSeconds;
        print(secs);
        int hours = (secs / 3600).floor();
        secs = secs - hours * 3600;
        int minutes = (secs / 60).floor();

        secs = secs - minutes * 60;

        // secs -= (hours * 3600) + (minutes * 60);

        String h = "", m = "", s = "";

        print("$hours:$minutes:$secs");

        hours.toString().length == 1 ? h = "0$hours" : h = "$hours";
        minutes.toString().length == 1 ? m = "0$minutes" : m = "$minutes";
        secs.toString().length == 1 ? s = "0$secs" : s = "$secs";
        // Now that we have the duration, stop the player.
        setState(() {
          // print(secs);
          // print("$hours:$minutes:$secs");
          // playingAudio = true;
          currentTime = "$h:$m:$s";
          if (currentTime == audioLength) {
            play_pause_icon = Icons.play_circle_fill_rounded;
          }
          // audioLength = double.parse(audioPlayer.getDuration());
        });
      }
    });

    audioPlayer.onDurationChanged.listen((Duration duration) {
      int secs = duration.inSeconds;
      print(secs);
      int hours = (secs / 3600).floor();
      secs = secs - hours * 3600;
      int minutes = (secs / 60).floor();

      secs = secs - minutes * 60;

      String h = "", m = "", s = "";

      hours.toString().length == 1 ? h = "0$hours" : h = hours.toString();
      minutes.toString().length == 1 ? m = "0$minutes" : m = "$minutes";
      secs.toString().length == 1 ? s = "0$secs" : s = "$secs";
      // Now that we have the duration, stop the player.
      setState(() {
        print(secs);
        print("$hours:$minutes:$secs");
        playingAudio = true;
        audioLength = "$h:$m:$s";
        // audioLength = double.parse(audioPlayer.getDuration());
      });
    });
  }

  checkIfAudioExists() async {
    final Directory? appDocDir = await getExternalStorageDirectory();
    var appDocPath = appDocDir?.path;
    var file = File("${appDocPath!}/${widget.surah_id}.mp3");
    if (await file.exists()) {
      setState(() {
        audioExists = true;
        downloadTapped = false;
      });
    } else {
      setState(() {
        audioExists = false;
      });
    }
  }

  // Function to get tafsir_text where surah == x and ayah == y
  String getTafsirText(int x, int y) {
    Map<String, dynamic>? result = data.firstWhere(
      (entry) {
        return entry['surah'] == x && entry['ayah'] == y;
      },
      orElse: () => Map<String, dynamic>.from({'tafsir_text': 'Not found'}),
    );

    return result['tafsir_text'].toString();
  }

  late Timer timer;
  late Database db_tafsir, db_bn;

  Future<String> specific_verse_tafsir(int surah, verse) async {
    // List<Map<dynamic, dynamic>> tafsir = await db_tafsir.rawQuery(
    //     "SELECT tafsir_text FROM tafsir_kathir WHERE surah = ? AND ayah = ?",
    //     [surah, verse]);
    List<Map<dynamic, dynamic>> tafsir = await db_tafsir.rawQuery(
        "SELECT text FROM verses WHERE sura = ? AND ayah = ?", [surah, verse]);
    // print(tafsir[0]["tafsir_text"].replaceAll("\\r", ""));
    return tafsir[0]["text"].replaceAll("\\r", "");
  }

  bool dbFilesLoad = false;

  initOtherDBs() async {
    DatabaseHelper databaseHelper = DatabaseHelper.instance;

    db_tafsir = await databaseHelper.initDatabase("en_jalalayn.db");
    db_bn = await databaseHelper.initDatabase("bn_bayaan.db");
    setState(() {
      db_tafsir = db_tafsir;
      db_bn = db_bn;
      dbFilesLoad = true;
    });
    // var databasesPath = await getDatabasesPath();
    // path = join(databasesPath, 'quran.db');
    //
    // database = await openDatabase(path);
    //
    // print(database.isOpen);

    // String databasePath1 = join('lib/assets/documents/', 'kathir_db.db');
    // String databasePath2 = join('lib/assets/documents/', 'bn_bayan.db');
    // db_tafsir = await openDatabase(databasePath1);
    // db_bn = await openDatabase(databasePath2);

    // final List<Map<String, dynamic>> tables = await db_bn.rawQuery(
    //   'SELECT name FROM sqlite_master WHERE type = "table"',
    // );
    //
    // for (final table in tables) {
    //   print(table['name']);
    // }
  }

  MySharedPreferences mySharedPreferences = MySharedPreferences();
  late SharedPreferences sharedPreferences;

  checkLanguage() async {
    current_lang = await (mySharedPreferences.getStringValue("lang"));

    setState(() {
      current_lang = current_lang;
    });
  }

  init() async {
    autoScrollController = AutoScrollController(
      axis: Axis.vertical,
    );

    _scrollToIndex();
    initializeThemeStarters();
    await checkLanguage();
    print(current_lang);
    sharedPreferences = await SharedPreferences.getInstance();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      // This function will be called after the widget has finished building
      initOtherDBs();
    });
    checkIfAudioExists();

    if (widget.image == "") {
      for (int i = 0; i < madani_surah.length; i++) {
        if (widget.surah_id == madani_surah[i].toString()) {
          widget.image = 'lib/assets/images/madinaWhiteIcon.png';
          break;
        } else {
          widget.image = 'lib/assets/images/makkaWhiteIcon.png';
          break;
        }
      }
    }

    startFetches();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init();
  }

  bool isVerseFavorite(int verse_number) {
    for (int i = 0; i < favorite_verses.length; i++) {
      if (favorite_verses[i]["verse_id"] == verse_number) {
        // favorite_verses.removeAt(i);
        return true;
      }
    }
    return false;
  }

  Future<void> startFetches() async {
    initiateDB().whenComplete(() async {
      await fetchVersesData(widget.surah_id);
    });
  }

  Future<void> startENData() async {
    widget.translated_verse = [
      ...await database.rawQuery(
          'SELECT text FROM verses WHERE lang_id = 2 AND surah_id = ?',
          [widget.surah_id])
    ];
    setState(() {
      widget.translated_verse = widget.translated_verse;
    });
  }

  Future<void> startBNData() async {
    // widget.translated_verse.clear();
    widget.translated_verse = [
      ...await db_bn.rawQuery('SELECT text FROM verses WHERE sura = ?',
          [int.parse(widget.surah_id)])
    ];
    setState(() {
      widget.translated_verse = widget.translated_verse;
    });
    List<Map<dynamic, dynamic>> temp =
        await db_bn.rawQuery('SELECT text FROM verses WHERE sura = ?', ["1"]);
    print(temp);
  }

  Future<void> initiateDB() async {
    // Get a location using getDatabasesPath
    var databasesPath = await getDatabasesPath();
    path = join(databasesPath, 'quran.db');

    database = await openDatabase(path);

    print(database.isOpen);
  }

  Future<void> fetchVersesData(String surah_id) async {
    // print(widget.verse_numbers);
    // verses.clear();
    await initiateDB().whenComplete(() async {
      widget.verses = [
        ...await database.rawQuery(
            'SELECT text FROM verses WHERE lang_id = 1 AND surah_id = ?',
            [widget.surah_id])
      ];
      current_lang == "eng"
          ? widget.translated_verse = [
              ...await database.rawQuery(
                  'SELECT text FROM verses WHERE lang_id = 2 AND surah_id = ?',
                  [widget.surah_id])
            ]
          : initOtherDBs().whenComplete(() => startBNData());
      // widget.translated_verse = await database.rawQuery(
      //     'SELECT text FROM verses_bn WHERE surah_id = ?',
      //     [widget.surah_id]);
      surah_name_arabic = await database.rawQuery(
          'SELECT * FROM surahnames WHERE lang_id = 1 AND surah_id = ?',
          [widget.surah_id]);
      surah_name_translated = await database.rawQuery(
          'SELECT * FROM surahnames WHERE lang_id = 2 AND surah_id = ?',
          [widget.surah_id]);
      sujood_surah_indices =
          await database.rawQuery('SELECT surah_id FROM sujood_verses');
      sujood_verse_indices =
          await database.rawQuery('SELECT verse_id FROM sujood_verses');
      favorite_verses = await database.rawQuery(
          'SELECT * FROM favorites WHERE surah_id = ?', [widget.surah_id]);
    });
    if (mounted) {
      setState(() {
        widget.verses = widget.verses;
        widget.translated_verse = widget.translated_verse;
        widget.surah_name = surah_name_translated[0]['translation'];
        widget.arabic_name = surah_name_arabic[0]['translation'];
      });
    }
    print("translated verses: ${widget.translated_verse.length}");
  }

  Future<void> fetchSurahSujoodVerses(int surah_id) async {
    widget.sujoodVerses = [];
    for (int i = 0; i < sujood_surah_indices.length; i++) {
      if (sujood_verse_indices[i]['verse_id'] == surah_id) {
        widget.sujoodVerses.add(sujood_verse_indices[i]['verse_id']);
      }
    }
  }

  Future _scrollToIndex() async {
    await autoScrollController.scrollToIndex(widget.scroll_to,
        preferPosition: AutoScrollPosition.begin);
    if (mounted) {
      setState(() {
        scrolled_to_destination = true;
      });
    }
  }

  @override
  Future<void> dispose() async {
    // TODO: implement dispose
    super.dispose();
    data.clear();
    yt.close();
    final Directory? appDocDir = await getExternalStorageDirectory();
    var appDocPath = appDocDir?.path;
    var file = File("${appDocPath!}/${widget.surah_id}.mp3");
    if (downloadTapped && progress != 100.0) {
      file.deleteSync();
    }
    if (playingAudio) {
      audioPlayer.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var status = PermissionStatus.denied;

    Future<bool?> askForStorageManagementPermission() async {
      status = await Permission.storage.status;
      if (status.isDenied) {
        await Permission.storage.request().then((value) {
          if (status.isDenied) {
            askForStorageManagementPermission();
          } else {
            return true;
          }
        });
      }
      return true;
    }

    downloadSurahMP3() async {
      var snapshot = await FirebaseDatabase.instance
          .ref('surah audios')
          .child(widget.surah_id)
          .get();

      yt = YoutubeExplode();
      var manifest =
          await yt.videos.streamsClient.getManifest(snapshot.value.toString());
      var streamInfo = manifest.audioOnly.withHighestBitrate();
      if (streamInfo != null) {
        if (await askForStorageManagementPermission() == true) {
          final Directory? appDocDir = await getExternalStorageDirectory();
          var appDocPath = appDocDir?.path;
          var stream = yt.videos.streamsClient.get(streamInfo);

          len = streamInfo.size.totalBytes;

          var file = File("${appDocPath!}/${widget.surah_id}.mp3");
          var fileStream = file.openWrite();

          await for (final data in stream) {
            count += data.length;

            setState(() {
              progress = ((count / len.toDouble()) * 100).ceil().toDouble();
              if (progress == 100.0) {
                playAudio();
                playingAudio = true;
                checkIfAudioExists();
              }
            });

            print(progress);
            fileStream.add(data);
          }

          await fileStream.flush();
          await fileStream.close().whenComplete(() {
            playAudio();
          });
        } else {
          print("denied");
        }
      }
      yt.close();
    }

    ArabicNumbers arabicNumber = ArabicNumbers();
    bool isPortraitMode() {
      return size.height > size.width ? true : false;
    }

    return Scaffold(
        backgroundColor: const Color(0xff1d3f5e),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          color: color_container_dark,
          child: SafeArea(
            child: Stack(
              children: [
                AnimatedPositioned(
                  left: 0,
                  right: 0,
                  top: playingAudio
                      ? AppBar().preferredSize.height * 2 +
                          AppBar().preferredSize.height * .29 * .5
                      : AppBar().preferredSize.height,
                  duration: const Duration(milliseconds: 355),
                  child: Container(
                    width: size.width,
                    color: color_container_dark,
                    padding: const EdgeInsets.all(0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                          child: Text(
                            'k',
                            textAlign: TextAlign.center,
                            // textScaleFactor: ,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              inherit: false,
                              color: widget.surah_id == '1' ||
                                      widget.surah_id == '9'
                                  ? Colors.transparent
                                  : color_main_text,
                              fontFamily: '110_Besmellah',
                              fontStyle: FontStyle.normal,
                              fontSize: AppBar().preferredSize.height * .71,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                AnimatedPositioned(
                  right: 0,
                  left: 0,
                  top: widget.surah_id == '1' || widget.surah_id == '9'
                      ? playingAudio
                          ? AppBar().preferredSize.height * 2 +
                              AppBar().preferredSize.height * .29 * .5
                          : AppBar().preferredSize.height
                      : playingAudio
                          ? AppBar().preferredSize.height * 3 +
                              AppBar().preferredSize.height * .29 * .5
                          : AppBar().preferredSize.height * 2,
                  duration: const Duration(milliseconds: 355),
                  child: Container(
                    width: size.width,
                    height: widget.surah_id == '1' || widget.surah_id == '9'
                        ? playingAudio
                            ? size.height -
                                (AppBar().preferredSize.height * 2 +
                                    AppBar().preferredSize.height * .29 * .5) -
                                MediaQuery.of(context).padding.top
                            : size.height -
                                AppBar().preferredSize.height -
                                MediaQuery.of(context).padding.top
                        : playingAudio
                            ? size.height -
                                (AppBar().preferredSize.height * 3 +
                                    AppBar().preferredSize.height * .29 * .5) -
                                MediaQuery.of(context).padding.top
                            : size.height -
                                AppBar().preferredSize.height * 2 -
                                MediaQuery.of(context).padding.top,
                    color: widget.verses.length.isOdd
                        ? color_container_dark
                        : color_container_light,
                    child: ListView.builder(
                        controller: autoScrollController,
                        scrollDirection: Axis.vertical,
                        physics: const BouncingScrollPhysics(),
                        cacheExtent: 1000,
                        itemCount: widget.translated_verse.isEmpty
                            ? 0
                            : widget.translated_verse.length,
                        itemBuilder: (BuildContext context, int index) {
                          return AutoScrollTag(
                            highlightColor: const Color(0xff1d3f5e),
                            key: ValueKey(index),
                            index: index,
                            controller: autoScrollController,
                            child: Hero(
                              tag: index.toString(),
                              createRectTween: (begin, end) {
                                return CustomRectTween(
                                    begin: begin!, end: end!);
                              },
                              child: GestureDetector(
                                onTap: !_menuClicked
                                    ? () async {
                                        await Navigator.of(context)
                                            .push(HeroDialogRoute(
                                          bgColor: bgColor.withOpacity(.75),
                                          builder: (context) => Center(
                                            child: VerseOptionsCard(
                                              tag: index.toString(),
                                              verse_english:
                                                  widget.translated_verse[index]
                                                          ['text'] +
                                                      "",
                                              verse_arabic: widget.verses[index]
                                                  ['text'],
                                              surah_name: widget.surah_name,
                                              surah_number: widget.surah_id,
                                              verse_number:
                                                  (index + 1).toString(),
                                              theme: bgColor,
                                            ),
                                          ),
                                        ))
                                            .then((_) {
                                          widget.scroll_to = index;
                                          startFetches().whenComplete(() {
                                            _scrollToIndex();
                                          });
                                        });
                                      }
                                    : () {},
                                child: Material(
                                  color: Colors.transparent,
                                  child: ClipRRect(
                                    child: Stack(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                              color: index.isEven
                                                  ? color_container_dark
                                                  : color_container_light),
                                          child: Padding(
                                            padding: const EdgeInsets.all(17.0),
                                            child: SingleChildScrollView(
                                              child: Column(
                                                children: [
                                                  Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .fromLTRB(
                                                                0, 7, 0, 7),
                                                        child: Column(
                                                          children: [
                                                            Stack(
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              children: [
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          1.0),
                                                                  child:
                                                                      Opacity(
                                                                    opacity:
                                                                        0.5,
                                                                    child: Image
                                                                        .asset(
                                                                      'lib/assets/images/surahIndex.png',
                                                                      height: isPortraitMode()
                                                                          ? size.width *
                                                                              .125
                                                                          : size.height *
                                                                              .125,
                                                                      width: isPortraitMode()
                                                                          ? size.width *
                                                                              .125
                                                                          : size.height *
                                                                              .125,
                                                                      color:
                                                                          color_favorite_and_index,
                                                                    ),
                                                                  ),
                                                                ),
                                                                Text.rich(
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  TextSpan(
                                                                    text: "${index + 1}".length ==
                                                                            1
                                                                        ? '00${index + 1}'
                                                                        : "${index + 1}".length ==
                                                                                2
                                                                            ? '0${index + 1}'
                                                                            : '${index + 1}',
                                                                    style:
                                                                        TextStyle(
                                                                      color:
                                                                          color_favorite_and_index,
                                                                      fontSize: isPortraitMode()
                                                                          ? size.width *
                                                                              .031
                                                                          : size.height *
                                                                              .031,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontFamily:
                                                                          'varela-round.regular',
                                                                    ),
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                            if (isVerseFavorite(
                                                                index + 1))
                                                              Icon(
                                                                Icons.stars,
                                                                color:
                                                                    color_favorite_and_index,
                                                              )
                                                          ],
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child:
                                                            SingleChildScrollView(
                                                          child: Material(
                                                            color: Colors
                                                                .transparent,
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .stretch,
                                                              children: [
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .end,
                                                                    children: [
                                                                      Text.rich(
                                                                          textDirection: TextDirection
                                                                              .rtl,
                                                                          textAlign: TextAlign
                                                                              .right,
                                                                          textScaleFactor: (isPortraitMode()
                                                                              ? size.height / size.width
                                                                              : size.width / size.height),
                                                                          TextSpan(
                                                                              style: TextStyle(
                                                                                // wordSpacing: 2,
                                                                                fontFamily: 'Al_Mushaf',
                                                                                fontWeight: FontWeight.w500,
                                                                                fontSize: widget.ar,
                                                                                color: color_main_text,
                                                                              ),
                                                                              children: [
                                                                                TextSpan(
                                                                                  text: widget.verses.isNotEmpty ? '${widget.verses[index]['text']}  ' : '',
                                                                                  // 'k',
                                                                                  style: TextStyle(
                                                                                    wordSpacing: 0,
                                                                                    fontFamily: 'Al Majeed Quranic Font_shiped',
                                                                                    // fontWeight: FontWeight.w500,
                                                                                    fontSize: widget.ar,
                                                                                    color: color_main_text,
                                                                                  ),
                                                                                ),
                                                                                TextSpan(
                                                                                  text: arabicNumber.convert(index + 1),
                                                                                  style: TextStyle(
                                                                                      // wordSpacing: 3,
                                                                                      fontSize: widget.ar - 5,
                                                                                      fontWeight: FontWeight.bold,
                                                                                      color: color_main_text,
                                                                                      fontFamily: "KFGQPC HafsEx1 Uthmanic Script"),
                                                                                ),
                                                                                widget.sujoodVerses.contains(index + 1)
                                                                                    ? WidgetSpan(
                                                                                        alignment: PlaceholderAlignment.bottom,
                                                                                        child: Image.asset(
                                                                                          'lib/assets/images/sujoodIcon.png',
                                                                                          width: 12,
                                                                                          height: 12,
                                                                                        ))
                                                                                    : const WidgetSpan(child: SizedBox())
                                                                              ])),
                                                                      const SizedBox(
                                                                        height:
                                                                            11,
                                                                      ),
                                                                      Text.rich(
                                                                          textAlign:
                                                                              TextAlign.start,
                                                                          TextSpan(children: [
                                                                            TextSpan(
                                                                              text: widget.translated_verse[index]['text'] + ' [${widget.surah_id}:${index + 1}]',
                                                                              style: TextStyle(fontFamily: 'varela-round.regular', fontWeight: FontWeight.w600, color: color_main_text, fontSize: widget.eng),
                                                                            ),
                                                                            widget.sujoodVerses.contains(index + 1)
                                                                                ? TextSpan(text: '\n\nverse of prostration ***', style: TextStyle(color: const Color(0xff518050), fontWeight: FontWeight.bold, fontFamily: 'varela-round.regular', fontSize: widget.eng))
                                                                                : const TextSpan()
                                                                          ])),
                                                                    ],
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Stack(
                                                    children: [
                                                      Align(
                                                        alignment:
                                                            AlignmentDirectional
                                                                .centerEnd,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Visibility(
                                                              visible: false,
                                                              // data.isEmpty,
                                                              child: SizedBox(
                                                                  width:
                                                                      size.width *
                                                                          .05,
                                                                  height:
                                                                      size.width *
                                                                          .05,
                                                                  child:
                                                                      const CircularProgressIndicator(
                                                                    color: Color(
                                                                        0xff1d3f5e),
                                                                  ))),
                                                        ),
                                                      ),
                                                      Visibility(
                                                        visible: tafsirIndex !=
                                                            index,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .end,
                                                          children: [
                                                            GestureDetector(
                                                              onTap:
                                                                  !_menuClicked
                                                                      ? () async {
                                                                          setState(
                                                                              () {
                                                                            show_tafsir =
                                                                                true;
                                                                            tafsirIndex =
                                                                                index;
                                                                          });
                                                                          tafsir = await specific_verse_tafsir(
                                                                              int.parse(widget.surah_id),
                                                                              index + 1);
                                                                          setState(
                                                                              () {
                                                                            tafsir =
                                                                                tafsir;
                                                                          });
                                                                          // }
                                                                        }
                                                                      : () {},
                                                              child: Container(
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: const Color(
                                                                        0xff1d3f5e),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            1000),
                                                                    boxShadow: [
                                                                      BoxShadow(
                                                                        color: const Color(0xff1d3f5e)
                                                                            .withOpacity(0.15),
                                                                        spreadRadius:
                                                                            3,
                                                                        blurRadius:
                                                                            19,
                                                                        offset: const Offset(
                                                                            0,
                                                                            0), // changes position of shadow
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  child:
                                                                      const Center(
                                                                    child:
                                                                        Padding(
                                                                      padding: EdgeInsets.symmetric(
                                                                          horizontal:
                                                                              11.0,
                                                                          vertical:
                                                                              7),
                                                                      child:
                                                                          Center(
                                                                        child: Text
                                                                            .rich(
                                                                          // textAlign: TextAlign.center,
                                                                          TextSpan(
                                                                              children: [
                                                                                TextSpan(text: "show tafsir", style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'varela-round.regular', fontSize: 12, color: Colors.white)),
                                                                                WidgetSpan(
                                                                                    alignment: PlaceholderAlignment.middle,
                                                                                    child: Padding(
                                                                                      padding: EdgeInsets.only(left: 7.0),
                                                                                      child: Icon(
                                                                                        Icons.info_outline,
                                                                                        color: Colors.white,
                                                                                        size: 19,
                                                                                      ),
                                                                                    ))
                                                                              ]),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  )),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Visibility(
                                                    visible:
                                                        tafsirIndex == index &&
                                                            show_tafsir,
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(31),
                                                          color: const Color(
                                                              0xff1d3f5e)),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(19.0),
                                                        child: Column(
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      bottom:
                                                                          11.0),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .end,
                                                                children: [
                                                                  GestureDetector(
                                                                    onTap:
                                                                        () async {
                                                                      setState(
                                                                          () {
                                                                        show_tafsir =
                                                                            false;
                                                                        tafsirIndex =
                                                                            -1;
                                                                      });
                                                                    },
                                                                    child: Container(
                                                                        // width: size.width,
                                                                        // height: AppBar().preferredSize.height * .67,
                                                                        decoration: BoxDecoration(
                                                                          color:
                                                                              const Color(0xffffffff),
                                                                          borderRadius:
                                                                              BorderRadius.circular(1000),
                                                                          boxShadow: [
                                                                            BoxShadow(
                                                                              color: const Color(0xffffffff).withOpacity(0.15),
                                                                              spreadRadius: 3,
                                                                              blurRadius: 19,
                                                                              offset: const Offset(0, 0), // changes position of shadow
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        child: const Center(
                                                                          child:
                                                                              Padding(
                                                                            padding:
                                                                                EdgeInsets.symmetric(horizontal: 11.0, vertical: 7),
                                                                            child:
                                                                                Center(
                                                                              child: Text.rich(
                                                                                // textAlign: TextAlign.center,
                                                                                TextSpan(children: [
                                                                                  TextSpan(text: "hide tafsir", style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'varela-round.regular', fontSize: 12, color: Color(0xff1d3f5e))),
                                                                                  WidgetSpan(
                                                                                      alignment: PlaceholderAlignment.middle,
                                                                                      child: Padding(
                                                                                        padding: EdgeInsets.only(left: 7.0),
                                                                                        child: Icon(
                                                                                          Icons.hide_source,
                                                                                          color: Color(0xff1d3f5e),
                                                                                          size: 19,
                                                                                        ),
                                                                                      ))
                                                                                ]),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        )),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            HtmlWidget(
                                                              "$tafsir",
                                                              buildAsync: true,
                                                              enableCaching:
                                                                  true,
                                                              textStyle: TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize:
                                                                      widget
                                                                          .eng,
                                                                  fontFamily:
                                                                      "varela-round.regular"),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        if (scrolled_to_destination &&
                                            widget.should_animate &&
                                            index == widget.scroll_to)
                                          Center(
                                            child: RippleAnimation(
                                                color: color_favorite_and_index,
                                                repeat: false,
                                                ripplesCount: 11,
                                                minRadius: size.width * .5,
                                                duration: const Duration(
                                                    milliseconds: 1500),
                                                child: const Center(
                                                    child: SizedBox())),
                                          )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                  ),
                ),
                Visibility(
                  visible: false,
                  child: AnimatedPositioned(
                    duration: const Duration(milliseconds: 355),
                    curve: Curves.decelerate,
                    top: AppBar().preferredSize.height * .29 * .5,
                    right: downloadTapped == false
                        ? playingAudio == false
                            ? (size.width * .25) * .15
                            : AppBar().preferredSize.height * .29 * .5
                        : size.width * .2,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          if (!audioExists) {
                            downloadTapped == true
                                ? downloadTapped = false
                                : downloadTapped = true;
                            downloadSurahMP3();
                          } else {
                            if (audioPlayer.state != PlayerState.paused &&
                                audioPlayer.state != PlayerState.playing &&
                                audioPlayer.state != PlayerState.completed) {
                              playingAudio = true;
                              playingAudio = true;
                              playAudio();
                            }
                          }
                        });
                        // if (playingAudio) playAudio();
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 255),
                            curve: Curves.easeInOut,
                            width: downloadTapped == false
                                ? playingAudio == false
                                    ? AppBar().preferredSize.height * .71
                                    : size.width -
                                        AppBar().preferredSize.height *
                                            .29 *
                                            .5 *
                                            2
                                : size.width * .6,
                            // : progress < 100.0 ? size.width * .6 : AppBar().preferredSize.height * .71,
                            height: playingAudio == false
                                ? AppBar().preferredSize.height * .71
                                : AppBar().preferredSize.height * 2,
                            decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: color_container_dark == Colors.black
                                        ? Colors.transparent.withOpacity(.35)
                                        : Colors.black.withOpacity(.15),
                                    spreadRadius: 7,
                                    blurRadius: 19,
                                    offset: const Offset(
                                        7, 7), // changes position of shadow
                                  ),
                                  BoxShadow(
                                    color: color_container_dark == Colors.black
                                        ? Colors.transparent.withOpacity(.35)
                                        : Colors.black.withOpacity(.15),
                                    spreadRadius: 7,
                                    blurRadius: 19,
                                    offset: const Offset(
                                        -7, -7), // changes position of shadow
                                  ),
                                ],
                                color: Colors.white,
                                borderRadius: playingAudio == false
                                    ? BorderRadius.circular(1000)
                                    : BorderRadius.circular(size.width * .105)),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Opacity(
                                  opacity: downloadTapped == true ||
                                          playingAudio == true
                                      ? 0
                                      : 1,
                                  child: Icon(
                                    audioExists
                                        ? Icons.play_arrow_rounded
                                        : Icons.headphones,
                                    color: const Color(0xff1d3f5e),
                                  ),
                                ),
                                Visibility(
                                  visible: playingAudio,
                                  child: SingleChildScrollView(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          width: size.width,
                                          height: AppBar().preferredSize.height,
                                          child: Center(
                                            child: Text.rich(
                                              textAlign: TextAlign.center,
                                              TextSpan(children: [
                                                WidgetSpan(
                                                    alignment:
                                                        PlaceholderAlignment
                                                            .middle,
                                                    child: Image.asset(
                                                      widget.image,
                                                      color: Colors.black,
                                                      height: 13,
                                                      width: 13,
                                                    )),
                                                TextSpan(
                                                    text:
                                                        '   ${widget.surah_name}  ',
                                                    style: TextStyle(
                                                        height: 0,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontFamily:
                                                            'varela-round.regular',
                                                        color: Colors.black,
                                                        fontSize: AppBar()
                                                                .preferredSize
                                                                .height *
                                                            .21)),
                                                TextSpan(
                                                  text: widget.arabic_name,
                                                  style: TextStyle(
                                                      height: 0,
                                                      color: Colors.black,
                                                      fontSize: AppBar()
                                                              .preferredSize
                                                              .height *
                                                          .21,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily: 'Diwanltr'),
                                                ),
                                                TextSpan(
                                                  text:
                                                      "\n$currentTime / $audioLength   ",
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: AppBar()
                                                              .preferredSize
                                                              .height *
                                                          .21,
                                                      fontFamily:
                                                          "varela-round.regular",
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ]),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: size.width,
                                          height: AppBar().preferredSize.height,
                                          child: Center(
                                            child: SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  GestureDetector(
                                                    //coding in wrong oplacwe
                                                    onTap: () {
                                                      audioPlayer.stop();
                                                      setState(() {
                                                        playingAudio = false;
                                                        currentTime =
                                                            "00:00:00";
                                                      });
                                                    },
                                                    child: Icon(
                                                      Icons.cancel,
                                                      size: AppBar()
                                                              .preferredSize
                                                              .height *
                                                          .55,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 5,
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      audioPlayer.stop();
                                                      setState(() {
                                                        stopClicked = true;
                                                        play_pause_icon = Icons
                                                            .play_circle_fill_rounded;
                                                        currentTime =
                                                            "00:00:00";
                                                      });
                                                    },
                                                    child: Icon(
                                                      Icons.stop_circle,
                                                      color: Colors.black,
                                                      size: AppBar()
                                                              .preferredSize
                                                              .height *
                                                          .55,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 5,
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        if (play_pause_icon ==
                                                            Icons
                                                                .pause_circle_filled_rounded) {
                                                          audioPlayer.pause();
                                                        } else {
                                                          stopClicked
                                                              ? playAudio()
                                                              : audioPlayer
                                                                  .resume();
                                                          // setState(() {
                                                          //   play_pause_icon = Icons.pause_circle_filled_rounded;
                                                          // });
                                                        }
                                                      });
                                                    },
                                                    child: Icon(
                                                      color: Colors.black,
                                                      play_pause_icon,
                                                      size: AppBar()
                                                              .preferredSize
                                                              .height *
                                                          .55,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Visibility(
                            visible: downloadTapped == true ? true : false,
                            child: Text.rich(TextSpan(children: [
                              WidgetSpan(
                                  child: SizedBox(
                                    width: AppBar().preferredSize.height * .31,
                                    height: AppBar().preferredSize.height * .31,
                                    child: CircularProgressIndicator(
                                        value: progress.toDouble() / 100,
                                        color: const Color(0xff1d3f5e)),
                                  ),
                                  alignment: PlaceholderAlignment.middle),
                              const TextSpan(
                                  text: "   downloading...",
                                  style: TextStyle(
                                      fontFamily: "varela-round.regular",
                                      color: Color(0xff1d3f5e),
                                      fontWeight: FontWeight.bold))
                            ])),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: AppBar().preferredSize.height * .29 * .5,
                  right: (size.width * .25) * .15,
                  child: GestureDetector(
                    onTap: () async {
                      setState(() {
                        downloadTapped = false;
                      });
                      yt.close();
                      final Directory? appDocDir =
                          await getExternalStorageDirectory();
                      var appDocPath = appDocDir?.path;
                      var file = File("${appDocPath!}/2.mp3");
                      file.delete();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 355),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(1000)),
                      width: downloadTapped
                          ? AppBar().preferredSize.height * .71
                          : 0,
                      height: downloadTapped
                          ? AppBar().preferredSize.height * .71
                          : 0,
                      child: Center(
                        child: Icon(
                          Icons.cancel,
                          color: const Color(0xff1d3f5e),
                          size: downloadTapped
                              ? AppBar().preferredSize.height * .71
                              : 0,
                        ),
                      ),
                    ),
                  ),
                ),
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 305),
                  top: _menuClicked ? 17 : 0,
                  left: _menuClicked ? 17 : 0,
                  right: _menuClicked ? 17 : 0,
                  child: AnimatedContainer(
                      curve: Curves.ease,
                      duration: const Duration(milliseconds: 355),
                      // height: menuClicked ? 0 : AppBar().preferredSize.height,
                      width: _menuClicked ? size.width - 22 : size.width,
                      decoration: BoxDecoration(
                          color: _menuClicked
                              ? const Color(0x001d3f5e)
                              : color_container_dark == Colors.black
                                  ? Colors.black
                                  : playingAudio
                                      ? color_container_dark
                                      : const Color(0xff1d3f5e),
                          borderRadius:
                              BorderRadius.circular(_menuClicked ? 31 : 0)),
                      child: _menuClicked
                          ? SettingsUI(
                              tag: "",
                              fontsize_english: widget.eng,
                              fontsize_arab: widget.ar,
                              theme: widget.bgColor,
                              surah_id: widget.surah_id,
                              toggleMenuClicked: () {
                                // Passes the setter function to WidgetB
                                setState(() {
                                  widget.ar = sharedPreferences
                                      .getDouble(("arabic_font_size"))!;
                                  widget.eng = sharedPreferences
                                      .getDouble(("english_font_size"))!;
                                  String theme = sharedPreferences
                                      .getString("theme mode")!;
                                  print("theme : $theme");
                                  theme == "dark"
                                      ? widget.bgColor = Colors.black
                                      : widget.bgColor = Colors.white;
                                  theme == "dark"
                                      ? bgColor = Colors.black
                                      : bgColor = Colors.white;
                                  initializeThemeStarters();
                                  _menuClicked = false;
                                  // init();
                                  checkLanguage()
                                      .whenComplete(() => startFetches());
                                });
                                print("menu clicked status: $_menuClicked");
                              },
                            )
                          // Column(
                          //   mainAxisSize: MainAxisSize.min,
                          //   children: [
                          //     Text(
                          //         "hkjhkkhsadakjshk",
                          //       style: TextStyle(
                          //         color: Colors.white
                          //       ),
                          //     ),
                          //   ],
                          // )
                          : SizedBox(
                              height: AppBar().preferredSize.height,
                              // width: size.width,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    Opacity(
                                      opacity: playingAudio ? 0 : .21,
                                      child: Image.asset(
                                        'lib/assets/images/headerDesignL.png',
                                        width: size.width * .25,
                                        fit: BoxFit.fitWidth,
                                      ),
                                    ),
                                    SizedBox(
                                      width: size.width * .5,
                                      height: AppBar().preferredSize.height,
                                      child: Column(
                                        // direction: Axis.vertical,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        // alignment: WrapAlignment.center,
                                        children: [
                                          Text.rich(
                                            textAlign: TextAlign.center,
                                            TextSpan(children: [
                                              WidgetSpan(
                                                  alignment:
                                                      PlaceholderAlignment
                                                          .middle,
                                                  child: Image.asset(
                                                    widget.image,
                                                    height: 13,
                                                    width: 13,
                                                  )),
                                              TextSpan(
                                                  text:
                                                      '  ${widget.surah_name}  ',
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily:
                                                          'varela-round.regular',
                                                      color: Colors.white,
                                                      fontSize: 13)),
                                              TextSpan(
                                                text: widget.arabic_name,
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: 'Diwanltr'),
                                              ),
                                            ]),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                              'Verses: ${widget.verses.length}  ',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      'varela-round.regular',
                                                  color: Colors.white,
                                                  fontSize: 11)),
                                        ],
                                      ),
                                    ),
                                    Opacity(
                                      opacity: playingAudio ? 0 : .21,
                                      child: Image.asset(
                                        'lib/assets/images/headerDesignR.png',
                                        width: size.width * .25,
                                        fit: BoxFit.fitWidth,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )),
                ),
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 355),
                  curve: Curves.decelerate,
                  top: AppBar().preferredSize.height * .5 -
                      ((AppBar().preferredSize.height * .55) * .5),
                  right: (((size.width * .25) -
                              (AppBar().preferredSize.height * .71)) *
                          .5) -
                      ((AppBar().preferredSize.height * .55) * .5),
                  // child: Icon(
                  //   Icons.settings,
                  //   color: Colors.white,
                  //   size: AppBar().preferredSize.height * .55,
                  // )
                  child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _menuClicked == false
                              ? _menuClicked = true
                              : _menuClicked = false;
                        });
                        // if (current_lang == "eng") {
                        //   setState(() {
                        //     current_lang = "ben";
                        //     lang_img = "lib/assets/images/ben.png";
                        //     startBNData();
                        //   });
                        // } else {
                        //   startENData();
                        //   setState(() {
                        //     current_lang = "eng";
                        //     lang_img = "lib/assets/images/eng.png";
                        //   });
                        // }
                      },
                      child: Visibility(
                        visible: !_menuClicked,
                        child: Icon(
                          Icons.settings,
                          color: Colors.white,
                          size: AppBar().preferredSize.height * .55,
                        ),
                      )

                      // AnimatedContainer(
                      //   duration: const Duration(milliseconds: 355),
                      //   height: AppBar().preferredSize.height * .55,
                      //   width: AppBar().preferredSize.height * .55,
                      //   decoration: BoxDecoration(
                      //       boxShadow: [
                      //         BoxShadow(
                      //           color: color_container_dark == Colors.black
                      //               ? Colors.transparent.withOpacity(.35)
                      //               : Colors.black.withOpacity(.15),
                      //           spreadRadius: 7,
                      //           blurRadius: 19,
                      //           offset: const Offset(
                      //               7, 7), // changes position of shadow
                      //         ),
                      //         BoxShadow(
                      //           color: color_container_dark == Colors.black
                      //               ? Colors.transparent.withOpacity(.35)
                      //               : Colors.black.withOpacity(.15),
                      //           spreadRadius: 7,
                      //           blurRadius: 19,
                      //           offset: const Offset(
                      //               -7, -7), // changes position of shadow
                      //         ),
                      //       ],
                      //       color: widget.bgColor == Colors.black
                      //           ? Colors.white
                      //           : Colors.black,
                      //       borderRadius: BorderRadius.circular(1000)),
                      //   child: Padding(
                      //     padding: const EdgeInsets.all(3.0),
                      //     child: Opacity(
                      //         opacity: .55,
                      //         child: Image.asset(
                      //           lang_img,
                      //           fit: BoxFit.cover,
                      //         )),
                      //   ),
                      // ),
                      ),
                ),
              ],
            ),
          ),
        ));
  }
}
