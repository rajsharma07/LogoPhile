import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:logophile/Models/book.dart';

class ChapterDisplay extends StatefulWidget {
  ChapterDisplay({super.key, required this.dbref})
      : pagesref = dbref.child("pages");
  final DatabaseReference dbref;

  final DatabaseReference pagesref;
  @override
  State<ChapterDisplay> createState() {
    return _ChapterDisplayState();
  }
}

class _ChapterDisplayState extends State<ChapterDisplay> {
  int start = 0;
  int end = 5;
  List<Pages> pages = [];
  final Chapter c = Chapter(
    id: "",
    title: "Loading...",
    bookId: "bookId",
    pageId: [],
  );
  void getChapter() async {
    c.id = await widget.dbref
        .child("id")
        .get()
        .then((value) => value.value.toString());
    c.title = await widget.dbref
        .child("title")
        .get()
        .then((value) => value.value as String);
    setState(() {});
  }

  void getpages() async {
    for (int i = 0; i < 5; i++) {
      final p = await widget.pagesref.child("$i").get().then(
        (value) {
          if (value.value == null) {
            i = 6;
            return null;
          }
          final Map m = value.value as Map;
          return Pages(id: m["id"], chapterId: c.id, content: m["content"]);
        },
      );
      if (p != null) {
        pages.add(p);
      }
    }
  }

  @override
  void initState() {
    getChapter();
    getpages();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Text(c.id),
        title: Text(c.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: pages.map(
            (e) {
              return Text(e.content);
            },
          ).toList(),
        ),
      ),
    );
  }
}
