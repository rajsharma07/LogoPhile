import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:logophile/Models/book.dart';
import 'package:logophile/src/UI/LogoPhileMain/Screens/contentDisplay/chapterdisplay.dart';

class BookDisplay extends StatefulWidget {
  const BookDisplay({super.key, required this.book, required this.ownerId});
  final Book book;
  final ownerId;
  @override
  State<BookDisplay> createState() {
    return _BookDisplayState();
  }
}

class _BookDisplayState extends State<BookDisplay> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book.title),
      ),
      body: Column(
        children: [
          Text(
            widget.book.title,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(
            height: 10,
          ),
          Image.network(
            widget.book.imagePath,
            fit: BoxFit.contain,
            height: MediaQuery.of(context).size.height * 0.3,
          ),
          const SizedBox(
            height: 5,
          ),
          Row(
            children: [
              const Icon(Icons.favorite_border),
              Text(widget.book.likes.toString())
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                  color: Theme.of(context).colorScheme.onPrimary,
                  style: BorderStyle.solid),
            ),
            padding: const EdgeInsets.all(8),
            child: Text(widget.book.description),
          ),
          const SizedBox(
            height: 20,
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.onPrimary,
                  style: BorderStyle.solid,
                ),
              ),
              child: ListView.builder(
                itemCount: widget.book.chapters.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) {
                          return ChapterDisplay(
                              dbref: FirebaseDatabase.instance
                                  .ref("user")
                                  .child(widget.ownerId)
                                  .child("content")
                                  .child(widget.book.id)
                                  .child("chapters")
                                  .child(widget.book.chapters[index][0]));
                        },
                      ));
                    },
                    leading: Text(widget.book.chapters[index][0]),
                    title: Text(widget.book.chapters[index][1]),
                  );
                },
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          )
        ],
      ),
    );
  }
}
