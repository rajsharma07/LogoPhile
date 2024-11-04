import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:logophile/data/currentuserdata.dart';
import 'package:logophile/src/UI/LogoPhileMain/Screens/YourZone/draftview.dart';
import 'package:logophile/src/UI/LogoPhileMain/Screens/YourZone/followinguserswidget.dart';
import 'package:logophile/src/UI/LogoPhileMain/Screens/YourZone/likedcontentwidget.dart';

class YourZone extends StatefulWidget {
  const YourZone({super.key});
  @override
  State<YourZone> createState() {
    return _YourZoneState();
  }
}

class _YourZoneState extends State<YourZone> {
  final dbref = FirebaseDatabase.instance.ref("user").child(currentuser.id);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text("Following:"),
        Expanded(
          child: FirebaseAnimatedList(
            padding: const EdgeInsets.symmetric(vertical: 5),
            scrollDirection: Axis.horizontal,
            defaultChild: const Text("You don't follow anyone"),
            query: dbref.child("private").child("following"),
            itemBuilder: (context, snapshot, animation, index) {
              return Followinguserswidget(userid: snapshot.value as String);
            },
          ),
        ),
        const Divider(),
        const SizedBox(
          height: 5,
        ),
        const Text("Liked:"),
        Expanded(
          child: FirebaseAnimatedList(
            defaultChild: const Text("You didn't liked any post"),
            padding: const EdgeInsets.symmetric(vertical: 5),
            scrollDirection: Axis.horizontal,
            query: dbref.child("private").child("liked"),
            itemBuilder: (context, snapshot, animation, index) {
              return Likedcontentwidget(contentid: snapshot.value as String);
            },
          ),
        ),
        const Divider(),
        const SizedBox(
          height: 5,
        ),
        const Text("Saved:"),
        Expanded(
          child: FirebaseAnimatedList(
            defaultChild: const Text("You haven't saved any post"),
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(vertical: 5),
            query: dbref.child("private").child("saved"),
            itemBuilder: (context, snapshot, animation, index) {
              return Likedcontentwidget(contentid: snapshot.value as String);
            },
          ),
        ),
        const Divider(),
        const SizedBox(
          height: 5,
        ),
        const Text("Draft:"),
        Expanded(
          child: FirebaseAnimatedList(
            defaultChild: const Text("Draft is empty"),
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(vertical: 5),
            query: dbref.child("private").child("drafts"),
            itemBuilder: (context, snapshot, animation, index) {
              final m = snapshot.value as Map;
              return Draftview(
                id: m["contentId"],
                imageUrl: m["imageUrl"],
                title: m["title"],
                type: m["type"],
                description: m["description"],
              );
            },
          ),
        ),
        const Divider(),
      ],
    );
  }
}
