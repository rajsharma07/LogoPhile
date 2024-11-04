import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logophile/Models/article.dart';
import 'package:logophile/Models/book.dart';
import 'package:logophile/Models/content.dart';
import 'package:logophile/Models/user.dart';
import 'package:logophile/src/Bloc/postcontrols/postcontrol_bloc.dart';
import 'package:logophile/src/Bloc/postcontrols/postcontrol_events.dart';
import 'package:logophile/src/Bloc/postcontrols/postcontrol_state.dart';

import 'package:logophile/src/UI/LogoPhileMain/Screens/ProfilePage/profilepage.dart';
import 'package:logophile/src/UI/LogoPhileMain/Screens/contentDisplay/article_display.dart';
import 'package:logophile/src/UI/LogoPhileMain/Screens/contentDisplay/bookdsplay.dart';

class ContentPreview extends StatefulWidget {
  const ContentPreview({super.key, required this.content});
  final Content content;

  @override
  State<ContentPreview> createState() => _ContentPreviewState();
}

class _ContentPreviewState extends State<ContentPreview> {
  String ownerName = "";
  String imageurl = "";

  void getOwnerData() async {
    final String postId =
        "${widget.content.ownerId}${widget.content.contentid}";
    context.read<PostcontrolBloc>().add(AddPostId(postId: postId));
    final dbref = FirebaseDatabase.instance
        .ref("user")
        .child(widget.content.ownerId)
        .child("public");
    ownerName = await dbref.child("user_name").get().then(
          (value) => value.value as String,
        );
    imageurl = await dbref.child("image").get().then(
          (value) => value.value as String,
        );
    if (mounted) {
      setState(() {});
    }
  }

  void display() async {
    if (widget.content.c == Contents.article) {
      final a = Article();
      await FirebaseDatabase.instance
          .ref("user")
          .child(widget.content.ownerId)
          .child("content")
          .child(widget.content.contentid)
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
          .child(widget.content.ownerId)
          .child("content")
          .child(widget.content.contentid)
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
              ownerId: widget.content.ownerId,
            );
          },
        ));
      }
    }
  }

  @override
  void initState() {
    getOwnerData();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenwidth = MediaQuery.sizeOf(context).width;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 8.0,
      ),
      child: Column(
        children: [
          SingleChildScrollView(
            child: Row(
              children: [
                SizedBox(
                  width: screenwidth * 0.6,
                  height: 200,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(widget.content.title,
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium!
                                .copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimary)),
                        const SizedBox(
                          height: 10,
                        ),
                        if (widget.content.imageId != null ||
                            widget.content.imageId != "")
                          Text(
                            widget.content.description,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimary),
                          ),
                        TextButton(
                            onPressed: () {
                              display();
                            },
                            child: Text(
                              "Read more..",
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary),
                            ))
                      ],
                    ),
                  ),
                ),
                (widget.content.imageId == null ||
                        widget.content.imageId!.trim() == "")
                    ? SizedBox(
                        width: screenwidth * 0.3,
                        height: 200,
                        child: SingleChildScrollView(
                          child: Text(
                            widget.content.description,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimary),
                          ),
                        ),
                      )
                    : Image.network(
                        widget.content.imageId!,
                        fit: BoxFit.contain,
                        height: 150,
                        width: screenwidth * 0.3,
                      )
              ],
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Row(children: [
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  User person = User();
                  final dbref = FirebaseDatabase.instance
                      .ref("user")
                      .child(widget.content.ownerId);
                  await dbref.child("public").get().then(
                    (value) {
                      final m = value.value as Map;
                      person.name = m["user_name"];
                      person.id = widget.content.ownerId;
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
                  person.followers =
                      await dbref.child("metadata/followers").get().then(
                    (value) {
                      if (value.value == null) {
                        return 0;
                      }
                      return value.value as int;
                    },
                  );
                  if (context.mounted) {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) {
                        return ProfilePage(
                          person: person,
                          iscurrentuser: false,
                        );
                      },
                    ));
                  }
                },
                child: Row(
                  children: [
                    (imageurl.trim() == "null" || imageurl == "")
                        ? const CircleAvatar(
                            child: Icon(Icons.person),
                          )
                        : CircleAvatar(
                            backgroundImage: NetworkImage(imageurl),
                            radius: 15,
                          ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      ownerName,
                      style: Theme.of(context).textTheme.labelLarge!.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              width: 50,
            ),
            Expanded(
              child: BlocBuilder<PostcontrolBloc, PostState>(
                  builder: (context, state) {
                return Row(
                  children: [
                    IconButton(
                      onPressed: state.isloading
                          ? null
                          : () {
                              context.read<PostcontrolBloc>().add(
                                  LikePost(ownerId: widget.content.ownerId));
                            },
                      icon: Icon(
                        state.liked ? Icons.favorite : Icons.favorite_border,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                      tooltip: "Like",
                    ),
                    Text(widget.content.likes.toString()),
                    const SizedBox(
                      width: 15,
                    ),
                    IconButton(
                        onPressed: state.isloading
                            ? null
                            : () {
                                context.read<PostcontrolBloc>().add(Save());
                              },
                        icon: Icon(state.saved
                            ? Icons.bookmark
                            : Icons.bookmark_border)),
                  ],
                );
              }),
            ),
          ]),
          const Divider()
        ],
      ),
    );
  }
}
