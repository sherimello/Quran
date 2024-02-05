import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sqflite/sqflite.dart';

import '../../classes/my_sharedpreferences.dart';
import 'package:path/path.dart';

class UserData {
  late final FirebaseAuth _auth;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  UserCredential? userCredential;
  late Database database1;
  late String path;
  late List<Map> bookmarkFolders = [], favorites = [];
  int bookmarkFolderSize = 0;
  List<Map> verses = [];

  Future<void> initiateDB() async {
    // Get a location using getDatabasesPath
    var databasesPath = await getDatabasesPath();
    path = join(databasesPath, 'quran.db');

    database1 = await openDatabase(path);

    print(database1.isOpen);
  }

  initBookmarkBackup(DatabaseReference ref) async {
    await addUserData(ref);
    // await pushValuesThatAreOnlyLocalToTheDevice(ref, bookmarkFoldersCopy);
    await updateTheCurrentLocalBookmarkDatabase(ref);
    await uploadFavorites(ref);
  }

  Future<void> fetchBookmarkFolders() async {
    // print(widget.verse_numbers);
    // verses.clear();

    await initiateDB().whenComplete(() async {
      bookmarkFolders =
          await database1.rawQuery('SELECT folder_name FROM bookmark_folders');
    }).whenComplete(() {
      bookmarkFolders = bookmarkFolders;
      bookmarkFolderSize = bookmarkFolders.length;
    });
  }

  Future<void> fetchFavorites() async {
    // print(widget.verse_numbers);
    // verses.clear();

    if (!database1.isOpen) {
      await initiateDB().whenComplete(() async {
        favorites = await database1.rawQuery('SELECT * FROM favorites');
      }).whenComplete(() {
        favorites = favorites;
      });
    } else {
      favorites = await database1.rawQuery('SELECT * FROM favorites');
    }
  }

  void handleSignOut(FirebaseAuth auth) async {
    await googleSignIn.signOut();
    await auth.signOut();
    print("User Signed Out");
  }

