import 'package:flutter/material.dart';

class Duas extends StatefulWidget {
  final String title;
  final double eng, ar;

  const Duas({Key? key, required this.title, required this.eng, required this.ar}) : super(key: key);

  @override
  State<Duas> createState() => _DuasState();
}

class _DuasState extends State<Duas> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    AppBar appBar = AppBar();
    var size = MediaQuery.of(context).size;

    return Container(
      width: size.width,
      height: size.height,
      color: Colors.white,
      child: Material(
        color: Colors.transparent,
        child: SafeArea(
          child: Stack(children: [
            Container(
              color: const Color(0xff1d3f5e),
              child: Row(
                children: [
                  Image.asset(
                    'lib/assets/images/headerDesignL.png',
                    width: size.width * .25,
                    height: appBar.preferredSize.height,
                    fit: BoxFit.fitWidth,
                  ),
                  SizedBox(
                      width: size.width * .5,
                      height: AppBar().preferredSize.height,
                      child: Column(
                          // direction: Axis.vertical,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          // alignment: WrapAlignment.center,
                          children: [
                            Text(
                                textAlign: TextAlign.center,
                                "du'as: ${widget.title}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontFamily: 'varela-round.regular',
                                    fontSize: 13)),
                          ])),
                  Image.asset(
                    'lib/assets/images/headerDesignR.png',
                    width: size.width * .25,
                    height: appBar.preferredSize.height,
                    fit: BoxFit.fitWidth,
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: appBar.preferredSize.height),
              child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: 3,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      decoration: BoxDecoration(
                          color: index.isEven
                              ? const Color(0xfff4f4ff)
                              : Colors.white),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              "اللّٰهُ أَكْبَر",
                                              // 'k',
                                              textDirection:
                                              TextDirection
                                                  .rtl,
                                              textAlign:
                                              TextAlign
                                                  .center,
                                              textScaleFactor: size.height / size.width,
                                              style: TextStyle(
                                                // wordSpacing: 2,
                                                fontFamily:
                                                    'Al Majeed Quranic Font_shiped',
                                                fontSize: widget.ar,
                                              ),
                                            ),
                                          ])),
                                  const SizedBox(
                                    height: 11,
                                  ),
                                  Text(
                                    "ALLAH is the greatest!",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontFamily: 'varela-round.regular',
                                    fontSize: widget.eng
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  }),
            ),
          ]),
        ),
      ),
    );
  }
}
