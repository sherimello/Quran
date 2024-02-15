import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:quran/classes/test_class.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TestingData extends StatefulWidget {

  final TestClass testClass;

  const TestingData({Key? key, required this.testClass}) : super(key: key);

  @override
  State<TestingData> createState() => _TestingDataState();
}

class _TestingDataState extends State<TestingData> {

  Future<void> init() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonString = prefs.getString('testClass')!;

    // Decode the JSON string
    Map<String, dynamic> decoded = jsonDecode(jsonString);

    // Create an instance of TestClass from the decoded JSON
    TestClass myClass = TestClass.fromJson(decoded);

    print(myClass.translated_verse);

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init();
    // print(widget.testClass.translated_verse);
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
