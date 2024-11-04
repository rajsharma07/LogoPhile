import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logophile/Models/content.dart';
import 'package:logophile/src/Bloc/postcontrols/postcontrol_bloc.dart';
import 'package:logophile/src/UI/LogoPhileMain/widgets/content_preview_widget.dart';

class Explore extends StatelessWidget {
  const Explore({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) {
          return PostcontrolBloc();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                    child: TextField(
                  decoration: InputDecoration(
                    label: Text("Search"),
                  ),
                )),
                IconButton(onPressed: () {}, icon: const Icon(Icons.search))
              ],
            ),
            const Divider(),
            const Text("Suggestions"),
            const Divider(),
            Expanded(
                child: FirebaseAnimatedList(
              query: FirebaseDatabase.instance.ref("content"),
              itemBuilder: (context, snapshot, animation, index) {
                final m = snapshot.value as Map;
                return ContentPreview(
                    content: Content(
                        tags: m["tags"],
                        title: m["title"],
                        contentid: m["contentId"],
                        ownerId: m["writerId"],
                        description: m["description"],
                        likes: m["likes"],
                        imageId: m["imageUrl"],
                        c: m["type"] == 0 ? Contents.article : Contents.book));
              },
            )),
            const Divider(),
          ],
        ));
  }
}
