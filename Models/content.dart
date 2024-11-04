enum Contents { article, book }

class Content {
  final String title;
  final String contentid;
  final String ownerId;
  final String? imageId;
  final String description;
  final Contents c;
  final int likes;
  final List tags;

  const Content(
      {required this.title,
      required this.contentid,
      required this.ownerId,
      required this.description,
      required this.likes,
      required this.tags,
      this.imageId,
      required this.c});
}
