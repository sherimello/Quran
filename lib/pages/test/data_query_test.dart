import 'package:flutter/material.dart';

class DataQueryTest extends StatefulWidget {
  const DataQueryTest({Key? key}) : super(key: key);

  @override
  State<DataQueryTest> createState() => _DataQueryTestState();
}

class _DataQueryTestState extends State<DataQueryTest> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {  },
          child: Text(
            ''
          ),
        ),
      ),
    );
  }
}
