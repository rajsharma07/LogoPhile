import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:logophile/Models/book.dart';
import 'package:logophile/Models/content.dart';

class CreateChapter extends StatefulWidget {
  const CreateChapter(
      {super.key,
      required this.dbref,
      required this.chapterid,
      this.title = "",
      this.conent = ""});
  final String title;
  final String conent;
  final DatabaseReference dbref;
  final int chapterid;
  @override
  State<CreateChapter> createState() => _CreateChapterState();
}

class _CreateChapterState extends State<CreateChapter> {
  final formkey = GlobalKey<FormState>();

  String content = "";

  String title = "";

  List<Pages> pages = [];

  final int contentpointer = 0;

  void chapterCreation() async {
    if (formkey.currentState!.validate()) {
      formkey.currentState!.save();

      try {
        await widget.dbref
            .child("chapters")
            .child(widget.chapterid.toString())
            .set({'title': title, 'id': widget.chapterid});

        final pagesref = widget.dbref
            .child("chapters")
            .child(widget.chapterid.toString())
            .child('pages');
        for (var i in pages) {
          await pagesref.child(i.id).set({
            "id": i.id,
            "content": i.content,
          });
        }
      } on FirebaseException catch (e) {
        print(e.message);
      }

      Chapter c = Chapter(
          id: widget.chapterid.toString(),
          title: title,
          bookId: "1",
          pageId: pages
              .map(
                (e) => e.id,
              )
              .toList());
      if (mounted) {
        Navigator.of(context).pop(c);
      }
    }
  }

  void checkChapter() {
    title = widget.title;
    content = widget.conent;
    setState(() {});
  }

  @override
  void initState() {
    checkChapter();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Add chapter"),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: formkey,
              child: Column(
                children: [
                  TextFormField(
                    initialValue: title == "" ? null : title,
                    style: Theme.of(context).textTheme.headlineMedium,
                    cursorColor: Theme.of(context).colorScheme.onPrimary,
                    decoration: InputDecoration(
                      label: Text(
                        "Title",
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary),
                      ),
                    ),
                    validator: (value) {
                      print(Contents.book);
                      if (value == null || value.trim().isEmpty) {
                        return "Enter valid title";
                      }
                      return null;
                    },
                    onSaved: (newValue) {
                      title = newValue!;
                    },
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        border: Border.all(
                            style: BorderStyle.solid,
                            width: 1,
                            color: Theme.of(context).colorScheme.onPrimary)),
                    child: TextFormField(
                      style: const TextStyle(fontSize: 20),
                      decoration: const InputDecoration(
                        hintText: "Write content here",
                      ),
                      initialValue: content == "" ? null : content,
                      cursorColor: Theme.of(context).colorScheme.onPrimary,
                      maxLines: 20,
                      minLines: 19,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Cannot submit empty chapter!";
                        }
                        return null;
                      },
                      onSaved: (newValue) {
                        if (newValue != null) {
                          content = newValue;
                          int i = 0;
                          int len = content.length;
                          for (int j = 0; j < (len / 600); j++) {
                            pages.add(Pages(
                                id: "$j",
                                chapterId: "chapterId",
                                content: (i + 600) > len
                                    ? content.substring(i, len)
                                    : content.substring(i, i + 400)));
                            i = i + 401;
                          }
                        }
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton.icon(
                    style: const ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(Colors.red)),
                    onPressed: () {
                      chapterCreation();
                    },
                    label: const Text("Save",
                        style: TextStyle(
                            color: Color(0xfffff9f2),
                            fontWeight: FontWeight.bold)),
                    icon: const Icon(
                      Icons.save,
                      color: Color(0xfffff9f2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
