class Book {
  String id;
  String title;
  String ownerId;
  int likes;
  final type = 1;
  String description;
  String imagePath;
  List<List<dynamic>> chapters;
  List tags;
  Book(
      {this.id = "",
      this.title = "",
      this.ownerId = "",
      this.chapters = const [],
      this.description = "",
      this.imagePath = "",
      this.likes = 0,
      this.tags = const []});
}

class Chapter {
  String id;
  String title;
  String bookId;
  List<dynamic> pageId;
  Chapter(
      {required this.id,
      required this.title,
      required this.bookId,
      required this.pageId});
}

class Pages {
  String id;
  String chapterId;
  String content;
  Pages({required this.id, required this.chapterId, required this.content});
}
