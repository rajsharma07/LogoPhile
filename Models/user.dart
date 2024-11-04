class User {
  String id;
  String email;
  String name;
  String imageId;
  String about;
  int likes;
  int followers;
  List interest;
  List liked;
  List posts;
  List following = [];
  List saved = [];
  User({
    this.id = "",
    this.email = "",
    this.name = "user",
    this.imageId = "",
    this.about = "no data",
    this.likes = 0,
    this.followers = 0,
    this.interest = const ["others"],
    this.liked = const [],
    this.posts = const [],
  });
}
