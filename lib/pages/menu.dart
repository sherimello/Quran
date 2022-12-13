import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

    Future<bool> showExitPopup() async {
      return await showDialog( //show confirm dialogue
        //the return value will be from "Yes" or "No" options
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(31)
          ),
          title: const Text('Exit App',
            style: TextStyle(
                fontFamily: 'varela-round.regular'
            ),),
          content: const Text('Do you want to exit?',
            style: TextStyle(
                fontFamily: 'varela-round.regular'
            ),),
          actions:[
            Padding(
              padding: const EdgeInsets.only(bottom: 11.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: const Color(0xff1d3f5e),
                  elevation: 7,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(31), // <-- Radius
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(false),
                //return false when click on "NO"
                child: const Text('No',

                  style: TextStyle(
                      fontFamily: 'varela-round.regular'
                  ),),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(right: 11.0, bottom: 11),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: const Color(0xff1d3f5e),
                  elevation: 7,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(31), // <-- Radius
                  ),
                ),
                onPressed: () => SystemChannels.platform.invokeMethod('SystemNavigator.pop'),
                //return true when click on "Yes"
                child: const Text('Yes',

                  style: TextStyle(
                      fontFamily: 'varela-round.regular'
                  ),),
              ),
            ),

          ],
        ),
      )??false; //if showDialouge had returned null, then return false
    }

    return WillPopScope(
      onWillPop: showExitPopup,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: AppBar().preferredSize.height * 2,
                ),
                Image.asset('lib/assets/images/quran icon.png', width: size.width * 0.15, height: size.height * 0.15,),
                SizedBox(
                  height: AppBar().preferredSize.height * .21,
                ),
                Text('Qur\'an',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Bismillah Script',
                  fontSize: size.width * .079,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5
                ),
                ),
                const Text(
                  '(search anniething)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'varela-round.regular',
                    fontWeight: FontWeight.bold,
                    height: 1,
                    color: Colors.black
                  ),
                ),
                SizedBox(
                  height: AppBar().preferredSize.height * 1.5,
                ),
                // Padding(
                //   padding: EdgeInsets.only(left: size.width * .085, bottom: 11),
                //   child: const Text('hear from الله :',
                //   style: TextStyle(
                //     fontFamily: 'varela-round.regular',
                //     fontWeight: FontWeight.bold,
                //     fontSize: 17,
                //     color: Colors.black
                //   ),
                //   ),
                // ),
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
        ),
      ),
    );
  }
}