  Future<UserCredential?> handleSignIn() async {
    // Firebase.initializeApp();
    _auth = FirebaseAuth.instance;
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount!.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      userCredential = await _auth.signInWithCredential(credential);

      var userNode = _auth.currentUser?.email
          ?.substring(0, _auth.currentUser?.email?.indexOf('@'))
          .replaceAll('.', 'dot')
          .replaceAll('#', 'hash')
          .replaceAll('\$', 'dollar')
          .replaceAll('[', 'leftThirdBracket')
          .replaceAll(']', 'rightThirdBracket');
      MySharedPreferences().setStringValue("userName", userNode!);

      DatabaseReference ref =
          FirebaseDatabase.instance.ref('users').child(userNode);

      initBookmarkBackup(ref);

      bool flag = await ref.once().then((value) => value.snapshot.exists);

      if (!flag) await ref.set("");

      return userCredential;
    } catch (error) {
      print("sign in error: $error");
      return null;
    }
  }

  List<Map> bookmarkFoldersCopy = [];

  addUserData(DatabaseReference ref) async {
    DataSnapshot dataSnapshot =
        await ref.child("bookmarks").once().then((snapshot) {
      return snapshot.snapshot;
    });

    Map<dynamic, dynamic>? values =
        dataSnapshot.value as Map<dynamic, dynamic>?;
    await fetchBookmarkFolders();
    bookmarkFoldersCopy = [...bookmarkFolders];
    if (values != null) {
      values.forEach((key, value) async {
        // folders.add(key);
        // allBookmarks.add(value);
        verses = [];
        verses = await database1.rawQuery(
            'SELECT surah_id, verse_id FROM bookmarks WHERE folder_name = ?',
            [key]);

        if (verses.isNotEmpty) {
          if (bookmarkFolders.any((map) => map.containsValue(key))) {
            bookmarkFoldersCopy.removeWhere((map) => map.containsValue(key));
            for (int i = 0; i < verses.length; i++) {
              if (!value.containsValue(
                  "${verses[i]["surah_id"].toString()}:${verses[i]["verse_id"]}")) {
                ref.child("bookmarks/$key").push().set(
                    "${verses[i]["surah_id"].toString()}:${verses[i]["verse_id"]}");
              }
            }
            print(
                "Key: $key and verses are ${verses.length} and ${verses[0]["surah_id"].toString()}:${verses[0]["verse_id"]}");
          }
        }
        // verses.clear();
      });
      if (verses.isNotEmpty) {
        await pushValuesThatAreOnlyLocalToTheDevice(ref, bookmarkFoldersCopy);
      }
    } else {
      await pushValuesThatAreOnlyLocalToTheDevice(ref, bookmarkFoldersCopy);
      print("No data found");
    }
  }

  pushValuesThatAreOnlyLocalToTheDevice(
      DatabaseReference ref, List<Map> bookmarkFoldersCopy) async {
    if (bookmarkFoldersCopy.isNotEmpty) {
      print("inside...${bookmarkFoldersCopy.length}");
      for (int i = 0; i < bookmarkFoldersCopy.length; i++) {
        verses = [];
        verses = await database1.rawQuery(
            'SELECT surah_id, verse_id FROM bookmarks WHERE folder_name = ?',
            [bookmarkFoldersCopy[i]["folder_name"]]);
        if (verses.isNotEmpty) {
          for (int j = 0; j < verses.length; j++) {
            print(bookmarkFoldersCopy.length);
            ref
                .child("bookmarks/${bookmarkFoldersCopy[i]["folder_name"]}")
                .push()
                .set(
                    "${verses[j]["surah_id"].toString()}:${verses[j]["verse_id"]}");
          }
        }
      }
    }
  }

  String currentFolderNameOfServerBookmark = "";

  updateTheCurrentLocalBookmarkDatabase(DatabaseReference ref) async {
    // List<Map> arabic_verses = await database1.rawQuery(
    //     'SELECT text FROM verses WHERE lang_id = 1');
    // List<Map> translated_verse = await database1.rawQuery(
    //     'SELECT text FROM verses WHERE lang_id = 2');
    await database1.rawDelete("DELETE FROM bookmark_folders");
    await database1.rawDelete("DELETE FROM bookmarks");
    print("innnnnnnnnnnnnn");

    DataSnapshot dataSnapshot =
        await ref.child("bookmarks").once().then((snapshot) {
      return snapshot.snapshot;
    });

    // Iterate over the children and get their keys
    Map<dynamic, dynamic>? values =
        dataSnapshot.value as Map<dynamic, dynamic>?;

    if (values != null) {
      values.forEach((key1, value) async {
        currentFolderNameOfServerBookmark = key1;
        await database1.transaction((txn) async {
          await txn
              .rawInsert('INSERT INTO bookmark_folders VALUES (?)', [key1]);
        });
      });
      values.forEach((key, value1) async {
        if (value1 is Map) {
          value1.forEach((key2, element) async {
            var surah = element.toString().substring(0, element.indexOf(":"));
            var ayat = element.toString().substring(element.indexOf(":") + 1);
            print(surah);
            print(ayat);
            List<Map> arabic_verses = await database1.rawQuery(
                'SELECT text FROM verses WHERE lang_id = 1 AND surah_id = ? AND verse_id = ?',
                [surah, ayat]);

            List<Map> translated_verse = await database1.rawQuery(
                'SELECT text FROM verses WHERE lang_id = 2 AND surah_id = ? AND verse_id = ?',
                [surah, ayat]);
            await database1.transaction((txn) async {
              await txn.rawInsert(
                  'INSERT INTO bookmarks VALUES (?, ?, ?, ?, ?)', [
                key,
                arabic_verses[0]['text'],
                translated_verse[0]['text'],
                surah,
                ayat
              ]);
            });
          });
        }
      });
    }
  }

  List<Map> favoritesTemp = [];

  uploadFavorites(DatabaseReference ref) async {
    DataSnapshot dataSnapshot =
        await ref.child("favorites").once().then((snapshot) {
      return snapshot.snapshot;
    });

    Map<dynamic, dynamic>? values =
        dataSnapshot.value as Map<dynamic, dynamic>?;

    await fetchFavorites();
    favoritesTemp = [...favorites];

    if (values != null) {
      values.forEach((key, value) {
        if (favorites.any((map) => map.containsValue(value))) {
          favoritesTemp.removeWhere((element) => element.containsValue(value));
        } else {
          //i don't know.....
        }
      });
      await handleLocalFavoritesDB(ref, favoritesTemp);
    } else {
      await handleLocalFavoritesDB(ref, favoritesTemp);
    }
  }

  handleLocalFavoritesDB(DatabaseReference ref, List<Map> favoritesTemp) async {
    print("hello ${favoritesTemp.length}");
    for (int i = 0; i < favoritesTemp.length; i++) {

      DatabaseEvent snapshotEvent = await ref.child("favorites").orderByValue().equalTo("${favoritesTemp[i]['surah_id']}:${favoritesTemp[i]['verse_id']}").once();

      if (snapshotEvent.snapshot.value != null) {
        print('The value exists in the database.');
      } else {
        print('The value does not exist in the database.');
        await ref.child("favorites").push().set(
            "${favoritesTemp[i]['surah_id']}:${favoritesTemp[i]['verse_id']}");
        // await ref.child("favorites").push().set(favorite);
      }

    }





    DataSnapshot dataSnapshot =
        await ref.child("favorites").once().then((snapshot) {
      return snapshot.snapshot;
    });

    Map<dynamic, dynamic>? values =
        dataSnapshot.value as Map<dynamic, dynamic>?;
    database1.rawDelete('DELETE FROM favorites');
    values!.forEach((key, value) async {
      var surah = value.toString().substring(0, value.indexOf(":"));
      var ayat = value.toString().substring(value.indexOf(":") + 1);
      List<Map> arabic_verses = await database1.rawQuery(
          'SELECT text FROM verses WHERE lang_id = 1 AND surah_id = ? AND verse_id = ?',
          [surah, ayat]);

      List<Map> translated_verse = await database1.rawQuery(
          'SELECT text FROM verses WHERE lang_id = 2 AND surah_id = ? AND verse_id = ?',
          [surah, ayat]);
      await database1.transaction((txn) async {
        await txn.rawInsert('INSERT INTO favorites VALUES (?, ?, ?, ?)', [
          arabic_verses[0]['text'],
          translated_verse[0]['text'],
          int.parse(surah),
          int.parse(ayat)
        ]);
      });
    });
  }

  addTheNewlyAddedBookmarkToServer(String bookmark, bookmarkFolder) async {
    String userName = await MySharedPreferences().getStringValue("userName");
    DatabaseReference ref =
        FirebaseDatabase.instance.ref('users').child(userName);
    await ref.child("bookmarks/$bookmarkFolder").push().set(bookmark);
  }

  addTheNewlyAddedFavoriteToServer(String favorite) async {
    print("inside atnafts");
    String userName = await MySharedPreferences().getStringValue("userName");
    DatabaseReference ref =
        FirebaseDatabase.instance.ref('users').child("$userName");
    // Query to find the value
    Query query = ref.child("favorites").orderByValue().equalTo(favorite);

    query.once().then((snapshot) async {
      if (snapshot.snapshot.exists) {
        print('The value $favorite exists in the database.');
      } else {
        print('The value $favorite does not exist in the database.');
        await ref.child("favorites").push().set(favorite);
      }
    }).catchError((error) {
      print('Error: $error');
    });






    // Check if the value exists
    // DatabaseEvent snapshotEvent = await ref.orderByValue().equalTo(favorite).once();
    //
    // if (snapshotEvent.snapshot.exists) {
    //   print('The value exists in the database.');
    // } else {
    //   print('The value does not exist in the database.');
    //   await ref.child("favorites").push().set(favorite);
    // }




    // DataSnapshot dataSnapshot = await ref.once().then((snapshot) {
    //   return snapshot.snapshot;
    // });
    // List<String> favsTemp = [];
    // Map<dynamic, dynamic>? values =
    // dataSnapshot.value as Map<dynamic, dynamic>?;
    // if(values != null) {
    //   values.forEach((key, value) {
    //     favsTemp.add(value);
    //   });
    //
    //     await ref.child("favorites").push().set(favorite);
    // }

  }

  removeBookmarkFromServer(String bookmark, bookmarkFolder) async {
    // String key = "";
    // String userName = await MySharedPreferences().getStringValue("userName");
    // DatabaseReference ref =
    // FirebaseDatabase.instance.ref('users').child("$userName/bookmarks");
    // // Query to find the value
    // Query query = ref.child(bookmarkFolder).orderByValue().equalTo(bookmark);
    //
    // query.once().then((snapshot) async {
    //   if (snapshot.snapshot.exists) {
    //     print('The value $bookmark exists in the database.');
    //     key = snapshot.snapshot.key.toString();
    //     await ref.child(bookmarkFolder).child(key).remove();
    //   }
    // }).catchError((error) {
    //   print('Error: $error');
    // });

    String userName = await MySharedPreferences().getStringValue("userName");

    DatabaseReference ref = FirebaseDatabase.instance
        .ref('users')
        .child(userName)
        .child("bookmarks/$bookmarkFolder");
    DataSnapshot dataSnapshot = await ref.once().then((snapshot) {
      return snapshot.snapshot;
    });
    Map<dynamic, dynamic>? values =
        dataSnapshot.value as Map<dynamic, dynamic>?;

    if (values != null) {
      values.forEach((key, value) async {
        if (value == bookmark) {
          await ref.child(key).remove();
          return;
        }
      });
    }
  }
  removeFavoriteFromServer(String favorite) async {
    // String key = "";
    // String userName = await MySharedPreferences().getStringValue("userName");
    // DatabaseReference ref =
    // FirebaseDatabase.instance.ref('users').child("$userName/bookmarks");
    // // Query to find the value
    // Query query = ref.child(bookmarkFolder).orderByValue().equalTo(bookmark);
    //
    // query.once().then((snapshot) async {
    //   if (snapshot.snapshot.exists) {
    //     print('The value $bookmark exists in the database.');
    //     key = snapshot.snapshot.key.toString();
    //     await ref.child(bookmarkFolder).child(key).remove();
    //   }
    // }).catchError((error) {
    //   print('Error: $error');
    // });

    String userName = await MySharedPreferences().getStringValue("userName");

    DatabaseReference ref = FirebaseDatabase.instance
        .ref('users')
        .child(userName)
        .child("favorites");
    DataSnapshot dataSnapshot = await ref.once().then((snapshot) {
      return snapshot.snapshot;
    });
    Map<dynamic, dynamic>? values =
        dataSnapshot.value as Map<dynamic, dynamic>?;

    if (values != null) {
      values.forEach((key, value) async {
        if (value == favorite) {
          await ref.child(key).remove();
          return;
        }
      });
    }
  }
}
