import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class AddSearchDBData extends StatefulWidget {
  const AddSearchDBData({Key? key}) : super(key: key);

  @override
  State<AddSearchDBData> createState() => _AddSearchDBDataState();
}

class _AddSearchDBDataState extends State<AddSearchDBData> {
  TextEditingController categoryController = TextEditingController();
  TextEditingController surah_number_Controller = TextEditingController();
  TextEditingController verse_number_Controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    addDua() async{
      final ref = FirebaseDatabase.instance.ref().child('search DB');
      ref.child(categoryController.text).push().set({
        'surah': surah_number_Controller.text,
        'verse': verse_number_Controller.text,
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
                  controller: surah_number_Controller,
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
                    labelText: "surah number",
                    hintText: 'e.g, 1',
                  ),
                  style: TextStyle(fontFamily: "varela-round.regular"),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(11.0),
                child: TextField(
                  controller: verse_number_Controller,
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
                    hintText: 'e.g, 155',
                  ),
                  style: const TextStyle(fontFamily: "varela-round.regular"),
                  textAlign: TextAlign.center,
                ),
              ),
              MaterialButton(
                onPressed: () {
                  addDua().whenComplete(() {
                    surah_number_Controller.clear();
                    verse_number_Controller.clear();
                  });
                },
                color: const Color(0xff1d3f5e),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11)),
                child: const Text(
                  'add verse',
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
