import 'package:flutter/material.dart';
import 'package:quran/pages/bookmark_folders.dart';
import 'package:quran/pages/settings_card.dart';

import '../hero_transition_handler/custom_rect_tween.dart';
import '../hero_transition_handler/hero_dialog_route.dart';
import 'favorite_verses.dart';

class Options extends StatefulWidget {

  final String tag;
  final Color theme;
  final double eng, ar;

  const Options({Key? key, required this.tag, required this.theme, required this.eng, required this.ar}) : super(key: key);

  @override
  State<Options> createState() => _OptionsState();
}

class _OptionsState extends State<Options> {

  bool value_snackbar = false;
  double snack_text_size = 0, snack_text_padding = 0;


  @override
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {

    var size = MediaQuery.of(context).size;
    AppBar appBar = AppBar();

    return SafeArea(child: Padding(
      padding: const EdgeInsets.all(19.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Hero(
            tag: widget.tag,
            createRectTween: (begin, end) {
              return CustomRectTween(begin: begin!, end: end!);
            },
            child: AnimatedContainer(
              curve: Curves.easeOut,
              duration: const Duration(milliseconds: 250),
              width: size.width - 38,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(31),
                color: const Color(0xff1d3f5e)
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 17.0, vertical: 17),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 11.0),
                                child: Container(
                                    width: appBar.preferredSize.height -
                                        appBar.preferredSize.height * .35,
                                    height: appBar.preferredSize.height -
                                        appBar.preferredSize.height * .35,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(1000),
                                        color: Colors.white.withOpacity(.5)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: Image.asset('lib/assets/images/quran icon.png'),
                                    )),
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: const [
                                  Text(
                                    'Qur\'an',
                                    style: TextStyle(
                                        fontFamily: 'Bismillah Script',
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.5,
                                        color: Colors.white,
                                        fontSize: 21),
                                  ),
                                ],
                              ),
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: GestureDetector(
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Icon(Icons.cancel_rounded, color: Colors.white,)),
                                ),
                              )
                            ],
                          ),
                        ),
                          const SizedBox(
                            height: 21,
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(HeroDialogRoute(
                                bgColor: Colors.transparent,
                                builder: (context) => BookmarkFolders(tag: widget.tag, from_where: "surah list", theme: widget.theme, eng: widget.eng, ar: widget.ar,),
                              ));
                            },
                            child: const Text.rich(
                                TextSpan(
                                    style: TextStyle(
                                        fontFamily:
                                        'varela-round.regular',
                                        fontSize: 21,
                                        color: Colors.white,
                                        fontWeight:
                                        FontWeight.bold),
                                    children: [
                                      WidgetSpan(
                                          alignment: PlaceholderAlignment.middle,child: Icon(Icons.bookmark_add, color: Colors.white,)),
                                      TextSpan(
                                          text: '  bookmark'
                                      ),
                                    ]
                                )
                            ),
                          ),
                          const SizedBox(
                            height: 17,
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(HeroDialogRoute(
                                bgColor: Colors.white.withOpacity(0.85),
                                builder: (context) => Center(child: FavoriteVerses(tag: widget.tag, from_where: "surah list", theme: widget.theme, eng: widget.eng, ar: widget.ar,)),
                              ));
                            },
                            child: const Text.rich(
                                TextSpan(
                                    style: TextStyle(
                                        fontFamily:
                                        'varela-round.regular',
                                        fontSize: 21,
                                        color: Colors.white,
                                        fontWeight:
                                        FontWeight.bold),
                                    children: [
                                      WidgetSpan(
                                          alignment: PlaceholderAlignment.middle,child: Icon(Icons.favorite_sharp, color: Colors.white,)),
                                      TextSpan(
                                          text: '  favorites'
                                      ),
                                    ]
                                )
                            ),
                          ),
                          const SizedBox(
                            height: 17,
                          ),
                          GestureDetector(
                            onTap: () {

                              Navigator.of(context).push(HeroDialogRoute(builder: (context)=> SettingsCard(tag: widget.tag, fontsize_english: widget.eng, fontsize_arab: widget.ar, theme: widget.theme,), bgColor: Colors.transparent,));

                              // setState(() {
                              //   snack_text_size = 13;
                              //   snack_text_padding = 39;
                              // });
                              //
                              // Future.delayed(const Duration(seconds: 3), () {
                              //   setState(() {
                              //     snack_text_size = 0;
                              //     snack_text_padding = 0;
                              //   });
                              // });

                              // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              //   content: Text('under development...'),
                              // ));
                            },
                            child: const Text.rich(
                                TextSpan(
                                    style: TextStyle(
                                        fontFamily:
                                        'varela-round.regular',
                                        fontSize: 21,
                                        color: Colors.white,
                                        fontWeight:
                                        FontWeight.bold),
                                    children: [
                                      WidgetSpan(
                                          alignment: PlaceholderAlignment.middle,child: Icon(Icons.settings, color: Colors.white,)),
                                      TextSpan(
                                          text: '  settings'
                                      ),
                                    ]
                                )
                            ),
                          ),
                          const SizedBox(
                            height: 19,
                          ),
                          AnimatedContainer(
                            curve: Curves.easeOut,
                            duration: const Duration(milliseconds: 250),
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(11), topRight: Radius.circular(11),
                              bottomLeft: Radius.circular(21), bottomRight: Radius.circular(21)),
                              color: Colors.white,
                            ),
                            width: size.width - 60,
                            height: snack_text_padding,
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 1000),
                                style: TextStyle(
                                    height: 1,
                                    color: const Color(0xff1d3f5e),
                                    fontFamily: 'varela-round.regular',
                                    fontSize: snack_text_size,
                                    fontWeight: FontWeight.bold
                                ),
                              child: Center(
                                child: Text(
                                  'under development...',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      height: 1,
                                      color: const Color(0xff1d3f5e),
                                      fontFamily: 'varela-round.regular',
                                      fontSize: snack_text_size,
                                      fontWeight: FontWeight.bold
                                  ),
                                ),
                              )

                            ),
                          ),
                          // const SizedBox(height: 11,),
                          SizedBox(
                            height: snack_text_size > 0 ? snack_text_size - 2 : snack_text_size,
                          ),
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
    ));
  }
}
