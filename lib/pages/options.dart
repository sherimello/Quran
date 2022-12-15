import 'package:flutter/material.dart';

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
                        children: [
                          const SizedBox(
                            height: 21,
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
