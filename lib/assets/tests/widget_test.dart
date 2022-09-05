import 'package:flutter/material.dart';

class WTest extends StatefulWidget {
  const WTest({Key? key}) : super(key: key);

  @override
  State<WTest> createState() => _WTestState();
}

class _WTestState extends State<WTest> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: const Center(
          child: Text(
          'لَمْ يَكُنِ ٱلَّذِينَ كَفَرُوا۟ مِنْ أَهْلِ ٱلْكِتَٰبِ وَٱلْمُشْرِكِينَ مُنفَكِّينَ حَتَّىٰ تَأْتِيَهُمُ ٱلْبَيِّنَة',
            style: TextStyle(
                color: Colors.black,
                fontSize: 25,
                // fontWeight: FontWeight.bold,
                fontFamily:
                'Quran karim 114'),
          ),
        ),
      ),
    );
  }
}
