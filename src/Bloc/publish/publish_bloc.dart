import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logophile/data/currentuserdata.dart';
import 'package:logophile/src/Bloc/publish/publish_event.dart';
import 'package:logophile/src/Bloc/publish/publish_state.dart';

class PublishBloc extends Bloc<PublishEvent, PublishState> {
  PublishBloc() : super(const PublishState()) {
    on<PublishArticle>(publishArticleLogic);
    on<PublishBook>(publishbookLogic);
  }

  //pulishing article
  void publishArticleLogic(PublishArticle event, emit) async {
    emit(state.copyWith(publishing: true));
    final contentdbref = FirebaseDatabase.instance.ref("content");
    final userDbRef =
        FirebaseDatabase.instance.ref("user").child(currentuser.id);
    try {
      //type 0=> article || 1=>book
      await contentdbref.child("${currentuser.id}${event.contentId}").set({
        "title": event.title,
        "description": event.description,
        "writerId": currentuser.id,
        "contentId": event.contentId,
        "imageUrl": event.imageUrl,
        "type": 0,
        "likes": 0,
        "tags": event.tags
      });
      await userDbRef.child("content").child(event.contentId).set({
        "title": event.title,
        "description": event.description,
        "content": event.content,
        "imageUrl": event.imageUrl,
        "likes": 0,
        "type": 0,
        "tags": event.tags
      });
      if (event.ctx.mounted) {
        ScaffoldMessenger.of(event.ctx).showSnackBar(
            snackBarAnimationStyle:
                AnimationStyle(duration: const Duration(seconds: 2)),
            const SnackBar(
              backgroundColor: Color.fromARGB(179, 255, 210, 210),
              content: Row(
                children: [
                  Icon(
                    Icons.done,
                    color: Colors.green,
                  ),
                  Text("Successfully Published")
                ],
              ),
            ));
      }
    } on FirebaseException catch (error) {
      if (event.ctx.mounted) {
        ScaffoldMessenger.of(event.ctx).showSnackBar(
            snackBarAnimationStyle:
                AnimationStyle(duration: const Duration(seconds: 2)),
            const SnackBar(
              backgroundColor: Colors.white70,
              content: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red,
                  ),
                  Text("Error occured while publishing")
                ],
              ),
            ));
        print(error.message);
      }
    }
    emit(state.copyWith(publishing: false));
  }

  //publishing book
  void publishbookLogic(PublishBook event, emit) async {
    emit(state.copyWith(publishing: true));
    try {
      //publishing in content doc
      await FirebaseDatabase.instance
          .ref("content")
          .child("${currentuser.id}${event.contentId}")
          .set({
        "title": event.title,
        "description": event.description,
        "writerId": currentuser.id,
        "contentId": event.contentId,
        "imageUrl": event.imageUrl,
        "type": 1,
        "likes": 0,
        "tags": event.tags
      });

      //publishing
      final bookdbref = FirebaseDatabase.instance
          .ref("user")
          .child(currentuser.id)
          .child("content");
      await bookdbref.child(event.contentId).child("type").set(1);
      await bookdbref.child(event.contentId).child("metadata").set({
        "title": event.title,
        "contentId": event.contentId,
        "imageUrl": event.imageUrl,
        "tags": event.tags,
        "likes": 0,
        "chapters": event.chapters.map(
          (e) {
            return {e.id: e.title};
          },
        ).toList()
      });

      //showing success message
      if (event.ctx.mounted) {
        ScaffoldMessenger.of(event.ctx).showSnackBar(
            snackBarAnimationStyle:
                AnimationStyle(duration: const Duration(seconds: 2)),
            const SnackBar(
              backgroundColor: Color.fromARGB(179, 255, 210, 210),
              content: Row(
                children: [
                  Icon(
                    Icons.done,
                    color: Colors.green,
                  ),
                  Text("Successfully Published")
                ],
              ),
            ));
      }
    } on FirebaseException catch (error) {
      if (event.ctx.mounted) {
        ScaffoldMessenger.of(event.ctx).showSnackBar(
            snackBarAnimationStyle:
                AnimationStyle(duration: const Duration(seconds: 2)),
            const SnackBar(
              backgroundColor: Colors.white70,
              content: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red,
                  ),
                  Text("Error occured while publishing")
                ],
              ),
            ));
      }
      print(error.message);
    }
    emit(state.copyWith(publishing: false));
  }
}
