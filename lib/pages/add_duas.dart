import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class AddDuas extends StatefulWidget {
  const AddDuas({Key? key}) : super(key: key);

  @override
  State<AddDuas> createState() => _AddDuasState();
}

class _AddDuasState extends State<AddDuas> {
  TextEditingController categoryController = TextEditingController();
  TextEditingController arabicController = TextEditingController();
  TextEditingController englishController = TextEditingController();
  TextEditingController referenceController = TextEditingController();
  TextEditingController hadithController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    addDua() async{
      final ref = FirebaseDatabase.instance.ref().child('duas');
      ref.child(categoryController.text).push().set({
        'arabic': arabicController.text,
        'english': englishController.text,
        'reference': referenceController.text,
        'hadith': hadithController.text,
      }).asStream();
    }

    return Container(
      color: Colors.white,
      child: Material(
        color: Colors.transparent,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(11.0),
                child: TextField(
                  controller: categoryController,
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
                    labelText: 'dua category',
                    hintText: 'e.g, depression',
                  ),
                  style: TextStyle(fontFamily: "varela-round.regular"),
                  textAlign: TextAlign.center,
                ),
              ),
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
                  controller: referenceController,
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
                    labelText: 'reference',
                    hintText: 'e.g, Bukhari Vol.1 Book 12/802',
                  ),
                  style: TextStyle(fontFamily: "varela-round.regular"),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(11.0),
                child: TextField(
                  controller: hadithController,
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
                    labelText: 'hadith',
                    hintText: 'e.g, Ibn Abbas (R.A) said...',
                  ),
                  style: TextStyle(fontFamily: "varela-round.regular"),
                  textAlign: TextAlign.center,
                ),
              ),
              MaterialButton(
                onPressed: () {
                  addDua().whenComplete(() {
                    arabicController.clear();
                    englishController.clear();
                    referenceController.clear();
                    hadithController.clear();
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
    );
  }
}
