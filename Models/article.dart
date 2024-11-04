class Article {
  String uid;
  String title;
  String ownerId;
  String description;
  String content;
  String imagePath;
  final type = 0;
  int likes;
  List tags;
  Article(
      {this.uid = "",
      this.title = "",
      this.ownerId = "",
      this.description = "",
      this.content = "",
      this.imagePath = "",
      this.likes = 0,
      this.tags = const []});
}
