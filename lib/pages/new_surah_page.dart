import 'package:arabic_numbers/arabic_numbers.dart';
import 'package:flutter/material.dart';

class UpdatedSurahPage extends StatefulWidget {
  final String surah_id, image, surah_name, arabic_name, sujood_index, verse_numbers;
  final List<Map> verses, translated_verse;

  const UpdatedSurahPage({Key? key, required this.surah_id, required this.image, required this.surah_name, required this.arabic_name, required this.sujood_index, required this.verse_numbers, required this.verses, required this.translated_verse}) : super(key: key);

  @override
  State<UpdatedSurahPage> createState() => _UpdatedSurahPageState();
}

class _UpdatedSurahPageState extends State<UpdatedSurahPage> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    ArabicNumbers arabicNumber = ArabicNumbers();
    bool isPortraitMode() {
      return size.height > size.width ? true : false;
    }

    return Scaffold(
      backgroundColor: const Color(0xff1d3f5e),
      appBar: AppBar(
        backgroundColor: const Color(0xff1d3f5e),
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        elevation: 0,
        centerTitle: true,
        title: Row(
          children: [
            Image.asset('lib/assets/images/headerDesignL.png', width: size.width * .25, fit: BoxFit.fitHeight,),
            SizedBox(
              width: size.width * .5,
              height: AppBar().preferredSize.height,
              child: Column(
                // direction: Axis.vertical,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                // alignment: WrapAlignment.center,
                children: [Text.rich(
                    textAlign: TextAlign.center,
                    TextSpan(
                        children: [
                          WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: Image.asset(widget.image, height: 13, width: 13,)),
                          TextSpan(
                              text: '  ${widget.surah_name}  ',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'varela-round.regular',
                                  fontSize: 13
                              )
                          ),
                          TextSpan(
                            text:
                            widget.arabic_name,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Diwanltr'),
                          ),
                        ]
                    )
                ),
                  Text(
                      'Verses: ${widget.verses.length}  ',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'varela-round.regular',
                          fontSize: 11
                      )
                  ),
                ],
              ),
            ),
            Image.asset('lib/assets/images/headerDesignR.png', width: size.width * .25, fit: BoxFit.fitHeight,),
          ],
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              width: size.width,
              color: const Color(0xfff4f4ff),
              height: AppBar().preferredSize.height,
              padding: const EdgeInsets.all(0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      'k',
                      textAlign: TextAlign.center,
                      // textScaleFactor: ,
                      style: TextStyle(
                          inherit: false,
                          color: Colors.black,
                          fontFamily: '110_Besmellah',
                          fontStyle: FontStyle.normal,
                          fontSize: 30,
                          height: isPortraitMode() ? size.height / size.width : size.width / size.height
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: widget.surah_id == '1' || widget.surah_id == '9'? const EdgeInsets.all(0) : EdgeInsets.only(top: AppBar().preferredSize.height),
              child: Container(
                color: widget.verses.length.isOdd
                    ? const Color(0xfff4f4ff)
                    : const Color(0xfffaf7f7),
                child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: widget.verses.length,
                    itemBuilder: (BuildContext context, int index) {
                      print('${isPortraitMode() ? size.height / size.width : size.width / size.height}');
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
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0, 7, 0, 7),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(1.0),
                                      child: Image.asset(
                                        'lib/assets/images/surahIndex.png',
                                        height: isPortraitMode() ? size.width * .10 : size.height * .10,
                                        width: isPortraitMode() ? size.width * .10 : size.height * .10,
                                      ),
                                    ),
                                    Text.rich(
                                      textAlign: TextAlign.center,
                                      TextSpan(
                                        text: '${index + 1}',
                                        style: TextStyle(
                                          color: const Color(0xff1d3f5e),
                                          fontSize: isPortraitMode() ? size.width * .023 : size.height * .023,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'varela-round.regular',
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.stretch,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text.rich(
                                              textDirection: TextDirection.rtl,
                                              textAlign: TextAlign.right,
                                              textScaleFactor:
                                              (isPortraitMode() ? size.height / size.width : size.width / size.height),
                                              TextSpan(children: [
                                                TextSpan(
                                                  text: widget.verses.isNotEmpty
                                                      ? '${widget.verses[index]['text']}  '
                                                      : '',
                                                  // 'k',
                                                  style: const TextStyle(
                                                    wordSpacing: 2,
                                                    fontFamily:
                                                    'Al Majeed Quranic Font_shiped',
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                const TextSpan(
                                                  text: '﴿  ',
                                                  style: TextStyle(
                                                    wordSpacing: 3,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily:
                                                    'Al Majeed Quranic Font_shiped',
                                                    fontSize: 07,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: arabicNumber
                                                      .convert(index + 1),
                                                  style: const TextStyle(
                                                      wordSpacing: 3,
                                                      fontSize: 07,
                                                      fontWeight: FontWeight.bold
                                                  ),
                                                ),
                                                const TextSpan(
                                                  text: '  ﴾        ',
                                                  style: TextStyle(
                                                      wordSpacing: 3,
                                                      fontFamily:
                                                      'Al Majeed Quranic Font_shiped',
                                                      fontSize: 07,
                                                      fontWeight: FontWeight.bold),
                                                ),
                                                index + 1 == int.parse(widget.sujood_index) ? WidgetSpan(
                                                    alignment: PlaceholderAlignment.bottom,
                                                    child: Image.asset('lib/assets/images/sujoodIcon.png', width: 12, height: 12,)) : WidgetSpan(child: SizedBox())
                                              ])),
                                          const SizedBox(height: 11,),
                                          Text.rich(
                                              textAlign: TextAlign.start,
                                              TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text: widget.translated_verse[index]['text'] + ' [${widget.surah_id}:${index + 1}]',
                                                      style: const TextStyle(
                                                          fontFamily: 'varela-round.regular'
                                                      ),
                                                    ),
                                                    index + 1 == int.parse(widget.sujood_index) ?
                                                    const TextSpan(
                                                        text: '\n\nverse of prostration ***',
                                                        style: TextStyle(
                                                            color: Color(0xff518050),
                                                            fontWeight: FontWeight.bold,
                                                            fontFamily: 'varela-round.regular',
                                                            fontSize: 15
                                                        )
                                                    ): const TextSpan()
                                                  ]
                                              ))
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                ),
              ),
            ),
          ],
        ),
      )
    );
  }
}
