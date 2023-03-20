import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class AddDuas extends StatefulWidget {
  const AddDuas({Key? key}) : super(key: key);

  @override
  State<AddDuas> createState() => _AddDuasState();
}

class _AddDuasState extends State<AddDuas> {
  TextEditingController pronunciationController = TextEditingController();
  TextEditingController arabicController = TextEditingController();
  TextEditingController englishController = TextEditingController();
  TextEditingController whenController = TextEditingController();
  TextEditingController surahNumberController = TextEditingController();
  TextEditingController verseNumberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    addDua() async{
      final ref = FirebaseDatabase.instance.ref().child('quranic duas');
      ref.push().set({
        'arabic': arabicController.text,
        'english': englishController.text,
        'pronunciation': pronunciationController.text,
        'recommendation': whenController.text,
        'surah': surahNumberController.text,
        'verse': verseNumberController.text,
      }).asStream();
    }

    return Container(
      color: Colors.white,
      child: Material(
        color: Colors.transparent,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(11.0),
                  child: TextField(
                    controller: arabicController,
                    scribbleEnabled: true,
                    enableIMEPersonalizedLearning: true,
                    enableInteractiveSelection: true,
                    enableSuggestions: true,
                    maxLines: 1,
                    decoration: InputDecoration(
                      focusColor: const Color(0xff1d3f5e),
                      fillColor: const Color(0xff1d3f5e),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: const Color(0xff1d3f5e))),
                      labelText: "arabic du'a",
                      hintText: 'e.g, ' 'اللّٰهُ أَكْبَر',
                    ),
                    style: TextStyle(fontFamily: "varela-round.regular"),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(11.0),
                  child: TextField(
                    controller: englishController,
                    scribbleEnabled: true,
                    enableIMEPersonalizedLearning: true,
                    enableInteractiveSelection: true,
                    enableSuggestions: true,
                    maxLines: 1,
                    decoration: InputDecoration(
                      focusColor: const Color(0xff1d3f5e),
                      fillColor: const Color(0xff1d3f5e),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: const Color(0xff1d3f5e))),
                      labelText: 'translation',
                      hintText: 'e.g, ALLAH is the greatest!',
                    ),
                    style: TextStyle(fontFamily: "varela-round.regular"),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(11.0),
                  child: TextField(
                    controller: pronunciationController,
                    scribbleEnabled: true,
                    enableIMEPersonalizedLearning: true,
                    enableInteractiveSelection: true,
                    enableSuggestions: true,
                    maxLines: 1,
                    decoration: InputDecoration(
                      focusColor: const Color(0xff1d3f5e),
                      fillColor: const Color(0xff1d3f5e),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: const Color(0xff1d3f5e))),
                      labelText: 'pronunciation',
                      hintText: '',
                    ),
                    style: TextStyle(fontFamily: "varela-round.regular"),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(11.0),
                  child: TextField(
                    controller: whenController,
                    scribbleEnabled: true,
                    enableIMEPersonalizedLearning: true,
                    enableInteractiveSelection: true,
                    enableSuggestions: true,
                    maxLines: 1,
                    decoration: InputDecoration(
                      focusColor: const Color(0xff1d3f5e),
                      fillColor: const Color(0xff1d3f5e),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: const Color(0xff1d3f5e))),
                      labelText: 'when to read',
                      hintText: '...',
                    ),
                    style: TextStyle(fontFamily: "varela-round.regular"),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(11.0),
                  child: TextField(
                    controller: surahNumberController,
                    scribbleEnabled: true,
                    enableIMEPersonalizedLearning: true,
                    enableInteractiveSelection: true,
                    enableSuggestions: true,
                    maxLines: 1,
                    decoration: InputDecoration(
                      focusColor: const Color(0xff1d3f5e),
                      fillColor: const Color(0xff1d3f5e),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide:
                          const BorderSide(color: Color(0xff1d3f5e))),
                      labelText: 'surah number',
                      hintText: '2',
                    ),
                    style: const TextStyle(fontFamily: "varela-round.regular"),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(11.0),
                  child: TextField(
                    controller: verseNumberController,
                    scribbleEnabled: true,
                    enableIMEPersonalizedLearning: true,
                    enableInteractiveSelection: true,
                    enableSuggestions: true,
                    maxLines: 1,
                    decoration: InputDecoration(
                      focusColor: const Color(0xff1d3f5e),
                      fillColor: const Color(0xff1d3f5e),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(color: Color(0xff1d3f5e))),
                      labelText: 'verse number',
                      hintText: '127',
                    ),
                    style: const TextStyle(fontFamily: "varela-round.regular"),
                    textAlign: TextAlign.center,
                  ),
                ),
                MaterialButton(
                  onPressed: () {
                    addDua().whenComplete(() {
                      arabicController.clear();
                      englishController.clear();
                      pronunciationController.clear();
                      whenController.clear();
                      verseNumberController.clear();
                      surahNumberController.clear();
                    });
                  },
                  color: const Color(0xff1d3f5e),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11)),
                  child: const Text(
                    'add dua',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
