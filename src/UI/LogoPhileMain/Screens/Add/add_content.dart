import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:logophile/Models/content.dart';
import 'package:logophile/data/currentuserdata.dart';
import 'package:logophile/src/UI/LogoPhileMain/Screens/Add/widget/create_article.dart';
import 'package:logophile/src/UI/LogoPhileMain/Screens/Add/widget/create_book.dart';

import 'draft_page/draft_view.dart';

class AddContent extends StatefulWidget {
  const AddContent({super.key});

  @override
  State<AddContent> createState() => _AddContentState();
}

class _AddContentState extends State<AddContent> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        ListTile(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) {
                return const CreateArticle();
              },
            ));
          },
          leading: const Icon(Icons.add),
          title: const Text("Create Article"),
        ),
        ListTile(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) {
                return const CreateBook();
              },
            ));
          },
          leading: const Icon(Icons.add),
          title: const Text("Create Book"),
        ),
        const Divider(),
        Expanded(
          child: FirebaseAnimatedList(
            query: FirebaseDatabase.instance
                .ref("user")
                .child(currentuser.id)
                .child("private")
                .child("drafts"),
            defaultChild: Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            itemBuilder: (context, snapshot, animation, index) {
              Map m = snapshot.value as Map;
              return DraftView(Content(
                  title: m["title"],
                  contentid: m["contentId"],
                  ownerId: "",
                  description: m["description"],
                  likes: 0,
                  c: m["type"] == 0 ? Contents.article : Contents.book,
                  imageId: m["imageUrl"],
                  tags: [""]));
            },
          ),
        )
      ],
    ));
  }
}
