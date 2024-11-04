import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:logophile/Models/article.dart';
import 'package:logophile/Models/book.dart';
import 'package:logophile/data/currentuserdata.dart';
import 'package:logophile/src/UI/LogoPhileMain/Screens/Add/widget/create_article.dart';
import 'package:logophile/src/UI/LogoPhileMain/Screens/Add/widget/create_book.dart';

class Draftview extends StatefulWidget {
  const Draftview(
      {super.key,
      required this.id,
      required this.imageUrl,
      required this.title,
      required this.type,
      required this.description});
  final String id;
  final String imageUrl;
  final String title;
  final int type;
  final String description;

  @override
  State<Draftview> createState() => _DraftviewState();
}

class _DraftviewState extends State<Draftview> {
  void gotocreate() async {
    final dbref = FirebaseDatabase.instance.ref("user").child(currentuser.id);
    if (widget.type == 0) {
      Article a = Article();
      await dbref.child("content").child(widget.id).get().then((value) {
        Map m = value.value as Map;
        a.title = m["title"];
        a.description = m["description"];
        a.content = m["content"];
        a.imagePath = m["imageUrl"];
        a.likes = m["likes"];
        a.tags = m["tags"] ?? [];
        a.uid = widget.id;
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
          .child(widget.id)
          .child("metadata")
          .get()
          .then(
        (value) {
          Map m = value.value as Map;
          b.id = widget.id;
          b.title = m["title"];
          b.ownerId = currentuser.id;
          final l = m["chapters"] as List;
          b.chapters = l.map(
            (e) {
              return e as List<dynamic>;
            },
          ).toList();
          b.description = widget.description;
          b.imagePath = m["imageUrl"];
          b.likes = m["likes"];
          b.tags = m["tags"] ?? [];
        },
      );
      if (context.mounted) {
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
    return InkWell(
      onTap: () {
        gotocreate();
      },
      child: SingleChildScrollView(
        child: Column(
          children: [
            widget.imageUrl == ""
                ? const Icon(Icons.photo)
                : Image.network(
                    widget.imageUrl,
                    fit: BoxFit.contain,
                    height: MediaQuery.of(context).size.height * 0.10,
                    width: MediaQuery.of(context).size.width * 0.4,
                  ),
            const SizedBox(
              height: 20,
            ),
            Text(widget.title)
          ],
        ),
      ),
    );
  }
}
