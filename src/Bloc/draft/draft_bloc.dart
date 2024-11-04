import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logophile/data/currentuserdata.dart';
import 'package:logophile/src/Bloc/draft/draft_event.dart';
import 'package:logophile/src/Bloc/draft/draft_state.dart';

class DraftBloc extends Bloc<DraftEvent, DraftState> {
  DraftBloc() : super(const DraftState()) {
    on<SaveArticle>(savearticleLogic);
    on<SaveBook>(savebookLogic);
  }

  //saving article
  void savearticleLogic(SaveArticle event, emit) async {
    emit(state.copywith(saving: true));
    try {
      final draftref = FirebaseDatabase.instance
          .ref("user")
          .child(currentuser.id)
          .child("private")
          .child("drafts");
      final userDbRef =
          FirebaseDatabase.instance.ref("user").child(currentuser.id);
      await draftref.child(event.contentId).set({
        "title": event.title,
        "description": event.description,
        "contentId": event.contentId,
        "imageUrl": event.imageUrl,
        "type": 0,
      });
      await userDbRef.child("content").child(event.contentId).set({
        "title": event.title,
        "description": event.description,
        "content": event.content,
        "imageUrl": event.imageUrl,
        "likes": 0,
        "type": 0,
        "tags": event.imageUrl
      });
      if (event.ctx.mounted) {
        ScaffoldMessenger.of(event.ctx).showSnackBar(
          const SnackBar(
            backgroundColor: Color.fromARGB(179, 255, 210, 210),
            content: Row(
              children: [
                Icon(
                  Icons.done,
                  color: Colors.green,
                ),
                Text("Article is saved as draft")
              ],
            ),
          ),
        );
      }
    } on FirebaseException catch (error) {
      if (event.ctx.mounted) {
        ScaffoldMessenger.of(event.ctx).showSnackBar(
          const SnackBar(
            backgroundColor: Color.fromARGB(179, 255, 210, 210),
            content: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.red,
                ),
                Text("Something went wrong")
              ],
            ),
          ),
        );
      }
      print(error.message);
    }
    emit(state.copywith(saving: false));
  }

  void savebookLogic(SaveBook event, emit) async {
    emit(state.copywith(saving: true));
    try {
      //saving to draft
      await FirebaseDatabase.instance
          .ref("user")
          .child(currentuser.id)
          .child("private")
          .child("drafts")
          .child(event.contentId)
          .set({
        "title": event.title,
        "description": event.description,
        "contentId": event.contentId,
        "imageUrl": event.imageUrl,
        "type": 1,
      });

      //publishing in private
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
                  Text("Successfully saved as draft")
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
                  Text("Error occured while saving draft")
                ],
              ),
            ));
      }
      print(error.message);
    }
    emit(state.copywith(saving: false));
  }
}
