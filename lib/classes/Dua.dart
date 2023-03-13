class Dua {
  final String arabic, english, pronunciation, recommendation, surah, verse;

  Dua(
      {required this.arabic,
      required this.english,
      required this.pronunciation,
      required this.recommendation,
      required this.surah,
      required this.verse});

  factory Dua.fromMap(Map<dynamic, dynamic> map) {
    return Dua(
      arabic: map['arabic'].toString() ?? '',
      english: map['english'].toString() ?? '',
      pronunciation: map['pronunciation'].toString() ?? '',
      recommendation: map['recommendation'].toString() ?? '',
      surah: map['surah'].toString() ?? '',
      verse: map['verse'].toString() ?? '',
    );
  }
}
