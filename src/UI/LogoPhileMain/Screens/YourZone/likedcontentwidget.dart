import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:logophile/Models/article.dart';
import 'package:logophile/Models/book.dart';
import 'package:logophile/src/UI/LogoPhileMain/Screens/contentDisplay/article_display.dart';
import 'package:logophile/src/UI/LogoPhileMain/Screens/contentDisplay/bookdsplay.dart';

class Likedcontentwidget extends StatefulWidget {
  const Likedcontentwidget({super.key, required this.contentid});
  final String contentid;

  @override
  State<Likedcontentwidget> createState() {
    return _LikedcontentwidgetState();
  }
}

class _LikedcontentwidgetState extends State<Likedcontentwidget> {
  String imageurl = "";
  String title = "";
  String ownerid = "";
  int type = 2;
  String contentid = "";
  void getdata() async {
    final dbref =
        FirebaseDatabase.instance.ref("content").child(widget.contentid);
    imageurl = await dbref.child("imageUrl").get().then((v) {
      if (v.value == null) {
        return "";
      }
      return v.value as String;
    });
    await dbref.get().then(
      (value) {
        if (value.value != null) {
          final m = value.value as Map;
          ownerid = m["writerId"];
          title = m["title"];
          type = m["type"];
          contentid = m["contentId"];
        }
      },
    );

    if (mounted) {
      setState(() {});
    }
  }

  void disp() async {
    if (type == 0) {
      final a = Article();
      await FirebaseDatabase.instance
          .ref("user")
          .child(ownerid)
          .child("content")
          .child(contentid)
          .get()
          .then(
        (value) {
          final m = value.value as Map;
          a.content = m["content"];
          a.title = m["title"];
          a.imagePath = m["imageUrl"];
          a.likes = m["likes"];
        },
      );
      if (mounted) {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) {
            return ArticleDisplay(a: a);
          },
        ));
      }
    } else {
      final book = Book();
      await FirebaseDatabase.instance
          .ref("user")
          .child(ownerid)
          .child("content")
          .child(contentid)
          .child("metadata")
          .get()
          .then(
        (value) {
          final m = value.value as Map;
          book.title = m["title"] ?? "";
          book.id = m["id"] ?? "";
          book.imagePath = m["imageUrl"] ?? "";
          book.tags = m["tag"] ?? [];
          book.likes = m["likes"] ?? 0;
          final l = m["chapters"] as List;
          book.chapters = l.map(
            (e) {
              return [e.keys.first, e.values.first];
            },
          ).toList();
        },
      );
      if (mounted) {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) {
            return BookDisplay(
              book: book,
              ownerId: ownerid,
            );
          },
        ));
      }
    }
  }

  @override
  void initState() {
    getdata();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: InkWell(
        onTap: () {
          disp();
        },
        child: Column(
          children: [
            imageurl == ""
                ? const CircularProgressIndicator()
                : Image.network(
                    imageurl,
                    fit: BoxFit.contain,
                    height: MediaQuery.of(context).size.height * 0.10,
                    width: MediaQuery.of(context).size.width * 0.4,
                  ),
            const SizedBox(
              height: 5,
            ),
            Text(title)
          ],
        ),
      ),
    );
  }
}
