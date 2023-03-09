import 'package:flutter/material.dart';

class DuaCategoryCard extends StatelessWidget {
  final String category_name, footer_text;
  const DuaCategoryCard({Key? key, required this.category_name, required this.footer_text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Container(
      width: size.width,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(31), color: Colors.white),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(11.0),
              child: Text(
                category_name,
                style: TextStyle(
                    fontFamily: "varela-round.regular",
                    fontSize: size.width * .055,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 11.0),
              child: Text(
                footer_text,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: "varela-round.regular",
                    fontSize: size.width * .031,
                    fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
