import 'package:flutter/material.dart';
import 'package:quran/pages/bookmark_folders.dart';

import '../hero_transition_handler/custom_rect_tween.dart';
import '../hero_transition_handler/hero_dialog_route.dart';

class Options extends StatefulWidget {

  final String tag;

  const Options({Key? key, required this.tag}) : super(key: key);

  @override
  State<Options> createState() => _OptionsState();
}

class _OptionsState extends State<Options> {
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
            child: Container(
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
                                builder: (context) => BookmarkFolders(tag: widget.tag),
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
                            height: 11,
                          ),
                          GestureDetector(
                            onTap: () {
                              // Navigator.of(context).push(HeroDialogRoute(
                              //   builder: (context) => Center(
                              //     child: Bookmarks(tag: widget.tag),
                              //   ),
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
                                          alignment: PlaceholderAlignment.middle,child: Icon(Icons.favorite_sharp, color: Colors.white,)),
                                      TextSpan(
                                          text: '  favorites'
                                      ),
                                    ]
                                )
                            ),
                          ),
                          const SizedBox(
                            height: 11,
                          ),
                          GestureDetector(
                            onTap: () {
                              // Navigator.of(context).push(HeroDialogRoute(
                              //   builder: (context) => Center(
                              //     child: Bookmarks(tag: widget.tag),
                              //   ),
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
                          const SizedBox(height: 11,),
                          const SizedBox(
                            height: 21,
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
