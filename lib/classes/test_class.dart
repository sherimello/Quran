class TestClass {
  List<Map<String, dynamic>> _verses;
  List<Map<String, dynamic>> _translated_verse;
  List<Map<String, dynamic>> _en_tafsir;
  List<Map<String, dynamic>> _bn_verses;
  List<Map<String, dynamic>> _transliteration;
  List<Map<String, dynamic>> _bn_tafsir;
  List<Map<String, dynamic>> _words_translations;
  List<Map<String, dynamic>> _surah_name_arabic;
  List<Map<String, dynamic>> _surah_name_english;
  List<Map<String, dynamic>> _sujood_surah_indices;
  List<Map<String, dynamic>> _sujood_verse_indices;


  TestClass(
      this._verses,
      this._translated_verse,
      this._en_tafsir,
      this._bn_verses,
      this._transliteration,
      this._bn_tafsir,
      this._words_translations,
      this._surah_name_arabic,
      this._surah_name_english,
      this._sujood_surah_indices,
      this._sujood_verse_indices,
      );

  List<Map<String, dynamic>> get translated_verse => _translated_verse;

  List<Map<String, dynamic>> get verses => _verses;

  List<Map<String, dynamic>> get en_tafsir => _en_tafsir;

  List<Map<String, dynamic>> get bn_verses => _bn_verses;

  List<Map<String, dynamic>> get transliteration => _transliteration;

  List<Map<String, dynamic>> get bn_tafsir => _bn_tafsir;

  List<Map<String, dynamic>> get words_translations => _words_translations;

  List<Map<String, dynamic>> get surah_name_arabic => _surah_name_arabic;

  List<Map<String, dynamic>> get surah_name_english => _surah_name_english;

  List<Map<String, dynamic>> get sujood_verse_indices => _sujood_verse_indices;

  List<Map<String, dynamic>> get sujood_surah_indices => _sujood_surah_indices;

  factory TestClass.fromJson(Map<String, dynamic> json) {
    return TestClass(
      json['verses'].cast<Map<String, dynamic>>(),
      json['translated_verse'].cast<Map<String, dynamic>>(),
      json['en_tafsir'].cast<Map<String, dynamic>>(),
      json['bn_verses'].cast<Map<String, dynamic>>(),
      json['transliteration'].cast<Map<String, dynamic>>(),
      json['bn_tafsir'].cast<Map<String, dynamic>>(),
      json['words_translations'].cast<Map<String, dynamic>>(),
      json['surah_name_arabic'].cast<Map<String, dynamic>>(),
      json['surah_name_english'].cast<Map<String, dynamic>>(),
      json['sujood_surah_indices'].cast<Map<String, dynamic>>(),
      json['sujood_verse_indices'].cast<Map<String, dynamic>>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'verses': _verses,
      'translated_verse': _translated_verse,
      'en_tafsir': _en_tafsir,
      'bn_verses': _bn_verses,
      'transliteration': _transliteration,
      'bn_tafsir': _bn_tafsir,
      'words_translations': _words_translations,
      'surah_name_arabic': _surah_name_arabic,
      'surah_name_english': _surah_name_english,
      'sujood_surah_indices': _sujood_surah_indices,
      'sujood_verse_indices': _sujood_verse_indices,
    };
  }

}