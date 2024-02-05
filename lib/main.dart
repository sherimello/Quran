import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quran/pages/add_duas.dart';
import 'package:quran/pages/add_search_DB_data.dart';
import 'package:quran/pages/splash.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  // SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  // if (sharedPreferences.containsKey('theme mode')) {
  //   sharedPreferences.getString("theme mode") == "light"
  //       ? SystemChrome.setSystemUIOverlayStyle(
  //           const SystemUiOverlayStyle(statusBarColor: Color(0xff1d3f5e)))
  //       : SystemChrome.setSystemUIOverlayStyle(
  //           const SystemUiOverlayStyle(statusBarColor: Color(0xff000000)));
  // }

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
        builder: (_, theme) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Qur\'an',
            theme: theme,
            // home: const AddDuas(),
            home: const Splash(),
            builder: (context, child) {
              return MediaQuery(
                  data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                  child: child!);
            },
            // home: const SurahPage(surah_id: '2',),
          );
        });
  }
}
