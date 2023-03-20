import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:quran/widgets/dua_category_card.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'dart:io';
import '../hero_transition_handler/custom_rect_tween.dart';
import 'package:path_provider/path_provider.dart';

import '../hero_transition_handler/hero_dialog_route.dart';
import '../pages/duas.dart';


class DuaList extends StatefulWidget {
  final double eng, ar;
  const DuaList({Key? key, required this.eng, required this.ar}) : super(key: key);

  @override
  State<DuaList> createState() => _DuaListState();
}

class _DuaListState extends State<DuaList> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var status = PermissionStatus.denied;

    Future<bool?> askForStorageManagementPermission() async {
      status = await Permission.storage.status;
      if(status.isDenied) {
        await Permission.storage.request().then((value) {
          if(status.isDenied) {
            askForStorageManagementPermission();
          }
          else {
            return true;
          }
        });
      }
      return true;
    }
    downloadSurahMP3() async {
      var yt = YoutubeExplode();
      var manifest = await yt.videos.streamsClient.getManifest('Dpp1sIL1m5Q');
      var streamInfo = manifest.audioOnly.withHighestBitrate();
      if (streamInfo != null) {
        if(await askForStorageManagementPermission()==true) {
          final Directory? appDocDir = await getExternalStorageDirectory();
          var appDocPath = appDocDir?.path;
          // Get the actual stream
          var stream = yt.videos.streamsClient.get(streamInfo);

          // Open a file for writing.
          var file = File(
              "${appDocPath!}/number1.mp3");
          var fileStream = file.openWrite();

          // Pipe all the content of the stream into the file.
          await stream.pipe(fileStream);

          // Close the file.
          await fileStream.flush();
          await fileStream.close();
        }
        else{
          print("denied");
        }

      }
      print(streamInfo);

      // Close the YoutubeExplode's http client.
      yt.close();
    }

    return Stack(children: [
      Center(
          child: Padding(
              padding: const EdgeInsets.all(19.0),
              child: Hero(
                  tag: 'animate',
                  createRectTween: (begin, end) {
                    return CustomRectTween(begin: begin!, end: end!);
                  },
                  child: Material(
                      color: Colors.transparent,
                      child: Container(
                        width: size.width,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(31),
                            color: const Color(0xff1d3f5e)),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "categories",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: "varela-round.regular",
                                    fontWeight: FontWeight.bold,
                                    fontSize: size.width * .055),
                              ),
                            ),
                            ListView.builder(
                                scrollDirection: Axis.vertical,
                                physics: const BouncingScrollPhysics(),
                                itemCount: 3,
                                shrinkWrap: true,
                                itemBuilder: (BuildContext context, int index) {
                                  return Padding(
                                    padding: index == 2? const EdgeInsets.fromLTRB(15,3.5,15,15) : const EdgeInsets.symmetric(horizontal: 15.0, vertical: 3.5),
                                    child: GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).push(HeroDialogRoute(
                                            bgColor: Colors.black.withOpacity(0.85),
                                            builder: (context) => Center(
                                                child: Duas(title: "after fard prayer", eng: widget.eng, ar: widget.ar, theme: Color(0xff000000),)),
                                          ));
                                          // downloadSurahMP3();
                                        },
                                        child: const DuaCategoryCard(category_name: "after fard prayer", footer_text: "Call on Me; I will answer your (Prayer)\n(Surah Ghafir, 40:60)")),
                                  );
                                })
                          ],
                        ),
                      )))))
    ]);
  }
}
