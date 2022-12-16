import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quran/pages/bookmarks.dart';
import 'package:quran/pages/verse_image_preset.dart';

import '../hero_transition_handler/custom_rect_tween.dart';
import '../hero_transition_handler/hero_dialog_route.dart';

class VerseOptionsCard extends StatefulWidget {

  final String tag, verse_english, verse_arabic, surah_name, verse_number, surah_number;

  const VerseOptionsCard({Key? key, required this.tag, required this.verse_english, required this.verse_arabic, required this.surah_name, required this.verse_number, required this.surah_number}) : super(key: key);

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
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(11.0),
                            child: GestureDetector(
                              onTap: () async{
                                Navigator.of(context).push(HeroDialogRoute(
                                  builder: (context) => Center(
                                    child: VerseImagePreset(tag: widget.tag, verse_english: widget.verse_english, verse_arabic: widget.verse_arabic, verse_number: widget.verse_number, surah_name: widget.surah_name, surah_number: widget.surah_number,),
                                  ),
                                ));
                                // await Clipboard.setData(const ClipboardData(text: "your text"));
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(1001),
                                  color: Colors.white,
                                ),
                                child: const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Icon(
                                      Icons.image,
                                      color: Color(0xff1d3f5e),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () async{
                              await Clipboard.setData(ClipboardData(text: "ALLAH (SWT) says:\n${widget.verse_arabic}\n${widget.verse_english}\n(surah ${widget.surah_name} - [${widget.surah_number}:${widget.verse_number}])"));
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(1001),
                                color: Colors.white,
                              ),
                              child: const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Icon(
                                    Icons.copy,
                                    color: Color(0xff1d3f5e),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ]
                      ),
                      const SizedBox(
                        height: 21,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(HeroDialogRoute(
                            builder: (context) => Center(
                              child: Bookmarks(tag: widget.tag, verse_arabic: widget.verse_arabic, verse_english: widget.verse_english, verse_id: widget.verse_number, surah_id: widget.surah_number,),
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
