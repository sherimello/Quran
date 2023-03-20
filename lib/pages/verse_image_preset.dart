import 'dart:typed_data';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:widgets_to_image/widgets_to_image.dart';

import '../hero_transition_handler/custom_rect_tween.dart';

class VerseImagePreset extends StatefulWidget {

  final String tag, verse_english, verse_arabic, verse_number, surah_number, surah_name;
  final Color theme;

  const VerseImagePreset({Key? key, required this.verse_english, required this.verse_arabic, required this.verse_number, required this.surah_number, required this.surah_name, required this.tag, required this.theme}) : super(key: key);

  @override
  State<VerseImagePreset> createState() => _VerseImagePresetState();
}

class _VerseImagePresetState extends State<VerseImagePreset> {

  double top_heading_size = 11, arabic_size = 31, english_size = 19, surah_tag = 11;
  bool value_arabic_text = true, value_english_tag = true, value_reference_tag = true;
  WidgetsToImageController controller = WidgetsToImageController();
  late Uint8List bytes;
  var bgColor = Colors.white, color_favorite_and_index = const Color(0xff1d3f5e), color_main_text = Colors.black,
  color_check_color = Colors.white;


  assignmentForLightMode() {
    bgColor = Colors.white;
    color_favorite_and_index = const Color(0xff1d3f5e);
    color_main_text = Colors.black;
    color_check_color = Colors.white;
  }

  assignmentForDarkMode() {
    bgColor = Colors.black;
    color_favorite_and_index = Colors.white;
    color_main_text = Colors.white;
    color_check_color = Colors.black;
  }

