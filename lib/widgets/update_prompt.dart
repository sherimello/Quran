import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../classes/my_sharedpreferences.dart';
import '../hero_transition_handler/custom_rect_tween.dart';

class UpdatePrompt extends StatefulWidget {
  final String url, title, content, negativeButtonText;

  const UpdatePrompt({Key? key, required this.url, required this.title, required this.content, required this.negativeButtonText}) : super(key: key);

  @override
  State<UpdatePrompt> createState() => _UpdatePromptState();
}

class _UpdatePromptState extends State<UpdatePrompt> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery
        .of(context)
        .size;

    launchURL() async {
      print(widget.url);
      if (!await launchUrl(
        Uri.parse(widget.url),
        mode: LaunchMode.externalApplication,
      )) {
        throw Exception('Could not launch ${widget.url}');
      }
    }

    return Stack(
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(19.0),
            child: Hero(
              tag: 'options',
              createRectTween: (begin, end) {
                return CustomRectTween(begin: begin!, end: end!);
              },
              child: Material(
                color: Colors.transparent,
                child: AnimatedContainer(
                  width: size.width,
                  duration: const Duration(milliseconds: 555),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(31),
                      color: Colors.white),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 11.0),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(11.0),
                            child: Text(
                              widget.title,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontFamily: 'varela-round.regular',
                                  fontWeight: FontWeight.bold,
                                  fontSize: size.width * .051),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(11.0),
                            child: Text(
                              widget.content,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontFamily: 'Rounded_Elegance',
                                  // fontWeight: FontWeight.bold,
                                  fontSize: size.width * .041),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(11.0),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      MySharedPreferences().setStringValue("disable update auto prompt", "true");
                                      Navigator.of(context).pop();
                                    },
                                    child: Container(
                                      // FlatButton widget is used to make a text to work like a button
                                      decoration: BoxDecoration(
                                          color: Colors.black,
                                          borderRadius:
                                          BorderRadius.circular(11)),
                                      // function used to perform after pressing the button
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 11.0, vertical: 7),
                                        child: Text(
                                          widget.negativeButtonText,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              height: 0,
                                              color: Colors.white,
                                              fontFamily:
                                              'varela-round.regular',
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 17,
                                  ),
                                  Visibility(
                                    visible: widget.negativeButtonText == 'great!' ? false : true,
                                    child: GestureDetector(
                                      onTap: () =>
                                          setState(() {
                                            launchURL();
                                          }),
                                      child: Container(
                                        // FlatButton widget is used to make a text to work like a button
                                        decoration: BoxDecoration(
                                            color: Colors.black,
                                            borderRadius:
                                            BorderRadius.circular(11)),
                                        // function used to perform after pressing the button
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 11.0, vertical: 7),
                                          child: Text(
                                            'download',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                height: 0,
                                                color: Colors.white,
                                                fontFamily:
                                                'varela-round.regular',
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
