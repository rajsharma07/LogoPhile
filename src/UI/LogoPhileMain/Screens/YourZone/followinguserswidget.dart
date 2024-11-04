import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:logophile/Models/user.dart';
import 'package:logophile/src/UI/LogoPhileMain/Screens/ProfilePage/profilepage.dart';

class Followinguserswidget extends StatefulWidget {
  const Followinguserswidget({super.key, required this.userid});
  final String userid;

  @override
  State<Followinguserswidget> createState() => _FollowinguserswidgetState();
}

class _FollowinguserswidgetState extends State<Followinguserswidget> {
  String imageurl = "";
  String name = "";

  void getdata() async {
    final dbref = FirebaseDatabase.instance
        .ref("user")
        .child(widget.userid)
        .child("public");
    imageurl = await dbref.child("image").get().then((v) {
      if (v.value == null) {
        return "";
      } else {
        return v.value as String;
      }
    });
    name = await dbref.child("user_name").get().then((v) {
      if (v.value == null) {
        return "";
      } else {
        return v.value as String;
      }
    });
    if (mounted) {
      setState(() {});
    }
  }

  void profileVisit() async {
    User person = User();
    final dbref = FirebaseDatabase.instance.ref("user").child(widget.userid);
    await dbref.child("public").get().then(
      (value) {
        final m = value.value as Map;
        person.name = m["user_name"];
        person.id = widget.userid;
        person.about = m["about"];

        person.imageId = m["image"];
        person.posts = m["posts"] ?? [];
      },
    );
    person.likes = await dbref.child("metadata/likes").get().then(
      (value) {
        if (value.value == null) {
          return 0;
        }
        return value.value as int;
      },
    );
    person.followers = await dbref.child("metadata/followers").get().then(
      (value) {
        if (value.value == null) {
          return 0;
        }
        return value.value as int;
      },
    );
    if (mounted) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) {
          return ProfilePage(
            person: person,
            iscurrentuser: false,
          );
        },
      ));
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
          profileVisit();
        },
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: imageurl == ""
                  ? const Icon(Icons.person)
                  : Image.network(
                      imageurl,
                      height: 50,
                      width: 50,
                    ),
            ),
            const SizedBox(
              height: 5,
            ),
            Text(
              name,
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }
}
