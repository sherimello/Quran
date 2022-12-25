import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quran/pages/home.dart';
import 'package:quran/pages/settings_card.dart';
import 'package:quran/pages/splash.dart';
import 'package:quran/pages/surah_DB_initializer.dart';
import 'package:quran/pages/surah_list.dart';
import 'package:quran/pages/surah_page.dart';
import 'package:quran/pages/test.dart';
import 'package:quran/pages/verse_image_preset.dart';
import 'package:quran/pages/verses_search.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xff1d3f5e)
  ));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ThemeProvider(
      initTheme: ThemeData(
        brightness: Brightness.light,
        disabledColor: const Color(0xfff4f4ff),
        cardColor: const Color(0xfffaf7f7),
      ),
      builder: (_,theme) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Qur\'an',
          theme: theme,
          home: const SurahList(),
          builder: (context, child) {
            return MediaQuery(data:
            MediaQuery.of(context).copyWith(textScaleFactor: 1.0), child: child!);
          },
          // home: const SurahPage(surah_id: '2',),
        );
      }
    );
  }
}