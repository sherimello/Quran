import 'package:flutter/material.dart';
import 'package:quran/pages/bookmarks.dart';

import '../hero_transition_handler/custom_rect_tween.dart';
import '../hero_transition_handler/hero_dialog_route.dart';

class VerseOptionsCard extends StatefulWidget {

  final String tag;

  const VerseOptionsCard({Key? key, required this.tag}) : super(key: key);

  @override
  State<VerseOptionsCard> createState() => _VerseOptionsCardState();
}

class _VerseOptionsCardState extends State<VerseOptionsCard> {

  bool value_last_read = false, value_favorites = false;

  @override
  Widget build(BuildContext context) {

    bool addAsLastRead() {
      return false;
    }

    var size = MediaQuery.of(context).size;

    return SafeArea(
      child: Center(
        child: Hero(
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
              child: Padding(
                padding: const EdgeInsets.all(11.0),
                child: Material(
                  color: Colors.transparent,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        height: 21,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(HeroDialogRoute(
                            builder: (context) => Center(
                              child: Bookmarks(tag: widget.tag),
                            ),
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
                      const SizedBox(height: 11,),
                      Text.rich(
                          style: const TextStyle(
                              fontFamily:
                              'varela-round.regular',
                              fontSize: 21,
                              color: Colors.white,
                              fontWeight:
                              FontWeight.bold),
                        TextSpan(
                         children: [
                           WidgetSpan(
                               alignment: PlaceholderAlignment.middle,child: Checkbox(shape: RoundedRectangleBorder(
                             borderRadius: BorderRadius.circular(5.0),
                           ),
                             side: MaterialStateBorderSide.resolveWith(
                                   (states) => const BorderSide(width: 2, color: Colors.white),
                             ),
                             checkColor: const Color(0xff1d3f5e),  // color of tick Mark
                             activeColor: Colors.white,value: value_favorites, onChanged: (bool? value) {
                             setState(() {
                               value_favorites = value!;
                             });
                           },)),
                           const TextSpan(
                           text: 'add to favorites'
                           ),
                         ]
                        )
                      ),
                      Text.rich(
                          style: const TextStyle(
                              fontFamily:
                              'varela-round.regular',
                              fontSize: 21,
                              color: Colors.white,
                              fontWeight:
                              FontWeight.bold),
                          TextSpan(
                              children: [
                                WidgetSpan(
                                    alignment: PlaceholderAlignment.middle,child: Checkbox(shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                  side: MaterialStateBorderSide.resolveWith(
                                        (states) => const BorderSide(width: 2.0, color: Colors.white),
                                  ),
                                  checkColor: const Color(0xff1d3f5e),  // color of tick Mark
                                  activeColor: Colors.white,
                                  value: value_last_read, onChanged: (bool? value) {
                                  setState(() {
                                    value_last_read = value!;
                                  });
                                },)),
                                const TextSpan(
                                    text: 'mark as last read'
                                ),
                              ]
                          )
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
}
