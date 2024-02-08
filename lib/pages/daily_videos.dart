// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:quran/classes/videos.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:youtube_explode_dart/youtube_explode_dart.dart';
//
// //https://img.youtube.com/vi/<insert-youtube-video-id-here>/0.jpg  --  Just add your youtube video Id here
//
// class DailyDuas extends StatefulWidget {
//   final Color theme;
//
//   const DailyDuas({Key? key, required this.theme}) : super(key: key);
//
//   @override
//   State<DailyDuas> createState() => _DailyDuasState();
// }
//
// class _DailyDuasState extends State<DailyDuas> {
//   List<String> url = [], description = [], titles = [];
//
//   // Future<void> getTitles() async {
//   //   for (int i = 0; i < description.length; i++) {
//   //     var video = await YoutubeExplode().videos.get('https://youtube.com/watch?v=${url[i]}'); // Returns a Video instance.
//   //     titles.add(video.title);
//   //   }
//   //   setState(() {
//   //     titles = titles;
//   //   });
//   // }
//
//   Future<void> fetchVideos() async {
//     final snapshot =
//         await FirebaseDatabase.instance.ref().child("daily videos").get();
//     final Map map = Map<String, dynamic>.from(snapshot.value as Map);
//     // final Map<dynamic, dynamic> url_map = (snapshot.value as Map)["url"];
//     // final Map<dynamic, dynamic> desc_map = (snapshot.value as Map)["description"];
//     // url = url_map as List<String>;
//     // description = desc_map as List<String>;
//     map.forEach((key, value) async {
//       final video = Videos.fromMap(value);
//       url.add(video.url);
//       description.add(video.description);
//       titles.add(video.title);
//     });
//     setState(() {
//       url = url;
//       description = description;
//       titles = titles;
//     });
//     // getTitles();
//   }
//
//   void changeStatusBarColor(int colorCode) {
//     setState(() {
//       SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
//           statusBarColor: Color(colorCode)
//       ));
//     });
//   }
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     changeStatusBarColor(widget.theme == Colors.black ? 0xff000000 : 0xff1d3f5e);
//     fetchVideos();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     var size = MediaQuery.of(context).size;
//     AppBar appBar = AppBar();
//
//     return Scaffold(
//       backgroundColor:
//           widget.theme == Colors.black ? Colors.black : Colors.white,
//       body: SafeArea(
//         child: Stack(
//           children: [
//             Visibility(
//               visible: titles.isEmpty,
//               child: const Center(
//                 child: CircularProgressIndicator(
//                   color: Color(0xff1d3f5e),
//                 ),
//               ),
//             ),
//             Container(
//               color: widget.theme == Colors.black
//                   ? Colors.black
//                   : const Color(0xff1d3f5e),
//               child: Row(
//                 children: [
//                   Opacity(
//                     opacity: .35,
//                     child: Image.asset(
//                       'lib/assets/images/headerDesignL.png',
//                       width: size.width * .25,
//                       height: appBar.preferredSize.height,
//                       fit: BoxFit.fitWidth,
//                     ),
//                   ),
//                   SizedBox(
//                       width: size.width * .5,
//                       height: AppBar().preferredSize.height,
//                       child: Column(
//                           // direction: Axis.vertical,
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           // alignment: WrapAlignment.center,
//                           children: [
//                             Text(
//                                 textAlign: TextAlign.center,
//                                 "videos (${url.length})",
//                                 // "${duas.length} du'as for you",
//                                 style: TextStyle(
//                                     height: 0,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.white,
//                                     fontFamily: 'varela-round.regular',
//                                     fontSize: size.width * .051)),
//                           ])),
//                   Opacity(
//                     opacity: .35,
//                     child: Image.asset(
//                       'lib/assets/images/headerDesignR.png',
//                       width: size.width * .25,
//                       height: appBar.preferredSize.height,
//                       fit: BoxFit.fitWidth,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Padding(
//               padding: EdgeInsets.only(top: appBar.preferredSize.height),
//               child: ListView.builder(
//                   scrollDirection: Axis.vertical,
//                   physics: const BouncingScrollPhysics(),
//                   itemCount: titles.isEmpty ? 0 : titles.length,
//                   shrinkWrap: true,
//                   itemBuilder: (BuildContext context, int index) {
//
//                     return Padding(
//                       padding: index == 0
//                           ? const EdgeInsets.fromLTRB(11, 11, 11, 3.5)
//                           : index == 12
//                               ? const EdgeInsets.fromLTRB(11, 3.5, 11, 11)
//                               : const EdgeInsets.fromLTRB(11, 3.5, 11, 3.5),
//                       child: GestureDetector(
//                         onTap: () {
//                           launchUrl(
//                               Uri.parse(
//                                   "https://www.youtube.com/watch?v=${url[index]}"),
//                               mode: LaunchMode.externalApplication);
//                         },
//                         child: Container(
//                           width: size.width,
//                           decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(31),
//                               color: widget.theme == Colors.black
//                                   ? const Color(0xff333333)
//                                   : const Color(0xffdedede)),
//                           child: Padding(
//                             padding: const EdgeInsets.all(11.0),
//                             child: Column(
//                               mainAxisSize: MainAxisSize.min,
//                               crossAxisAlignment:
//                                   CrossAxisAlignment.start,
//                               children: [
//                                 Container(
//                                   width: size.width,
//                                   height: size.width * .45,
//                                   decoration: BoxDecoration(
//                                       borderRadius: BorderRadius.circular(31),
//                                       color: Colors.black),
//                                   child: ClipRRect(
//                                       borderRadius: BorderRadius.circular(31),
//                                       child: Image.network(
//                                         "https://img.youtube.com/vi/${url[index]}/0.jpg",
//                                         fit: BoxFit.cover,
//                                       )),
//                                 ),
//                                 const SizedBox(height: 11,),
//                                 Padding(
//                                   padding: const EdgeInsets.symmetric(horizontal: 11.0),
//                                   child: Text(
//                                     titles[index],
//                                     style: TextStyle(
//                                         color:
//                                             widget.theme == Colors.black
//                                                 ? Colors.white
//                                                 : Color(0xff1d3f5e),
//                                         fontFamily:
//                                             "varela-round.regular",
//                                         fontSize: size.width * .041,
//                                         fontWeight: FontWeight.bold),
//                                   ),
//                                 ),
//                                 const SizedBox(
//                                   height: 7,
//                                 ),
//                                 Padding(
//                                   padding: const EdgeInsets.symmetric(horizontal: 11.0),
//                                   child: Text(
//                                     'description',
//                                     style: TextStyle(
//                                         color:
//                                             widget.theme == Colors.black
//                                                 ? Colors.white
//                                                 : const Color(0xff000000),
//                                         fontFamily:
//                                             "varela-round.regular",
//                                         fontSize: size.width * .041,
//                                         fontWeight: FontWeight.bold),
//                                   ),
//                                 ),
//                                 Padding(
//                                   padding: const EdgeInsets.fromLTRB(11.0, 5, 11, 11),
//                                   child: Text(
//                                     description[index],
//                                     style: TextStyle(
//                                         color:
//                                             widget.theme == Colors.black
//                                                 ? Colors.white38
//                                                 : Color(0x75000000),
//                                         fontFamily:
//                                             "varela-round.regular",
//                                         fontSize: size.width * .031,
//                                         fontWeight: FontWeight.bold),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     );
//                   }),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class DailyDuas extends StatefulWidget {
  final Color theme;

  const DailyDuas({Key? key, required this.theme}) : super(key: key);

  @override
  State<DailyDuas> createState() => _DailyDuasState();
}

