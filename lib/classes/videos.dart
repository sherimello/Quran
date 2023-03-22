class Videos {
  final String url, description, title;

  Videos({
    required this.url,
    required this.description,
    required this.title,
  });

  factory Videos.fromMap(Map map) {
    return Videos(
      url: map['url'].toString(),
      description: map['description'].toString(),
      title: map['title'].toString(),
    );
  }
}
