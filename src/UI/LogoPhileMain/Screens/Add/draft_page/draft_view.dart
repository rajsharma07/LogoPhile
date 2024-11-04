import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:logophile/Models/article.dart';
import 'package:logophile/Models/book.dart';
import 'package:logophile/Models/content.dart';
import 'package:logophile/data/currentuserdata.dart';
import 'package:logophile/src/UI/LogoPhileMain/Screens/Add/widget/create_article.dart';
import 'package:logophile/src/UI/LogoPhileMain/Screens/Add/widget/create_book.dart';

class DraftView extends StatefulWidget {
  const DraftView(this.c, {super.key});
  final Content c;

  @override
  State<DraftView> createState() => _DraftViewState();
}

class _DraftViewState extends State<DraftView> {
  void gotocreate() async {
    final dbref = FirebaseDatabase.instance.ref("user").child(currentuser.id);
    if (widget.c.c == Contents.article) {
      Article a = Article();
      await dbref
          .child("content")
          .child(widget.c.contentid)
          .get()
          .then((value) {
        Map m = value.value as Map;
        a.title = m["title"];
        a.description = m["description"];
        a.content = m["content"];
        a.imagePath = m["imageUrl"];
        a.likes = m["likes"];
        a.tags = m["tags"] ?? [];
        a.uid = widget.c.contentid;
        return;
      });
      if (mounted) {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) {
            return CreateArticle(
              a: a,
            );
          },
        ));
      }
    } else {
      Book b = Book();
      await dbref
          .child("content")
          .child(widget.c.contentid)
          .child("metadata")
          .get()
          .then(
        (value) {
          Map m = value.value as Map;
          b.id = widget.c.contentid;
          b.title = m["title"];
          b.ownerId = currentuser.id;
          final l = m["chapters"] as List;
          b.chapters = l.map(
            (e) {
              return e as List<dynamic>;
            },
          ).toList();
          b.description = widget.c.description;
          b.imagePath = m["imageUrl"];
          b.likes = m["likes"];
          b.tags = m["tags"] ?? [];
        },
      );

      if (mounted) {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) {
            return CreateBook(
              b: b,
            );
          },
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        gotocreate();
      },
      title: Text(widget.c.title,
          style: Theme.of(context)
              .textTheme
              .headlineMedium!
              .copyWith(color: Theme.of(context).colorScheme.onPrimary)),
      subtitle: Text(widget.c.description),
      leading: (widget.c.imageId == "" || widget.c.imageId == null)
          ? null
          : Image.network(
              widget.c.imageId!,
              fit: BoxFit.contain,
              height: 150,
              width: MediaQuery.of(context).size.width * 0.3,
            ),
    );
  }
}