class _DailyDuasState extends State<DailyDuas> {
  List<String> url = [], description = [], titles = [];
  bool isLoading = true;

  Future<void> fetchVideos() async {
    final snapshot =
        await FirebaseDatabase.instance.ref().child("daily videos").get();
    final Map map = Map<String, dynamic>.from(snapshot.value as Map);

    map.forEach((key, value) async {
      final video = Videos.fromMap(value);
      url.add(video.url);
      description.add(video.description);
      titles.add(video.title);
    });

    setState(() {
      isLoading = false;
    });
  }

  void changeStatusBarColor(int colorCode) {
    setState(() {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Color(colorCode),
      ));
    });
  }

  @override
  void initState() {
    super.initState();
    changeStatusBarColor(
        widget.theme == Colors.black ? 0xff000000 : 0xff1d3f5e);
    fetchVideos().whenComplete(() => setState(() {
          url = url.reversed.toList();
          description = description.reversed.toList();
          titles = titles.reversed.toList();
        }));
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    AppBar appBar = AppBar();

    return Scaffold(
      backgroundColor:
          widget.theme == Colors.black ? Colors.black : Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Visibility(
              visible: isLoading,
              child: const Center(
                child: CircularProgressIndicator(
                  color: Color(0xff1d3f5e),
                ),
              ),
            ),
            Container(
              color: widget.theme == Colors.black
                  ? Colors.black
                  : const Color(0xff1d3f5e),
              child: Row(
                children: [
                  Opacity(
                    opacity: .35,
                    child: Image.asset(
                      'lib/assets/images/headerDesignL.png',
                      width: size.width * .25,
                      height: appBar.preferredSize.height,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                  SizedBox(
                      width: size.width * .5,
                      height: AppBar().preferredSize.height,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text("videos (${url.length})",
                                style: TextStyle(
                                    height: 0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontFamily: 'varela-round.regular',
                                    fontSize: size.width * .051)),
                          ])),
                  Opacity(
                    opacity: .35,
                    child: Image.asset(
                      'lib/assets/images/headerDesignR.png',
                      width: size.width * .25,
                      height: appBar.preferredSize.height,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: appBar.preferredSize.height),
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                physics: const BouncingScrollPhysics(),
                itemCount: titles.isEmpty ? 0 : titles.length,
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: index == 0
                        ? const EdgeInsets.fromLTRB(11, 11, 11, 3.5)
                        : index == 12
                            ? const EdgeInsets.fromLTRB(11, 3.5, 11, 11)
                            : const EdgeInsets.fromLTRB(11, 3.5, 11, 3.5),
                    child: GestureDetector(
                      onTap: () {
                        launchUrl(
                            Uri.parse(
                                "https://www.youtube.com/watch?v=${url[index]}"),
                            mode: LaunchMode.externalApplication);
                      },
                      child: Container(
                        width: size.width,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(31),
                            color: widget.theme == Colors.black
                                ? const Color(0xff333333)
                                : const Color(0xffdedede)),
                        child: Padding(
                          padding: const EdgeInsets.all(11.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: size.width,
                                height: size.width * .45,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(31),
                                    color: Colors.black),
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(31),
                                    child: CachedNetworkImage(
                                      imageUrl:
                                          "https://img.youtube.com/vi/${url[index]}/0.jpg",
                                      fit: BoxFit.cover,
                                    )),
                              ),
                              const SizedBox(
                                height: 11,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 11.0),
                                child: Text(
                                  titles[index],
                                  style: TextStyle(
                                      color: widget.theme == Colors.black
                                          ? Colors.white
                                          : const Color(0xff1d3f5e),
                                      fontFamily: "varela-round.regular",
                                      fontSize: size.width * .041,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(
                                height: 7,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 11.0),
                                child: Text(
                                  'description',
                                  style: TextStyle(
                                      color: widget.theme == Colors.black
                                          ? Colors.white
                                          : const Color(0xff000000),
                                      fontFamily: "varela-round.regular",
                                      fontSize: size.width * .041,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(11.0, 5, 11, 11),
                                child: Text(
                                  description[index],
                                  style: TextStyle(
                                      color: widget.theme == Colors.black
                                          ? Colors.white38
                                          : Color(0x75000000),
                                      fontFamily: "varela-round.regular",
                                      fontSize: size.width * .031,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Videos {
  final String url;
  final String description;
  final String title;

  Videos({
    required this.url,
    required this.description,
    required this.title,
  });

  factory Videos.fromMap(Map<dynamic, dynamic> map) {
    return Videos(
      url: map['url'] ?? '',
      description: map['description'] ?? '',
      title: map['title'] ?? '',
    );
  }
}

// Add the rest of your code...