  void initializeThemeStarters() {
    if(widget.theme == Colors.white) {
      assignmentForLightMode();
    }
    else {
      assignmentForDarkMode();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initializeThemeStarters();
  }

  @override
  Widget build(BuildContext context) {

    var size = MediaQuery.of(context).size;

    Widget verseImage() {
      return WidgetsToImage(
        controller: controller,
        child: Material(
          color: Colors.transparent,
          child: Center(
              child: Container(
                width: size.width,
                height: size.width - 38,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(31),
                  color: bgColor,
                  border: Border.all(color: const Color(0xff1d3f5e), width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xff1d3f5e).withOpacity(0.1),
                      spreadRadius: 5,
                      blurRadius: 17,
                      offset: const Offset(0, 0), // changes position of shadow
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(11.0),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Opacity(
                        opacity: 0.19,
                        child: Image.asset('lib/assets/images/quran icon.png',
                          width: size.width * .55,
                          height: size.width * .55,
                        ),
                      ),
                      SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(
                              height: 21,
                            ),
                            Visibility(
                              visible: widget.surah_name != "",
                              child: Text(
                                'ALLAH (SWT) says:',
                                style: TextStyle(
                                    fontFamily: 'varela-round.regular',
                                    fontWeight: FontWeight.bold,
                                    fontSize: top_heading_size,
                                  color: color_main_text
                                ),
                              ),
                            ),
                            value_arabic_text ? Visibility(
                              visible: widget.surah_name == "",
                              child: const SizedBox(
                                height: 11,
                              ),
                            ) : const SizedBox(),
                            value_arabic_text ? Text(
                              widget.verse_arabic,
                              // 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
                              textDirection: TextDirection.rtl,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                wordSpacing: 2,
                                height: 1.5,
                                fontFamily:
                                'Al Majeed Quranic Font_shiped',
                                fontSize: arabic_size,
                                color: color_main_text
                              ),
                            ) : const SizedBox(),
                            value_english_tag ? const SizedBox(
                              height: 21,
                            ) : const SizedBox(),
                            value_english_tag ? Text(
                              widget.verse_english,
                              // 'In the name of ALLAH, The Most Merciful, The Specially Merciful.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontFamily: 'varela-round.regular',
                                  fontWeight: FontWeight.bold,
                                  color: color_favorite_and_index,
                                  fontSize: english_size,
                              ),
                            ) : const SizedBox(),
                            value_reference_tag ? const SizedBox(
                              height: 11,
                            ) : const SizedBox(),
                            value_reference_tag ? Text(
                              widget.surah_name == "" ?
                                  widget.verse_number == "0" ?
                                      widget.surah_number
                                  : "Qur'an [${widget.surah_number}:${widget.verse_number}]"
                                  :
                              'Surah ${widget.surah_name} | [${widget.surah_number}:${widget.verse_number}]',
                              style: TextStyle(
                                  fontFamily: 'Rounded_Elegance',
                                  fontWeight: FontWeight.bold,
                                  fontSize: surah_tag,
                                color: color_main_text
                              ),
                              textAlign: TextAlign.center,
                            ) : const SizedBox(),
                            const SizedBox(
                              height: 21,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )),
        ),
      );
    }

    ScaffoldFeatureController<SnackBar, SnackBarClosedReason> snackBar(String message) {
      return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
      ));
    }

    Future<void> saveImage() async {

      await [Permission.storage].request();

      if (await Permission.storage.isGranted) {
        final time = DateTime.now()
            .toIso8601String()
            .replaceAll('.', '_')
            .replaceAll(':', '_');
        final name = 'qur_an_$time';
        await ImageGallerySaver.saveImage(bytes.buffer.asUint8List(), name: name);
        snackBar("saved to gallery");
      }
      else{
        snackBar('storage permission denied!');
      }
    }
    return Scaffold(
      backgroundColor: bgColor,
      floatingActionButton: FloatingActionButton(
        onPressed: () async{
          final bytes = await controller.capture();
          setState(() {
            this.bytes = bytes!;
            saveImage();
          });
          print(bytes?.length.toString());
        },
        backgroundColor: const Color(0xff1d3f5e),
        child: const Icon(
          Icons.save_alt,
          color: Colors.white,
        ),
      ),
      body: SafeArea(
          child: Column(
            children: [
              Material(
                color: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.all(19.0),
                  child: Hero(
                      tag: widget.tag,
                      createRectTween: (begin, end) {
                        return CustomRectTween(begin: begin!, end: end!);
                      },
                      child: verseImage()),
                ),
              ),
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(19.0),
                      child: Text(
                        '***adjust text size(s) with the help of the "+"/"-" button. otherwise it\'s very likely that you won\'t get all the information in your picture.' ,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'varela-round.regular',
                            color: color_main_text,
                            // color: Color(0xff1d3f5e),
                            fontStyle: FontStyle.italic
                        ),),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: (){
                            setState(() {
                              top_heading_size -= .25;
                              arabic_size -= 1;
                              english_size -= 1;
                              surah_tag -= .25;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(11),
                                color: const Color(0xff1d3f5e)
                            ),
                            // width: 45,
                            // height: 45,
                            child: const Center(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.minimize_rounded,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 11,),
                        GestureDetector(
                          onTap: (){
                            setState(() {
                              top_heading_size += .25;
                              arabic_size += 1;
                              english_size += 1;
                              surah_tag += .25;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(11),
                                color: const Color(0xff1d3f5e)
                            ),
                            // width: 45,
                            // height: 45,
                            child: const Center(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.add,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 19,
                    ),
                    Text.rich(
                        style: TextStyle(
                            fontFamily:
                            'varela-round.regular',
                            fontSize: 21,
                            color: color_main_text,
                            fontWeight:
                            FontWeight.bold),
                        TextSpan(
                            children: [
                              WidgetSpan(
                                  alignment: PlaceholderAlignment.middle,child: Checkbox(shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                                side: MaterialStateBorderSide.resolveWith(
                                      (states) => BorderSide(width: 2.0, color: color_favorite_and_index),
                                ),
                                checkColor: color_check_color,  // color of tick Mark
                                activeColor: color_favorite_and_index,
                                value: value_arabic_text, onChanged: (bool? value) {
                                  setState(() {
                                    value_arabic_text = value!;
                                  });
                                },)),
                              const TextSpan(
                                  text: 'add arabic text'
                              ),
                            ]
                        )
                    ),
                    Text.rich(
                        style: const TextStyle(
                            fontFamily:
                            'varela-round.regular',
                            fontSize: 21,
                            color: Colors.black,
                            fontWeight:
                            FontWeight.bold),
                        TextSpan(
                            children: [
                              WidgetSpan(
                                  alignment: PlaceholderAlignment.middle,child: Checkbox(shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                                side: MaterialStateBorderSide.resolveWith(
                                      (states) => BorderSide(width: 2.0, color: color_favorite_and_index),
                                ),
                                checkColor: color_check_color,  // color of tick Mark
                                activeColor: color_favorite_and_index,
                                value: value_english_tag, onChanged: (bool? value) {
                                  setState(() {
                                    value_english_tag = value!;
                                  });
                                },)),
                              TextSpan(
                                  text: 'add english text',
                                  style: TextStyle(
                                    color: color_main_text,
                                    fontFamily:
                                    'varela-round.regular',
                                  )
                              ),
                            ]
                        )
                    ),
                    Text.rich(
                        style: TextStyle(
                            fontFamily:
                            'varela-round.regular',
                            fontSize: 21,
                            color: color_main_text,
                            fontWeight:
                            FontWeight.bold),
                        TextSpan(
                            children: [
                              WidgetSpan(
                                  alignment: PlaceholderAlignment.middle,child: Checkbox(shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                                side: MaterialStateBorderSide.resolveWith(
                                      (states) => BorderSide(width: 2.0, color: color_favorite_and_index),
                                ),
                                checkColor: color_check_color,  // color of tick Mark
                                activeColor: color_favorite_and_index,
                                value: value_reference_tag, onChanged: (bool? value) {
                                  setState(() {
                                    value_reference_tag = value!;
                                  });
                                },)),
                              TextSpan(
                                  text: 'add reference tag',
                                style: TextStyle(
                                  color: color_main_text,
                                  fontFamily:
                                  'varela-round.regular',
                                )
                              ),
                            ]
                        )
                    ),
                    const SizedBox(
                      height: 19,
                    ),
                  ],
                ),
              ),

            ],
          )),
    );
  }
}
