import 'package:flutter/material.dart';
import 'package:quran/pages/surah_list.dart';
import 'package:quran/pages/verses_search.dart';

class Menu extends StatefulWidget {
  const Menu({Key? key}) : super(key: key);

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  @override
  Widget build(BuildContext context) {

    var size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.asset('lib/assets/images/quran icon.png', width: size.width * 0.15, height: size.height * 0.15,),
            const SizedBox(
              height: 35,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * .085),
              child: GestureDetector(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const SurahList()));
                },
                child: Container(
                  width: size.width,
                  // height: AppBar().preferredSize.height * .67,
                    decoration: BoxDecoration(
                      color: const Color(0xff1d3f5e),
                      borderRadius: BorderRadius.circular(13),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xff1d3f5e).withOpacity(0.15),
                          spreadRadius: 3,
                          blurRadius: 19,
                          offset: const Offset(0,0), // changes position of shadow
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 11.0, vertical: 11),
                        child: Center(
                          child: Text.rich(
                            textAlign: TextAlign.center,
                            TextSpan(
                                children: [
                                  WidgetSpan(
                                      alignment: PlaceholderAlignment.middle,
                                      child: Padding(
                                        padding: EdgeInsets.only(right: 7.0),
                                        child: Icon(Icons.menu_book_outlined, color: Colors.white, size: 19,),
                                      )),
                                  TextSpan(
                                      text: "  read Qur'an",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'varela-round.regular',
                                          fontSize: 13,
                                          color: Colors.white
                                      )
                                  ),
                                ]
                            ),
                          ),
                        ),
                      ),
                    )
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * .085, vertical: 7),
              child: GestureDetector(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const VersesSearch()));
                },
                child: Container(
                  width: size.width,
                  // height: AppBar().preferredSize.height * .67,
                    decoration: BoxDecoration(
                      color: const Color(0xff1d3f5e),
                      borderRadius: BorderRadius.circular(11),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xff1d3f5e).withOpacity(0.15),
                          spreadRadius: 3,
                          blurRadius: 19,
                          offset: const Offset(0,0), // changes position of shadow
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 11.0, vertical: 11),
                        child: Center(
                          child: Text.rich(
                            textAlign: TextAlign.center,
                            TextSpan(
                                children: [
                                  WidgetSpan(
                                      alignment: PlaceholderAlignment.middle,
                                      child: Padding(
                                        padding: EdgeInsets.only(right: 7.0),
                                        child: Icon(Icons.search, color: Colors.white, size: 19,),
                                      )),
                                  TextSpan(
                                      text: "  search in Qur'an",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'varela-round.regular',
                                          fontSize: 13,
                                          color: Colors.white
                                      )
                                  ),
                                ]
                            ),
                          ),
                        ),
                      ),
                    )
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
